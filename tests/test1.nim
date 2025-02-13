import wgpu
import yasync

type
  VertexAttr = object
    x, y, z: float32
    r, g, b, a: uint8

  InstanceAttr = object
    x, y: float32

  Context = object
    device: Device
    pipeline: RenderPipeline
    vertexBuffer: Buffer
    instanceBuffer: Buffer

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

const instanceData = [
  -0.5'f32, -0.2, # First instance
  0.5, 0.2, # SecondInstance
]

const shaderCode = """
struct VertexInput {
  @location(0) position: vec3f,
  @location(1) color: u32,
  @location(2) instancePos: vec2f,
};

struct VertexOutput {
  @builtin(position) position: vec4f,
  @location(0) color: vec4f,
};

@vertex
fn vs_main(in: VertexInput) -> VertexOutput {
  return VertexOutput(
    vec4(in.position, 1.0) + vec4(in.instancePos, 0.0, 0.0),
    unpack4x8unorm(in.color)
  );
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4f {
  return in.color;
}
"""

const
  winWidth = 640
  winHeight = 480

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

  var va1: array[2, VertexAttribute]
  va1[0].shaderLocation = 0
  va1[0].format = vfFloat32x3
  va1[0].offset = 0

  va1[1].shaderLocation = 1
  va1[1].format = vfUint32
  va1[1].offset = sizeof(float32) * 3

  var va2: array[1, VertexAttribute]
  va2[0].shaderLocation = 2
  va2[0].format = vfFloat32x2
  va2[0].offset = 0

  var vbl: array[2, VertexBufferLayout]
  vbl[0].arrayStride = sizeof(VertexAttr).uint64
  vbl[0].attributeCount = va1.len.uint32
  vbl[0].attributes = addr va1[0]
  vbl[1].arrayStride = sizeof(InstanceAttr).uint64
  vbl[1].stepMode = vsmInstance
  vbl[1].attributeCount = va2.len.uint32
  vbl[1].attributes = addr va2[0]

  var pipelineDesc: RenderPipelineDescriptor
  pipelineDesc.vertex.module = shaderModule
  pipelineDesc.vertex.entryPoint = "vs_main"
  pipelineDesc.vertex.bufferCount = vbl.len.uint32
  pipelineDesc.vertex.buffers = addr vbl[0]

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

proc init(c: var Context, d: Device, swapChainFormat: TextureFormat) =
  c.device = d
  c.pipeline = d.createPipeline(swapChainFormat)
  assert(not c.pipeline.isNil)
  c.vertexBuffer = d.createBuffer(vertexData)
  c.instanceBuffer = d.createBuffer(instanceData)

proc renderFrame(d: Device, context: Context, textureView: TextureView) =
  let encoder = context.device.createCommandEncoder()

  var renderPassColorAttachment: RenderPassColorAttachment
  renderPassColorAttachment.view = textureView
  renderPassColorAttachment.loadOp = loClear
  renderPassColorAttachment.storeOp = soStore
  renderPassColorAttachment.clearValue = Color(r: 0.9, g: 0.1, b: 0.2, a: 1.0)

  var renderPassDesc: RenderPassDescriptor
  renderPassDesc.colorAttachmentCount = 1
  renderPassDesc.colorAttachments = addr renderPassColorAttachment
  var renderPass = encoder.beginRenderPass(renderPassDesc)
  renderPass.setPipeline(context.pipeline)
  renderPass.setVertexBuffer(0, context.vertexBuffer)
  renderPass.setVertexBuffer(1, context.instanceBuffer)
  renderPass.draw(vertexData.len.uint32, 2, 0, 0)
  renderPass.finish()

  context.device.getQueue().submit(encoder.finish())

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
  proc `width=`(c: HTMLElement, v: int) {.importwasmp.}
  proc `height=`(c: HTMLElement, v: int) {.importwasmp.}

  proc configure(c: GPUCanvasContext, d: Device, fmt: TextureFormat) {.importwasmraw: """
  _nimo[$0].configure({device: _nimo[$1], format: _nimwct[$2]})
  """}

  proc getCurrentTexture(c: GPUCanvasContext): GPUTexture {.importwasmm.}
  proc createView(t: GPUTexture): TextureView {.importwasmm.}

  proc createCanvasContext(): GPUCanvasContext =
    let doc = document()
    let canvas = doc.createElement("canvas").to(HTMLCanvasElement)
    canvas.width = winWidth
    canvas.height = winHeight
    doc.body.append(canvas)
    canvas.getContext("webgpu").to(GPUCanvasContext)

  proc mainLoop(d: Device, format: TextureFormat) =
    let canvasContext = createCanvasContext()
    canvasContext.configure(d, format)
    var context: Context
    init(context, d, format)
    let textureView = canvasContext.getCurrentTexture().createView()
    renderFrame(d, context, textureView)

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

  proc createSurface(i: Instance, w: glfw.Window): Surface =
    when defined(linux):
      proc getX11Display(): pointer {.importc: "glfwGetX11Display".}
      proc getX11Window(w: glfw.Window): uint32 {.importc: "glfwGetX11Window".}

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

  proc createTextureView(t: Texture): TextureView =
    var viewDescriptor: TextureViewDescriptor
    viewDescriptor.format = t.format
    viewDescriptor.dimension = tvd2D
    viewDescriptor.baseMipLevel = 0
    viewDescriptor.mipLevelCount = 1
    viewDescriptor.baseArrayLayer = 0
    viewDescriptor.arrayLayerCount = 1
    viewDescriptor.aspect = taAll
    t.createView(viewDescriptor)

  proc getPreferredFormat(surface: Surface, adapter: Adapter): TextureFormat =
    var caps: SurfaceCapabilities
    surface.getCapabilities(adapter, caps)
    caps.formats[0]

  proc mainLoop(a: Adapter, d: Device, surface: Surface, w: glfw.Window) =
    let swapChainFormat = surface.getPreferredFormat(a)
    # let swapChain = createSwapChain(d, surface, swapchainFormat)
    var context: Context
    init(context, d, swapChainFormat)

    while windowShouldClose(w) == 0:
      pollEvents()
      var t: SurfaceTexture
      surface.getCurrentTexture(t)
      if t.status == gctsSuccess:
        let nextTexture = t.texture.createTextureView()
        renderFrame(d, context, nextTexture)
        surface.present()
      else:
        echo "Error getting next swap chain texture"
        break

      # wgpuTextureViewDrop(nextTexture)

  proc configureSurface(d: Device, a: Adapter, s: Surface) =
    var c: SurfaceConfiguration
    c.width = winWidth
    c.height = winHeight
    c.device = d
    c.format = s.getPreferredFormat(a)
    c.usage = {tuRenderAttachment}
    s.configure(c)

  proc main() {.async.} =
    discard glfw.init()
    glfw.windowHint(hClientApi.int32, oaNoApi.int32)
    let w = glfw.createWindow(winWidth, winHeight, "Hi", nil, nil)
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
    deviceOpts.uncapturedErrorCallbackInfo.callback = proc(e: ErrorType, message: cstring, data: pointer) {.cdecl.} =
      echo "Uncaptured rrror: ", e, ": ", message
      writeStackTrace()
    let d = await a.requestDevice(deviceOpts)
    assert(d != nil)
    configureSurface(d, a, surface)
    mainLoop(a, d, surface, w)

  waitFor main()
