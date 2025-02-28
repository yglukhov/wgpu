import yasync
when defined(wasm):
  import wasmrt
  export wasmrt.isNil

template defineTyp(t: untyped) =
  when defined(wasm):
    type t* = object of JSObj

    proc `==`*(o: t, n: typeof(nil)): bool {.inline.} = o.o.isNil

  else:
    type
      `t Ptr` = ptr object
      t* = object
        p*: `t Ptr`

    proc `wgpu t Reference`(v: `t Ptr`) {.w.}
    proc `wgpu t Release`(v: `t Ptr`) {.w.}

    proc isNil*(v: t): bool {.inline.} = v.p.isNil
    proc `=destroy`*(v: t) =
      if not v.p.isNil:
        # echo "RELEASE ", astToStr(t)
        `wgpu t Release`(v.p)
    proc `=copy`*(dst: var t, src: t) =
      if dst.p != src.p:
        if not src.p.isNil:
          # echo "COPY REF ", astToStr(t)
          `wgpu t Reference`(src.p)
        if not dst.p.isNil:
          # echo "COPY REL ", astToStr(t)
          `wgpu t Release`(dst.p)
        dst.p = src.p
    proc `==`*(v: t, n: typeof(nil)): bool {.inline.} = v.p.isNil
    proc toShared*(v: `t Ptr`): t = t(p: v)
    proc toSharedRetain*(v: `t Ptr`): t =
      `wgpu t Reference`(v)
      t(p: v)

when defined(wasm):
  proc init() {.importwasmraw: """
 // AddressMode
window._nimwca = ['repeat','mirror-repeat','clamp-to-edge'];
 // BufferBindingType
window._nimwcb = [,'uniform','storage','read-only-storage'];
 // TextureFormat
window._nimwct = [,..."r8unorm r8snorm r8uint r8sint r16uint r16sint r16float rg8unorm rg8snorm rg8uint rg8sint r32uint r32sint r32float rg16uint rg16sint rg16float rgba8unorm rgba8unorm-srgb rgba8snorm rgba8uint rgba8sint bgra8unorm bgra8unorm-srgb rgb9e5ufloat rgb10a2unorm rg11b10ufloat rg32uint rg32sint rg32float rgba16uint rgba16sint rgba16float rgba32uint rgba32sint rgba32float stencil8 depth16unorm depth24plus depth24plus-stencil8 depth32float depth32float-stencil8 bc1-rgba-unorm bc1-rgba-unorm-srgb bc2-rgba-unorm bc2-rgba-unorm-srgb bc3-rgba-unorm bc3-rgba-unorm-srgb bc4-r-unorm bc4-r-snorm bc5-rg-unorm bc5-rg-snorm bc6h-rgb-ufloat bc6h-rgb-float bc7-rgba-unorm bc7-rgba-unorm-srgb etc2-rgb8unorm etc2-rgb8unorm-srgb etc2-rgb8a1unorm etc2-rgb8a1unorm-srgb etc2-rgba8unorm etc2-rgba8unorm-srgb eac-r11unorm eac-r11snorm eac-rg11unorm eac-rg11snorm astc-4x4-unorm astc-4x4-unorm-srgb astc-5x4-unorm astc-5x4-unorm-srgb astc-5x5-unorm astc-5x5-unorm-srgb astc-6x5-unorm astc-6x5-unorm-srgb astc-6x6-unorm astc-6x6-unorm-srgb astc-8x5-unorm astc-8x5-unorm-srgb astc-8x6-unorm astc-8x6-unorm-srgb astc-8x8-unorm astc-8x8-unorm-srgb astc-10x5-unorm astc-10x5-unorm-srgb astc-10x6-unorm astc-10x6-unorm-srgb astc-10x8-unorm astc-10x8-unorm-srgb astc-10x10-unorm astc-10x10-unorm-srgb astc-12x10-unorm astc-12x10-unorm-srgb astc-12x12-unorm astc-12x12-unorm-srgb".split(' ')];
 // VertexFormat
window._nimwcv = [,..."uint8x2 uint8x4 sint8x2 sint8x4 unorm8x2 unorm8x4 snorm8x2 snorm8x4 uint16x2 uint16x4 sint16x2 sint16x4 unorm16x2 unorm16x4 snorm16x2 snorm16x4 float16x2 float16x4 float32 float32x2 float32x3 float32x4 uint32 uint32x2 uint32x3 uint32x4 sint32 sint32x2 sint32x3 sint32x4".split(' ')];
 // PrimitiveTopology
window._nimwcp = ["point-list","line-list","line-strip","triangle-list","triangle-strip"];
 // FrontFace
window._nimwcf = ["ccw","cw"];
 // CullMode
window._nimwcc = ["none","front","back"];
 // IndexFormat
window._nimwci = [,"uint16","uint32"];
 // FilterMode and MipmapFilterMode
window._nimwcF = ["nearest","linear"];
 // CompareFunction
window._nimwcC = [,"never","less","less-equal","greater","greater-equal","equal","not-equal","always"];
 // VertexStepMode
window._nimwcs = ["vertex","instance"];
 // TextureDimension
window._nimwcd = ["1d","2d","3d"];
 // TextureViewDimension
window._nimwcD = ["1d","2d","2d-array","cube","cube-array","3d"];
 // TextureSampleType
window._nimwcS = ["float","unfilterable-float","depth","sint","uint"];
 // BufferMapState reversed
window._nimwms = {unmapped: 0, pending: 1, mapped: 2}

""".}
  init()
elif defined(linux):
  import std/[strutils, os]
  const thisPath = currentSourcePath.rsplit({DirSep, AltSep}, 1)[0]
  static:
    echo "DYNLIB: ", thisPath & "/wgpu/linux-x86_64/libwgpu_native.so"
  {.pragma: w, dynlib: thisPath & "/wgpu/linux-x86_64/libwgpu_native.so", importc.}
elif defined(macosx):
  import std/[strutils, os]
  const thisPath = currentSourcePath.rsplit({DirSep, AltSep}, 1)[0]
  when defined(arm64):
    static:
      echo "DYNLIB: ", thisPath & "/wgpu/macos-aarch64/libwgpu_native.dylib"
    {.pragma: w, dynlib: thisPath & "/wgpu/macos-aarch64/libwgpu_native.dylib", importc.}
  elif defined(amd64):
    static:
      echo "DYNLIB: ", thisPath & "/wgpu/macos-x86_64/libwgpu_native.dylib"
    {.pragma: w, dynlib: thisPath & "/wgpu/macos-x86_64/libwgpu_native.dylib", importc.}

defineTyp(Adapter)
defineTyp(BindGroup)
defineTyp(BindGroupLayout)
defineTyp(Buffer)
defineTyp(CommandBuffer)
defineTyp(CommandEncoder)
defineTyp(ComputePassEncoder)
defineTyp(ComputePipeline)
defineTyp(Device)
defineTyp(Instance)
defineTyp(PipelineLayout)
defineTyp(QuerySet)
defineTyp(Queue)
defineTyp(RenderBundle)
defineTyp(RenderBundleEncoder)
defineTyp(RenderPassEncoder)
defineTyp(RenderPipeline)
defineTyp(Sampler)
defineTyp(ShaderModule)
defineTyp(Surface)
# defineTyp(SwapChain)
defineTyp(Texture)
defineTyp(TextureView)

type
  Bool* = uint32

  AdapterType* {.size: sizeof(cint).} = enum
    atDiscreteGPU = 0x00000000,
    atIntegratedGPU = 0x00000001,
    atCPU = 0x00000002,
    atUnknown = 0x00000003,

  AddressMode* {.size: sizeof(cint).} = enum
    amRepeat = 0x00000000,
    amMirrorRepeat = 0x00000001,
    amClampToEdge = 0x00000002,

  BackendType* {.size: sizeof(cint).} = enum
    btUndefined = 0x00000000,
    btNull = 0x00000001,
    btWebGPU = 0x00000002,
    btD3D11 = 0x00000003,
    btD3D12 = 0x00000004,
    btMetal = 0x00000005,
    btVulkan = 0x00000006,
    btOpenGL = 0x00000007,
    btOpenGLES = 0x00000008,

  BlendFactor* {.size: sizeof(cint).} = enum
    bfZero = 0x00000000,
    bfOne = 0x00000001,
    bfSrc = 0x00000002,
    bfOneMinusSrc = 0x00000003,
    bfSrcAlpha = 0x00000004,
    bfOneMinusSrcAlpha = 0x00000005,
    bfDst = 0x00000006,
    bfOneMinusDst = 0x00000007,
    bfDstAlpha = 0x00000008,
    bfOneMinusDstAlpha = 0x00000009,
    bfSrcAlphaSaturated = 0x0000000A,
    bfConstant = 0x0000000B,
    bfOneMinusConstant = 0x0000000C,

  BlendOperation* {.size: sizeof(cint).} = enum
    boAdd = 0x00000000,
    boSubtract = 0x00000001,
    boReverseSubtract = 0x00000002,
    boMin = 0x00000003,
    boMax = 0x00000004,

  BufferBindingType* {.size: sizeof(cint).} = enum
    bbtUndefined = 0x00000000,
    bbtUniform = 0x00000001,
    bbtStorage = 0x00000002,
    bbtReadOnlyStorage = 0x00000003,

  BufferMapAsyncStatus* {.size: sizeof(cint).} = enum
    bmasSuccess = 0x00000000,
    bmasError = 0x00000001,
    bmasUnknown = 0x00000002,
    bmasDeviceLost = 0x00000003,
    bmasDestroyedBeforeCallback = 0x00000004,
    bmasUnmappedBeforeCallback = 0x00000005,

  BufferMapState* {.size: sizeof(cint).} = enum
    msUnmapped = 0x00000000,
    msPending = 0x00000001,
    msMapped = 0x00000002,

  CompareFunction* {.size: sizeof(cint).} = enum
    cfUndefined = 0x00000000,
    cfNever = 0x00000001,
    cfLess = 0x00000002,
    cfLessEqual = 0x00000003,
    cfGreater = 0x00000004,
    cfGreaterEqual = 0x00000005,
    cfEqual = 0x00000006,
    cfNotEqual = 0x00000007,
    cfAlways = 0x00000008,

  CompilationInfoRequestStatus* {.size: sizeof(cint).} = enum
    cirsSuccess = 0x00000000,
    cirsError = 0x00000001,
    cirsDeviceLost = 0x00000002,
    cirsUnknown = 0x00000003,

  CompilationMessageType* {.size: sizeof(cint).} = enum
    cmtError = 0x00000000,
    cmtWarning = 0x00000001,
    cmtInfo = 0x00000002,

  CompositeAlphaMode* {.size: sizeof(cint).} = enum
    camAuto = 0x00000000,
    camOpaque = 0x00000001,
    camPremultiplied = 0x00000002,
    camUnpremultiplied = 0x00000003,
    camInherit = 0x00000004,

  ComputePassTimestampLocation* {.size: sizeof(cint).} = enum
    cptlBeginning = 0x00000000,
    cptlEnd = 0x00000001,

  CreatePipelineAsyncStatus* {.size: sizeof(cint).} = enum
    cpasSuccess = 0x00000000,
    cpasError = 0x00000001,
    cpasDeviceLost = 0x00000002,
    cpasDeviceDestroyed = 0x00000003,
    cpasUnknown = 0x00000004,

  CullMode* {.size: sizeof(cint).} = enum
    cmNone = 0x00000000,
    cmFront = 0x00000001,
    cmBack = 0x00000002,

  DeviceLostReason* {.size: sizeof(cint).} = enum
    dlrUndefined = 0x00000000,
    dlrDestroyed = 0x00000001,

  ErrorFilter* {.size: sizeof(cint).} = enum
    efValidation = 0x00000000,
    efOutOfMemory = 0x00000001,
    efInternal = 0x00000002,

  ErrorType* {.size: sizeof(cint).} = enum
    etNoError = 0x00000000,
    etValidation = 0x00000001,
    etOutOfMemory = 0x00000002,
    etInternal = 0x00000003,
    etUnknown = 0x00000004,
    etDeviceLost = 0x00000005,

  FeatureName* {.size: sizeof(cint).} = enum
    fnUndefined = 0x00000000,
    fnDepthClipControl = 0x00000001,
    fnDepth24UnormStencil8 = 0x00000002,
    fnDepth32FloatStencil8 = 0x00000003,
    fnTimestampQuery = 0x00000004,
    fnPipelineStatisticsQuery = 0x00000005,
    fnTextureCompressionBC = 0x00000006,
    fnTextureCompressionETC2 = 0x00000007,
    fnTextureCompressionASTC = 0x00000008,
    fnIndirectFirstInstance = 0x00000009,

  FilterMode* {.size: sizeof(cint).} = enum
    fmNearest = 0x00000000,
    fmLinear = 0x00000001,

  FrontFace* {.size: sizeof(cint).} = enum
    ffCCW = 0x00000000,
    ffCW = 0x00000001,

  IndexFormat* {.size: sizeof(cint).} = enum
    ifUndefined = 0x00000000,
    ifUint16 = 0x00000001,
    ifUint32 = 0x00000002,

  LoadOp* {.size: sizeof(cint).} = enum
    loUndefined = 0x00000000,
    loClear = 0x00000001,
    loLoad = 0x00000002,

  MipmapFilterMode* {.size: sizeof(cint).} = enum
    mfmNearest = 0x00000000,
    mfmLinear = 0x00000001,

  PipelineStatisticName* {.size: sizeof(cint).} = enum
    psnVertexShaderInvocations = 0x00000000,
    psnClipperInvocations = 0x00000001,
    psnClipperPrimitivesOut = 0x00000002,
    psnFragmentShaderInvocations = 0x00000003,
    psnComputeShaderInvocations = 0x00000004,

  PowerPreference* {.size: sizeof(cint).} = enum
    ppUndefined = 0x00000000,
    ppLowPower = 0x00000001,
    ppHighPerformance = 0x00000002,

  PredefinedColorSpace* {.size: sizeof(cint).} = enum
    pcsUndefined = 0x00000000,
    pcsSrgb = 0x00000001,

  PresentMode* {.size: sizeof(cint).} = enum
    pmFifo = 0x00000000,
    pmFifoRelaxed = 0x00000001,
    pmImmediate = 0x00000002,
    pmMailbox = 0x00000003,

  PrimitiveTopology* {.size: sizeof(cint).} = enum
    ptPointList = 0x00000000,
    ptLineList = 0x00000001,
    ptLineStrip = 0x00000002,
    ptTriangleList = 0x00000003,
    ptTriangleStrip = 0x00000004,

  QueryType* {.size: sizeof(cint).} = enum
    qtOcclusion = 0x00000000,
    qtTimestamp = 0x00000001,

  QueueWorkDoneStatus* {.size: sizeof(cint).} = enum
    qwdsSuccess = 0x00000000,
    qwdsError = 0x00000001,
    qwdsUnknown = 0x00000002,
    qwdsDeviceLost = 0x00000003,

  RequestAdapterStatus* {.size: sizeof(cint).} = enum
    rasSuccess = 0x00000000,
    rasUnavailable = 0x00000001,
    rasError = 0x00000002,
    rasUnknown = 0x00000003,

  RequestDeviceStatus* {.size: sizeof(cint).} = enum
    rdsSuccess = 0x00000000,
    rdsError = 0x00000001,
    rdsUnknown = 0x00000002,

  SType* {.size: sizeof(cint).} = enum
    stInvalid = 0x00000000,
    stSurfaceDescriptorFromMetalLayer = 0x00000001,
    stSurfaceDescriptorFromWindowsHWND = 0x00000002,
    stSurfaceDescriptorFromXlibWindow = 0x00000003,
    stSurfaceDescriptorFromCanvasHTMLSelector = 0x00000004,
    stShaderModuleSPIRVDescriptor = 0x00000005,
    stShaderModuleWGSLDescriptor = 0x00000006,
    stPrimitiveDepthClipControl = 0x00000007,
    stSurfaceDescriptorFromWaylandSurface = 0x00000008,
    stSurfaceDescriptorFromAndroidNativeWindow = 0x00000009,
    stSurfaceDescriptorFromXcbWindow = 0x0000000A,

  SamplerBindingType* {.size: sizeof(cint).} = enum
    sbtUndefined = 0x00000000,
    sbtFiltering = 0x00000001,
    sbtNonFiltering = 0x00000002,
    sbtComparison = 0x00000003,

  StencilOperation* {.size: sizeof(cint).} = enum
    soKeep = 0x00000000,
    soZero = 0x00000001,
    soReplace = 0x00000002,
    soInvert = 0x00000003,
    soIncrementClamp = 0x00000004,
    soDecrementClamp = 0x00000005,
    soIncrementWrap = 0x00000006,
    soDecrementWrap = 0x00000007,

  StorageTextureAccess* {.size: sizeof(cint).} = enum
    staUndefined = 0x00000000,
    staWriteOnly = 0x00000001,
    staReadOnly = 0x00000002,
    staReadWrite = 0x00000003,

  StoreOp* {.size: sizeof(cint).} = enum
    soUndefined = 0x00000000,
    soStore = 0x00000001,
    soDiscard = 0x00000002,

  SurfaceGetCurrentTextureStatus* {.size: sizeof(cint).} = enum
    gctsSuccess = 0x00000000,
    gctsTimeout = 0x00000001,
    gctsOutdated = 0x00000002,
    gctsLost = 0x00000003,
    gctsOutOfMemory = 0x00000004,
    gctsDeviceLost = 0x00000005,

  TextureAspect* {.size: sizeof(cint).} = enum
    taAll = 0x00000000,
    taStencilOnly = 0x00000001,
    taDepthOnly = 0x00000002,

  TextureComponentType* {.size: sizeof(cint).} = enum
    tctFloat = 0x00000000,
    tctSint = 0x00000001,
    tctUint = 0x00000002,
    tctDepthComparison = 0x00000003,

  TextureDimension* {.size: sizeof(cint).} = enum
    td1D = 0x00000000,
    td2D = 0x00000001,
    td3D = 0x00000002,

  TextureFormat* {.size: sizeof(cint).} = enum
    tfUndefined = 0x00000000,
    tfR8Unorm = 0x00000001,
    tfR8Snorm = 0x00000002,
    tfR8Uint = 0x00000003,
    tfR8Sint = 0x00000004,
    tfR16Uint = 0x00000005,
    tfR16Sint = 0x00000006,
    tfR16Float = 0x00000007,
    tfRG8Unorm = 0x00000008,
    tfRG8Snorm = 0x00000009,
    tfRG8Uint = 0x0000000A,
    tfRG8Sint = 0x0000000B,
    tfR32Float = 0x0000000C,
    tfR32Uint = 0x0000000D,
    tfR32Sint = 0x0000000E,
    tfRG16Uint = 0x0000000F,
    tfRG16Sint = 0x00000010,
    tfRG16Float = 0x00000011,
    tfRGBA8Unorm = 0x00000012,
    tfRGBA8UnormSrgb = 0x00000013,
    tfRGBA8Snorm = 0x00000014,
    tfRGBA8Uint = 0x00000015,
    tfRGBA8Sint = 0x00000016,
    tfBGRA8Unorm = 0x00000017,
    tfBGRA8UnormSrgb = 0x00000018,
    tfRGB10A2Unorm = 0x00000019,
    tfRG11B10Ufloat = 0x0000001A,
    tfRGB9E5Ufloat = 0x0000001B,
    tfRG32Float = 0x0000001C,
    tfRG32Uint = 0x0000001D,
    tfRG32Sint = 0x0000001E,
    tfRGBA16Uint = 0x0000001F,
    tfRGBA16Sint = 0x00000020,
    tfRGBA16Float = 0x00000021,
    tfRGBA32Float = 0x00000022,
    tfRGBA32Uint = 0x00000023,
    tfRGBA32Sint = 0x00000024,
    tfStencil8 = 0x00000025,
    tfDepth16Unorm = 0x00000026,
    tfDepth24Plus = 0x00000027,
    tfDepth24PlusStencil8 = 0x00000028,
    tfDepth24UnormStencil8 = 0x00000029,
    tfDepth32Float = 0x0000002A,
    tfDepth32FloatStencil8 = 0x0000002B,
    tfBC1RGBAUnorm = 0x0000002C,
    tfBC1RGBAUnormSrgb = 0x0000002D,
    tfBC2RGBAUnorm = 0x0000002E,
    tfBC2RGBAUnormSrgb = 0x0000002F,
    tfBC3RGBAUnorm = 0x00000030,
    tfBC3RGBAUnormSrgb = 0x00000031,
    tfBC4RUnorm = 0x00000032,
    tfBC4RSnorm = 0x00000033,
    tfBC5RGUnorm = 0x00000034,
    tfBC5RGSnorm = 0x00000035,
    tfBC6HRGBUfloat = 0x00000036,
    tfBC6HRGBFloat = 0x00000037,
    tfBC7RGBAUnorm = 0x00000038,
    tfBC7RGBAUnormSrgb = 0x00000039,
    tfETC2RGB8Unorm = 0x0000003A,
    tfETC2RGB8UnormSrgb = 0x0000003B,
    tfETC2RGB8A1Unorm = 0x0000003C,
    tfETC2RGB8A1UnormSrgb = 0x0000003D,
    tfETC2RGBA8Unorm = 0x0000003E,
    tfETC2RGBA8UnormSrgb = 0x0000003F,
    tfEACR11Unorm = 0x00000040,
    tfEACR11Snorm = 0x00000041,
    tfEACRG11Unorm = 0x00000042,
    tfEACRG11Snorm = 0x00000043,
    tfASTC4x4Unorm = 0x00000044,
    tfASTC4x4UnormSrgb = 0x00000045,
    tfASTC5x4Unorm = 0x00000046,
    tfASTC5x4UnormSrgb = 0x00000047,
    tfASTC5x5Unorm = 0x00000048,
    tfASTC5x5UnormSrgb = 0x00000049,
    tfASTC6x5Unorm = 0x0000004A,
    tfASTC6x5UnormSrgb = 0x0000004B,
    tfASTC6x6Unorm = 0x0000004C,
    tfASTC6x6UnormSrgb = 0x0000004D,
    tfASTC8x5Unorm = 0x0000004E,
    tfASTC8x5UnormSrgb = 0x0000004F,
    tfASTC8x6Unorm = 0x00000050,
    tfASTC8x6UnormSrgb = 0x00000051,
    tfASTC8x8Unorm = 0x00000052,
    tfASTC8x8UnormSrgb = 0x00000053,
    tfASTC10x5Unorm = 0x00000054,
    tfASTC10x5UnormSrgb = 0x00000055,
    tfASTC10x6Unorm = 0x00000056,
    tfASTC10x6UnormSrgb = 0x00000057,
    tfASTC10x8Unorm = 0x00000058,
    tfASTC10x8UnormSrgb = 0x00000059,
    tfASTC10x10Unorm = 0x0000005A,
    tfASTC10x10UnormSrgb = 0x0000005B,
    tfASTC12x10Unorm = 0x0000005C,
    tfASTC12x10UnormSrgb = 0x0000005D,
    tfASTC12x12Unorm = 0x0000005E,
    tfASTC12x12UnormSrgb = 0x0000005F,

  TextureSampleType* {.size: sizeof(cint).} = enum
    tstUndefined = 0x00000000,
    tstFloat = 0x00000001,
    tstUnfilterableFloat = 0x00000002,
    tstDepth = 0x00000003,
    tstSint = 0x00000004,
    tstUint = 0x00000005,

  TextureViewDimension* {.size: sizeof(cint).} = enum
    tvdUndefined = 0x00000000,
    tvd1D = 0x00000001,
    tvd2D = 0x00000002,
    tvd2DArray = 0x00000003,
    tvdCube = 0x00000004,
    tvdCubeArray = 0x00000005,
    tvd3D = 0x00000006,

  VertexFormat* {.size: sizeof(cint).} = enum
    vfUndefined = 0x00000000,
    vfUint8x2 = 0x00000001,
    vfUint8x4 = 0x00000002,
    vfSint8x2 = 0x00000003,
    vfSint8x4 = 0x00000004,
    vfUnorm8x2 = 0x00000005,
    vfUnorm8x4 = 0x00000006,
    vfSnorm8x2 = 0x00000007,
    vfSnorm8x4 = 0x00000008,
    vfUint16x2 = 0x00000009,
    vfUint16x4 = 0x0000000A,
    vfSint16x2 = 0x0000000B,
    vfSint16x4 = 0x0000000C,
    vfUnorm16x2 = 0x0000000D,
    vfUnorm16x4 = 0x0000000E,
    vfSnorm16x2 = 0x0000000F,
    vfSnorm16x4 = 0x00000010,
    vfFloat16x2 = 0x00000011,
    vfFloat16x4 = 0x00000012,
    vfFloat32 = 0x00000013,
    vfFloat32x2 = 0x00000014,
    vfFloat32x3 = 0x00000015,
    vfFloat32x4 = 0x00000016,
    vfUint32 = 0x00000017,
    vfUint32x2 = 0x00000018,
    vfUint32x3 = 0x00000019,
    vfUint32x4 = 0x0000001A,
    vfSint32 = 0x0000001B,
    vfSint32x2 = 0x0000001C,
    vfSint32x3 = 0x0000001D,
    vfSint32x4 = 0x0000001E,

  VertexStepMode* {.size: sizeof(cint).} = enum
    vsmVertex = 0x00000000,
    vsmInstance = 0x00000001,

  BufferUsage* {.size: sizeof(cint).} = enum
    # none = 0x00000000,
    buMapRead# = 0x00000001,
    buMapWrite# = 0x00000002,
    buCopySrc# = 0x00000004,
    buCopyDst# = 0x00000008,
    buIndex# = 0x00000010,
    buVertex# = 0x00000020,
    buUniform# = 0x00000040,
    buStorage# = 0x00000080,
    buIndirect# = 0x00000100,
    buQueryResolve# = 0x00000200,

  ColorWriteMask* {.size: sizeof(cint).} = enum
    # None = 0x00000000,
    cwmRed# = 0x00000001,
    cwmGreen# = 0x00000002,
    cwmBlue# = 0x00000004,
    cwmAlpha# = 0x00000008,
    # cwmAll# = 0x0000000F,

  MapMode* {.size: sizeof(cint).} = enum
    # None = 0x00000000,
    mmRead# = 0x00000001,
    mmWrite# = 0x00000002,

  ShaderStage* {.size: sizeof(cint).} = enum
    # WGPUShaderStage_None = 0x00000000,
    ssVertex# = 0x00000001,
    ssFragment# = 0x00000002,
    ssCompute# = 0x00000004,

  TextureUsage* {.size: sizeof(cint).} = enum
    # none = 0x00000000,
    tuCopySrc# = 0x00000001,
    tuCopyDst# = 0x00000002,
    tuTextureBinding# = 0x00000004,
    tuStorageBinding# = 0x00000008,
    tuRenderAttachment# = 0x00000010,

  ChainedStruct* {.inheritable, pure.} = object
    next*: ptr ChainedStruct
    sType*: SType

  ChainedStructOut* {.inheritable, pure.} = object
    next*: ptr ChainedStructOut
    sType*: SType

  BindGroupEntry* = object
    nextInChain*: ptr ChainedStruct
    binding*: uint32
    buffer*: Buffer # nullable
    offset*: uint64
    size*: uint64
    sampler*: Sampler # nullable
    textureView*: TextureView # nullable

  PipelineLayoutDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    bindGroupLayoutCount*: csize_t
    bindGroupLayouts*: ptr BindGroupLayout

  PrimitiveState* = object
    nextInChain*: ptr ChainedStruct
    topology*: PrimitiveTopology
    stripIndexFormat*: IndexFormat
    frontFace*: FrontFace
    cullMode*: CullMode

  QueueDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable

  Limits* = object
    maxTextureDimension1D*: uint32
    maxTextureDimension2D*: uint32
    maxTextureDimension3D*: uint32
    maxTextureArrayLayers*: uint32
    maxBindGroups*: uint32
    maxBindGroupsPlusVertexBuffers*: uint32
    maxBindingsPerBindGroup*: uint32
    maxDynamicUniformBuffersPerPipelineLayout*: uint32
    maxDynamicStorageBuffersPerPipelineLayout*: uint32
    maxSampledTexturesPerShaderStage*: uint32
    maxSamplersPerShaderStage*: uint32
    maxStorageBuffersPerShaderStage*: uint32
    maxStorageTexturesPerShaderStage*: uint32
    maxUniformBuffersPerShaderStage*: uint32
    maxUniformBufferBindingSize*: uint64
    maxStorageBufferBindingSize*: uint64
    minUniformBufferOffsetAlignment*: uint32
    minStorageBufferOffsetAlignment*: uint32
    maxVertexBuffers*: uint32
    maxBufferSize*: uint64
    maxVertexAttributes*: uint32
    maxVertexBufferArrayStride*: uint32
    maxInterStageShaderComponents*: uint32
    maxInterStageShaderVariables*: uint32
    maxColorAttachments*: uint32
    maxColorAttachmentBytesPerSample*: uint32
    maxComputeWorkgroupStorageSize*: uint32
    maxComputeInvocationsPerWorkgroup*: uint32
    maxComputeWorkgroupSizeX*: uint32
    maxComputeWorkgroupSizeY*: uint32
    maxComputeWorkgroupSizeZ*: uint32
    maxComputeWorkgroupsPerDimension*: uint32

  MultisampleState* = object
    nextInChain*: ptr ChainedStruct
    count*: uint32
    mask*: uint32
    alphaToCoverageEnabled*: Bool

  Origin3D* = object
    x*: uint32
    y*: uint32
    z*: uint32

  RequiredLimits* = object
    nextInChain*: ptr ChainedStruct
    limits*: Limits

  ShaderModuleDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    hintCount*: csize_t
    hints*: ptr ShaderModuleCompilationHint

  TextureDescriptor * = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    usage*: set[TextureUsage]
    dimension*: TextureDimension
    size*: Extent3D
    format*: TextureFormat
    mipLevelCount*: uint32
    sampleCount*: uint32
    viewFormatCount*: csize_t
    viewFormats*: ptr TextureFormat

  ConstantEntry* = object
    nextInChain*: ptr ChainedStruct
    key*: cstring
    value*: float

  Extent3D* = object
    width*: uint32
    height*: uint32
    depthOrArrayLayers*: uint32

  InstanceDescriptor* = object
    nextInChain*: ptr ChainedStruct

  RenderPassDepthStencilAttachment* = object
    view*: TextureView
    depthLoadOp*: LoadOp
    depthStoreOp*: StoreOp
    depthClearValue*: float32
    depthReadOnly*: Bool
    stencilLoadOp*: LoadOp
    stencilStoreOp*: StoreOp
    stencilClearValue*: uint32
    stencilReadOnly*: Bool

  RenderPassTimestampWrites* = object
    querySet*: QuerySet
    beginningOfPassWriteIndex*: uint32
    endOfPassWriteIndex*: uint32

  RequestAdapterOptions* = object
    nextInChain*: ptr ChainedStruct
    compatibleSurface*: Surface # nullable
    powerPreference*: PowerPreference
    backendType*: BackendType
    forceFallbackAdapter*: Bool

  SamplerBindingLayout* = object
    nextInChain*: ptr ChainedStruct
    kind*: SamplerBindingType

  SamplerDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    addressModeU*: AddressMode
    addressModeV*: AddressMode
    addressModeW*: AddressMode
    magFilter*: FilterMode
    minFilter*: FilterMode
    mipmapFilter*: MipmapFilterMode
    lodMinClamp*: float32
    lodMaxClamp*: float32
    compare*: CompareFunction
    maxAnisotropy*: uint16

  ShaderModuleCompilationHint* = object
    nextInChain*: ptr ChainedStruct
    entryPoint*: cstring
    layout*: PipelineLayout

  ShaderModuleWGSLDescriptor* = object of ChainedStruct
    code*: cstring

  StencilFaceState* = object
    compare*: CompareFunction
    failOp*: StencilOperation
    depthFailOp*: StencilOperation
    passOp*: StencilOperation

  StorageTextureBindingLayout* = object
    nextInChain*: ptr ChainedStruct
    access*: StorageTextureAccess
    format*: TextureFormat
    viewDimension*: TextureViewDimension

  SurfaceCapabilities* = object
    nextInChain*: ptr ChainedStructOut
    usages*: set[TextureUsage]
    formatCount*: csize_t
    formats*: ptr UncheckedArray[TextureFormat]
    presentModeCount*: csize_t
    presentModes*: ptr PresentMode
    alphaModeCount*: csize_t
    alphaModes*: ptr CompositeAlphaMode

  SurfaceConfiguration* = object
    nextInChain*: ptr ChainedStructOut
    device*: Device
    format*: TextureFormat
    usage*: set[TextureUsage]
    viewFormatCount*: csize_t
    viewFormats*: ptr UncheckedArray[TextureFormat]
    alphaMode*: CompositeAlphaMode
    width*: uint32
    height*: uint32
    presentMode*: PresentMode

  SurfaceDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable

  BlendComponent* = object
    operation*: BlendOperation
    srcFactor*: BlendFactor
    dstFactor*: BlendFactor

  BufferBindingLayout* = object
    nextInChain*: ptr ChainedStruct
    kind*: BufferBindingType
    hasDynamicOffset*: Bool
    minBindingSize*: uint64

  BufferDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    usage*: set[BufferUsage]
    size*: uint64
    mappedAtCreation*: Bool

  Color* = object
    r*: float
    g*: float
    b*: float
    a*: float

  CommandBufferDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable

  CommandEncoderDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable

  ComputePassTimestampWrite* = object
    querySet*: QuerySet
    queryIndex*: uint32
    location*: ComputePassTimestampLocation

  VertexBufferLayout* = object
    arrayStride*: uint64
    stepMode*: VertexStepMode
    attributeCount*: csize_t
    attributes*: ptr VertexAttribute

  BindGroupLayoutDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    entryCount*: csize_t
    entries*: ptr BindGroupLayoutEntry

  ColorTargetState* = object
    nextInChain*: ptr ChainedStruct
    format*: TextureFormat
    blend*: ptr BlendState # nullable
    writeMask*: set[ColorWriteMask]

  ComputePipelineDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    layout*: PipelineLayout
    compute*: ProgrammableStageDescriptor

  DeviceDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    requiredFeaturesCount*: csize_t
    requiredFeatures*: ptr FeatureName
    requiredLimits*: ptr RequiredLimits # nullable
    defaultQueue*: QueueDescriptor
    deviceLostCallback*: DeviceLostCallback
    deviceLostUserData*: pointer
    uncapturedErrorCallbackInfo*: UncapturedErrorCallbackInfo

  RenderPassColorAttachment* = object
    nextInChain*: ptr ChainedStruct
    view*: TextureView # nullable
    depthSlice*: uint32
    resolveTarget*: TextureView # nullable
    loadOp*: LoadOp
    storeOp*: StoreOp
    clearValue*: Color

  RenderPassDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    colorAttachmentCount*: csize_t
    colorAttachments*: ptr RenderPassColorAttachment
    depthStencilAttachment*: ptr RenderPassDepthStencilAttachment #nullable
    occlusionQuerySet*: QuerySet# nullable
    timestampWrites*: RenderPassTimestampWrites

  SurfaceDescriptorFromAndroidNativeWindow* = object of ChainedStruct
    window*: pointer

  SurfaceDescriptorFromMetalLayer* = object of ChainedStruct
    layer*: pointer

  SurfaceDescriptorFromWaylandSurface* = object of ChainedStruct
    display*: pointer
    surface*: pointer

  SurfaceDescriptorFromWindowsHWND* = object of ChainedStruct
    hinstance*: pointer
    hwnd*: pointer

  SurfaceDescriptorFromXcbWindow* = object of ChainedStruct
    connection*: pointer
    window*: uint32

  SurfaceDescriptorFromXlibWindow* = object of ChainedStruct
    display*: pointer
    window*: uint32

  SurfaceTexture* = object
    texture*: Texture
    suboptimal*: Bool
    status*: SurfaceGetCurrentTextureStatus

  SwapChainDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    usage*: set[TextureUsage]
    format*: TextureFormat
    width*: uint32
    height*: uint32
    presentMode*: PresentMode

  TextureDataLayout* = object
    nextInChain*: ptr ChainedStruct
    offset*: uint64
    bytesPerRow*: uint32
    rowsPerImage*: uint32

  TextureViewDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    format*: TextureFormat
    dimension*: TextureViewDimension
    baseMipLevel*: uint32
    mipLevelCount*: uint32
    baseArrayLayer*: uint32
    arrayLayerCount*: uint32
    aspect*: TextureAspect

  UncapturedErrorCallbackInfo* = object
    nextInChain*: ptr ChainedStruct
    callback*: ErrorCallback
    userdata*: pointer

  TextureBindingLayout* = object
    nextInChain*: ptr ChainedStruct
    sampleType*: TextureSampleType
    viewDimension*: TextureViewDimension
    multisampled*: Bool

  VertexAttribute* = object
    format*: VertexFormat
    offset*: uint64
    shaderLocation*: uint32

  BindGroupDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    layout*: BindGroupLayout
    entryCount*: csize_t
    entries*: ptr BindGroupEntry

  BindGroupLayoutEntry* = object
    nextInChain*: ptr ChainedStruct
    binding*: uint32
    visibility*: set[ShaderStage]
    buffer*: BufferBindingLayout
    sampler*: SamplerBindingLayout
    texture*: TextureBindingLayout
    storageTexture*: StorageTextureBindingLayout

  BlendState* = object
    color*: BlendComponent
    alpha*: BlendComponent

  ComputePassDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    timestampWriteCount*: uint32
    timestampWrites*: ptr ComputePassTimestampWrite

  DepthStencilState* = object
    nextInChain*: ptr ChainedStruct
    format*: TextureFormat
    depthWriteEnabled*: Bool
    depthCompare*: CompareFunction
    stencilFront*: StencilFaceState
    stencilBack*: StencilFaceState
    stencilReadMask*: uint32
    stencilWriteMask*: uint32
    depthBias*: int32
    depthBiasSlopeScale*: float32
    depthBiasClamp*: float32

  ImageCopyTexture* = object
    nextInChain*: ptr ChainedStruct
    texture*: Texture
    mipLevel*: uint32
    origin*: Origin3D
    aspect*: TextureAspect

  ProgrammableStageDescriptor* = object
    nextInChain*: ptr ChainedStruct
    module*: ShaderModule
    entryPoint*: cstring
    constantCount*: csize_t
    constants*: ptr ConstantEntry

  VertexState* = object
    nextInChain*: ptr ChainedStruct
    module*: ShaderModule
    entryPoint*: cstring
    constantCount*: csize_t
    constants*: ptr ConstantEntry
    bufferCount*: csize_t
    buffers*: ptr VertexBufferLayout

  FragmentState* = object
    nextInChain*: ptr ChainedStruct
    module*: ShaderModule
    entryPoint*: cstring
    constantCount*: csize_t
    constants*: ptr ConstantEntry
    targetCount*: csize_t
    targets*: ptr ColorTargetState

  RenderPipelineDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    layout*: PipelineLayout # nullable
    vertex*: VertexState
    primitive*: PrimitiveState
    depthStencil*: ptr DepthStencilState # nullable
    multisample*: MultisampleState
    fragment*: ptr FragmentState # nullable

  DeviceLostCallback* = proc(reason: DeviceLostReason, message: cstring, userdata: pointer) {.cdecl.}
  ErrorCallback* = proc(e: ErrorType, message: cstring, userdata: pointer) {.cdecl.}

const
  cwmAll* = {cwmRed, cwmGreen, cwmBlue, cwmAlpha}

proc extent3d*(x, y, z: uint32): Extent3D {.inline.} = Extent3D(width: x, height: y, depthOrArrayLayers: z)


when defined(wasm):
  proc createInstance*(): Instance {.importwasmp: "navigator['gpu'] || null".}
  proc getPreferredCanvasFormat*(i: Instance): TextureFormat {.importwasmexpr: "_nimwct.indexOf(_nimo[$0].getPreferredCanvasFormat())".}

else:
  proc wgpuCreateInstance(descriptor: ptr InstanceDescriptor): InstancePtr {.w.}
  proc createInstance*(): Instance {.inline.} =
    var d: InstanceDescriptor
    wgpuCreateInstance(addr d).toShared

  proc createInstance*(descriptor: InstanceDescriptor): Instance {.inline.} = wgpuCreateInstance(addr descriptor).toShared


when defined(wasm):
  type
    RequestAdapterCallbackWasm = proc(status: RequestAdapterStatus, adapter: JSRef, message: cstring, userdata: pointer) {.cdecl.}
  proc wgpuInstanceRequestAdapter(instance: Instance, options: ptr RequestAdapterOptions, callback: RequestAdapterCallbackWasm, userdata: pointer) {.importwasmraw: """
  _nimo[$0].requestAdapter().then(a => _nime._dviiii($2, 0, _nimok(a), 0, $3))
  """.}

  proc requestAdapterCallback(status: RequestAdapterStatus, adapter: JSRef, message: cstring, env: pointer) {.cdecl.} =
    defineDyncall("viiii")
    let env = cast[Future[Adapter]](env)
    GC_unref(env)
    env.complete(Adapter(o: adapter))

else:
  type
    RequestAdapterCallback* = proc(status: RequestAdapterStatus, adapter: AdapterPtr, message: cstring, userdata: pointer) {.cdecl.}
  proc wgpuInstanceRequestAdapter(instance: Instance, options: ptr RequestAdapterOptions, callback: RequestAdapterCallback, userdata: pointer) {.w.}

  proc requestAdapterCallback(status: RequestAdapterStatus, adapter: AdapterPtr, message: cstring, env: pointer) {.cdecl.} =
    let env = cast[Future[Adapter]](env)
    GC_unref(env)
    env.complete(adapter.toShared)

proc requestAdapter(instance: Instance, options: ptr RequestAdapterOptions): Future[Adapter] =
  result.new()
  GC_ref(result)
  let env = cast[pointer](result)
  wgpuInstanceRequestAdapter(instance, options, requestAdapterCallback, env)

proc requestAdapter*(instance: Instance, options: RequestAdapterOptions): Future[Adapter] {.inline.} = instance.requestAdapter(addr options)

proc requestAdapter*(instance: Instance): Future[Adapter] {.inline.} = instance.requestAdapter(nil)


# Procs of Adapter
when defined(wasm):
  discard
else:
  proc wgpuAdapterEnumerateFeatures(adapter: AdapterPtr, features: ptr FeatureName): csize_t {.w.}
  proc features*(a: Adapter): seq[FeatureName] =
    let s = wgpuAdapterEnumerateFeatures(a.p, nil)
    result.setLen(s)
    if s != 0:
      discard wgpuAdapterEnumerateFeatures(a.p, addr result[0])

when defined(wasm):
  type
    RequestDeviceCallbackWasm* = proc(status: RequestDeviceStatus, device: JSRef, message: cstring, userdata: pointer) {.cdecl.}
  proc wgpuAdapterRequestDevice(adapter: Adapter, descriptor: ptr DeviceDescriptor, callback: RequestDeviceCallbackWasm, userdata: pointer) {.importwasmraw: """
  _nimo[$0].requestDevice().then(a => _nime._dviiii($2, 0, _nimok(a), 0, $3))
  """.}

  proc requestDeviceCallback(status: RequestDeviceStatus, device: JSRef, message: cstring, env: pointer) {.cdecl.} =
    defineDyncall("viiii")
    let env = cast[Future[Device]](env)
    GC_unref(env)
    env.complete(Device(o: device))
    delete(device)

else:
  type
    RequestDeviceCallback* = proc(status: RequestDeviceStatus, device: DevicePtr, message: cstring, userdata: pointer) {.cdecl.}
  proc wgpuInstanceCreateSurface(instance: InstancePtr, descriptor: ptr SurfaceDescriptor): SurfacePtr {.w.}
  proc createSurface*(instance: Instance, descriptor: SurfaceDescriptor): Surface {.inline.} = wgpuInstanceCreateSurface(instance.p, addr descriptor).toShared

  proc wgpuAdapterRequestDevice(adapter: Adapter, descriptor: ptr DeviceDescriptor, callback: RequestDeviceCallback, userdata: pointer) {.w.}

  proc requestDeviceCallback(status: RequestDeviceStatus, device: DevicePtr, message: cstring, env: pointer) {.cdecl.} =
    let env = cast[Future[Device]](env)
    GC_unref(env)
    env.complete(device.toShared)

  proc wgpuInstanceProcessEvents(i: InstancePtr) {.w.}
  proc processEvents*(i: Instance) {.inline.} =
    wgpuInstanceProcessEvents(i.p)

proc requestDevice(adapter: Adapter, options: ptr DeviceDescriptor): Future[Device] =
  result.new()
  GC_ref(result)
  let env = cast[pointer](result)
  wgpuAdapterRequestDevice(adapter, options, requestDeviceCallback, env)

proc requestDevice*(adapter: Adapter, options: DeviceDescriptor): Future[Device] {.inline.} = adapter.requestDevice(addr options)

template ptrArrayElem[T](p: ptr T, i: int): ptr T =
  addr cast[ptr UncheckedArray[T]](p)[i]

# Procs of Buffer
when defined(wasm):
  proc bufferSize(b: Buffer): uint32 {.importwasmp: "size".}
  proc usage*(b: Buffer): set[BufferUsage] {.importwasmp.}
  proc size*(b: Buffer): uint64 {.inline.} = b.bufferSize

  proc mapAsync(b: Buffer, m: uint32, o, s: uint32, cb: proc(p: pointer) {.cdecl.}, data: pointer) {.importwasmraw: """
_nimo[$0].mapAsync($1, $2, $3).then(() => _nime._dvi($4, $5))
""".}

  proc onMapComplete(p: pointer) {.cdecl.} =
    let f = cast[Future[void]](p)
    GC_unref(f)
    f.complete()

  proc mapAsync*(b: Buffer, mode: set[MapMode], offset, size: uint64): Future[void] =
    defineDyncall("vi")
    result = newFuture(void)
    GC_ref(result)
    mapAsync(b, cast[uint32](mode), offset.uint32, size.uint32, onMapComplete, cast[pointer](result))

  proc copyMappedRangeOutAux(b: Buffer, offset, size: uint32, dest: pointer) {.importwasmraw: """
new Uint8Array(_nima).set(new Uint8Array(_nimo[$0].getMappedRange($1, $2)), $3)
""".}

  proc copyMappedRangeOut*(b: Buffer, offset, size: uint64, dest: pointer) {.inline.} =
    copyMappedRangeOutAux(b, offset.uint32, size.uint32, dest)

else:
  proc size*(b: Buffer): uint64 {.w, importc: "wgpuBufferGetSize".}
  proc usage*(b: Buffer): set[BufferUsage] {.w, importc: "wgpuBufferGetUsage".}

  type BufferMapAsyncCallback* = proc(status: BufferMapAsyncStatus, userdata: pointer) {.cdecl.}
  proc wgpuBufferMapAsync(b: BufferPtr, mode: set[MapMode], o, s: csize_t, c: BufferMapAsyncCallback, u: pointer) {.w.}
  proc mapAsync*(b: Buffer, mode: set[MapMode], offset, size: uint64, cb: BufferMapAsyncCallback, userdata: pointer) {.inline.} =
    wgpuBufferMapAsync(b.p, mode, offset.csize_t, size.csize_t, cb, userdata)

  type CBWrap = ref object
    cb: proc(status: BufferMapAsyncStatus)
  proc onMapComplete(s: BufferMapAsyncStatus, cb: pointer) {.cdecl.} =
    let cb = cast[CBWrap](cb)
    GC_unref(cb)
    cb.cb(s)

  proc mapAsync*(b: Buffer, mode: set[MapMode], offset, size: uint64, cb: proc(status: BufferMapAsyncStatus)) {.inline.} =
    let w = CBWrap(cb: cb)
    GC_ref(w)
    mapAsync(b, mode, offset, size, onMapComplete, cast[pointer](w))

  proc onMapFutComplete(s: BufferMapAsyncStatus, f: pointer) {.cdecl.} =
    let f = cast[Future[void]](f)
    GC_unref(f)
    f.complete()

  proc mapAsync*(b: Buffer, mode: set[MapMode], offset, size: uint64): Future[void] =
    result = newFuture(void)
    GC_ref(result)
    mapAsync(b, mode, offset, size, onMapFutComplete, cast[pointer](result))

  proc wgpuBufferUnmap(b: BufferPtr) {.w.}
  proc unmap*(b: Buffer) {.inline.} =
    wgpuBufferUnmap(b.p)

  proc wgpuBufferGetConstMappedRange(b: BufferPtr, o, s: csize_t): pointer {.w.}
  proc getConstMappedRange*(b: Buffer, o, s: csize_t): pointer {.inline.} =
    wgpuBufferGetConstMappedRange(b.p, o, s)

  proc copyMappedRangeOut*(b: Buffer, offset, size: uint64, dest: pointer) =
    let s = getConstMappedRange(b, offset, size)
    copyMem(dest, s, size)

# Procs of Device

when defined(wasm):
  proc makeJsArray(count: uint32): JSObj {.importwasmf: "new Array".}

  proc addBindgroupEntry(t: JSObj, idx: int32, binding, offset, size: uint32, resource: JSRef) {.importwasmraw: "var n=_nimo,o=n[$5];n[$0][$1] = {binding: $2, resource: $4?{offset: $3, size: $4, buffer: o}:o}".}

  proc log(o: JSObj){.importwasmraw: """console.log('entr', _nimo[$0])""".}

  proc createBindGroup(device: Device, layout: BindGroupLayout, entries: JSObj): BindGroup {.importwasmp: """
  createBindGroup({layout: _nimo[$1], entries: _nimo[$2]})
  """}

  proc createBindGroup*(device: Device, descriptor: BindGroupDescriptor): BindGroup {.inline.} =
    let entryCount = descriptor.entryCount
    let entries = makeJsArray(entryCount)
    for i in 0 ..< entryCount.int:
      let e = ptrArrayElem(descriptor.entries, i)
      var res = e.buffer.o
      if res.isNil:
        res = e.sampler.o
        if res.isNil:
          res = e.textureView.o
      addBindgroupEntry(entries, i.int32, e.binding, uint32(e.offset), uint32(e.size), res)
    createBindGroup(device, descriptor.layout, entries)

else:
  proc wgpuDeviceCreateBindGroup(device: DevicePtr, descriptor: ptr BindGroupDescriptor): BindGroupPtr {.w.}
  proc createBindGroup*(device: Device, descriptor: BindGroupDescriptor): BindGroup {.inline.} =
    wgpuDeviceCreateBindGroup(device.p, addr descriptor).toShared

when defined(wasm):
  proc createBindGroupLayout(device: Device, entries: JSObj): BindGroupLayout {.importwasmp: """
  createBindGroupLayout({entries:_nimo[$1]})
  """.}

  proc addBindgroupLayoutEntryBuffer(t: JSObj, idx: int32, binding, visibility: uint32, k: BufferBindingType, hdo: bool, mbs: uint32) {.importwasmraw: "_nimo[$0][$1] = {binding: $2, visibility: $3, buffer: {type: _nimwcb[$4], hasDynamicOffset: $5, minBindingSize: $6}}".}
  proc addBindgroupLayoutEntryTexture(t: JSObj, idx: int32, binding, visibility: uint32, s, d: int32, multisampled: int32) {.importwasmraw: "_nimo[$0][$1] = {binding: $2, visibility: $3, texture: {sampleType: _nimwcS[$4], viewDimension: _nimwcD[$5], multisampled: $6}}".}

  proc createBindGroupLayout*(device: Device, descriptor: BindGroupLayoutDescriptor): BindGroupLayout =
    let entryCount = descriptor.entryCount
    let entries = makeJsArray(entryCount)
    for i in 0 ..< entryCount.int:
      let e = ptrArrayElem(descriptor.entries, i)
      if e.buffer.kind != bbtUndefined:
        addBindgroupLayoutEntryBuffer(entries, i.int32, e.binding, cast[uint32](e.visibility), e.buffer.kind, e.buffer.hasDynamicOffset, uint32(e.buffer.minBindingSize))
      elif e.texture.sampleType != tstUndefined:
        addBindGroupLayoutEntryTexture(entries, i.int32, e.binding, cast[uint32](e.visibility), cast[int32](e.texture.sampleType) - 1, cast[int32](e.texture.viewDimension) - 1, e.texture.multisampled.int32)
      else:
        assert(false, "Not implemented")
    log(entries)
    createBindGroupLayout(device, entries)

else:
  proc wgpuDeviceCreateBindGroupLayout(device: DevicePtr, descriptor: ptr BindGroupLayoutDescriptor): BindGroupLayoutPtr {.w}
  proc createBindGroupLayout*(device: Device, descriptor: BindGroupLayoutDescriptor): BindGroupLayout {.inline.} =
    wgpuDeviceCreateBindGroupLayout(device.p, addr descriptor).toShared

when defined(wasm):
  proc createBuffer(device: Device, usage: uint32, size: uint32, mappedAtCreation: bool): Buffer {.importwasmp: """
  createBuffer({usage: $1, size: $2, mappedAtCreation: $3})
  """.}
  proc createBuffer*(device: Device, d: BufferDescriptor): Buffer {.inline.} =
    createBuffer(device, cast[uint32](d.usage), d.size.uint32, d.mappedAtCreation)
else:
  proc wgpuDeviceCreateBuffer(device: DevicePtr, descriptor: ptr BufferDescriptor): BufferPtr {.w.}
  proc createBuffer*(device: Device, descriptor: BufferDescriptor): Buffer {.inline.} =
    wgpuDeviceCreateBuffer(device.p, addr descriptor).toShared

when defined(wasm):
  proc getQueue*(device: Device): Queue {.importwasmp: "queue".}
else:
  proc wgpuDeviceGetQueue(device: DevicePtr): QueuePtr {.w.}
  proc getQueue*(device: Device): Queue {.inline.} =
    wgpuDeviceGetQueue(device.p).toSharedRetain()

when defined(wasm):
  discard
else:
  proc wgpuDevicePopErrorScope(device: DevicePtr, callback: ErrorCallback, userdata: pointer) {.w.}
  proc wgpuDevicePushErrorScope(device: DevicePtr, filter: ErrorFilter) {.w.}

  type
    ErrorInfo* = object
      kind*: ErrorType
      message*: string

  proc onExitErrorScope(e: ErrorType, message: cstring, userdata: pointer) {.cdecl.} =
    let r = cast[Future[ErrorInfo]](userdata)
    GC_unref(r)
    r.complete(ErrorInfo(kind: e, message: $message))

  proc pushErrorScope*(d: Device, f: ErrorFilter) {.inline.} =
    wgpuDevicePushErrorScope(d.p, f)
  proc popErrorScope*(d: Device): Future[ErrorInfo] =
    result = newFuture(ErrorInfo)
    GC_ref(result)
    wgpuDevicePopErrorScope(d.p, onExitErrorScope, cast[pointer](result))

when defined(wasm):
  proc createCommandEncoder*(device: Device): CommandEncoder {.importwasmm.}
  proc createCommandEncoder*(device: Device, descriptor: CommandEncoderDescriptor): CommandEncoder {.inline.} =
    device.createCommandEncoder()

else:
  proc wgpuDeviceCreateCommandEncoder(device: DevicePtr, descriptor: ptr CommandEncoderDescriptor): CommandEncoderPtr {.w.}
  proc createCommandEncoder*(device: Device): CommandEncoder {.inline.} =
    wgpuDeviceCreateCommandEncoder(device.p, nil).toShared

  proc createCommandEncoder*(device: Device, descriptor: CommandEncoderDescriptor): CommandEncoder {.inline.} =
    wgpuDeviceCreateCommandEncoder(device.p, addr descriptor).toShared

when defined(wasm):
  proc createComputePipeline(device: Device, layout: PipelineLayout, shaderModule: ShaderModule, entryPoint: cstring): ComputePipeline {.importwasmp: """
createComputePipeline({layout: _nimo[$1], compute: { module: _nimo[$2], entryPoint: _nimsj($3) }})
""".}
  proc createComputePipeline*(device: Device, d: ComputePipelineDescriptor): ComputePipeline {.inline.} =
    createComputePipeline(device, d.layout, d.compute.module, d.compute.entryPoint)
else:
  proc wgpuDeviceCreateComputePipeline(device: DevicePtr, descriptor: ptr ComputePipelineDescriptor): ComputePipelinePtr {.w.}

  proc createComputePipeline*(device: Device, descriptor: ComputePipelineDescriptor): ComputePipeline {.inline.} =
    wgpuDeviceCreateComputePipeline(device.p, addr descriptor).toShared

when defined(wasm):
  proc createRenderPipeline(device: Device, layout: PipelineLayout, vsModule: ShaderModule, vsEntry: cstring, buffers, fsState: JSObj, topology: PrimitiveTopology, stripIndexFormat: IndexFormat, frontFace: FrontFace, cullMode: CullMode): RenderPipeline {.importwasmp: """
  createRenderPipeline({layout: _nimo[$1]||'auto', vertex: {module: _nimo[$2], entryPoint: _nimsj($3), buffers: _nimo[$4]}, fragment: _nimo[$5]||undefined, primitive: {topology: _nimwcp[$6], stripIndexFormat: _nimwci[$7], frontFace: _nimwcf[$8], cullMode: _nimwcc[$9]}})
  """.}

  proc makeFsState(m: ShaderModule, e: cstring, targets: JSObj): JSObj {.importwasmexpr: """
  {module: _nimo[$0], entryPoint: _nimsj($1), targets: _nimo[$2]}
  """}

  proc addTarget(t: JSObj, idx: int32, format: TextureFormat) {.importwasmraw: "_nimo[$0][$1] = {format: _nimwct[$2]}".}
  proc addBufferLayout(t: JSObj, idx: int32, arrayStride: uint32, attrs: JSObj, stepMode: VertexStepMode) {.importwasmraw: "_nimo[$0][$1] = {arrayStride: $2, attributes: _nimo[$3], stepMode: _nimwcs[$4]}".}
  proc addAttribute(t: JSObj, idx: int32, fmt, offset, shaderLoc: uint32) {.importwasmraw: "_nimo[$0][$1] = {format: _nimwcv[$2], offset: $3, shaderLocation: $4}".}

  proc createRenderPipeline*(device: Device, d: RenderPipelineDescriptor): RenderPipeline =
    var fsState: JSObj
    let f = d.fragment
    if not f.isNil:
      let targets = makeJsArray(f.targetCount)
      for i in 0 ..< f.targetCount.int:
        let tt = ptrArrayElem(f.targets, i)
        addTarget(targets, i.int32, tt.format)

      fsState = makeFsState(f.module, f.entryPoint, targets)
    let buffers = makeJsArray(d.vertex.bufferCount)
    for i in 0 ..< d.vertex.bufferCount.int:
      let tt = ptrArrayElem(d.vertex.buffers, i)
      let attributes = makeJsArray(tt.attributeCount)
      for j in 0 ..< tt.attributeCount.int:
        let aa = ptrArrayElem(tt.attributes, j)
        addAttribute(attributes, j.int32, aa.format.uint32, aa.offset.uint32, aa.shaderLocation)
      addBufferLayout(buffers, i.int32, tt.arrayStride.uint32, attributes, tt.stepMode)

    createRenderPipeline(device, d.layout, d.vertex.module, d.vertex.entryPoint, buffers, fsState, d.primitive.topology, d.primitive.stripIndexFormat, d.primitive.frontFace, d.primitive.cullMode)
else:
  proc wgpuDeviceCreateRenderPipeline(device: DevicePtr, descriptor: ptr RenderPipelineDescriptor): RenderPipelinePtr {.w.}

  proc createRenderPipeline*(device: Device, descriptor: RenderPipelineDescriptor): RenderPipeline {.inline.} =
    wgpuDeviceCreateRenderPipeline(device.p, addr descriptor).toShared

when defined(wasm):
  proc createTexture(device: Device, w, h, z, m, s: uint32, d: TextureDimension, f: TextureFormat, u: set[TextureUsage]): Texture {.importwasmp: """
createTexture({size: {width: $1, height: $2, depthOrArrayLayers: $3}, mipLevelCount: $4, sampleCount: $5, dimension: _nimwcd[$6], format: _nimwct[$7], usage: $8, viewFormats: []})
"""}
  proc createTexture*(device: Device, d: TextureDescriptor): Texture {.inline.} =
    device.createTexture(d.size.width, d.size.height, d.size.depthOrArrayLayers, d.mipLevelCount, d.sampleCount, d.dimension, d.format, d.usage)
else:
  proc wgpuDeviceCreateTexture(device: DevicePtr, descriptor: ptr TextureDescriptor): TexturePtr {.w.}
  proc createTexture*(device: Device, descriptor: TextureDescriptor): Texture {.inline.} =
    wgpuDeviceCreateTexture(device.p, addr descriptor).toShared

when defined(wasm):
  proc createSampler*(device: Device): Sampler {.importwasmm.}
  proc createSampler(device: Device, u, v, w: AddressMode, magf, minf: FilterMode, mf: MipmapFilterMode, lmin, lmax: float32, c: CompareFunction, a: uint32): Sampler {.importwasmp: """
  createSampler({addressModeU: _nimwca[$1], addressModeV: _nimwca[$2], addressModeW: _nimwca[$3], magFilter: _nimwcF[$4], minFilter: _nimwcF[$5], mipmapFilter: _nimwcF[$6], lodMinClamp: $7, lodMaxClamp: $8, compare: _nimwcC[$9], maxAnisotropy: $10})
"""}
  proc createSampler*(device: Device, d: SamplerDescriptor): Sampler {.inline.} =
    createSampler(device, d.addressModeU, d.addressModeV, d.addressModeW, d.magFilter, d.minFilter, d.mipmapFilter, d.lodMinClamp, d.lodMaxClamp, d.compare, d.maxAnisotropy)

else:
  proc wgpuDeviceCreateSampler(device: DevicePtr, descriptor: ptr SamplerDescriptor): SamplerPtr {.w.}

  proc createSampler*(device: Device, descriptor: SamplerDescriptor): Sampler {.inline.} =
    wgpuDeviceCreateSampler(device.p, addr descriptor).toShared

  proc createSampler*(device: Device): Sampler {.inline.} =
    wgpuDeviceCreateSampler(device.p, nil).toShared

when defined(wasm):
  proc createShaderModule*(device: Device, code: cstring): ShaderModule {.importwasmp: "createShaderModule({code:_nimsj($1)})".}
else:
  proc wgpuDeviceCreateShaderModule(device: DevicePtr, descriptor: ptr ShaderModuleDescriptor): ShaderModulePtr {.w.}
  proc createShaderModule*(device: Device, descriptor: ShaderModuleDescriptor): ShaderModule {.inline.} =
    wgpuDeviceCreateShaderModule(device.p, addr descriptor).toShared
  proc createShaderModule*(device: Device, code: cstring): ShaderModule {.inline.} =
    var shaderDesc: ShaderModuleDescriptor
    var shaderCodeDesc: ShaderModuleWGSLDescriptor
    shaderCodeDesc.sType = stShaderModuleWGSLDescriptor
    shaderCodeDesc.code = code
    shaderDesc.nextInChain = addr shaderCodeDesc
    createShaderModule(device, shaderDesc)

when defined(wasm):
  proc createPipelineLayout*(device: Device): PipelineLayout {.importwasmp: "createPipelineLayout({bindGroupLayouts:[]})".}
  proc createPipelineLayout(device: Device, entries: JSObj): PipelineLayout {.importwasmp: "createPipelineLayout({bindGroupLayouts:_nimo[$1]})".}
  proc addBindGroupLayout(t: JSObj, idx: int32, l: JSObj) {.importwasmraw: "_nimo[$0][$1] = _nimo[$2]".}
  proc createPipelineLayout*(device: Device, descriptor: PipelineLayoutDescriptor): PipelineLayout =
    let entries = makeJsArray(descriptor.bindGroupLayoutCount)
    for i in 0 ..< descriptor.bindGroupLayoutCount.int:
      let e = ptrArrayElem(descriptor.bindGroupLayouts, i)
      addBindGroupLayout(entries, i.int32, e[])
    createPipelineLayout(device, entries)
else:
  proc wgpuDeviceCreatePipelineLayout(device: DevicePtr, descriptor: ptr PipelineLayoutDescriptor): PipelineLayoutPtr {.w.}

  proc createPipelineLayout*(device: Device, descriptor: PipelineLayoutDescriptor): PipelineLayout {.inline.} =
    wgpuDeviceCreatePipelineLayout(device.p, addr descriptor).toShared
  proc createPipelineLayout*(device: Device): PipelineLayout {.inline.} =
    var d: PipelineLayoutDescriptor
    wgpuDeviceCreatePipelineLayout(device.p, addr d).toShared

# Procs of Queue
# # WGPU_EXPORT void wgpuQueueOnSubmittedWorkDone(WGPUQueue queue, WGPUQueueWorkDoneCallback callback, void * userdata);
# proc setLabel*(queue: QueuePtr, label: cstring) {.w, importc: "wgpuQueueSetLabel".}

when defined(wasm):
  proc submit(queue: Queue, n: int32, command: ptr CommandBuffer) {.importwasmraw: """
  _nimo[$0].submit([...new Uint32Array(_nime.memory.buffer, $2, $1 * 2)].flatMap((p,i) => i&1?[_nimo[p]]:[]))
  """.}
  proc submit*(queue: Queue, command: CommandBuffer) {.importwasmraw: """
  _nimo[$0].submit([_nimo[$1]])
  """.}
  proc submit*(queue: Queue, commands: openarray[CommandBuffer]) {.inline.} =
    submit(queue, commands.len.int32, cast[ptr CommandBuffer](addr commands))
else:
  proc wgpuQueueSubmit(queue: QueuePtr, commandCount: uint32, commands: ptr CommandBufferPtr) {.w.}
  proc submit*(queue: Queue, commandCount: int, commands: ptr CommandBuffer) {.inline.} =
    wgpuQueueSubmit(queue.p, commandCount.uint32, cast[ptr CommandBufferPtr](commands))
  proc submit*(queue: Queue, command: CommandBuffer) {.inline.} = submit(queue, 1, addr command)
  proc submit*(queue: Queue, commands: openarray[CommandBuffer]) {.inline.} = submit(queue, commands.len, cast[ptr CommandBuffer](addr commands))

when defined(wasm):
  proc writeBuffer*(queue: Queue, buffer: Buffer, bufferOffset: int, data: pointer, size: int) {.importwasmraw: """
  _nimo[$0].writeBuffer(_nimo[$1], $2, _nima, $3, $4)
  """.}
else:
  proc wgpuQueueWriteBuffer(queue: QueuePtr, buffer: BufferPtr, bufferOffset: uint64, data: pointer, size: csize_t) {.w.}
  proc writeBuffer*(queue: Queue, buffer: Buffer, bufferOffset: int, data: pointer, size: int) {.inline.} =
    wgpuQueueWriteBuffer(queue.p, buffer.p, bufferOffset.uint64, data, size.csize_t)

when defined(wasm):
  proc writeTexture(queue: Queue, t: Texture, p: pointer, s, o, bpr, rpi, w, h, z: uint32) {.importwasmraw: """
  _nimo[$0].writeTexture({texture: _nimo[$1]}, new Uint8Array(_nime.memory.buffer, $2, $3), {offset: $4, bytesPerRow: $5, rowsPerImage: $6}, {width: $7, height: $8, depthOrArrayLayers: $9})
  """.}

  proc writeTexture*(queue: Queue, destination: ImageCopyTexture, data: pointer, dataSize: int, dataLayout: TextureDataLayout, writeSize: Extent3D) {.inline.} =
    queue.writeTexture(destination.texture, data, dataSize.uint32, dataLayout.offset.uint32, dataLayout.bytesPerRow, dataLayout.rowsPerImage, writeSize.width, writeSize.height, writeSize.depthOrArrayLayers)
else:
  proc wgpuQueueWriteTexture(queue: Queue, destination: ptr ImageCopyTexture, data: pointer, dataSize: csize_t, dataLayout: ptr TextureDataLayout, writeSize: ptr Extent3D) {.w.}
  proc writeTexture*(queue: Queue, destination: ImageCopyTexture, data: pointer, dataSize: int, dataLayout: TextureDataLayout, writeSize: Extent3D) {.inline.} =
    wgpuQueueWriteTexture(queue, addr destination, data, dataSize.csize_t, addr dataLayout, addr writeSize)

# Procs of CommandEncoder
when defined(wasm):
  proc beginComputePass*(commandEncoder: CommandEncoder): ComputePassEncoder {.importwasmm.}
else:
  proc wgpuCommandEncoderBeginComputePass(commandEncoder: CommandEncoderPtr, descriptor: ptr ComputePassDescriptor): ComputePassEncoderPtr {.w.}
  proc beginComputePass*(commandEncoder: CommandEncoder, descriptor: ComputePassDescriptor): ComputePassEncoder {.inline.} =
    wgpuCommandEncoderBeginComputePass(commandEncoder.p, addr descriptor).toShared

  proc beginComputePass*(commandEncoder: CommandEncoder): ComputePassEncoder {.inline.} =
    wgpuCommandEncoderBeginComputePass(commandEncoder.p, nil).toShared

when defined(wasm):
  proc beginRenderPass(e: CommandEncoder, c: JSObj): RenderPassEncoder {.importwasmp: "beginRenderPass({colorAttachments: _nimo[$1]})".}

  proc addColorAttachment(a: JSObj, i: int32, tv: TextureView, cr, cg, cb, ca: float) {.importwasmraw: """
  _nimo[$0][$1] = {view: _nimo[$2], clearValue: {r: $3, g: $4, b: $5, a: $6}, loadOp: 'clear', storeOp: 'store'}
  """}
  proc beginRenderPass*(commandEncoder: CommandEncoder, d: RenderPassDescriptor): RenderPassEncoder =
    let colorAttachments = makeJsArray(d.colorAttachmentCount)
    let tt = cast[ptr UncheckedArray[RenderPassColorAttachment]](d.colorAttachments)
    for i in 0 ..< d.colorAttachmentCount.int:
      addColorAttachment(colorAttachments, i.int32, tt[i].view, tt[i].clearValue.r, tt[i].clearValue.g, tt[i].clearValue.b, tt[i].clearValue.a)
    beginRenderPass(commandEncoder, colorAttachments)
else:
  proc wgpuCommandEncoderBeginRenderPass(commandEncoder: CommandEncoderPtr, descriptor: ptr RenderPassDescriptor): RenderPassEncoderPtr {.w.}
  proc beginRenderPass*(commandEncoder: CommandEncoder, descriptor: RenderPassDescriptor): RenderPassEncoder {.inline.} =
    wgpuCommandEncoderBeginRenderPass(commandEncoder.p, addr descriptor).toShared

# # WGPU_EXPORT void wgpuCommandEncoderClearBuffer(WGPUCommandEncoder commandEncoder, WGPUBuffer buffer, uint64_t offset, uint64_t size);

when defined(wasm):
  proc copyBufferToBufferAux(commandEncoder: CommandEncoder, s: Buffer, os: uint32, d: Buffer, od, sz: uint32) {.importwasmm: "copyBufferToBuffer".}
  proc copyBufferToBuffer*(commandEncoder: CommandEncoder, s: Buffer, os: uint64, d: Buffer, od, sz: uint64) {.inline.} =
    copyBufferToBufferAux(commandEncoder, s, os.uint32, d, od.uint32, sz.uint32)
else:
  proc wgpuCommandEncoderCopyBufferToBuffer(commandEncoder: CommandEncoderPtr, s: BufferPtr, os: uint64, d: BufferPtr, od, sz: uint64) {.w.}
  proc copyBufferToBuffer*(commandEncoder: CommandEncoder, s: Buffer, os: uint64, d: Buffer, od, sz: uint64) {.inline.} =
    wgpuCommandEncoderCopyBufferToBuffer(commandEncoder.p, s.p, os, d.p, od, sz)

# WGPU_EXPORT void wgpuCommandEncoderCopyBufferToBuffer(WGPUCommandEncoder commandEncoder, WGPUBuffer source, uint64_t sourceOffset, WGPUBuffer destination, uint64_t destinationOffset, uint64_t size) WGPU_FUNCTION_ATTRIBUTE;
# # WGPU_EXPORT void wgpuCommandEncoderCopyBufferToTexture(WGPUCommandEncoder commandEncoder, WGPUImageCopyBuffer const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize);
# # WGPU_EXPORT void wgpuCommandEncoderCopyTextureToBuffer(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const * source, WGPUImageCopyBuffer const * destination, WGPUExtent3D const * copySize);
# # WGPU_EXPORT void wgpuCommandEncoderCopyTextureToTexture(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize);
when defined(wasm):
  proc finish*(commandEncoder: CommandEncoder): CommandBuffer {.importwasmm.}
else:
  proc wgpuCommandEncoderFinish(commandEncoder: CommandEncoderPtr, descriptor: ptr CommandBufferDescriptor): CommandBufferPtr {.w.}
  proc finish*(commandEncoder: CommandEncoder, descriptor: CommandBufferDescriptor): CommandBuffer {.inline.} =
    wgpuCommandEncoderFinish(commandEncoder.p, addr descriptor).toShared
  proc finish*(commandEncoder: CommandEncoder): CommandBuffer {.inline.} = wgpuCommandEncoderFinish(commandEncoder.p, nil).toShared

# proc insertDebugMarker*(commandEncoder: CommandEncoderPtr, markerLabel: cstring) {.w, importc: "wgpuCommandEncoderInsertDebugMarker".}
# # WGPU_EXPORT void wgpuCommandEncoderPopDebugGroup(WGPUCommandEncoder commandEncoder);
# # WGPU_EXPORT void wgpuCommandEncoderPushDebugGroup(WGPUCommandEncoder commandEncoder, char const * groupLabel);
# # WGPU_EXPORT void wgpuCommandEncoderResolveQuerySet(WGPUCommandEncoder commandEncoder, WGPUQuerySet querySet, uint32_t firstQuery, uint32_t queryCount, WGPUBuffer destination, uint64_t destinationOffset);
# # WGPU_EXPORT void wgpuCommandEncoderSetLabel(WGPUCommandEncoder commandEncoder, char const * label);
# # WGPU_EXPORT void wgpuCommandEncoderWriteTimestamp(WGPUCommandEncoder commandEncoder, WGPUQuerySet querySet, uint32_t queryIndex);

# Procs of ComputePassEncoder
# WGPU_EXPORT void wgpuComputePassEncoderBeginPipelineStatisticsQuery(WGPUComputePassEncoder computePassEncoder, WGPUQuerySet querySet, uint32_t queryIndex) WGPU_FUNCTION_ATTRIBUTE;
when defined(wasm):
  proc dispatchWorkgroups(e: ComputePassEncoder, cx, cy, cz: uint32) {.importwasmm.}
  proc dispatchWorkgroups*(e: ComputePassEncoder, cx: int, cy = 1, cz = 1) {.inline.} =
    dispatchWorkgroups(e, cx.uint32, cy.uint32, cz.uint32)
else:
  proc wgpuComputePassEncoderDispatchWorkgroups(e: ComputePassEncoderPtr, cx, cy, cz: uint32) {.w.}
  proc dispatchWorkgroups*(e: ComputePassEncoder, cx: int, cy = 1, cz = 1) {.inline.} =
    wgpuComputePassEncoderDispatchWorkgroups(e.p, cx.uint32, cy.uint32, cz.uint32)

# WGPU_EXPORT void wgpuComputePassEncoderDispatchWorkgroupsIndirect(WGPUComputePassEncoder computePassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset) WGPU_FUNCTION_ATTRIBUTE;
when defined(wasm):
  proc finish*(e: ComputePassEncoder) {.importwasmm: "end".}
else:
  proc wgpuComputePassEncoderEnd(e: ComputePassEncoderPtr) {.w.}

  proc finish*(e: sink[ComputePassEncoder]) {.inline.} =
    wgpuComputePassEncoderEnd(e.p)


# WGPU_EXPORT void wgpuComputePassEncoderEndPipelineStatisticsQuery(WGPUComputePassEncoder computePassEncoder) WGPU_FUNCTION_ATTRIBUTE;
# WGPU_EXPORT void wgpuComputePassEncoderInsertDebugMarker(WGPUComputePassEncoder computePassEncoder, char const * markerLabel) WGPU_FUNCTION_ATTRIBUTE;
# WGPU_EXPORT void wgpuComputePassEncoderPopDebugGroup(WGPUComputePassEncoder computePassEncoder) WGPU_FUNCTION_ATTRIBUTE;
# WGPU_EXPORT void wgpuComputePassEncoderPushDebugGroup(WGPUComputePassEncoder computePassEncoder, char const * groupLabel) WGPU_FUNCTION_ATTRIBUTE;
when defined(wasm):
  proc setBindGroup(e: ComputePassEncoder, groupIndex: uint32, group: BindGroup) {.importwasmm.}
  proc setBindGroup*(e: ComputePassEncoder, groupIdx: int, g: BindGroup) {.inline.} =
    e.setBindGroup(groupIdx.uint32, g)
else:
  proc wgpuComputePassEncoderSetBindGroup(e: ComputePassEncoderPtr, i: uint32, g: BindGroupPtr, c: uint32, o: ptr uint32) {.w.}
  proc setBindGroup*(e: ComputePassEncoder, groupIdx: int, g: BindGroup, dynamicOffsets: openarray[uint32]) {.inline.} =
    let sz = dynamicOffsets.len.uint32
    let o = if sz != 0: addr dynamicOffsets[0] else: nil
    wgpuComputePassEncoderSetBindGroup(e.p, groupIdx.uint32, g.p, sz, o)
  proc setBindGroup*(e: ComputePassEncoder, groupIdx: int, g: BindGroup) {.inline.} =
    wgpuComputePassEncoderSetBindGroup(e.p, groupIdx.uint32, g.p, 0, nil)

# WGPU_EXPORT void wgpuComputePassEncoderSetLabel(WGPUComputePassEncoder computePassEncoder, char const * label) WGPU_FUNCTION_ATTRIBUTE;
when defined(wasm):
  proc setPipeline*(e: ComputePassEncoder, p: ComputePipeline) {.importwasmm.}
else:
  proc wgpuComputePassEncoderSetPipeline(e: ComputePassEncoderPtr, p: ComputePipelinePtr) {.w.}
  proc setPipeline*(e: ComputePassEncoder, p: ComputePipeline) {.inline.} =
    wgpuComputePassEncoderSetPipeline(e.p, p.p)

# Procs of ComputePipeline
# WGPU_EXPORT WGPUBindGroupLayout wgpuComputePipelineGetBindGroupLayout(WGPUComputePipeline computePipeline, uint32_t groupIndex) WGPU_FUNCTION_ATTRIBUTE;
when defined(wasm):
  discard
else:
  proc wgpuComputePipelineGetBindGroupLayout(p: ComputePipelinePtr, i: uint32): BindGroupLayoutPtr {.w.}
  proc getBindGroupLayout*(e: ComputePipeline, i: uint32): BindGroupLayout {.inline.} =
    wgpuComputePipelineGetBindGroupLayout(e.p, i).toSharedRetain()

# WGPU_EXPORT void wgpuComputePipelineSetLabel(WGPUComputePipeline computePipeline, char const * label) WGPU_FUNCTION_ATTRIBUTE;

# # Procs of Surface
when defined(wasm):
  discard
else:

  proc wgpuSurfaceConfigure(surface: SurfacePtr, config: ptr SurfaceConfiguration) {.w.}
  proc configure*(surface: Surface, config: SurfaceConfiguration) {.inline.} =
    wgpuSurfaceConfigure(surface.p, addr config)

  proc wgpuSurfaceGetCapabilities(surface: SurfacePtr, adapter: AdapterPtr, capabilities: ptr SurfaceCapabilities) {.w.}
  proc getCapabilities*(surface: Surface, adapter: Adapter, capabilities: var SurfaceCapabilities) {.inline.} =
    wgpuSurfaceGetCapabilities(surface.p, adapter.p, addr capabilities)

  proc wgpuSurfaceGetCurrentTexture(surface: SurfacePtr, surfaceTexture: ptr SurfaceTexture) {.w.}
  proc getCurrentTexture*(surface: Surface, texture: var SurfaceTexture) {.inline.} =
    wgpuSurfaceGetCurrentTexture(surface.p, addr texture)

  proc wgpuSurfacePresent(s: SurfacePtr) {.w.}
  proc present*(s: Surface) {.inline.} =
    wgpuSurfacePresent(s.p)

# Procs of Texture
when defined(wasm):
  proc createView*(t: Texture): TextureView {.importwasmm.}
else:
  proc wgpuTextureCreateView(texture: TexturePtr, descriptor: ptr TextureViewDescriptor): TextureViewPtr {.w.}
  proc createView*(texture: Texture, descriptor: TextureViewDescriptor): TextureView {.inline.} =
    wgpuTextureCreateView(texture.p, addr descriptor).toShared
  proc createView*(texture: Texture): TextureView {.inline.} =
    wgpuTextureCreateView(texture.p, nil).toShared

when defined(wasm):
  discard
else:
  proc depthOrArrayLayers*(texture: Texture): uint32 {.w, importc: "wgpuTextureGetDepthOrArrayLayers".}
  proc dimension*(texture: Texture): TextureDimension  {.w, importc: "wgpuTextureGetDimension".}
  proc format*(texture: Texture): TextureFormat  {.w, importc: "wgpuTextureGetFormat".}
  proc height*(texture: Texture): uint32 {.w, importc: "wgpuTextureGetHeight".}
  proc width*(texture: Texture): uint32 {.w, importc: "wgpuTextureGetWidth".}


# # Procs of RenderPassEncoder
# # WGPU_EXPORT void wgpuRenderPassEncoderBeginOcclusionQuery(WGPURenderPassEncoder renderPassEncoder, uint32_t queryIndex);
# # WGPU_EXPORT void wgpuRenderPassEncoderBeginPipelineStatisticsQuery(WGPURenderPassEncoder renderPassEncoder, WGPUQuerySet querySet, uint32_t queryIndex);
when defined(wasm):
  proc draw*(renderPassEncoder: RenderPassEncoder, vertexCount, instanceCount, firstVertex, firstInstance: uint32) {.importwasmm.}
else:
  proc wgpuRenderPassEncoderDraw(renderPassEncoder: RenderPassEncoderPtr, vertexCount, instanceCount, firstVertex, firstInstance: uint32) {.w.}
  proc draw*(renderPassEncoder: RenderPassEncoder, vertexCount, instanceCount, firstVertex, firstInstance: uint32) {.inline.} =
    wgpuRenderPassEncoderDraw(renderPassEncoder.p, vertexCount, instanceCount, firstVertex, firstInstance)


# # WGPU_EXPORT void wgpuRenderPassEncoderDrawIndexed(WGPURenderPassEncoder renderPassEncoder, uint32_t indexCount, uint32_t instanceCount, uint32_t firstIndex, int32_t baseVertex, uint32_t firstInstance);
# # WGPU_EXPORT void wgpuRenderPassEncoderDrawIndexedIndirect(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
# # WGPU_EXPORT void wgpuRenderPassEncoderDrawIndirect(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
when defined(wasm):
  proc finish*(renderPassEncoder: RenderPassEncoder) {.importwasmm: "end".}
else:
  proc wgpuRenderPassEncoderEnd(renderPassEncoder: RenderPassEncoderPtr) {.w.}
  proc finish*(renderPassEncoder: sink[RenderPassEncoder]) {.inline.} = wgpuRenderPassEncoderEnd(renderPassEncoder.p)

# # WGPU_EXPORT void wgpuRenderPassEncoderEndOcclusionQuery(WGPURenderPassEncoder renderPassEncoder);
# # WGPU_EXPORT void wgpuRenderPassEncoderEndPipelineStatisticsQuery(WGPURenderPassEncoder renderPassEncoder);
# # WGPU_EXPORT void wgpuRenderPassEncoderExecuteBundles(WGPURenderPassEncoder renderPassEncoder, uint32_t bundlesCount, WGPURenderBundle const * bundles);
# # WGPU_EXPORT void wgpuRenderPassEncoderInsertDebugMarker(WGPURenderPassEncoder renderPassEncoder, char const * markerLabel);
# # WGPU_EXPORT void wgpuRenderPassEncoderPopDebugGroup(WGPURenderPassEncoder renderPassEncoder);
# # WGPU_EXPORT void wgpuRenderPassEncoderPushDebugGroup(WGPURenderPassEncoder renderPassEncoder, char const * groupLabel);

when defined(wasm):
  proc setBindGroup*(renderPassEncoder: RenderPassEncoder, groupIndex: uint32, group: BindGroup) {.importwasmm.}

  proc setBindGroup(renderPassEncoder: RenderPassEncoder, groupIndex, offsets, count: uint32, group: BindGroup) {.importwasmraw: """
_nimo[$0].setBindGroup($1, _nimo[$4], new Uint32Array(_nima, $2, $3))
""".}

  discard
else:
  proc wgpuRenderPassEncoderSetBindGroup(renderPassEncoder: RenderPassEncoderPtr, groupIndex: uint32, group: BindGroupPtr, dynamicOffsetCount: uint32, dynamicOffsets: ptr uint32) {.w.}
  proc setBindGroup*(renderPassEncoder: RenderPassEncoder, groupIndex: uint32, group: BindGroup, dynamicOffsets: openarray[uint32]) {.inline.} =
    wgpuRenderPassEncoderSetBindGroup(renderPassEncoder.p, groupIndex, group.p, dynamicOffsets.len.uint32, cast[ptr uint32](addr dynamicOffsets))
  proc setBindGroup*(renderPassEncoder: RenderPassEncoder, groupIndex: uint32, group: BindGroup) {.inline.} =
    wgpuRenderPassEncoderSetBindGroup(renderPassEncoder.p, groupIndex, group.p, 0, nil)

# # WGPU_EXPORT void wgpuRenderPassEncoderSetBlendConstant(WGPURenderPassEncoder renderPassEncoder, WGPUColor const * color);
# # WGPU_EXPORT void wgpuRenderPassEncoderSetIndexBuffer(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer buffer, WGPUIndexFormat format, uint64_t offset, uint64_t size);
# WGPU_EXPORT void wgpuRenderPassEncoderSetLabel(WGPURenderPassEncoder renderPassEncoder, char const * label);
when defined(wasm):
  proc setPipeline*(renderPassEncoder: RenderPassEncoder, pipeline: RenderPipeline) {.importwasmm.}
else:
  proc setPipeline*(renderPassEncoder: RenderPassEncoder, pipeline: RenderPipeline) {.w, importc: "wgpuRenderPassEncoderSetPipeline".}

# # WGPU_EXPORT void wgpuRenderPassEncoderSetScissorRect(WGPURenderPassEncoder renderPassEncoder, uint32_t x, uint32_t y, uint32_t width, uint32_t height);
# # WGPU_EXPORT void wgpuRenderPassEncoderSetStencilReference(WGPURenderPassEncoder renderPassEncoder, uint32_t reference);
when defined(wasm):
  proc setVertexBuffer(renderPassEncoder: RenderPassEncoder, slot: uint32, buffer: Buffer, offset, size: uint32) {.importwasmm.}
  proc setVertexBuffer*(renderPassEncoder: RenderPassEncoder, slot: uint32, buffer: Buffer, offset, size: uint64) {.inline.} =
    renderPassEncoder.setVertexBuffer(slot, buffer, offset.uint32, size.uint32)

else:
  proc wgpuRenderPassEncoderSetVertexBuffer(renderPassEncoder: RenderPassEncoderPtr, slot: uint32, buffer: BufferPtr, offset, size: uint64) {.w.}

  proc setVertexBuffer*(renderPassEncoder: RenderPassEncoder, slot: uint32, buffer: Buffer, offset, size: uint64) {.inline.} =
    wgpuRenderPassEncoderSetVertexBuffer(renderPassEncoder.p, slot, buffer.p, offset, size)

proc setVertexBuffer*(renderPassEncoder: RenderPassEncoder, slot: uint32, buffer: Buffer, offset: uint64 = 0) {.inline.} =
  renderPassEncoder.setVertexBuffer(slot, buffer, offset, buffer.size - offset)

when defined(wasm):
  discard
else:
  proc wgpuRenderPassEncoderSetViewport(renderPassEncoder: RenderPassEncoderPtr, x, y, width, height, minDepth, maxDepth: float32) {.w.}
  proc setViewport*(renderPassEncoder: RenderPassEncoder, x, y, width, height, minDepth, maxDepth: float32) {.inline.} =
    wgpuRenderPassEncoderSetViewport(renderPassEncoder.p, x, y, width, height, minDepth, maxDepth)

# Procs of RenderPipeline
when defined(wasm):
  proc getBindGroupLayout*(renderPipeline: RenderPipeline, groupIndex: uint32): BindGroupLayout {.importwasmm.}
else:
  proc getBindGroupLayout*(renderPipeline: RenderPipeline, groupIndex: uint32): BindGroupLayout {.w, importc: "wgpuRenderPipelineGetBindGroupLayout".}

# WGPU_EXPORT void wgpuRenderPipelineSetLabel(WGPURenderPipeline renderPipeline, char const * label);
