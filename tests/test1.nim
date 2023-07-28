import wgpu
import yasync

type
  VertexAttr = object
    x, y, z: float32
    r, g, b, a: uint8

const vertexData = block:
  template va(xx, yy, zz: float32, rr, gg, bb, aa: uint8): VertexAttr =
    VertexAttr(x: xx, y: yy, z: zz, r: rr, g: gg, b: bb, a: aa)

  template va(x, y, z: float32, r, g, b: uint8): VertexAttr =
    va(x, y, z, r, g, b, 255)

  template va(x, y: float32, r, g, b: uint8): VertexAttr =
    va(x, y, 0.0, r, g, b)

  [  # x, y,             r, g, b
    va(-0.5, -0.5,       255, 0, 0),
    va(0.5, -0.5,        0, 255, 0),
    va(0.0, 0.5,         0, 0, 255),
  ]

const shaderCode = """
struct VertexInput {
  @location(0) position: vec3<f32>,
  @location(1) color: vec4<u32>,
};

struct VertexOutput {
  @builtin(position) position: vec4<f32>,
  @location(0) color: vec4<f32>,
};

@vertex
fn vs_main(in: VertexInput) -> VertexOutput {
  var o: VertexOutput;
  o.position = vec4(in.position, 1.0);
  o.color = vec4<f32>(in.color) / 255.0;
  return o;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
  return in.color;
}
"""

proc createBuffer(d: Device, data: pointer, size: int): Buffer =
  var desc: BufferDescriptor
  desc.size = size.uint64
  desc.usage = {buCopyDst, buVertex}
  result = d.createBuffer(desc)
  d.getQueue().writeBuffer(result, 0, data, size)

proc createBuffer[T](d: Device, data: openarray[T]): Buffer {.inline.} =
  d.createBuffer(addr data, sizeof(T) * data.len)

proc createPipeline(d: Device, swapChainFormat: TextureFormat): RenderPipeline =
  let shaderModule = d.createShaderModule(shaderCode)
  assert(not shaderModule.isNil)

  var va: array[2, VertexAttribute]
  va[0].shaderLocation = 0
  va[0].format = vfFloat32x3
  va[0].offset = 0

  va[1].shaderLocation = 1
  va[1].format = vfUint8x4
  va[1].offset = sizeof(float32) * 3

  var vbl: VertexBufferLayout
  vbl.arrayStride = sizeof(VertexAttr).uint64
  vbl.attributeCount = 2
  vbl.attributes = addr va[0]

  var pipelineDesc: RenderPipelineDescriptor
  pipelineDesc.vertex.module = shaderModule
  pipelineDesc.vertex.entryPoint = "vs_main"
  pipelineDesc.vertex.bufferCount = 1
  pipelineDesc.vertex.buffers = addr vbl

  pipelineDesc.primitive.topology = ptTriangleList
  pipelineDesc.primitive.stripIndexFormat = ifUndefined
  pipelineDesc.primitive.frontFace = ffCCW
  pipelineDesc.primitive.cullMode = cmNone

  var fragmentState: FragmentState
  fragmentState.module = shaderModule
  fragmentState.entryPoint = "fs_main"

  pipelineDesc.fragment = addr fragmentState

  var blendState: BlendState
  blendState.color.srcFactor = bfSrcAlpha
  blendState.color.dstFactor = bfOneMinusSrcAlpha
  blendState.color.operation = boAdd

  var colorTarget: ColorTargetState
  colorTarget.format = swapChainFormat
  colorTarget.blend = addr blendState
  colorTarget.writeMask = cwmAll

  fragmentState.targetCount = 1
  fragmentState.targets = addr colorTarget

  pipelineDesc.multisample.count = 1
  pipelineDesc.multisample.mask = uint32.high

  let layout = d.createPipelineLayout()
  pipelineDesc.layout = layout

  d.createRenderPipeline(pipelineDesc)

proc renderFrame(d: Device, pipeline: RenderPipeline, textureView: TextureView, buffer: Buffer) =
  let encoder = d.createCommandEncoder()

  var renderPassColorAttachment: RenderPassColorAttachment
  renderPassColorAttachment.view = textureView
  renderPassColorAttachment.loadOp = loClear
  renderPassColorAttachment.storeOp = soStore
  renderPassColorAttachment.clearValue = Color(r: 0.9, g: 0.1, b: 0.2, a: 1.0)

  var renderPassDesc: RenderPassDescriptor
  renderPassDesc.colorAttachmentCount = 1
  renderPassDesc.colorAttachments = addr renderPassColorAttachment
  let renderPass = encoder.beginRenderPass(renderPassDesc)
  renderPass.setPipeline(pipeline)
  renderPass.setVertexBuffer(0, buffer, 0, vertexData.len * sizeof(vertexData[0]))
  renderPass.draw(vertexData.len.uint32, 1, 0, 0)
  renderPass.finish()

  d.getQueue().submit(encoder.finish())

when defined(wasm):
  import wasmrt

  type
    HTMLElement* = object of JSObj
    Document* = object of HTMLElement
    HTMLCanvasElement* = object of HTMLElement
    GPUCanvasContext* = object of JSObj
    GPUTexture* = object of JSObj

  proc document(): Document {.importwasmp.}
  proc write(d: Document, s: cstring) {.importwasmm.}
  proc createElement(d: Document, t: cstring): HTMLElement {.importwasmm.}
  proc body(d: Document): HTMLElement {.importwasmp.}
  proc append(p, c: HTMLElement) {.importwasmm.}
  proc getContext(c: HTMLCanvasElement, s: cstring): JSObj {.importwasmm.}

  proc configure(c: GPUCanvasContext, d: Device, fmt: TextureFormat) {.importwasmraw: """
  _nimo[$0].configure({device: _nimo[$1], format: _nimwca[$2]})
  """}

  proc getCurrentTexture(c: GPUCanvasContext): GPUTexture {.importwasmm.}
  proc createView(t: GPUTexture): TextureView {.importwasmm.}

  proc createContext(): GPUCanvasContext =
    let doc = document()
    let canvas = doc.createElement("canvas").to(HTMLCanvasElement)
    doc.body.append(canvas)
    canvas.getContext("webgpu").to(GPUCanvasContext)

  proc mainLoop(d: Device, format: TextureFormat) =
    let ctx = createContext()
    ctx.configure(d, format)
    let pipeline = createPipeline(d, format)
    assert(not pipeline.isNil)
    let buffer = createBuffer(d, vertexData)
    let textureView = ctx.getCurrentTexture().createView()
    renderFrame(d, pipeline, textureView, buffer)

  proc main() {.async.} =
    let i = createInstance()
    if i.isNil:
      document().write("WebGPU is not supported by your browser")
      return
    var options: RequestAdapterOptions
    let a = await i.requestAdapter(options)
    var deviceOpts: DeviceDescriptor
    let d = await a.requestDevice(deviceOpts)
    let format = i.getPreferredCanvasFormat()
    mainLoop(d, format)

  discard main()

else:
  import yasync/compat
  import glfw/wrapper as glfw

  proc getX11Display(): pointer {.importc: "glfwGetX11Display".}
  proc getX11Window(w: glfw.Window): uint32 {.importc: "glfwGetX11Window".}

  proc createSurface(i: Instance, w: glfw.Window): Surface =
    when defined(linux):
      var x11d: SurfaceDescriptorFromXlibWindow
      x11d.sType = stSurfaceDescriptorFromXlibWindow
      x11d.display = getX11Display()
      x11d.window = getX11Window(w)
      assert(x11d.display != nil)
      assert(x11d.window != 0)
      var sd: SurfaceDescriptor
      sd.nextInChain = addr x11d
      i.createSurface(sd)
    elif defined(windows):
      {.error: "Not implemented".}
    elif defined(macosx):
      {.error: "Not implemented".}
    else:
      {.error: "Unknown platworm".}

  proc createSwapChain(d: Device, surface: Surface, swapChainFormat: TextureFormat): Swapchain =
    var swapChainDesc: SwapChainDescriptor
    swapChainDesc.width = 640
    swapChainDesc.height = 480
    swapChainDesc.format = swapChainFormat
    swapChainDesc.usage = {renderAttachment}
    swapChainDesc.presentMode = pmImmediate
    d.createSwapChain(surface, swapChainDesc)

  proc mainLoop(a: Adapter, d: Device, surface: Surface, w: glfw.Window) =
    d.setUncapturedErrorCallback(proc(e: ErrorType, message: cstring, data: pointer) {.cdecl.} =
      echo "Error: ", e, ": ", message
      writeStackTrace()
    )

    let swapChainFormat = surface.getPreferredFormat(a)
    let swapChain = createSwapchain(d, surface, swapchainFormat)
    let pipeline = createPipeline(d, swapChainFormat)
    let buffer = createBuffer(d, vertexData)

    while windowShouldClose(w) == 0:
      pollEvents()
      let nextTexture = swapChain.getCurrentTextureView()
      if nextTexture == nil:
        echo "Error getting next swap chain texture"
        break

      renderFrame(d, pipeline, nextTexture, buffer)
      wgpuTextureViewDrop(nextTexture)
      swapChain.present()

  proc main() {.async.} =
    discard glfw.init()
    glfw.windowHint(hClientApi.int32, oaNoApi.int32)
    let w = glfw.createWindow(640, 480, "Hi", nil, nil)
    assert(w != nil)
    let i = createInstance()
    assert(i != nil)
    let surface = createSurface(i, w)
    assert(surface != nil)
    var adapterOpts: RequestAdapterOptions
    adapterOpts.compatibleSurface = surface
    let a = await i.requestAdapter(adapterOpts)
    assert(a != nil)
    var deviceOpts: DeviceDescriptor
    let d = await a.requestDevice(deviceOpts)
    assert(d != nil)
    mainLoop(a, d, surface, w)

  waitFor main()
