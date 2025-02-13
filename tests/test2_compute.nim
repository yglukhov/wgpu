import std/[math]
from std/asyncdispatch import nil
import wgpu
import yasync

type
  App = object
    device: Device
    buffer: Buffer
    readBuffer: Buffer
    pipeline: ComputePipeline
    bindGroup: BindGroup

const shaderCode = """
@group(0) @binding(0) var<storage, read_write> dataBuffer: array<u32>;

@compute @workgroup_size(32, 1, 1) // Set workgroup size to 256
fn main(@builtin(global_invocation_id) global_id : vec3<u32>) {
    let index = global_id.x; // Index of the current thread
    dataBuffer[index] = dataBuffer[index] * 2;
}
"""

proc createBuffer(d: Device, data: pointer, size: int): Buffer =
  var desc: BufferDescriptor
  desc.size = size.uint64
  desc.usage = {buCopyDst, buCopySrc, buStorage}
  result = d.createBuffer(desc)
  d.getQueue().writeBuffer(result, 0, data, size)

proc createReadBuffer(d: Device, size: int): Buffer =
  var desc: BufferDescriptor
  desc.size = size.uint64
  desc.usage = {buCopyDst, buMapRead}
  result = d.createBuffer(desc)

proc createBuffer[T](d: Device, data: openarray[T]): Buffer {.inline.} =
  d.createBuffer(addr data, sizeof(T) * data.len)

proc init(app: var App) =
  let data = [1.uint32, 2, 3, 4, 5, 6, 7, 8]
  # let data = [0.uint32, 0, 0, 0, 0, 0, 0, 0]
  app.buffer = app.device.createBuffer(data)
  assert(app.buffer != nil)

  app.readBuffer = app.device.createReadBuffer(data.len * sizeof(data[0]))

  let shaderModule = app.device.createShaderModule(shaderCode)
  assert(shaderModule != nil)

  var layoutDesc: BindGroupLayoutDescriptor
  var layoutEntries: array[1, BindGroupLayoutEntry]
  layoutDesc.entryCount = layoutEntries.len.uint32
  layoutDesc.entries = addr layoutEntries[0]

  layoutEntries[0].visibility = {ssCompute}
  layoutEntries[0].buffer.kind = bbtStorage

  let layout = app.device.createBindGroupLayout(layoutDesc)
  assert(layout != nil)

  var pipelineLayoutDesc: PipelineLayoutDescriptor
  pipelineLayoutDesc.bindGroupLayoutCount = 1;
  pipelineLayoutDesc.bindGroupLayouts = addr layout

  let pipelineLayout = app.device.createPipelineLayout(pipelineLayoutDesc)
  assert(pipelineLayout != nil)

  var pipelineDesc: ComputePipelineDescriptor
  pipelineDesc.compute.module = shaderModule
  pipelineDesc.compute.entryPoint = "main"
  pipelineDesc.layout = pipelineLayout
  app.pipeline = app.device.createComputePipeline(pipelineDesc)
  assert(app.pipeline != nil)

  var bindGroupDescriptor: BindGroupDescriptor
  bindGroupDescriptor.layout = layout
  var bindGroupEntries: array[1, BindGroupEntry]
  bindGroupDescriptor.entryCount = bindGroupEntries.len.uint32
  bindGroupDescriptor.entries = addr bindGroupEntries[0]
  bindGroupEntries[0].buffer = app.buffer
  bindGroupEntries[0].size = app.buffer.size

  app.bindGroup = app.device.createBindGroup(bindGroupDescriptor)

proc displayResult(app: App) =
  var dataOut = newSeq[uint32](8)
  app.readBuffer.copyMappedRangeOut(0, app.readBuffer.size, addr dataOut[0])
  # let p = app.readBuffer.getConstMappedRange(0, app.readBuffer.size)
  # copyMem(addr dataOut[0], p, sizeof(uint32) * dataOut.len)
  echo dataOut

proc compute(app: App) =
  let queue = app.device.getQueue()
  # queue.writeBuffer(app.buffer, 0, addr data[0], data.len * sizeof(data[0]))

  let commandEncoder = app.device.createCommandEncoder()

  var passEncoder = commandEncoder.beginComputePass()
  assert(not passEncoder.isNil)

  passEncoder.setPipeline(app.pipeline)
  passEncoder.setBindGroup(0, app.bindGroup)
  const workgroupSize = 32; # We set this in the shader
  # const numWorkgroups = ceil(data.len / workgroupSize).int
  # echo numWorkgroups

  passEncoder.dispatchWorkgroups(1, 1, 1)
  passEncoder.finish()

  commandEncoder.copyBufferToBuffer(app.buffer, 0, app.readBuffer, 0, app.buffer.size)

  let commandBuffer = commandEncoder.finish()

  queue.submit(commandBuffer)


when defined(wasm):
  import wasmrt

  type
    HTMLElement* = object of JSObj
    Document* = object of HTMLElement

  proc document(): Document {.importwasmp.}
  proc write(d: Document, s: cstring) {.importwasmm.}

  proc main() {.async.} =
    let i = createInstance()
    if i.isNil:
      document().write("WebGPU is not supported by your browser")
      return
    var options: RequestAdapterOptions
    let a = await i.requestAdapter(options)
    var deviceOpts: DeviceDescriptor
    let d = await a.requestDevice(deviceOpts)
    var app: App
    app.device = d
    init(app)
    compute(app)
    await app.readBuffer.mapAsync({mmRead}, 0, app.readBuffer.size)
    displayResult(app)

  discard main()

else:
  import yasync/compat

  proc mapBuffer(app: App) =
    var done = false

    app.readBuffer.mapAsync({mmRead}, 0, app.readBuffer.size).then do(e: ref Exception):
      done = true

    let queue = app.device.getQueue()
    while not done:
      queue.submit([])

  proc main() {.async.} =
    var app: App
    let i = createInstance()
    assert(i != nil)
    var adapterOpts: RequestAdapterOptions
    let a = await i.requestAdapter(adapterOpts)
    assert(a != nil)
    var deviceOpts: DeviceDescriptor
    deviceOpts.uncapturedErrorCallbackInfo.callback = proc(e: ErrorType, message: cstring, data: pointer) {.cdecl.} =
      echo "Uncaptured rrror: ", e, ": ", message
      writeStackTrace()

    let d = await a.requestDevice(deviceOpts)
    assert(d != nil)
    app.device = d
    app.init()
    app.compute()
    app.mapBuffer()

    displayResult(app)

  waitFor main()
