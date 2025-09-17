import yasync
when defined(wasm):
  import wasmrt
  export wasmrt.isNil

const
  ARRAY_LAYER_COUNT_UNDEFINED* = uint32.high
  COPY_STRIDE_UNDEFINED* = uint32.high
  DEPTH_SLICE_UNDEFINED* = uint32.high
  LIMIT_U32_UNDEFINED* = uint32.high
  LIMIT_U64_UNDEFINED* = uint64.high
  MIP_LEVEL_COUNT_UNDEFINED* = uint32.high
  QUERY_SET_INDEX_UNDEFINED* = uint32.high
  WHOLE_SIZE* = uint64.high

template defineTyp(t: untyped) =
  when defined(wasm):
    type t* = object of JSObj

    proc `==`*(o: t, n: typeof(nil)): bool {.inline.} = o.o.isNil

  else:
    type
      `t Ptr` = ptr object
      t* = object
        p*: `t Ptr`

    proc `wgpu t AddRef`(v: `t Ptr`) {.w.}
    proc `wgpu t Release`(v: `t Ptr`) {.w.}

    proc isNil*(v: t): bool {.inline.} = v.p.isNil
    proc `=destroy`*(v: t) =
      if not v.p.isNil:
        # when astToStr(t) == "Buffer":
        #   echo "RELEASE ", astToStr(t), ": ", cast[int](v.p)
        `wgpu t Release`(v.p)
    proc `=copy`*(dst: var t, src: t) =
      if dst.p != src.p:
        if not src.p.isNil:
          # when astToStr(t) == "Buffer":
          #   echo "COPY REF ", astToStr(t), ": ", cast[int](src.p)
          `wgpu t AddRef`(src.p)
        if not dst.p.isNil:
          # echo "COPY REL ", astToStr(t)
          `wgpu t Release`(dst.p)
        dst.p = src.p
    proc `==`*(v: t, n: typeof(nil)): bool {.inline.} = v.p.isNil
    proc toShared*(v: `t Ptr`): t = t(p: v)
    proc toSharedRetain*(v: `t Ptr`): t =
      `wgpu t AddRef`(v)
      t(p: v)

when defined(wasm):
  proc init() {.importwasmraw: """
 // AddressMode
window._nimwca = [,'repeat','mirror-repeat','clamp-to-edge'];
 // BufferBindingType
window._nimwcb = [,,'uniform','storage','read-only-storage'];
 // TextureFormat
window._nimwct = [,..."r8unorm r8snorm r8uint r8sint r16uint r16sint r16float rg8unorm rg8snorm rg8uint rg8sint r32uint r32sint r32float rg16uint rg16sint rg16float rgba8unorm rgba8unorm-srgb rgba8snorm rgba8uint rgba8sint bgra8unorm bgra8unorm-srgb rgb9e5ufloat rgb10a2unorm rg11b10ufloat rg32uint rg32sint rg32float rgba16uint rgba16sint rgba16float rgba32uint rgba32sint rgba32float stencil8 depth16unorm depth24plus depth24plus-stencil8 depth32float depth32float-stencil8 bc1-rgba-unorm bc1-rgba-unorm-srgb bc2-rgba-unorm bc2-rgba-unorm-srgb bc3-rgba-unorm bc3-rgba-unorm-srgb bc4-r-unorm bc4-r-snorm bc5-rg-unorm bc5-rg-snorm bc6h-rgb-ufloat bc6h-rgb-float bc7-rgba-unorm bc7-rgba-unorm-srgb etc2-rgb8unorm etc2-rgb8unorm-srgb etc2-rgb8a1unorm etc2-rgb8a1unorm-srgb etc2-rgba8unorm etc2-rgba8unorm-srgb eac-r11unorm eac-r11snorm eac-rg11unorm eac-rg11snorm astc-4x4-unorm astc-4x4-unorm-srgb astc-5x4-unorm astc-5x4-unorm-srgb astc-5x5-unorm astc-5x5-unorm-srgb astc-6x5-unorm astc-6x5-unorm-srgb astc-6x6-unorm astc-6x6-unorm-srgb astc-8x5-unorm astc-8x5-unorm-srgb astc-8x6-unorm astc-8x6-unorm-srgb astc-8x8-unorm astc-8x8-unorm-srgb astc-10x5-unorm astc-10x5-unorm-srgb astc-10x6-unorm astc-10x6-unorm-srgb astc-10x8-unorm astc-10x8-unorm-srgb astc-10x10-unorm astc-10x10-unorm-srgb astc-12x10-unorm astc-12x10-unorm-srgb astc-12x12-unorm astc-12x12-unorm-srgb".split(' ')];
 // VertexFormat
window._nimwcv = [,..."uint8 uint8x2 uint8x4 sint8 sint8x2 sint8x4 unorm8 unorm8x2 unorm8x4 snorm8 snorm8x2 snorm8x4 uint16 uint16x2 uint16x4 sint16 sint16x2 sint16x4 unorm16 unorm16x2 unorm16x4 snorm16 snorm16x2 snorm16x4 float16 float16x2 float16x4 float32 float32x2 float32x3 float32x4 uint32 uint32x2 uint32x3 uint32x4 sint32 sint32x2 sint32x3 sint32x4 unorm10-10-10-2 unorm8x4-bgra".split(' ')];
 // PrimitiveTopology
window._nimwcp = [,"point-list","line-list","line-strip","triangle-list","triangle-strip"];
 // FrontFace
window._nimwcf = [,"ccw","cw"];
 // CullMode
window._nimwcc = [,"none","front","back"];
 // IndexFormat
window._nimwci = [,"uint16","uint32"];
 // FilterMode and MipmapFilterMode
window._nimwcF = [,"nearest","linear"];
 // CompareFunction
window._nimwcC = [,"never","less","less-equal","greater","greater-equal","equal","not-equal","always"];
 // VertexStepMode
window._nimwcs = [,,"vertex","instance"];
 // TextureDimension
window._nimwcd = [,"1d","2d","3d"];
 // TextureViewDimension
window._nimwcD = [,"1d","2d","2d-array","cube","cube-array","3d"];
 // TextureSampleType
window._nimwcS = [,,"float","unfilterable-float","depth","sint","uint"];
 // BufferMapState reversed
window._nimwms = {unmapped: 1, pending: 2, mapped: 3};
 // BlendFactor
window._nimwbf = [, "zero", "one", "src", "one-minus-src", "src-alpha", "one-minus-src-alpha", "dst", "one-minus-dst", "dst-alpha", "one-minus-dst-alpha", "src-alpha-saturated", "constant", "one-minus-constant", "src1", "one-minus-src1", "src1-alpha", "one-minus-src1-alpha"];
 // BlendOperation
window._nimwbo = [, "add", "subtract", "reverse-subtract", "min", "max"];

// The following function f takes array and returns dict of elements mapped to indexes
f = a=>(o={},a.forEach((v,i)=>o[v]=i),o);
window._nimwcT = f(_nimwct)
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
defineTyp(Texture)
defineTyp(TextureView)

type
  Bool* = uint32

  StringView* = object
    data*: cstring
    length*: csize_t

  AdapterType* {.size: sizeof(cint).} = enum
    atDiscreteGPU = 0x00000001
    atIntegratedGPU = 0x00000002
    atCPU = 0x00000003
    atUnknown = 0x00000004

  AddressMode* {.size: sizeof(cint).} = enum
    amUndefined = 0x00000000
    amClampToEdge = 0x00000001
    amRepeat = 0x00000002
    amMirrorRepeat = 0x00000003

  BackendType* {.size: sizeof(cint).} = enum
    btUndefined = 0x00000000
    btNull = 0x00000001
    btWebGPU = 0x00000002
    btD3D11 = 0x00000003
    btD3D12 = 0x00000004
    btMetal = 0x00000005
    btVulkan = 0x00000006
    btOpenGL = 0x00000007
    btOpenGLES = 0x00000008

  BlendFactor* {.size: sizeof(cint).} = enum
    bfUndefined = 0x00000000
    bfZero = 0x00000001
    bfOne = 0x00000002
    bfSrc = 0x00000003
    bfOneMinusSrc = 0x00000004
    bfSrcAlpha = 0x00000005
    bfOneMinusSrcAlpha = 0x00000006
    bfDst = 0x00000007
    bfOneMinusDst = 0x00000008
    bfDstAlpha = 0x00000009
    bfOneMinusDstAlpha = 0x0000000A
    bfSrcAlphaSaturated = 0x0000000B
    bfConstant = 0x0000000C
    bfOneMinusConstant = 0x0000000D
    bfSrc1 = 0x0000000E
    bfOneMinusSrc1 = 0x0000000F
    bfSrc1Alpha = 0x00000010
    bfOneMinusSrc1Alpha = 0x00000011

  BlendOperation* {.size: sizeof(cint).} = enum
    boUndefined = 0x00000000
    boAdd = 0x00000001
    boSubtract = 0x00000002
    boReverseSubtract = 0x00000003
    boMin = 0x00000004
    boMax = 0x00000005

  BufferBindingType* {.size: sizeof(cint).} = enum
    bbtBindingNotUsed = 0x00000000
    bbtUndefined = 0x00000001
    bbtUniform = 0x00000002
    bbtStorage = 0x00000003
    bbtReadOnlyStorage = 0x00000004

  BufferMapState* {.size: sizeof(cint).} = enum
    bmsUnmapped = 0x00000001
    bmsPending = 0x00000002
    bmsMapped = 0x00000003

  CallbackMode* {.size: sizeof(cint).} = enum
    cmWaitAnyOnly = 0x00000001
    cmAllowProcessEvents = 0x00000002
    cmAllowSpontaneous = 0x00000003

  CompareFunction* {.size: sizeof(cint).} = enum
    cfUndefined = 0x00000000
    cfNever = 0x00000001
    cfLess = 0x00000002
    cfEqual = 0x00000003
    cfLessEqual = 0x00000004
    cfGreater = 0x00000005
    cfNotEqual = 0x00000006
    cfGreaterEqual = 0x00000007
    cfAlways = 0x00000008

  CompilationInfoRequestStatus* {.size: sizeof(cint).} = enum
    cirsSuccess = 0x00000001
    cirsInstanceDropped = 0x00000002
    cirsError = 0x00000003
    cirsUnknown = 0x00000004

  CompilationMessageType* {.size: sizeof(cint).} = enum
    cmtError = 0x00000001
    cmtWarning = 0x00000002
    cmtInfo = 0x00000003

  CompositeAlphaMode* {.size: sizeof(cint).} = enum
    camAuto = 0x00000000
    camOpaque = 0x00000001
    camPremultiplied = 0x00000002
    camUnpremultiplied = 0x00000003
    camInherit = 0x00000004

  CreatePipelineAsyncStatus* {.size: sizeof(cint).} = enum
    cpasSuccess = 0x00000001
    cpasInstanceDropped = 0x00000002
    cpasValidationError = 0x00000003
    cpasInternalError = 0x00000004
    cpasUnknown = 0x00000005

  CullMode* {.size: sizeof(cint).} = enum
    cmUndefined = 0x00000000
    cmNone = 0x00000001
    cmFront = 0x00000002
    cmBack = 0x00000003

  DeviceLostReason* {.size: sizeof(cint).} = enum
    dlrUnknown = 0x00000001
    dlrDestroyed = 0x00000002
    dlrInstanceDropped = 0x00000003
    dlrFailedCreation = 0x00000004

  ErrorFilter* {.size: sizeof(cint).} = enum
    efValidation = 0x00000001
    efOutOfMemory = 0x00000002
    efInternal = 0x00000003

  ErrorType* {.size: sizeof(cint).} = enum
    etNoError = 0x00000001
    etValidation = 0x00000002
    etOutOfMemory = 0x00000003
    etInternal = 0x00000004
    etUnknown = 0x00000005

  FeatureLevel* {.size: sizeof(cint).} = enum
    flCompatibility = 0x00000001
    flCore = 0x00000002

  FeatureName* {.size: sizeof(cint).} = enum
    fnUndefined = 0x00000000
    fnDepthClipControl = 0x00000001
    fnDepth32FloatStencil8 = 0x00000002
    fnTimestampQuery = 0x00000003
    fnTextureCompressionBC = 0x00000004
    fnTextureCompressionBCSliced3D = 0x00000005
    fnTextureCompressionETC2 = 0x00000006
    fnTextureCompressionASTC = 0x00000007
    fnTextureCompressionASTCSliced3D = 0x00000008
    fnIndirectFirstInstance = 0x00000009
    fnShaderF16 = 0x0000000A
    fnRG11B10UfloatRenderable = 0x0000000B
    fnBGRA8UnormStorage = 0x0000000C
    fnFloat32Filterable = 0x0000000D
    fnFloat32Blendable = 0x0000000E
    fnClipDistances = 0x0000000F
    fnDualSourceBlending = 0x00000010

  FilterMode* {.size: sizeof(cint).} = enum
    fmUndefined = 0x00000000
    fmNearest = 0x00000001
    fmLinear = 0x00000002

  FrontFace* {.size: sizeof(cint).} = enum
    ffUndefined = 0x00000000
    ffCCW = 0x00000001
    ffCW = 0x00000002

  IndexFormat* {.size: sizeof(cint).} = enum
    ifUndefined = 0x00000000
    ifUint16 = 0x00000001
    ifUint32 = 0x00000002

  InputStepMode* {.size: sizeof(cint).} = enum
    ismUndefined = 0x00000000
    ismVertex = 0x00000001
    ismInstance = 0x00000002

  LoadOp* {.size: sizeof(cint).} = enum
    loUndefined = 0x00000000
    loLoad = 0x00000001
    loClear = 0x00000002

  MapAsyncStatus* {.size: sizeof(cint).} = enum
    masSuccess = 0x00000001
    masInstanceDropped = 0x00000002
    masError = 0x00000003
    masAborted = 0x00000004
    masUnknown = 0x00000005

  MipmapFilterMode* {.size: sizeof(cint).} = enum
    mfmUndefined = 0x00000000
    mfmNearest = 0x00000001
    mfmLinear = 0x00000002

  OptionalBool* {.size: sizeof(cint).} = enum
    obFalse = 0x00000000
    obTrue = 0x00000001
    obUndefined = 0x00000002

  PopErrorScopeStatus* {.size: sizeof(cint).} = enum
    pessSuccess = 0x00000001
    pessInstanceDropped = 0x00000002
    pessEmptyStack = 0x00000003

  PowerPreference* {.size: sizeof(cint).} = enum
    ppUndefined = 0x00000000
    ppLowPower = 0x00000001
    ppHighPerformance = 0x00000002

  PresentMode* {.size: sizeof(cint).} = enum
    pmUndefined = 0x00000000
    pmFifo = 0x00000001
    pmFifoRelaxed = 0x00000002
    pmImmediate = 0x00000003
    pmMailbox = 0x00000004

  PrimitiveTopology* {.size: sizeof(cint).} = enum
    ptUndefined = 0x00000000
    ptPointList = 0x00000001
    ptLineList = 0x00000002
    ptLineStrip = 0x00000003
    ptTriangleList = 0x00000004
    ptTriangleStrip = 0x00000005

  QueryType* {.size: sizeof(cint).} = enum
    qtOcclusion = 0x00000001
    qtTimestamp = 0x00000002

  QueueWorkDoneStatus* {.size: sizeof(cint).} = enum
    qwdsSuccess = 0x00000001
    qwdsInstanceDropped = 0x00000002
    qwdsError = 0x00000003
    qwdsUnknown = 0x00000004

  RequestAdapterStatus* {.size: sizeof(cint).} = enum
    rasSuccess = 0x00000001
    rasInstanceDropped = 0x00000002
    rasUnavailable = 0x00000003
    rasError = 0x00000004
    rasUnknown = 0x00000005

  RequestDeviceStatus* {.size: sizeof(cint).} = enum
    rdsSuccess = 0x00000001
    rdsInstanceDropped = 0x00000002
    rdsError = 0x00000003
    rdsUnknown = 0x00000004

  SType* {.size: sizeof(cint).} = enum
    stShaderSourceSPIRV = 0x00000001
    stShaderSourceWGSL = 0x00000002
    stRenderPassMaxDrawCount = 0x00000003
    stSurfaceSourceMetalLayer = 0x00000004
    stSurfaceSourceWindowsHWND = 0x00000005
    stSurfaceSourceXlibWindow = 0x00000006
    stSurfaceSourceWaylandSurface = 0x00000007
    stSurfaceSourceAndroidNativeWindow = 0x00000008
    stSurfaceSourceXCBWindow = 0x00000009

  SamplerBindingType* {.size: sizeof(cint).} = enum
    sbtBindingNotUsed = 0x00000000
    sbtUndefined = 0x00000001
    sbtFiltering = 0x00000002
    sbtNonFiltering = 0x00000003
    sbtComparison = 0x00000004

  Status* {.size: sizeof(cint).} = enum
    sSuccess = 0x00000001
    sError = 0x00000002

  StencilOperation* {.size: sizeof(cint).} = enum
    soUndefined = 0x00000000
    soKeep = 0x00000001
    soZero = 0x00000002
    soReplace = 0x00000003
    soInvert = 0x00000004
    soIncrementClamp = 0x00000005
    soDecrementClamp = 0x00000006
    soIncrementWrap = 0x00000007
    soDecrementWrap = 0x00000008

  StorageTextureAccess* {.size: sizeof(cint).} = enum
    staBindingNotUsed = 0x00000000
    staUndefined = 0x00000001
    staWriteOnly = 0x00000002
    staReadOnly = 0x00000003
    staReadWrite = 0x00000004

  StoreOp* {.size: sizeof(cint).} = enum
    soUndefined = 0x00000000
    soStore = 0x00000001
    soDiscard = 0x00000002

  SurfaceGetCurrentTextureStatus* {.size: sizeof(cint).} = enum
    gctsSuccessOptimal = 0x00000001
    gctsSuccessSuboptimal = 0x00000002
    gctsTimeout = 0x00000003
    gctsOutdated = 0x00000004
    gctsLost = 0x00000005
    gctsOutOfMemory = 0x00000006
    gctsDeviceLost = 0x00000007
    gctsError = 0x00000008

  TextureAspect* {.size: sizeof(cint).} = enum
    taUndefined = 0x00000000
    taAll = 0x00000001
    taStencilOnly = 0x00000002
    taDepthOnly = 0x00000003

  TextureDimension* {.size: sizeof(cint).} = enum
    tdUndefined = 0x00000000
    td1D = 0x00000001
    td2D = 0x00000002
    td3D = 0x00000003

  TextureFormat* {.size: sizeof(cint).} = enum
    tfUndefined = 0x00000000
    tfR8Unorm = 0x00000001
    tfR8Snorm = 0x00000002
    tfR8Uint = 0x00000003
    tfR8Sint = 0x00000004
    tfR16Uint = 0x00000005
    tfR16Sint = 0x00000006
    tfR16Float = 0x00000007
    tfRG8Unorm = 0x00000008
    tfRG8Snorm = 0x00000009
    tfRG8Uint = 0x0000000A
    tfRG8Sint = 0x0000000B
    tfR32Float = 0x0000000C
    tfR32Uint = 0x0000000D
    tfR32Sint = 0x0000000E
    tfRG16Uint = 0x0000000F
    tfRG16Sint = 0x00000010
    tfRG16Float = 0x00000011
    tfRGBA8Unorm = 0x00000012
    tfRGBA8UnormSrgb = 0x00000013
    tfRGBA8Snorm = 0x00000014
    tfRGBA8Uint = 0x00000015
    tfRGBA8Sint = 0x00000016
    tfBGRA8Unorm = 0x00000017
    tfBGRA8UnormSrgb = 0x00000018
    tfRGB10A2Uint = 0x00000019
    tfRGB10A2Unorm = 0x0000001A
    tfRG11B10Ufloat = 0x0000001B
    tfRGB9E5Ufloat = 0x0000001C
    tfRG32Float = 0x0000001D
    tfRG32Uint = 0x0000001E
    tfRG32Sint = 0x0000001F
    tfRGBA16Uint = 0x00000020
    tfRGBA16Sint = 0x00000021
    tfRGBA16Float = 0x00000022
    tfRGBA32Float = 0x00000023
    tfRGBA32Uint = 0x00000024
    tfRGBA32Sint = 0x00000025
    tfStencil8 = 0x00000026
    tfDepth16Unorm = 0x00000027
    tfDepth24Plus = 0x00000028
    tfDepth24PlusStencil8 = 0x00000029
    tfDepth32Float = 0x0000002A
    tfDepth32FloatStencil8 = 0x0000002B
    tfBC1RGBAUnorm = 0x0000002C
    tfBC1RGBAUnormSrgb = 0x0000002D
    tfBC2RGBAUnorm = 0x0000002E
    tfBC2RGBAUnormSrgb = 0x0000002F
    tfBC3RGBAUnorm = 0x00000030
    tfBC3RGBAUnormSrgb = 0x00000031
    tfBC4RUnorm = 0x00000032
    tfBC4RSnorm = 0x00000033
    tfBC5RGUnorm = 0x00000034
    tfBC5RGSnorm = 0x00000035
    tfBC6HRGBUfloat = 0x00000036
    tfBC6HRGBFloat = 0x00000037
    tfBC7RGBAUnorm = 0x00000038
    tfBC7RGBAUnormSrgb = 0x00000039
    tfETC2RGB8Unorm = 0x0000003A
    tfETC2RGB8UnormSrgb = 0x0000003B
    tfETC2RGB8A1Unorm = 0x0000003C
    tfETC2RGB8A1UnormSrgb = 0x0000003D
    tfETC2RGBA8Unorm = 0x0000003E
    tfETC2RGBA8UnormSrgb = 0x0000003F
    tfEACR11Unorm = 0x00000040
    tfEACR11Snorm = 0x00000041
    tfEACRG11Unorm = 0x00000042
    tfEACRG11Snorm = 0x00000043
    tfASTC4x4Unorm = 0x00000044
    tfASTC4x4UnormSrgb = 0x00000045
    tfASTC5x4Unorm = 0x00000046
    tfASTC5x4UnormSrgb = 0x00000047
    tfASTC5x5Unorm = 0x00000048
    tfASTC5x5UnormSrgb = 0x00000049
    tfASTC6x5Unorm = 0x0000004A
    tfASTC6x5UnormSrgb = 0x0000004B
    tfASTC6x6Unorm = 0x0000004C
    tfASTC6x6UnormSrgb = 0x0000004D
    tfASTC8x5Unorm = 0x0000004E
    tfASTC8x5UnormSrgb = 0x0000004F
    tfASTC8x6Unorm = 0x00000050
    tfASTC8x6UnormSrgb = 0x00000051
    tfASTC8x8Unorm = 0x00000052
    tfASTC8x8UnormSrgb = 0x00000053
    tfASTC10x5Unorm = 0x00000054
    tfASTC10x5UnormSrgb = 0x00000055
    tfASTC10x6Unorm = 0x00000056
    tfASTC10x6UnormSrgb = 0x00000057
    tfASTC10x8Unorm = 0x00000058
    tfASTC10x8UnormSrgb = 0x00000059
    tfASTC10x10Unorm = 0x0000005A
    tfASTC10x10UnormSrgb = 0x0000005B
    tfASTC12x10Unorm = 0x0000005C
    tfASTC12x10UnormSrgb = 0x0000005D
    tfASTC12x12Unorm = 0x0000005E
    tfASTC12x12UnormSrgb = 0x0000005F

  TextureSampleType* {.size: sizeof(cint).} = enum
    tstBindingNotUsed = 0x00000000
    tstUndefined = 0x00000001
    tstFloat = 0x00000002
    tstUnfilterableFloat = 0x00000003
    tstDepth = 0x00000004
    tstSint = 0x00000005
    tstUint = 0x00000006

  TextureViewDimension* {.size: sizeof(cint).} = enum
    tvdUndefined = 0x00000000
    tvd1D = 0x00000001
    tvd2D = 0x00000002
    tvd2DArray = 0x00000003
    tvdCube = 0x00000004
    tvdCubeArray = 0x00000005
    tvd3D = 0x00000006

  VertexFormat* {.size: sizeof(cint).} = enum
    vfUint8 = 0x00000001
    vfUint8x2 = 0x00000002
    vfUint8x4 = 0x00000003
    vfSint8 = 0x00000004
    vfSint8x2 = 0x00000005
    vfSint8x4 = 0x00000006
    vfUnorm8 = 0x00000007
    vfUnorm8x2 = 0x00000008
    vfUnorm8x4 = 0x00000009
    vfSnorm8 = 0x0000000A
    vfSnorm8x2 = 0x0000000B
    vfSnorm8x4 = 0x0000000C
    vfUint16 = 0x0000000D
    vfUint16x2 = 0x0000000E
    vfUint16x4 = 0x0000000F
    vfSint16 = 0x00000010
    vfSint16x2 = 0x00000011
    vfSint16x4 = 0x00000012
    vfUnorm16 = 0x00000013
    vfUnorm16x2 = 0x00000014
    vfUnorm16x4 = 0x00000015
    vfSnorm16 = 0x00000016
    vfSnorm16x2 = 0x00000017
    vfSnorm16x4 = 0x00000018
    vfFloat16 = 0x00000019
    vfFloat16x2 = 0x0000001A
    vfFloat16x4 = 0x0000001B
    vfFloat32 = 0x0000001C
    vfFloat32x2 = 0x0000001D
    vfFloat32x3 = 0x0000001E
    vfFloat32x4 = 0x0000001F
    vfUint32 = 0x00000020
    vfUint32x2 = 0x00000021
    vfUint32x3 = 0x00000022
    vfUint32x4 = 0x00000023
    vfSint32 = 0x00000024
    vfSint32x2 = 0x00000025
    vfSint32x3 = 0x00000026
    vfSint32x4 = 0x00000027
    vfUnorm10_10_10_2 = 0x00000028
    vfUnorm8x4BGRA = 0x00000029

  VertexStepMode* {.size: sizeof(cint).} = enum
    vsmVertexBufferNotUsed = 0x00000000
    vsmUndefined = 0x00000001
    vsmVertex = 0x00000002
    vsmInstance = 0x00000003

  WGSLLanguageFeatureName* {.size: sizeof(cint).} = enum
    wlfReadonlyAndReadwriteStorageTextures = 0x00000001
    wlfPacked4x8IntegerDotProduct = 0x00000002
    wlfUnrestrictedPointerParameters = 0x00000003
    wlfPointerCompositeAccess = 0x00000004

  WaitStatus* {.size: sizeof(cint).} = enum
    wsSuccess = 0x00000001
    wsTimedOut = 0x00000002
    wsUnsupportedTimeout = 0x00000003
    wsUnsupportedCount = 0x00000004
    wsUnsupportedMixedSources = 0x00000005

  # BitFlags
  BufferUsage* = enum
    buMapRead
    buMapWrite
    buCopySrc
    buCopyDst
    buIndex
    buVertex
    buUniform
    buStorage
    buIndirect
    buQueryResolve
    _ = 63 # Force uint64 size

  ColorWriteMask* = enum
    cwmRed
    cwmGreen
    cwmBlue
    cwmAlpha
    _ = 63 # Force uint64 size

  MapMode* = enum
    mmRead
    mmWrite
    _ = 63 # Force uint64 size

  ShaderStage* = enum
    ssVertex
    ssFragment
    ssCompute
    _ = 63 # Force uint64 size

  TextureUsage* = enum
    tuCopySrc
    tuCopyDst
    tuTextureBinding
    tuStorageBinding
    tuRenderAttachment
    _ = 63 # Force uint64 size

  # Callbacks
  BufferMapCallback* = proc(status: MapAsyncStatus, message: StringView, userdata1, userdata2: pointer) {.cdecl.}
  CompilationInfoCallback* = proc(status: CompilationInfoRequestStatus, compilationInfo: ptr CompilationInfo, userdata1, userdata2: pointer) {.cdecl.}
  DeviceLostCallback* = proc(device: Device, reason: DeviceLostReason, message: StringView, userdata1, userdata2: pointer) {.cdecl.}
  PopErrorScopeCallback* = proc(status: PopErrorScopeStatus, etype: ErrorType, message: StringView, userdata1, userdata2: pointer) {.cdecl.}
  QueueWorkDoneCallback* = proc(status: QueueWorkDoneStatus, userdata1, userdata2: pointer) {.cdecl.}
  UncapturedErrorCallback* = proc(device: Device, etype: ErrorType, message: StringView, userdata1, userdata2: pointer) {.cdecl.}

  ChainedStruct* {.inheritable, pure.} = object
    next*: ptr ChainedStruct
    sType*: SType

  ChainedStructOut* {.inheritable, pure.} = object
    next*: ptr ChainedStructOut
    sType*: SType

  CallbackInfo[T] = object
    nextInChain*: ptr ChainedStruct
    mode*: CallbackMode
    callback*: T
    userdata1*: pointer
    userdata2*: pointer

  BufferMapCallbackInfo* = CallbackInfo[BufferMapCallback]
  CompilationInfoCallbackInfo* = CallbackInfo[CompilationInfoCallback]
  DeviceLostCallbackInfo* = CallbackInfo[DeviceLostCallback]
  PopErrorScopeCallbackInfo* = CallbackInfo[PopErrorScopeCallback]
  QueueWorkDoneCallbackInfo* = CallbackInfo[QueueWorkDoneCallback]
  UncapturedErrorCallbackInfo* = CallbackInfo[UncapturedErrorCallback]

  AdapterInfo* = object
    nextInChain*: ptr ChainedStructOut
    vendor*: StringView
    architecture*: StringView
    device*: StringView
    description*: StringView
    backendType*: BackendType
    adapterType*: AdapterType
    vendorID*: uint32
    deviceID*: uint32

  BindGroupEntry* = object
    nextInChain*: ptr ChainedStruct
    binding*: uint32
    buffer*: Buffer # nullable
    offset*: uint64
    size*: uint64
    sampler*: Sampler # nullable
    textureView*: TextureView # nullable

  BlendComponent* = object
    operation*: BlendOperation
    srcFactor*: BlendFactor
    dstFactor*: BlendFactor

  BufferBindingLayout* = object
    nextInChain*: ptr ChainedStruct
    typ*: BufferBindingType
    hasDynamicOffset*: Bool
    minBindingSize*: uint64

  BufferDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    usage*: set[BufferUsage]
    size*: uint64
    mappedAtCreation*: Bool

  Color* = object
    r*: cdouble
    g*: cdouble
    b*: cdouble
    a*: cdouble

  CommandBufferDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView

  CommandEncoderDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView

  CompilationMessage* = object
    nextInChain*: ptr ChainedStruct
    message*: StringView
    typ*: CompilationMessageType
    lineNum*: uint64
    linePos*: uint64
    offset*: uint64
    length*: uint64

  ComputePassTimestampWrites* = object
    querySet*: QuerySet
    beginningOfPassWriteIndex*: uint32
    endOfPassWriteIndex*: uint32

  ConstantEntry* = object
    nextInChain*: ptr ChainedStruct
    key*: StringView
    value*: cdouble

  Extent3D* = object
    width*: uint32
    height*: uint32
    depthOrArrayLayers*: uint32

  WGPUFuture* = object
    id*: uint64

  InstanceCapabilities* = object
    nextInChain*: ptr ChainedStructOut
    timedWaitAnyEnable*: Bool
    timedWaitAnyMaxCount*: csize_t

  Limits* = object
    nextInChain*: ptr ChainedStructOut
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

  PipelineLayoutDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    bindGroupLayoutCount*: csize_t
    bindGroupLayouts*: ptr BindGroupLayout

  PrimitiveState* = object
    nextInChain*: ptr ChainedStruct
    topology*: PrimitiveTopology
    stripIndexFormat*: IndexFormat
    frontFace*: FrontFace
    cullMode*: CullMode
    unclippedDepth*: Bool

  QuerySetDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    typ*: QueryType
    count*: uint32

  QueueDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView

  RenderBundleDescriptor * = object
    nextInChain*: ptr ChainedStruct
    label*: StringView

  RenderBundleEncoderDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    colorFormatCount*: csize_t
    colorFormats*: ptr TextureFormat
    depthStencilFormat*: TextureFormat
    sampleCount*: uint32
    depthReadOnly*: Bool
    stencilReadOnly*: Bool

  RenderPassDepthStencilAttachment* = object
    view*: TextureView
    depthLoadOp*: LoadOp
    depthStoreOp*: StoreOp
    depthClearValue*: cfloat
    depthReadOnly*: Bool
    stencilLoadOp*: LoadOp
    stencilStoreOp*: StoreOp
    stencilClearValue*: uint32
    stencilReadOnly*: Bool

  RenderPassMaxDrawCount* = object
    chain*: ChainedStruct
    maxDrawCount*: uint64

  RenderPassTimestampWrites* = object
    querySet*: QuerySet
    beginningOfPassWriteIndex*: uint32
    endOfPassWriteIndex*: uint32

  RequestAdapterOptions* = object
    nextInChain*: ptr ChainedStruct
    featureLevel*: FeatureLevel
    powerPreference*: PowerPreference
    forceFallbackAdapter*: Bool
    backendType*: BackendType
    compatibleSurface*: Surface # Nullable

  SamplerBindingLayout* = object
    nextInChain*: ptr ChainedStruct
    typ*: SamplerBindingType

  SamplerDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    addressModeU*: AddressMode
    addressModeV*: AddressMode
    addressModeW*: AddressMode
    magFilter*: FilterMode
    minFilter*: FilterMode
    mipmapFilter*: MipmapFilterMode
    lodMinClamp*: cfloat
    lodMaxClamp*: cfloat
    compare*: CompareFunction
    maxAnisotropy*: uint16

  ShaderModuleDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView

  ShaderSourceSPIRV * = object of ChainedStruct
    codeSize*: uint32
    code*: ptr uint32

  ShaderSourceWGSL* = object of ChainedStruct
    code*: StringView

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

  SupportedFeatures* = object
    featureCount*: csize_t
    features*: ptr UncheckedArray[FeatureName]

  SupportedWGSLLanguageFeatures* = object
    featureCount*: csize_t
    features*: ptr UncheckedArray[WGSLLanguageFeatureName]

  SurfaceCapabilities* = object
    nextInChain*: ptr ChainedStructOut
    usages*: set[TextureUsage]
    formatCount*: csize_t
    formats*: ptr UncheckedArray[TextureFormat]
    presentModeCount*: csize_t
    presentModes*: ptr UncheckedArray[PresentMode]
    alphaModeCount*: csize_t
    alphaModes*: ptr UncheckedArray[CompositeAlphaMode]

  SurfaceConfiguration* = object
    nextInChain*: ptr ChainedStructOut
    device*: Device
    format*: TextureFormat
    usage*: set[TextureUsage]
    width*: uint32
    height*: uint32
    viewFormatCount*: csize_t
    viewFormats*: ptr UncheckedArray[TextureFormat]
    alphaMode*: CompositeAlphaMode
    presentMode*: PresentMode

  SurfaceDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView

  SurfaceSourceAndroidNativeWindow* = object of ChainedStruct
    window*: pointer

  SurfaceSourceMetalLayer* = object of ChainedStruct
    layer*: pointer

  SurfaceSourceWaylandSurface* = object of ChainedStruct
    display*: pointer
    surface*: pointer

  SurfaceSourceWindowsHWND* = object of ChainedStruct
    hinstance*: pointer
    hwnd*: pointer

  SurfaceSourceXCBWindow* = object of ChainedStruct
    connection*: pointer
    window*: uint32

  SurfaceSourceXlibWindow* = object of ChainedStruct
    display*: pointer
    window*: uint64

  SurfaceTexture* = object
    nextInChain*: ptr ChainedStruct
    texture*: Texture
    status*: SurfaceGetCurrentTextureStatus

  TexelCopyBufferLayout* = object
    offset*: uint64
    bytesPerRow*: uint32
    rowsPerImage*: uint32

  TextureBindingLayout* = object
    nextInChain*: ptr ChainedStruct
    sampleType*: TextureSampleType
    viewDimension*: TextureViewDimension
    multisampled*: Bool

  TextureViewDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    format*: TextureFormat
    dimension*: TextureViewDimension
    baseMipLevel*: uint32
    mipLevelCount*: uint32
    baseArrayLayer*: uint32
    arrayLayerCount*: uint32
    aspect*: TextureAspect
    usage*: set[TextureUsage]

  VertexAttribute* = object
    format*: VertexFormat
    offset*: uint64
    shaderLocation*: uint32

  BindGroupDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    layout*: BindGroupLayout
    entryCount*: csize_t
    entries*: ptr UncheckedArray[BindGroupEntry]

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

  CompilationInfo* = object
    nextInChain*: ptr ChainedStruct
    messageCount*: csize_t
    messages*: ptr UncheckedArray[CompilationMessage]

  ComputePassDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    timestampWrites*: ptr ComputePassTimestampWrites

  DepthStencilState* = object
    nextInChain*: ptr ChainedStruct
    format*: TextureFormat
    depthWriteEnabled*: OptionalBool
    depthCompare*: CompareFunction
    stencilFront*: StencilFaceState
    stencilBack*: StencilFaceState
    stencilReadMask*: uint32
    stencilWriteMask*: uint32
    depthBias*: int32
    depthBiasSlopeScale*: cfloat
    depthBiasClamp*: cfloat

  DeviceDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    requiredFeaturesCount*: csize_t
    requiredFeatures*: ptr UncheckedArray[FeatureName]
    requiredLimits*: ptr Limits # nullable
    defaultQueue*: QueueDescriptor
    deviceLostCallbackInfo*: DeviceLostCallbackInfo
    uncapturedErrorCallbackInfo*: UncapturedErrorCallbackInfo

  FutureWaitInfo* = object
    future*: WGPUFuture
    completed*: Bool

  InstanceDescriptor* = object
    nextInChain*: ptr ChainedStruct
    features*: InstanceCapabilities

  ProgrammableStageDescriptor* = object
    nextInChain*: ptr ChainedStruct
    module*: ShaderModule
    entryPoint*: StringView
    constantCount*: csize_t
    constants*: ptr UncheckedArray[ConstantEntry]

  RenderPassColorAttachment* = object
    nextInChain*: ptr ChainedStruct
    view*: TextureView # nullable
    depthSlice*: uint32
    resolveTarget*: TextureView # nullable
    loadOp*: LoadOp
    storeOp*: StoreOp
    clearValue*: Color

  TexelCopyBufferInfo* = object
    layout*: TexelCopyBufferLayout
    buffer*: Buffer

  TexelCopyTextureInfo* = object
    texture*: Texture
    mipLevel*: uint32
    origin*: Origin3D
    aspect*: TextureAspect

  TextureDescriptor * = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    usage*: set[TextureUsage]
    dimension*: TextureDimension
    size*: Extent3D
    format*: TextureFormat
    mipLevelCount*: uint32
    sampleCount*: uint32
    viewFormatCount*: csize_t
    viewFormats*: ptr UncheckedArray[TextureFormat]

  VertexBufferLayout* = object
    stepMode*: VertexStepMode
    arrayStride*: uint64
    attributeCount*: csize_t
    attributes*: ptr UncheckedArray[VertexAttribute]

  BindGroupLayoutDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    entryCount*: csize_t
    entries*: ptr UncheckedArray[BindGroupLayoutEntry]

  ColorTargetState* = object
    nextInChain*: ptr ChainedStruct
    format*: TextureFormat
    blend*: ptr BlendState # nullable
    writeMask*: set[ColorWriteMask]

  ComputePipelineDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    layout*: PipelineLayout
    compute*: ProgrammableStageDescriptor

  RenderPassDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    colorAttachmentCount*: csize_t
    colorAttachments*: ptr UncheckedArray[RenderPassColorAttachment]
    depthStencilAttachment*: ptr RenderPassDepthStencilAttachment #nullable
    occlusionQuerySet*: QuerySet# nullable
    timestampWrites*: RenderPassTimestampWrites

  VertexState* = object
    nextInChain*: ptr ChainedStruct
    module*: ShaderModule
    entryPoint*: StringView
    constantCount*: csize_t
    constants*: ptr UncheckedArray[ConstantEntry]
    bufferCount*: csize_t
    buffers*: ptr UncheckedArray[VertexBufferLayout]

  FragmentState* = object
    nextInChain*: ptr ChainedStruct
    module*: ShaderModule
    entryPoint*: StringView
    constantCount*: csize_t
    constants*: ptr UncheckedArray[ConstantEntry]
    targetCount*: csize_t
    targets*: ptr UncheckedArray[ColorTargetState]

  RenderPipelineDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: StringView
    layout*: PipelineLayout # nullable
    vertex*: VertexState
    primitive*: PrimitiveState
    depthStencil*: ptr DepthStencilState # nullable
    multisample*: MultisampleState
    fragment*: ptr FragmentState # nullable

const
  cwmAll* = {cwmRed, cwmGreen, cwmBlue, cwmAlpha}

proc extent3d*(x, y, z: uint32): Extent3D {.inline.} = Extent3D(width: x, height: y, depthOrArrayLayers: z)

when defined(wasm):
  discard
else:
  type
    CreateComputePipelineAsyncCallback* = proc(status: CreatePipelineAsyncStatus, pipeline: ComputePipelinePtr, message: StringView, userdata1, userdata2: pointer) {.cdecl.}
    CreateRenderPipelineAsyncCallback* = proc(status: CreatePipelineAsyncStatus, pipeline: RenderPipelinePtr, message: StringView, userdata1, userdata2: pointer) {.cdecl.}
    RequestAdapterCallback* = proc(status: RequestAdapterStatus, adapter: AdapterPtr, message: StringView, userdata1, userdata2: pointer) {.cdecl.}
    RequestDeviceCallback* = proc(status: RequestDeviceStatus, device: DevicePtr, message: StringView, userdata1, userdata2: pointer) {.cdecl.}

    CreateComputePipelineAsyncCallbackInfo* = CallbackInfo[CreateComputePipelineAsyncCallback]
    CreateRenderPipelineAsyncCallbackInfo* = CallbackInfo[CreateRenderPipelineAsyncCallback]
    RequestAdapterCallbackInfo* = CallbackInfo[RequestAdapterCallback]
    RequestDeviceCallbackInfo* = CallbackInfo[RequestDeviceCallback]

  include ./wgpu/native_functions

proc `$`(s: StringView): string =
  if s.data == nil or s.length == 0: return
  if s.length == csize_t.high: return $s.data
  result = newStringUninit(s.length)
  copyMem(addr result[0], s.data, s.length)

converter toStringView*(s: string): StringView =
  result.length = s.len.csize_t
  if s.len != 0:
    result.data = addr s[0]

when defined(wasm):
  proc createInstance*(): Instance {.importwasmp: "navigator.gpu || null".}
  proc getPreferredCanvasFormat*(i: Instance): TextureFormat {.importwasmexpr: "_nimwct.indexOf($0.getPreferredCanvasFormat())".}

else:
  proc createInstance*(): Instance {.inline.} = wgpuCreateInstance(nil).toShared
  proc createInstance*(descriptor: InstanceDescriptor): Instance {.inline.} = wgpuCreateInstance(addr descriptor).toShared


# Procs of instance
when defined(wasm):
  discard
else:
  proc hasWGSLLanguageFeature*(i: Instance, f: WGSLLanguageFeatureName): bool {.inline.} =
    wgpuInstanceHasWGSLLanguageFeature(i, f).bool

when defined(wasm):
  type
    RequestAdapterCallback = proc(adapter: JSExternObj[Adapter], userdata: pointer) {.cdecl.}

  proc requestAdapterWasm(inst: Instance, p: PowerPreference, cb: RequestAdapterCallback, env: pointer) {.importwasmraw: """
  $0.requestAdapter().then(a => $2(a, $3))
  """.}

  proc requestAdapterCallback(adapter: JSExternObj[Adapter], env: pointer) {.cdecl.} =
    # defineDyncall("vii")
    let env = cast[Future[Adapter]](env)
    GC_unref(env)
    env.complete(adapter)

  proc requestAdapter(instance: Instance, options: ptr RequestAdapterOptions): Future[Adapter] =
    result.new()
    GC_ref(result)
    let env = cast[pointer](result)
    var p: PowerPreference
    if options != nil:
      p = options.powerPreference
    requestAdapterWasm(instance, p, requestAdapterCallback, env)

else:
  proc requestAdapterCallback(status: RequestAdapterStatus, adapter: AdapterPtr, message: StringView, userdata1, userdata2: pointer) {.cdecl.} =
    let env = cast[Future[Adapter]](userdata1)
    GC_unref(env)
    env.complete(adapter.toShared)

  proc requestAdapter(instance: Instance, options: ptr RequestAdapterOptions): Future[Adapter] =
    result.new()
    GC_ref(result)
    let env = cast[pointer](result)
    var cb: RequestAdapterCallbackInfo
    cb.mode = cmAllowProcessEvents
    cb.callback = requestAdapterCallback
    cb.userdata1 = env

    discard wgpuInstanceRequestAdapter(instance, options, cb)

proc requestAdapter*(instance: Instance, options: RequestAdapterOptions): Future[Adapter] {.inline.} = instance.requestAdapter(addr options)

proc requestAdapter*(instance: Instance): Future[Adapter] {.inline.} = instance.requestAdapter(nil)


# Procs of Adapter
# when defined(wasm):
#   discard
# else:
#   proc features*(a: Adapter): seq[FeatureName] =
#     let s = wgpuAdapterEnumerateFeatures(a.p, nil)
#     result.setLen(s)
#     if s != 0:
#       discard wgpuAdapterEnumerateFeatures(a.p, addr result[0])

when defined(wasm):
  type
    RequestDeviceCallback = proc(device: JSExternObj[Device], env: pointer) {.cdecl.}

  proc requestDeviceWasm(adapter: Adapter, descriptor: ptr DeviceDescriptor, callback: RequestDeviceCallback, userdata: pointer) {.importwasmraw: """
  $0.requestDevice().then(a => $2(a, $3));
  """.}

  proc requestDeviceCallback(device: JSExternObj[Device], env: pointer) {.cdecl.} =
    let env = cast[Future[Device]](env)
    GC_unref(env)
    env.complete(device)

  proc requestDevice(adapter: Adapter, options: ptr DeviceDescriptor): Future[Device] =
    result.new()
    GC_ref(result)
    let env = cast[pointer](result)
    requestDeviceWasm(adapter, options, requestDeviceCallback, env)

else:
  proc createSurface*(instance: Instance, descriptor: SurfaceDescriptor): Surface {.inline.} = wgpuInstanceCreateSurface(instance, addr descriptor).toShared

  proc requestDeviceCallback(status: RequestDeviceStatus, device: DevicePtr, message: StringView, userdata1, userdata2: pointer) {.cdecl.} =
    let env = cast[Future[Device]](userdata1)
    GC_unref(env)
    env.complete(device.toShared)

  proc processEvents*(i: Instance) {.inline.} = wgpuInstanceProcessEvents(i)

  proc requestDevice(adapter: Adapter, options: ptr DeviceDescriptor): Future[Device] =
    result.new()
    GC_ref(result)
    let env = cast[pointer](result)
    var cb: RequestDeviceCallbackInfo
    cb.mode = cmAllowProcessEvents
    cb.callback = requestDeviceCallback
    cb.userdata1 = env
    discard wgpuAdapterRequestDevice(adapter, options, cb)

proc requestDevice*(adapter: Adapter, options: DeviceDescriptor): Future[Device] {.inline.} = adapter.requestDevice(addr options)

template ptrArrayElem[T](p: ptr T, i: int): ptr T =
  addr cast[ptr UncheckedArray[T]](p)[i]

# Procs of Buffer
when defined(wasm):
  proc bufferSize(b: Buffer): uint32 {.importwasmp: "size".}
  proc usage*(b: Buffer): set[BufferUsage] {.importwasmp.}
  proc size*(b: Buffer): uint64 {.inline.} = b.bufferSize

  proc mapAsync(b: Buffer, m: uint32, o, s: uint32, cb: proc(p: pointer) {.cdecl.}, data: pointer) {.importwasmraw: """
  $0.mapAsync($1, $2, $3).then(() => $4($5))
  """.}

  proc onMapComplete(p: pointer) {.cdecl.} =
    let f = cast[Future[void]](p)
    GC_unref(f)
    f.complete()

  proc mapAsync*(b: Buffer, mode: set[MapMode], offset, size: uint64): Future[void] =
    # defineDyncall("vi")
    result = newFuture(void)
    GC_ref(result)
    mapAsync(b, cast[uint32](mode), offset.uint32, size.uint32, onMapComplete, cast[pointer](result))

  proc copyMappedRangeOutAux(b: Buffer, offset, size: uint32, dest: pointer) {.importwasmraw: """
  new Uint8Array(_nima).set(new Uint8Array($0.getMappedRange($1, $2)), $3)
  """.}

  proc copyMappedRangeOut*(b: Buffer, offset, size: uint64, dest: pointer) {.inline.} =
    copyMappedRangeOutAux(b, offset.uint32, size.uint32, dest)

  proc unmap*(b: Buffer) {.importwasmm.}

else:
  proc size*(b: Buffer): uint64 {.inline.} = wgpuBufferGetSize(b)
  proc usage*(b: Buffer): set[BufferUsage] {.inline.} = wgpuBufferGetUsage(b)

  proc onMapFutComplete(status: MapAsyncStatus, message: StringView, userdata1, userdata2: pointer) {.cdecl.} =
    let f = cast[Future[void]](userdata1)
    GC_unref(f)
    f.complete()

  proc mapAsync*(b: Buffer, mode: set[MapMode], offset, size: uint64): Future[void] =
    result = newFuture(void)
    GC_ref(result)
    var cb: BufferMapCallbackInfo
    cb.mode = cmAllowProcessEvents
    cb.callback = onMapFutComplete
    cb.userdata1 = cast[pointer](result)
    discard wgpuBufferMapAsync(b, mode, offset.csize_t, size.csize_t, cb)

  proc unmap*(b: Buffer) {.inline.} = wgpuBufferUnmap(b)

  proc getConstMappedRange*(b: Buffer, o, s: csize_t): pointer {.inline.} =
    wgpuBufferGetConstMappedRange(b, o, s)

  proc copyMappedRangeOut*(b: Buffer, offset, size: uint64, dest: pointer) =
    let s = getConstMappedRange(b, offset, size)
    copyMem(dest, s, size)

# Procs of Device

when defined(wasm):
  proc makeJsArray(count: uint32): JSObj {.importwasmf: "new Array".}
  proc setArrayElem(t: JSObj, idx: int32, l: JSObj) {.importwasmraw: "$0[$1] = $2".}

  proc addBindgroupEntry(t: JSObj, idx: int32, binding, offset, size: uint32, resource: JSRef) {.importwasmraw: "$0[$1] = {binding: $2, resource: $4?{offset: $3, size: $4, buffer: $5}:$5}".}

  proc log(o: JSObj){.importwasmraw: """console.log('entr', $0)""".}

  proc createBindGroup(device: Device, layout: BindGroupLayout, entries: JSObj): BindGroup {.importwasmp: """
  createBindGroup({layout: $1, entries: $2})
  """}

  proc createBindGroup*(device: Device, descriptor: BindGroupDescriptor): BindGroup {.inline.} =
    let entryCount = descriptor.entryCount
    let entries = makeJsArray(entryCount.uint32)
    for i in 0 ..< entryCount.int:
      let e = addr descriptor.entries[i]
      var res = e.buffer.o
      if res.isNil:
        res = e.sampler.o
        if res.isNil:
          res = e.textureView.o
      addBindgroupEntry(entries, i.int32, e.binding, uint32(e.offset), uint32(e.size), res)
    createBindGroup(device, descriptor.layout, entries)

else:
  proc createBindGroup*(device: Device, descriptor: BindGroupDescriptor): BindGroup {.inline.} =
    wgpuDeviceCreateBindGroup(device, addr descriptor).toShared

when defined(wasm):
  proc createBindGroupLayout(device: Device, entries: JSObj): BindGroupLayout {.importwasmp: """
  createBindGroupLayout({entries:$1})
  """.}

  proc addBindgroupLayoutEntryBuffer(t: JSObj, idx: int32, binding, visibility: uint32,
                                     k: BufferBindingType, hdo: bool, mbs: uint32) {.importwasmraw: "$0[$1] = {binding: $2, visibility: $3, buffer: {type: _nimwcb[$4], hasDynamicOffset: $5, minBindingSize: $6}}".}
  proc addBindgroupLayoutEntryTexture(t: JSObj, idx: int32, binding, visibility: uint32, s, d: int32, multisampled: int32) {.importwasmraw: "$0[$1] = {binding: $2, visibility: $3, texture: {sampleType: _nimwcS[$4], viewDimension: _nimwcD[$5], multisampled: $6}}".}
  proc addBindgroupLayoutEntrySampler(t: JSObj, idx: int32, binding, visibility: uint32, typ: SamplerBindingType) {.importwasmraw: "$0[$1] = {binding: $2, visibility: $3, sampler: {type: [,,'filtering','non-filtering','comparison'][$4]}}".}

  proc createBindGroupLayout*(device: Device, descriptor: BindGroupLayoutDescriptor): BindGroupLayout =
    let entryCount = descriptor.entryCount
    let entries = makeJsArray(entryCount.uint32)
    for i in 0 ..< entryCount.int:
      let e = addr descriptor.entries[i]
      if e.buffer.typ notin {bbtBindingNotUsed, bbtUndefined}:
        addBindgroupLayoutEntryBuffer(entries, i.int32, e.binding, cast[uint32](e.visibility), e.buffer.typ, e.buffer.hasDynamicOffset.bool, uint32(e.buffer.minBindingSize))
      elif e.texture.sampleType notin {tstBindingNotUsed, tstUndefined}:
        addBindGroupLayoutEntryTexture(entries, i.int32, e.binding, cast[uint32](e.visibility), cast[int32](e.texture.sampleType), cast[int32](e.texture.viewDimension), e.texture.multisampled.int32)
      elif e.sampler.typ notin {sbtBindingNotUsed, sbtUndefined}:
        addBindgroupLayoutEntrySampler(entries, i.int32, e.binding, cast[uint32](e.visibility), e.sampler.typ)
      else:
        assert(false, "Not implemented: binding group layout entry type")
    # log(entries)
    createBindGroupLayout(device, entries)

else:
  proc createBindGroupLayout*(device: Device, descriptor: BindGroupLayoutDescriptor): BindGroupLayout {.inline.} =
    wgpuDeviceCreateBindGroupLayout(device, addr descriptor).toShared

when defined(wasm):
  proc createBuffer(device: Device, usage: uint32, size: uint32, mappedAtCreation: bool): Buffer {.importwasmp: """
  createBuffer({usage: $1, size: $2, mappedAtCreation: $3})
  """.}
  proc createBuffer*(device: Device, d: BufferDescriptor): Buffer {.inline.} =
    createBuffer(device, cast[uint32](d.usage), d.size.uint32, d.mappedAtCreation.bool)
else:
  proc createBuffer*(device: Device, descriptor: BufferDescriptor): Buffer {.inline.} =
    wgpuDeviceCreateBuffer(device, addr descriptor).toShared

when defined(wasm):
  proc getQueue*(device: Device): Queue {.importwasmp: "queue".}
else:
  proc getQueue*(device: Device): Queue {.inline.} =
    wgpuDeviceGetQueue(device).toSharedRetain()

when defined(wasm):
  proc getLimits*(device: Device, limits: var Limits): bool =
    # For WASM, set reasonable defaults (WebGPU provides these via device.limits)
    limits.minUniformBufferOffsetAlignment = 256
    true
else:
  proc getLimits*(device: Device, limits: var Limits): bool {.inline.} =
    wgpuDeviceGetLimits(device, addr limits) == sSuccess

type
  ErrorInfo* = object
    typ*: ErrorType
    message*: string

when defined(wasm):
  # Error filter names for WebGPU
  proc pushErrorScopeAux(d: Device, f: cstring) {.importwasmm: "pushErrorScope".}
  proc pushErrorScope*(d: Device, f: ErrorFilter) =
    let filterName = case f
      of efValidation: "validation"
      of efOutOfMemory: "out-of-memory"
      of efInternal: "internal"
    pushErrorScopeAux(d, filterName)

  proc popErrorScopeWasm(d: Device, cb: proc(err: JSExternRef, env: pointer) {.cdecl.}, env: pointer) {.importwasmraw: """
  $0.popErrorScope().then(e => $1(e, $2))
  """.}

  proc popErrorScopeCallback(err: JSExternRef, env: pointer) {.cdecl.} =
    let fut = cast[Future[ErrorInfo]](env)
    GC_unref(fut)
    if err.isNil:
      fut.complete(ErrorInfo(typ: etNoError, message: ""))
    else:
      fut.complete(ErrorInfo(typ: etValidation, message: "Validation error"))

  proc popErrorScope*(d: Device): Future[ErrorInfo] =
    result = newFuture(ErrorInfo)
    GC_ref(result)
    popErrorScopeWasm(d, popErrorScopeCallback, cast[pointer](result))

else:
  proc onExitErrorScope(status: PopErrorScopeStatus, etype: ErrorType, message: StringView, userdata1, userdata2: pointer) {.cdecl.} =
    let r = cast[Future[ErrorInfo]](userdata1)
    GC_unref(r)
    r.complete(ErrorInfo(typ: etype, message: $message))

  proc pushErrorScope*(d: Device, f: ErrorFilter) {.inline.} =
    wgpuDevicePushErrorScope(d, f)
  proc popErrorScope*(d: Device): Future[ErrorInfo] =
    result = newFuture(ErrorInfo)
    GC_ref(result)
    var cb: PopErrorScopeCallbackInfo
    cb.mode = cmAllowProcessEvents
    cb.callback = onExitErrorScope
    cb.userdata1 = cast[pointer](result)
    discard wgpuDevicePopErrorScope(d, cb)

when defined(wasm):
  proc createCommandEncoder*(device: Device): CommandEncoder {.importwasmm.}
  proc createCommandEncoder*(device: Device, descriptor: CommandEncoderDescriptor): CommandEncoder {.inline.} =
    device.createCommandEncoder()

else:
  proc createCommandEncoder*(device: Device): CommandEncoder {.inline.} =
    wgpuDeviceCreateCommandEncoder(device, nil).toShared

  proc createCommandEncoder*(device: Device, descriptor: CommandEncoderDescriptor): CommandEncoder {.inline.} =
    wgpuDeviceCreateCommandEncoder(device, addr descriptor).toShared

when defined(wasm):
  proc createComputePipeline(device: Device, layout: PipelineLayout, shaderModule: ShaderModule, entryPoint: JSExternObj[JSString]): ComputePipeline {.importwasmp: """
createComputePipeline({layout: $1, compute: { module: $2, entryPoint: $3 }})
""".}
  proc createComputePipeline*(device: Device, d: ComputePipelineDescriptor): ComputePipeline {.inline.} =
    createComputePipeline(device, d.layout, d.compute.module, strToJs(d.compute.entryPoint.data, d.compute.entryPoint.length.uint32))
else:

  proc createComputePipeline*(device: Device, descriptor: ComputePipelineDescriptor): ComputePipeline {.inline.} =
    wgpuDeviceCreateComputePipeline(device, addr descriptor).toShared

when defined(wasm):
  proc createRenderPipeline(device: Device, layout: PipelineLayout, vsModule: ShaderModule,
                            vsEntry: JSExternObj[JSString], buffers, fsState: JSObj,
                            topology: PrimitiveTopology, stripIndexFormat: IndexFormat,
                            frontFace: FrontFace, cullMode: CullMode): RenderPipeline {.importwasmp: """
  createRenderPipeline({layout: $1||'auto', vertex: {module: $2, entryPoint: $3, buffers: $4}, fragment: $5||undefined, primitive: {topology: _nimwcp[$6], stripIndexFormat: _nimwci[$7], frontFace: _nimwcf[$8], cullMode: _nimwcc[$9]}})
  """.}

  proc makeFsState(m: ShaderModule, e: JSExternObj[JSString], targets: JSObj): JSObj {.importwasmexpr: """
  {module: $0, entryPoint: $1, targets: $2}
  """}

  proc mkTarget(format: TextureFormat): JSObj {.importwasmexpr: "{format: _nimwct[$0]}".}
  proc mkBlendComponent(op: BlendOperation, srcFac, dstFac: BlendFactor): JSObj {.importwasmexpr: "{operation: _nimwbo[$0], srcFactor: _nimwbf[$1], dstFactor: _nimwbf[$2]}".}
  proc mkBlend(c, a: JSObj): JSObj {.importwasmexpr:"{color: $0, alpha: $1}".}
  proc `blend=`(t: JSObj, b: JSObj) {.importwasmp.}

  proc addBufferLayout(t: JSObj, idx: int32, arrayStride: uint32, attrs: JSObj, stepMode: VertexStepMode) {.importwasmraw: "$0[$1] = {arrayStride: $2, attributes: $3, stepMode: _nimwcs[$4]}".}
  proc addAttribute(t: JSObj, idx: int32, fmt, offset, shaderLoc: uint32) {.importwasmraw: "$0[$1] = {format: _nimwcv[$2], offset: $3, shaderLocation: $4}".}

  proc createRenderPipeline*(device: Device, d: RenderPipelineDescriptor): RenderPipeline =
    var fsState: JSObj
    let f = d.fragment
    if not f.isNil:
      let targets = makeJsArray(f.targetCount.uint32)
      for i in 0 ..< f.targetCount.int:
        let tt = addr f.targets[i]
        let jtarget = mkTarget(tt.format)
        let b = tt.blend
        if not b.isNil:
          jtarget.blend = mkBlend(mkBlendComponent(b.color.operation, b.color.srcFactor, b.color.dstFactor), mkBlendComponent(b.alpha.operation, b.alpha.srcFactor, b.alpha.dstFactor))
        setArrayElem(targets, i.int32, jtarget)

      fsState = makeFsState(f.module, strToJs(f.entryPoint.data, f.entryPoint.length.uint32), targets)
    let buffers = makeJsArray(d.vertex.bufferCount.uint32)
    for i in 0 ..< d.vertex.bufferCount.int:
      let tt = addr d.vertex.buffers[i]
      let attributes = makeJsArray(tt.attributeCount.uint32)
      for j in 0 ..< tt.attributeCount.int:
        let aa = addr tt.attributes[j]
        addAttribute(attributes, j.int32, aa.format.uint32, aa.offset.uint32, aa.shaderLocation)
      addBufferLayout(buffers, i.int32, tt.arrayStride.uint32, attributes, tt.stepMode)

    createRenderPipeline(device, d.layout, d.vertex.module, strToJs(d.vertex.entryPoint.data, d.vertex.entryPoint.length.uint32), buffers, fsState, d.primitive.topology, d.primitive.stripIndexFormat, d.primitive.frontFace, d.primitive.cullMode)
else:

  proc createRenderPipeline*(device: Device, descriptor: RenderPipelineDescriptor): RenderPipeline {.inline.} =
    wgpuDeviceCreateRenderPipeline(device, addr descriptor).toShared

when defined(wasm):
  proc createTexture(device: Device, w, h, z, m, s: uint32, d: TextureDimension, f: TextureFormat, u: int32): Texture {.importwasmp: """
  createTexture({size: {width: $1, height: $2, depthOrArrayLayers: $3}, mipLevelCount: $4, sampleCount: $5, dimension: _nimwcd[$6], format: _nimwct[$7], usage: $8, viewFormats: []})
  """}
  proc createTexture*(device: Device, d: TextureDescriptor): Texture {.inline.} =
    device.createTexture(d.size.width, d.size.height, d.size.depthOrArrayLayers, d.mipLevelCount, d.sampleCount, d.dimension, d.format, cast[int32](d.usage))
else:
  proc createTexture*(device: Device, descriptor: TextureDescriptor): Texture {.inline.} =
    wgpuDeviceCreateTexture(device, addr descriptor).toShared

when defined(wasm):
  proc createSampler*(device: Device): Sampler {.importwasmm.}
  proc createSampler(device: Device, u, v, w: AddressMode, magf, minf: FilterMode, mf: MipmapFilterMode, lmin, lmax: float32, c: CompareFunction, a: uint32): Sampler {.importwasmp: """
  createSampler({addressModeU: _nimwca[$1], addressModeV: _nimwca[$2], addressModeW: _nimwca[$3], magFilter: _nimwcF[$4], minFilter: _nimwcF[$5], mipmapFilter: _nimwcF[$6], lodMinClamp: $7, lodMaxClamp: $8, compare: _nimwcC[$9], maxAnisotropy: $10})
  """}
  proc createSampler*(device: Device, d: SamplerDescriptor): Sampler {.inline.} =
    createSampler(device, d.addressModeU, d.addressModeV, d.addressModeW, d.magFilter, d.minFilter, d.mipmapFilter, d.lodMinClamp, d.lodMaxClamp, d.compare, d.maxAnisotropy)

else:

  proc createSampler*(device: Device, descriptor: SamplerDescriptor): Sampler {.inline.} =
    wgpuDeviceCreateSampler(device, addr descriptor).toShared

  proc createSampler*(device: Device): Sampler {.inline.} =
    wgpuDeviceCreateSampler(device, nil).toShared

when defined(wasm):
  proc createShaderModule*(device: Device, code: string): ShaderModule {.importwasmp: "createShaderModule({code:$1})".}
else:
  proc createShaderModule*(device: Device, descriptor: ShaderModuleDescriptor): ShaderModule {.inline.} =
    wgpuDeviceCreateShaderModule(device, addr descriptor).toShared
  proc createShaderModule*(device: Device, code: string): ShaderModule {.inline.} =
    var shaderDesc: ShaderModuleDescriptor
    var shaderCodeDesc: ShaderSourceWGSL
    shaderCodeDesc.sType = stShaderSourceWGSL
    shaderCodeDesc.code = code
    shaderDesc.nextInChain = addr shaderCodeDesc
    createShaderModule(device, shaderDesc)

when defined(wasm):
  proc createPipelineLayout*(device: Device): PipelineLayout {.importwasmp: "createPipelineLayout({bindGroupLayouts:[]})".}
  proc createPipelineLayout(device: Device, entries: JSObj): PipelineLayout {.importwasmp: "createPipelineLayout({bindGroupLayouts:$1})".}
  proc addBindGroupLayout(t: JSObj, idx: int32, l: BindGroupLayout) {.importwasmraw: "$0[$1] = $2".}
  proc createPipelineLayout*(device: Device, descriptor: PipelineLayoutDescriptor): PipelineLayout =
    let entries = makeJsArray(descriptor.bindGroupLayoutCount.uint32)
    for i in 0 ..< descriptor.bindGroupLayoutCount.int:
      let e = ptrArrayElem(descriptor.bindGroupLayouts, i)
      addBindGroupLayout(entries, i.int32, e[])
    createPipelineLayout(device, entries)
else:

  proc createPipelineLayout*(device: Device, descriptor: PipelineLayoutDescriptor): PipelineLayout {.inline.} =
    wgpuDeviceCreatePipelineLayout(device, addr descriptor).toShared
  proc createPipelineLayout*(device: Device): PipelineLayout {.inline.} =
    var d: PipelineLayoutDescriptor
    wgpuDeviceCreatePipelineLayout(device, addr d).toShared

# Procs of Queue
# # WGPU_EXPORT void wgpuQueueOnSubmittedWorkDone(WGPUQueue queue, WGPUQueueWorkDoneCallback callback, void * userdata);
# proc setLabel*(queue: QueuePtr, label: cstring) {.w, importc: "wgpuQueueSetLabel".}

when defined(wasm):
  proc submitArr(q: Queue, arr: JSObj) {.importwasmm: "submit".}
  proc submit*(q: Queue, cmd: JSExternObj[CommandBuffer]) =
    let arr = makeJsArray(1)
    setArrayElem(arr, 0, JSExternRef(cmd))
    submitArr(q, arr)

  proc submit*(q: Queue, commands: openarray[CommandBuffer]) =
    let arr = makeJsArray(1)
    for i, c in commands:
      setArrayElem(arr, i.int32, JSObj(c))
    submitArr(q, arr)

else:
  proc submit*(queue: Queue, commandCount: int, commands: ptr CommandBuffer) {.inline.} =
    wgpuQueueSubmit(queue, commandCount.uint32, cast[ptr CommandBufferPtr](commands))
  proc submit*(queue: Queue, command: CommandBuffer) {.inline.} = submit(queue, 1, addr command)
  proc submit*(queue: Queue, commands: openarray[CommandBuffer]) {.inline.} = submit(queue, commands.len, cast[ptr CommandBuffer](addr commands))

when defined(wasm):
  proc writeBuffer*(queue: Queue, buffer: Buffer, bufferOffset: int, data: pointer, size: int) {.importwasmraw: """
  $0.writeBuffer($1, $2, _nima, $3, $4)
  """.}
else:
  proc writeBuffer*(queue: Queue, buffer: Buffer, bufferOffset: int, data: pointer, size: int) {.inline.} =
    wgpuQueueWriteBuffer(queue, buffer, bufferOffset.uint64, data, size.csize_t)

when defined(wasm):
  proc writeTexture(queue: Queue, t: Texture, p: pointer, s, o, bpr, rpi, w, h, z: uint32) {.importwasmraw: """
  $0.writeTexture({texture: $1}, new Uint8Array(_nime.memory.buffer, $2, $3), {offset: $4, bytesPerRow: $5, rowsPerImage: $6}, {width: $7, height: $8, depthOrArrayLayers: $9})
  """.}

  proc writeTexture*(queue: Queue, destination: TexelCopyTextureInfo, data: pointer, dataSize: int, dataLayout: TexelCopyBufferLayout, writeSize: Extent3D) {.inline.} =
    queue.writeTexture(destination.texture, data, dataSize.uint32, dataLayout.offset.uint32, dataLayout.bytesPerRow, dataLayout.rowsPerImage, writeSize.width, writeSize.height, writeSize.depthOrArrayLayers)
else:
  proc writeTexture*(queue: Queue, destination: TexelCopyTextureInfo, data: pointer, dataSize: int, dataLayout: TexelCopyBufferLayout, writeSize: Extent3D) {.inline.} =
    wgpuQueueWriteTexture(queue, addr destination, data, dataSize.csize_t, addr dataLayout, addr writeSize)

# Procs of CommandEncoder
when defined(wasm):
  proc beginComputePass*(commandEncoder: CommandEncoder): ComputePassEncoder {.importwasmm.}
else:
  proc beginComputePass*(commandEncoder: CommandEncoder, descriptor: ComputePassDescriptor): ComputePassEncoder {.inline.} =
    wgpuCommandEncoderBeginComputePass(commandEncoder, addr descriptor).toShared

  proc beginComputePass*(commandEncoder: CommandEncoder): ComputePassEncoder {.inline.} =
    wgpuCommandEncoderBeginComputePass(commandEncoder, nil).toShared

when defined(wasm):
  proc beginRenderPass(e: CommandEncoder, c: JSObj): RenderPassEncoder {.importwasmp: "beginRenderPass({colorAttachments: $1})".}

  proc addColorAttachment(a: JSObj, i: int32, tv: TextureView, cr, cg, cb, ca: float) {.importwasmraw: """
  $0[$1] = {view: $2, clearValue: {r: $3, g: $4, b: $5, a: $6}, loadOp: 'clear', storeOp: 'store'}
  """}
  proc beginRenderPass*(commandEncoder: CommandEncoder, d: RenderPassDescriptor): RenderPassEncoder =
    let colorAttachments = makeJsArray(d.colorAttachmentCount.uint32)
    let tt = cast[ptr UncheckedArray[RenderPassColorAttachment]](d.colorAttachments)
    for i in 0 ..< d.colorAttachmentCount.int:
      addColorAttachment(colorAttachments, i.int32, tt[i].view, tt[i].clearValue.r, tt[i].clearValue.g, tt[i].clearValue.b, tt[i].clearValue.a)
    beginRenderPass(commandEncoder, colorAttachments)
  proc clearBufferAux(e: CommandEncoder, b: Buffer, o, s: uint32) {.importwasmm: "clearBuffer".}
  proc clearBuffer*(e: CommandEncoder, b: Buffer, o, s: uint64) {.inline.} =
    clearBufferAux(e, b, o.uint32, s.uint32)

else:
  proc beginRenderPass*(commandEncoder: CommandEncoder, descriptor: RenderPassDescriptor): RenderPassEncoder {.inline.} =
    wgpuCommandEncoderBeginRenderPass(commandEncoder, addr descriptor).toShared

  proc clearBuffer*(e: CommandEncoder, b: Buffer, o, s: uint64) {.inline.} =
    wgpuCommandEncoderClearBuffer(e, b, o, s)

when defined(wasm):
  proc copyBufferToBufferAux(commandEncoder: CommandEncoder, s: Buffer, os: uint32, d: Buffer, od, sz: uint32) {.importwasmm: "copyBufferToBuffer".}
  proc copyBufferToBuffer*(commandEncoder: CommandEncoder, s: Buffer, os: uint64, d: Buffer, od, sz: uint64) {.inline.} =
    copyBufferToBufferAux(commandEncoder, s, os.uint32, d, od.uint32, sz.uint32)
else:
  proc copyBufferToBuffer*(commandEncoder: CommandEncoder, s: Buffer, os: uint64, d: Buffer, od, sz: uint64) {.inline.} =
    wgpuCommandEncoderCopyBufferToBuffer(commandEncoder, s, os, d, od, sz)

# WGPU_EXPORT void wgpuCommandEncoderCopyBufferToBuffer(WGPUCommandEncoder commandEncoder, WGPUBuffer source, uint64_t sourceOffset, WGPUBuffer destination, uint64_t destinationOffset, uint64_t size) WGPU_FUNCTION_ATTRIBUTE;
# # WGPU_EXPORT void wgpuCommandEncoderCopyBufferToTexture(WGPUCommandEncoder commandEncoder, WGPUImageCopyBuffer const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize);
# # WGPU_EXPORT void wgpuCommandEncoderCopyTextureToBuffer(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const * source, WGPUImageCopyBuffer const * destination, WGPUExtent3D const * copySize);
# # WGPU_EXPORT void wgpuCommandEncoderCopyTextureToTexture(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize);
when defined(wasm):
  proc finish*(commandEncoder: CommandEncoder): CommandBuffer {.importwasmm.}
else:
  proc finish*(commandEncoder: CommandEncoder, descriptor: CommandBufferDescriptor): CommandBuffer {.inline.} =
    wgpuCommandEncoderFinish(commandEncoder, addr descriptor).toShared
  proc finish*(commandEncoder: CommandEncoder): CommandBuffer {.inline.} = wgpuCommandEncoderFinish(commandEncoder, nil).toShared

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
  proc dispatchWorkgroups*(e: ComputePassEncoder, cx: int, cy = 1, cz = 1) {.inline.} =
    wgpuComputePassEncoderDispatchWorkgroups(e, cx.uint32, cy.uint32, cz.uint32)

# WGPU_EXPORT void wgpuComputePassEncoderDispatchWorkgroupsIndirect(WGPUComputePassEncoder computePassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset) WGPU_FUNCTION_ATTRIBUTE;
when defined(wasm):
  proc finish*(e: ComputePassEncoder) {.importwasmm: "end".}
else:

  proc finish*(e: sink[ComputePassEncoder]) {.inline.} =
    wgpuComputePassEncoderEnd(e)


# WGPU_EXPORT void wgpuComputePassEncoderEndPipelineStatisticsQuery(WGPUComputePassEncoder computePassEncoder) WGPU_FUNCTION_ATTRIBUTE;
# WGPU_EXPORT void wgpuComputePassEncoderInsertDebugMarker(WGPUComputePassEncoder computePassEncoder, char const * markerLabel) WGPU_FUNCTION_ATTRIBUTE;
# WGPU_EXPORT void wgpuComputePassEncoderPopDebugGroup(WGPUComputePassEncoder computePassEncoder) WGPU_FUNCTION_ATTRIBUTE;
# WGPU_EXPORT void wgpuComputePassEncoderPushDebugGroup(WGPUComputePassEncoder computePassEncoder, char const * groupLabel) WGPU_FUNCTION_ATTRIBUTE;
when defined(wasm):
  proc setBindGroup(e: ComputePassEncoder, groupIndex: uint32, group: BindGroup) {.importwasmm.}
  proc setBindGroup*(e: ComputePassEncoder, groupIdx: int, g: BindGroup) {.inline.} =
    e.setBindGroup(groupIdx.uint32, g)
else:
  proc setBindGroup*(e: ComputePassEncoder, groupIdx: int, g: BindGroup, dynamicOffsets: openarray[uint32]) {.inline.} =
    let sz = dynamicOffsets.len.uint32
    let o = if sz != 0: addr dynamicOffsets[0] else: nil
    wgpuComputePassEncoderSetBindGroup(e, groupIdx.uint32, g, sz, o)
  proc setBindGroup*(e: ComputePassEncoder, groupIdx: int, g: BindGroup) {.inline.} =
    wgpuComputePassEncoderSetBindGroup(e, groupIdx.uint32, g, 0, nil)

# WGPU_EXPORT void wgpuComputePassEncoderSetLabel(WGPUComputePassEncoder computePassEncoder, char const * label) WGPU_FUNCTION_ATTRIBUTE;
when defined(wasm):
  proc setPipeline*(e: ComputePassEncoder, p: ComputePipeline) {.importwasmm.}
else:
  proc setPipeline*(e: ComputePassEncoder, p: ComputePipeline) {.inline.} =
    wgpuComputePassEncoderSetPipeline(e, p)

# Procs of ComputePipeline
# WGPU_EXPORT WGPUBindGroupLayout wgpuComputePipelineGetBindGroupLayout(WGPUComputePipeline computePipeline, uint32_t groupIndex) WGPU_FUNCTION_ATTRIBUTE;
when defined(wasm):
  discard
else:
  proc getBindGroupLayout*(e: ComputePipeline, i: uint32): BindGroupLayout {.inline.} =
    wgpuComputePipelineGetBindGroupLayout(e, i).toSharedRetain()

# WGPU_EXPORT void wgpuComputePipelineSetLabel(WGPUComputePipeline computePipeline, char const * label) WGPU_FUNCTION_ATTRIBUTE;

# # Procs of Surface
when defined(wasm):
  discard
else:

  proc configure*(surface: Surface, config: SurfaceConfiguration) {.inline.} =
    wgpuSurfaceConfigure(surface, addr config)

  proc getCapabilities*(surface: Surface, adapter: Adapter, capabilities: var SurfaceCapabilities): bool {.inline.} =
    wgpuSurfaceGetCapabilities(surface, adapter, addr capabilities) == sSuccess

  proc getCurrentTexture*(surface: Surface, texture: var SurfaceTexture) {.inline.} =
    wgpuSurfaceGetCurrentTexture(surface, addr texture)

  proc present*(s: Surface): bool {.inline.} =
    wgpuSurfacePresent(s) == sSuccess

# Procs of Texture
when defined(wasm):
  proc createView*(t: Texture): TextureView {.importwasmm.}

  proc createViewWithDescriptor(t: Texture, format: TextureFormat, dimension: TextureViewDimension,
                                baseMip, mipCount, baseLayer, layerCount: uint32, aspect: TextureAspect): TextureView {.importwasmp: """
  createView({format: _nimwct[$1], dimension: _nimwcD[$2], baseMipLevel: $3, mipLevelCount: $4, baseArrayLayer: $5, arrayLayerCount: $6, aspect: [,'all','stencil-only','depth-only'][$7]})
  """.}

  proc createView*(texture: Texture, descriptor: TextureViewDescriptor): TextureView {.inline.} =
    createViewWithDescriptor(texture, descriptor.format, descriptor.dimension,
      descriptor.baseMipLevel, descriptor.mipLevelCount,
      descriptor.baseArrayLayer, descriptor.arrayLayerCount, descriptor.aspect)
else:
  proc createView*(texture: Texture, descriptor: TextureViewDescriptor): TextureView {.inline.} =
    wgpuTextureCreateView(texture, addr descriptor).toShared
  proc createView*(texture: Texture): TextureView {.inline.} =
    wgpuTextureCreateView(texture, nil).toShared

when defined(wasm):
  proc format*(texture: Texture): TextureFormat {.importwasmexpr: "_nimwcT[$0.format]".}
  proc width*(texture: Texture): uint32 {.importwasmp.}
  proc height*(texture: Texture): uint32 {.importwasmp.}
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
  proc draw*(renderPassEncoder: RenderPassEncoder, vertexCount, instanceCount, firstVertex, firstInstance: uint32) {.inline.} =
    wgpuRenderPassEncoderDraw(renderPassEncoder, vertexCount, instanceCount, firstVertex, firstInstance)


# # WGPU_EXPORT void wgpuRenderPassEncoderDrawIndexed(WGPURenderPassEncoder renderPassEncoder, uint32_t indexCount, uint32_t instanceCount, uint32_t firstIndex, int32_t baseVertex, uint32_t firstInstance);
# # WGPU_EXPORT void wgpuRenderPassEncoderDrawIndexedIndirect(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
# # WGPU_EXPORT void wgpuRenderPassEncoderDrawIndirect(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
when defined(wasm):
  proc finish*(renderPassEncoder: RenderPassEncoder) {.importwasmm: "end".}
else:
  proc finish*(renderPassEncoder: sink[RenderPassEncoder]) {.inline.} = wgpuRenderPassEncoderEnd(renderPassEncoder)

# # WGPU_EXPORT void wgpuRenderPassEncoderEndOcclusionQuery(WGPURenderPassEncoder renderPassEncoder);
# # WGPU_EXPORT void wgpuRenderPassEncoderEndPipelineStatisticsQuery(WGPURenderPassEncoder renderPassEncoder);
# # WGPU_EXPORT void wgpuRenderPassEncoderExecuteBundles(WGPURenderPassEncoder renderPassEncoder, uint32_t bundlesCount, WGPURenderBundle const * bundles);
# # WGPU_EXPORT void wgpuRenderPassEncoderInsertDebugMarker(WGPURenderPassEncoder renderPassEncoder, char const * markerLabel);
# # WGPU_EXPORT void wgpuRenderPassEncoderPopDebugGroup(WGPURenderPassEncoder renderPassEncoder);
# # WGPU_EXPORT void wgpuRenderPassEncoderPushDebugGroup(WGPURenderPassEncoder renderPassEncoder, char const * groupLabel);

when defined(wasm):
  proc setBindGroup*(renderPassEncoder: RenderPassEncoder, groupIndex: uint32, group: BindGroup) {.importwasmm.}

  proc setBindGroupWithOffsetsAux(renderPassEncoder: RenderPassEncoder, groupIndex, offsets, count: uint32, group: BindGroup) {.importwasmraw: """
$0.setBindGroup($1, $4, new Uint32Array(_nima, $2, $3))
""".}

  proc setBindGroup*(renderPassEncoder: RenderPassEncoder, groupIndex: uint32, group: BindGroup, dynamicOffsets: openarray[uint32]) =
    if dynamicOffsets.len > 0:
      setBindGroupWithOffsetsAux(renderPassEncoder, groupIndex, cast[uint32](addr dynamicOffsets[0]), dynamicOffsets.len.uint32, group)
    else:
      setBindGroup(renderPassEncoder, groupIndex, group)

else:
  proc setBindGroup*(renderPassEncoder: RenderPassEncoder, groupIndex: uint32, group: BindGroup, dynamicOffsets: openarray[uint32]) {.inline.} =
    wgpuRenderPassEncoderSetBindGroup(renderPassEncoder, groupIndex, group, dynamicOffsets.len.uint32, cast[ptr uint32](addr dynamicOffsets))
  proc setBindGroup*(renderPassEncoder: RenderPassEncoder, groupIndex: uint32, group: BindGroup) {.inline.} =
    wgpuRenderPassEncoderSetBindGroup(renderPassEncoder, groupIndex, group, 0, nil)

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

  proc setVertexBuffer*(renderPassEncoder: RenderPassEncoder, slot: uint32, buffer: Buffer, offset, size: uint64) {.inline.} =
    wgpuRenderPassEncoderSetVertexBuffer(renderPassEncoder, slot, buffer, offset, size)

proc setVertexBuffer*(renderPassEncoder: RenderPassEncoder, slot: uint32, buffer: Buffer, offset: uint64 = 0) {.inline.} =
  renderPassEncoder.setVertexBuffer(slot, buffer, offset, buffer.size - offset)

when defined(wasm):
  discard
else:
  proc setViewport*(renderPassEncoder: RenderPassEncoder, x, y, width, height, minDepth, maxDepth: float32) {.inline.} =
    wgpuRenderPassEncoderSetViewport(renderPassEncoder, x, y, width, height, minDepth, maxDepth)

# Procs of RenderPipeline
when defined(wasm):
  proc getBindGroupLayout*(renderPipeline: RenderPipeline, groupIndex: uint32): BindGroupLayout {.importwasmm.}
else:
  proc getBindGroupLayout*(renderPipeline: RenderPipeline, groupIndex: uint32): BindGroupLayout {.w, importc: "wgpuRenderPipelineGetBindGroupLayout".}

# WGPU_EXPORT void wgpuRenderPipelineSetLabel(WGPURenderPipeline renderPipeline, char const * label);
