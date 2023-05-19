import wgpu
import yasync

const shaderCode = """
@vertex
fn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> @builtin(position) vec4<f32> {
  var p = vec2(0.0, 0.0);
  if (in_vertex_index == 0u) {
    p = vec2(-0.5, -0.5);
  } else if (in_vertex_index == 1u) {
    p = vec2(0.5, -0.5);
  } else {
    p = vec2(0.0, 0.5);
  }
  return vec4(p, 0.0, 1.0);
}
@fragment
fn fs_main() -> @location(0) vec4<f32> {
  return vec4(0.0, 0.4, 1.0, 1.0);
}
"""

proc createPipeline(d: Device, swapChainFormat: TextureFormat): RenderPipeline =
  let shaderModule = d.createShaderModule(shaderCode)

  var pipelineDesc: RenderPipelineDescriptor
  pipelineDesc.vertex.module = shaderModule
  pipelineDesc.vertex.entryPoint = "vs_main"
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

proc renderFrame(d: Device, pipeline: RenderPipeline, textureView: TextureView) =
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
  renderPass.draw(3, 1, 0, 0)
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
    let canvas = HTMLCanvasElement(doc.createElement("canvas"))
    doc.body.append(canvas)
    GPUCanvasContext(canvas.getContext("webgpu"))

  proc mainLoop(d: Device) =
    let ctx = createContext()
    let format = tfBGRA8UnormSrgb
    ctx.configure(d, format)
    let pipeline = createPipeline(d, format)
    let textureView = ctx.getCurrentTexture().createView()
    renderFrame(d, pipeline, textureView)

  proc main() {.async.} =
    let i = createInstance()
    if i.isNil:
      document().write("WebGPU is not supported by your browser")
      return
    var options: RequestAdapterOptions
    let a = await i.requestAdapter(options)
    var deviceOpts: DeviceDescriptor
    let d = await a.requestDevice(deviceOpts)
    mainLoop(d)

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
    swapChainDesc.presentMode = pmFifo
    d.createSwapChain(surface, swapChainDesc)

  proc mainLoop(a: Adapter, d: Device, surface: Surface, w: glfw.Window) =
    d.setUncapturedErrorCallback(proc(e: ErrorType, message: cstring, data: pointer) {.cdecl.} =
      echo "Error: ", e, ": ", message
      writeStackTrace()
    )

    let swapChainFormat = surface.getPreferredFormat(a)
    let swapchain = createSwapchain(d, surface, swapchainFormat)
    let pipeline = createPipeline(d, swapChainFormat)

    while windowShouldClose(w) == 0:
      pollEvents()
      let nextTexture = swapChain.getCurrentTextureView()
      if nextTexture == nil:
        echo "Error getting next swap chain texture"
        break

      renderFrame(d, pipeline, nextTexture)
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
