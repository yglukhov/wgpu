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
  type
    `t Ptr`* = ptr object
    t* = object
      p*: `t Ptr`

  when defined(wasm):
    proc `wgpu t AddRef`(v: `t Ptr`) {.exportc.} = retain(cast[JSRef](v))
    proc `wgpu t Release`(v: `t Ptr`) {.exportc.} = release(cast[JSRef](v))
  else:
    proc `wgpu t AddRef`(v: `t Ptr`) {.w.}
    proc `wgpu t Release`(v: `t Ptr`) {.w.}

  proc isNil*(v: t): bool {.inline.} = v.p.isNil
  proc `=destroy`*(v: t) =
    if not v.p.isNil:
      `wgpu t Release`(v.p)
  proc `=copy`*(dst: var t, src: t) =
    if dst.p != src.p:
      if not src.p.isNil:
        `wgpu t AddRef`(src.p)
      if not dst.p.isNil:
        `wgpu t Release`(dst.p)
      dst.p = src.p
  proc `==`*(v: t, n: typeof(nil)): bool {.inline.} = v.p.isNil
  proc toShared*(v: `t Ptr`): t = t(p: v)
  proc toSharedRetain*(v: `t Ptr`): t =
    `wgpu t AddRef`(v)
    t(p: v)

when defined(wasm):
  {.pragma: w, importc.}
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
  UncapturedErrorCallbackInfo* = object
    # Note: unlike other CallbackInfo structs, C's WGPUUncapturedErrorCallbackInfo
    # does NOT have a mode field.
    nextInChain*: ptr ChainedStruct
    callback*: UncapturedErrorCallback
    userdata1*: pointer
    userdata2*: pointer

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

proc c_memset*(p: pointer, value: cint, size: csize_t): pointer {.
  importc: "memset", discardable.}

proc defaultLimits*(): Limits =
  # Set all mem to 0xff, except the first pointer
  discard c_memset(addr result.maxTextureDimension1D, 0xff, csize_t(sizeof(result) - sizeof(pointer)))

type
  CreateComputePipelineAsyncCallback* = proc(status: CreatePipelineAsyncStatus, pipeline: ComputePipelinePtr, message: StringView, userdata1, userdata2: pointer) {.cdecl.}
  CreateRenderPipelineAsyncCallback* = proc(status: CreatePipelineAsyncStatus, pipeline: RenderPipelinePtr, message: StringView, userdata1, userdata2: pointer) {.cdecl.}
  RequestAdapterCallback* = proc(status: RequestAdapterStatus, adapter: AdapterPtr, message: StringView, userdata1, userdata2: pointer) {.cdecl.}
  RequestDeviceCallback* = proc(status: RequestDeviceStatus, device: DevicePtr, message: StringView, userdata1, userdata2: pointer) {.cdecl.}

  CreateComputePipelineAsyncCallbackInfo* = CallbackInfo[CreateComputePipelineAsyncCallback]
  CreateRenderPipelineAsyncCallbackInfo* = CallbackInfo[CreateRenderPipelineAsyncCallback]
  RequestAdapterCallbackInfo* = CallbackInfo[RequestAdapterCallback]
  RequestDeviceCallbackInfo* = CallbackInfo[RequestDeviceCallback]

when defined(wasm):
  include ./wasm_glue
else:
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

proc createInstance*(): Instance {.inline.} = wgpuCreateInstance(nil).toShared
proc createInstance*(descriptor: InstanceDescriptor): Instance {.inline.} = wgpuCreateInstance(addr descriptor).toShared

when defined(wasm):
  proc getPreferredCanvasFormatI(i: JSObject): uint32 {.importwasmexpr: "_nimwct.indexOf($0.getPreferredCanvasFormat())".}
  proc getPreferredCanvasFormat*(i: Instance): TextureFormat {.inline.} =
    cast[TextureFormat](getPreferredCanvasFormatI(cast[JSRef](i.p)))

# Procs of instance
proc hasWGSLLanguageFeature*(i: Instance, f: WGSLLanguageFeatureName): bool {.inline.} =
  wgpuInstanceHasWGSLLanguageFeature(i, f).bool

when not defined(wasm):
  proc createSurface*(instance: Instance, descriptor: SurfaceDescriptor): Surface {.inline.} = wgpuInstanceCreateSurface(instance, addr descriptor).toShared

proc processEvents*(i: Instance) {.inline.} = wgpuInstanceProcessEvents(i)

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
proc requestDeviceCallback(status: RequestDeviceStatus, device: DevicePtr, message: StringView, userdata1, userdata2: pointer) {.cdecl.} =
  let env = cast[Future[Device]](userdata1)
  GC_unref(env)
  env.complete(device.toShared)

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

proc getFeatures*(adapter: Adapter, features: var SupportedFeatures) {.inline.} =
  wgpuAdapterGetFeatures(adapter, addr features)

proc getInfo*(adapter: Adapter, info: var AdapterInfo): bool {.inline.} =
  wgpuAdapterGetInfo(adapter, addr info) == sSuccess

proc getLimits*(adapter: Adapter, limits: var Limits): bool {.inline.} =
  wgpuAdapterGetLimits(adapter, addr limits) == sSuccess

proc hasFeature*(adapter: Adapter, feature: FeatureName): bool {.inline.} =
  wgpuAdapterHasFeature(adapter, feature).bool

proc freeMembers*(info: AdapterInfo) {.inline.} = wgpuAdapterInfoFreeMembers(info)

template ptrArrayElem[T](p: ptr T, i: int): ptr T =
  addr cast[ptr UncheckedArray[T]](p)[i]

# Procs of Buffer
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
proc destroy*(b: Buffer) {.inline.} = wgpuBufferDestroy(b)
proc mapState*(b: Buffer): BufferMapState {.inline.} = wgpuBufferGetMapState(b)
proc getMappedRange*(b: Buffer, o, s: csize_t): pointer {.inline.} = wgpuBufferGetMappedRange(b, o, s)
proc `label=`*(b: Buffer, label: StringView) {.inline.} = wgpuBufferSetLabel(b, label)

proc getConstMappedRange*(b: Buffer, o, s: csize_t): pointer {.inline.} =
  wgpuBufferGetConstMappedRange(b, o, s)

proc copyMappedRangeOut*(b: Buffer, offset, size: uint64, dest: pointer) =
  let s = getConstMappedRange(b, offset.csize_t, size.csize_t)
  copyMem(dest, s, size)

# Procs of Device
proc createBindGroup*(device: Device, descriptor: BindGroupDescriptor): BindGroup {.inline.} =
  wgpuDeviceCreateBindGroup(device, addr descriptor).toShared

proc createBindGroupLayout*(device: Device, descriptor: BindGroupLayoutDescriptor): BindGroupLayout {.inline.} =
  wgpuDeviceCreateBindGroupLayout(device, addr descriptor).toShared

proc createBuffer*(device: Device, descriptor: BufferDescriptor): Buffer {.inline.} =
  wgpuDeviceCreateBuffer(device, addr descriptor).toShared

proc getQueue*(device: Device): Queue {.inline.} =
  wgpuDeviceGetQueue(device).toSharedRetain()

proc getLimits*(device: Device, limits: var Limits): bool {.inline.} =
  wgpuDeviceGetLimits(device, addr limits) == sSuccess

type
  ErrorInfo* = object
    typ*: ErrorType
    message*: string

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

proc createCommandEncoder*(device: Device): CommandEncoder {.inline.} =
  wgpuDeviceCreateCommandEncoder(device, nil).toShared

proc createCommandEncoder*(device: Device, descriptor: CommandEncoderDescriptor): CommandEncoder {.inline.} =
  wgpuDeviceCreateCommandEncoder(device, addr descriptor).toShared

proc createComputePipeline*(device: Device, descriptor: ComputePipelineDescriptor): ComputePipeline {.inline.} =
  wgpuDeviceCreateComputePipeline(device, addr descriptor).toShared

proc createRenderPipeline*(device: Device, descriptor: RenderPipelineDescriptor): RenderPipeline {.inline.} =
  wgpuDeviceCreateRenderPipeline(device, addr descriptor).toShared

proc createTexture*(device: Device, descriptor: TextureDescriptor): Texture {.inline.} =
  wgpuDeviceCreateTexture(device, addr descriptor).toShared

proc createSampler*(device: Device, descriptor: SamplerDescriptor): Sampler {.inline.} =
  wgpuDeviceCreateSampler(device, addr descriptor).toShared

proc createSampler*(device: Device): Sampler {.inline.} =
  wgpuDeviceCreateSampler(device, nil).toShared

proc createShaderModule*(device: Device, descriptor: ShaderModuleDescriptor): ShaderModule {.inline.} =
  wgpuDeviceCreateShaderModule(device, addr descriptor).toShared
proc createShaderModule*(device: Device, code: string): ShaderModule {.inline.} =
  var shaderDesc: ShaderModuleDescriptor
  var shaderCodeDesc: ShaderSourceWGSL
  shaderCodeDesc.sType = stShaderSourceWGSL
  shaderCodeDesc.code = code
  shaderDesc.nextInChain = addr shaderCodeDesc
  createShaderModule(device, shaderDesc)

proc createPipelineLayout*(device: Device, descriptor: PipelineLayoutDescriptor): PipelineLayout {.inline.} =
  wgpuDeviceCreatePipelineLayout(device, addr descriptor).toShared
proc createPipelineLayout*(device: Device): PipelineLayout {.inline.} =
  var d: PipelineLayoutDescriptor
  wgpuDeviceCreatePipelineLayout(device, addr d).toShared

proc createQuerySet*(device: Device, descriptor: QuerySetDescriptor): QuerySet {.inline.} =
  wgpuDeviceCreateQuerySet(device, addr descriptor)

proc createRenderBundleEncoder*(device: Device, descriptor: RenderBundleEncoderDescriptor): RenderBundleEncoder {.inline.} =
  wgpuDeviceCreateRenderBundleEncoder(device, addr descriptor)

proc destroy*(device: Device) {.inline.} = wgpuDeviceDestroy(device)

proc getFeatures*(device: Device, features: var SupportedFeatures) {.inline.} =
  wgpuDeviceGetFeatures(device, addr features)

proc hasFeature*(device: Device, feature: FeatureName): bool {.inline.} =
  wgpuDeviceHasFeature(device, feature).bool

proc `label=`*(device: Device, label: StringView) {.inline.} =
  wgpuDeviceSetLabel(device, label)

# Procs of Queue
proc submit*(queue: Queue, commandCount: int, commands: ptr CommandBuffer) {.inline.} =
  wgpuQueueSubmit(queue, commandCount.uint32, cast[ptr CommandBufferPtr](commands))
proc submit*(queue: Queue, command: CommandBuffer) {.inline.} = submit(queue, 1, addr command)
proc submit*(queue: Queue, commands: openarray[CommandBuffer]) {.inline.} = submit(queue, commands.len, cast[ptr CommandBuffer](addr commands))

proc writeBuffer*(queue: Queue, buffer: Buffer, bufferOffset: int, data: pointer, size: int) {.inline.} =
  wgpuQueueWriteBuffer(queue, buffer, bufferOffset.uint64, data, size.csize_t)

proc writeTexture*(queue: Queue, destination: TexelCopyTextureInfo, data: pointer, dataSize: int, dataLayout: TexelCopyBufferLayout, writeSize: Extent3D) {.inline.} =
  wgpuQueueWriteTexture(queue, addr destination, data, dataSize.csize_t, addr dataLayout, addr writeSize)

proc onSubmittedWorkDoneCallback(status: QueueWorkDoneStatus, userdata1, userdata2: pointer) {.cdecl.} =
  let f = cast[Future[void]](userdata1)
  GC_unref(f)
  f.complete()

proc onSubmittedWorkDone*(queue: Queue): Future[void] =
  result = newFuture(void)
  GC_ref(result)
  var cb: QueueWorkDoneCallbackInfo
  cb.mode = cmAllowProcessEvents
  cb.callback = onSubmittedWorkDoneCallback
  cb.userdata1 = cast[pointer](result)
  discard wgpuQueueOnSubmittedWorkDone(queue, cb)

proc `label=`*(queue: Queue, label: StringView) {.inline.} =
  wgpuQueueSetLabel(queue, label)

# Procs of CommandEncoder
proc beginComputePass*(commandEncoder: CommandEncoder, descriptor: ComputePassDescriptor): ComputePassEncoder {.inline.} =
  wgpuCommandEncoderBeginComputePass(commandEncoder, addr descriptor).toShared

proc beginComputePass*(commandEncoder: CommandEncoder): ComputePassEncoder {.inline.} =
  wgpuCommandEncoderBeginComputePass(commandEncoder, nil).toShared

proc beginRenderPass*(commandEncoder: CommandEncoder, descriptor: RenderPassDescriptor): RenderPassEncoder {.inline.} =
  wgpuCommandEncoderBeginRenderPass(commandEncoder, addr descriptor).toShared

proc clearBuffer*(e: CommandEncoder, b: Buffer, o, s: uint64) {.inline.} =
  wgpuCommandEncoderClearBuffer(e, b, o, s)

proc copyBufferToBuffer*(commandEncoder: CommandEncoder, s: Buffer, os: uint64, d: Buffer, od, sz: uint64) {.inline.} =
  wgpuCommandEncoderCopyBufferToBuffer(commandEncoder, s, os, d, od, sz)

proc copyBufferToTexture*(e: CommandEncoder, source: TexelCopyBufferInfo, destination: TexelCopyTextureInfo, copySize: Extent3D) {.inline.} =
  wgpuCommandEncoderCopyBufferToTexture(e, addr source, addr destination, addr copySize)

proc copyTextureToBuffer*(e: CommandEncoder, source: TexelCopyTextureInfo, destination: TexelCopyBufferInfo, copySize: Extent3D) {.inline.} =
  wgpuCommandEncoderCopyTextureToBuffer(e, addr source, addr destination, addr copySize)

proc copyTextureToTexture*(e: CommandEncoder, source, destination: TexelCopyTextureInfo, copySize: Extent3D) {.inline.} =
  wgpuCommandEncoderCopyTextureToTexture(e, addr source, addr destination, addr copySize)

proc resolveQuerySet*(e: CommandEncoder, querySet: QuerySet, firstQuery, queryCount: uint32, destination: Buffer, destinationOffset: uint64) {.inline.} =
  wgpuCommandEncoderResolveQuerySet(e, querySet, firstQuery, queryCount, destination, destinationOffset)

proc writeTimestamp*(e: CommandEncoder, querySet: QuerySet, queryIndex: uint32) {.inline.} =
  wgpuCommandEncoderWriteTimestamp(e, querySet, queryIndex)

proc insertDebugMarker*(e: CommandEncoder, label: StringView) {.inline.} =
  wgpuCommandEncoderInsertDebugMarker(e, label)

proc pushDebugGroup*(e: CommandEncoder, label: StringView) {.inline.} =
  wgpuCommandEncoderPushDebugGroup(e, label)

proc popDebugGroup*(e: CommandEncoder) {.inline.} =
  wgpuCommandEncoderPopDebugGroup(e)

proc `label=`*(e: CommandEncoder, label: StringView) {.inline.} =
  wgpuCommandEncoderSetLabel(e, label)

proc `label=`*(e: CommandBuffer, label: StringView) {.inline.} =
  wgpuCommandBufferSetLabel(e, label)

proc finish*(commandEncoder: CommandEncoder, descriptor: CommandBufferDescriptor): CommandBuffer {.inline.} =
  wgpuCommandEncoderFinish(commandEncoder, addr descriptor).toShared
proc finish*(commandEncoder: CommandEncoder): CommandBuffer {.inline.} = wgpuCommandEncoderFinish(commandEncoder, nil).toShared

# Procs of ComputePassEncoder
proc dispatchWorkgroups*(e: ComputePassEncoder, cx: int, cy = 1, cz = 1) {.inline.} =
  wgpuComputePassEncoderDispatchWorkgroups(e, cx.uint32, cy.uint32, cz.uint32)

proc finish*(e: sink[ComputePassEncoder]) {.inline.} =
  wgpuComputePassEncoderEnd(e)

proc setBindGroup*(e: ComputePassEncoder, groupIdx: int, g: BindGroup, dynamicOffsets: openarray[uint32]) {.inline.} =
  let sz = dynamicOffsets.len.uint32
  let o = if sz != 0: addr dynamicOffsets[0] else: nil
  wgpuComputePassEncoderSetBindGroup(e, groupIdx.uint32, g, sz, o)
proc setBindGroup*(e: ComputePassEncoder, groupIdx: int, g: BindGroup) {.inline.} =
  wgpuComputePassEncoderSetBindGroup(e, groupIdx.uint32, g, 0, nil)

proc setPipeline*(e: ComputePassEncoder, p: ComputePipeline) {.inline.} =
  wgpuComputePassEncoderSetPipeline(e, p)

proc dispatchWorkgroupsIndirect*(e: ComputePassEncoder, indirectBuffer: Buffer, indirectOffset: uint64) {.inline.} =
  wgpuComputePassEncoderDispatchWorkgroupsIndirect(e, indirectBuffer, indirectOffset)

proc insertDebugMarker*(e: ComputePassEncoder, label: StringView) {.inline.} =
  wgpuComputePassEncoderInsertDebugMarker(e, label)

proc pushDebugGroup*(e: ComputePassEncoder, label: StringView) {.inline.} =
  wgpuComputePassEncoderPushDebugGroup(e, label)

proc popDebugGroup*(e: ComputePassEncoder) {.inline.} =
  wgpuComputePassEncoderPopDebugGroup(e)

proc `label=`*(e: ComputePassEncoder, label: StringView) {.inline.} =
  wgpuComputePassEncoderSetLabel(e, label)

# Procs of ComputePipeline
proc getBindGroupLayout*(e: ComputePipeline, i: uint32): BindGroupLayout {.inline.} =
  wgpuComputePipelineGetBindGroupLayout(e, i).toSharedRetain()

proc `label=`*(e: ComputePipeline, label: StringView) {.inline.} =
  wgpuComputePipelineSetLabel(e, label)

# Procs of Surface
when not defined(wasm):
  proc configure*(surface: Surface, config: SurfaceConfiguration) {.inline.} =
    wgpuSurfaceConfigure(surface, addr config)

  proc getCapabilities*(surface: Surface, adapter: Adapter, capabilities: var SurfaceCapabilities): bool {.inline.} =
    wgpuSurfaceGetCapabilities(surface, adapter, addr capabilities) == sSuccess

  proc getCurrentTexture*(surface: Surface, texture: var SurfaceTexture) {.inline.} =
    wgpuSurfaceGetCurrentTexture(surface, addr texture)

  proc present*(s: Surface): bool {.inline.} =
    wgpuSurfacePresent(s) == sSuccess

# Procs of Texture
proc createView*(texture: Texture, descriptor: TextureViewDescriptor): TextureView {.inline.} =
  wgpuTextureCreateView(texture, addr descriptor).toShared
proc createView*(texture: Texture): TextureView {.inline.} =
  wgpuTextureCreateView(texture, nil).toShared

proc depthOrArrayLayers*(texture: Texture): uint32 {.inline.} = wgpuTextureGetDepthOrArrayLayers(texture)
proc dimension*(texture: Texture): TextureDimension {.inline.} = wgpuTextureGetDimension(texture)
proc format*(texture: Texture): TextureFormat {.inline.} = wgpuTextureGetFormat(texture)
proc height*(texture: Texture): uint32 {.inline.} = wgpuTextureGetHeight(texture)
proc width*(texture: Texture): uint32 {.inline.} = wgpuTextureGetWidth(texture)
proc mipLevelCount*(texture: Texture): uint32 {.inline.} = wgpuTextureGetMipLevelCount(texture)
proc sampleCount*(texture: Texture): uint32 {.inline.} = wgpuTextureGetSampleCount(texture)
proc destroy*(texture: Texture) {.inline.} = wgpuTextureDestroy(texture)
proc `label=`*(texture: Texture, label: StringView) {.inline.} = wgpuTextureSetLabel(texture, label)
proc `label=`*(tv: TextureView, label: StringView) {.inline.} = wgpuTextureViewSetLabel(tv, label)

# Procs of RenderPassEncoder
proc draw*(renderPassEncoder: RenderPassEncoder, vertexCount, instanceCount, firstVertex, firstInstance: uint32) {.inline.} =
  wgpuRenderPassEncoderDraw(renderPassEncoder, vertexCount, instanceCount, firstVertex, firstInstance)

proc finish*(renderPassEncoder: sink[RenderPassEncoder]) {.inline.} = wgpuRenderPassEncoderEnd(renderPassEncoder)

proc setBindGroup*(renderPassEncoder: RenderPassEncoder, groupIndex: uint32, group: BindGroup, dynamicOffsets: openarray[uint32]) {.inline.} =
  wgpuRenderPassEncoderSetBindGroup(renderPassEncoder, groupIndex, group, dynamicOffsets.len.uint32, cast[ptr uint32](addr dynamicOffsets))
proc setBindGroup*(renderPassEncoder: RenderPassEncoder, groupIndex: uint32, group: BindGroup) {.inline.} =
  wgpuRenderPassEncoderSetBindGroup(renderPassEncoder, groupIndex, group, 0, nil)

proc setPipeline*(renderPassEncoder: RenderPassEncoder, pipeline: RenderPipeline) {.inline.} =
  wgpuRenderPassEncoderSetPipeline(renderPassEncoder, pipeline)

proc setVertexBuffer*(renderPassEncoder: RenderPassEncoder, slot: uint32, buffer: Buffer, offset, size: uint64) {.inline.} =
  wgpuRenderPassEncoderSetVertexBuffer(renderPassEncoder, slot, buffer, offset, size)

proc setVertexBuffer*(renderPassEncoder: RenderPassEncoder, slot: uint32, buffer: Buffer, offset: uint64 = 0) {.inline.} =
  renderPassEncoder.setVertexBuffer(slot, buffer, offset, buffer.size - offset)

proc setViewport*(renderPassEncoder: RenderPassEncoder, x, y, width, height, minDepth, maxDepth: float32) {.inline.} =
  wgpuRenderPassEncoderSetViewport(renderPassEncoder, x, y, width, height, minDepth, maxDepth)

# Procs of RenderPassEncoder (continued)
proc drawIndexed*(e: RenderPassEncoder, indexCount, instanceCount, firstIndex: uint32, baseVertex: int32, firstInstance: uint32) {.inline.} =
  wgpuRenderPassEncoderDrawIndexed(e, indexCount, instanceCount, firstIndex, baseVertex, firstInstance)

proc drawIndirect*(e: RenderPassEncoder, indirectBuffer: Buffer, indirectOffset: uint64) {.inline.} =
  wgpuRenderPassEncoderDrawIndirect(e, indirectBuffer, indirectOffset)

proc drawIndexedIndirect*(e: RenderPassEncoder, indirectBuffer: Buffer, indirectOffset: uint64) {.inline.} =
  wgpuRenderPassEncoderDrawIndexedIndirect(e, indirectBuffer, indirectOffset)

proc setIndexBuffer*(e: RenderPassEncoder, buffer: Buffer, format: IndexFormat, offset, size: uint64) {.inline.} =
  wgpuRenderPassEncoderSetIndexBuffer(e, buffer, format, offset, size)

proc setIndexBuffer*(e: RenderPassEncoder, buffer: Buffer, format: IndexFormat, offset: uint64 = 0) {.inline.} =
  e.setIndexBuffer(buffer, format, offset, buffer.size - offset)

proc setScissorRect*(e: RenderPassEncoder, x, y, width, height: uint32) {.inline.} =
  wgpuRenderPassEncoderSetScissorRect(e, x, y, width, height)

proc setStencilReference*(e: RenderPassEncoder, reference: uint32) {.inline.} =
  wgpuRenderPassEncoderSetStencilReference(e, reference)

proc setBlendConstant*(e: RenderPassEncoder, color: Color) {.inline.} =
  wgpuRenderPassEncoderSetBlendConstant(e, addr color)

proc executeBundles*(e: RenderPassEncoder, bundles: openarray[RenderBundle]) {.inline.} =
  wgpuRenderPassEncoderExecuteBundles(e, bundles.len.csize_t, cast[ptr RenderBundle](addr bundles))

proc beginOcclusionQuery*(e: RenderPassEncoder, queryIndex: uint32) {.inline.} =
  wgpuRenderPassEncoderBeginOcclusionQuery(e, queryIndex)

proc endOcclusionQuery*(e: RenderPassEncoder) {.inline.} =
  wgpuRenderPassEncoderEndOcclusionQuery(e)

proc insertDebugMarker*(e: RenderPassEncoder, label: StringView) {.inline.} =
  wgpuRenderPassEncoderInsertDebugMarker(e, label)

proc pushDebugGroup*(e: RenderPassEncoder, label: StringView) {.inline.} =
  wgpuRenderPassEncoderPushDebugGroup(e, label)

proc popDebugGroup*(e: RenderPassEncoder) {.inline.} =
  wgpuRenderPassEncoderPopDebugGroup(e)

proc `label=`*(e: RenderPassEncoder, label: StringView) {.inline.} =
  wgpuRenderPassEncoderSetLabel(e, label)

# Procs of RenderPipeline
proc getBindGroupLayout*(renderPipeline: RenderPipeline, groupIndex: uint32): BindGroupLayout {.inline.} =
  wgpuRenderPipelineGetBindGroupLayout(renderPipeline, groupIndex).toSharedRetain()

proc `label=`*(e: RenderPipeline, label: StringView) {.inline.} =
  wgpuRenderPipelineSetLabel(e, label)

# Procs of RenderBundleEncoder
proc draw*(e: RenderBundleEncoder, vertexCount, instanceCount, firstVertex, firstInstance: uint32) {.inline.} =
  wgpuRenderBundleEncoderDraw(e, vertexCount, instanceCount, firstVertex, firstInstance)

proc drawIndexed*(e: RenderBundleEncoder, indexCount, instanceCount, firstIndex: uint32, baseVertex: int32, firstInstance: uint32) {.inline.} =
  wgpuRenderBundleEncoderDrawIndexed(e, indexCount, instanceCount, firstIndex, baseVertex, firstInstance)

proc drawIndirect*(e: RenderBundleEncoder, indirectBuffer: Buffer, indirectOffset: uint64) {.inline.} =
  wgpuRenderBundleEncoderDrawIndirect(e, indirectBuffer, indirectOffset)

proc drawIndexedIndirect*(e: RenderBundleEncoder, indirectBuffer: Buffer, indirectOffset: uint64) {.inline.} =
  wgpuRenderBundleEncoderDrawIndexedIndirect(e, indirectBuffer, indirectOffset)

proc finish*(e: RenderBundleEncoder, descriptor: RenderBundleDescriptor): RenderBundle {.inline.} =
  wgpuRenderBundleEncoderFinish(e, addr descriptor)

proc finish*(e: RenderBundleEncoder): RenderBundle {.inline.} =
  wgpuRenderBundleEncoderFinish(e, nil)

proc setPipeline*(e: RenderBundleEncoder, pipeline: RenderPipeline) {.inline.} =
  wgpuRenderBundleEncoderSetPipeline(e, pipeline)

proc setBindGroup*(e: RenderBundleEncoder, groupIndex: uint32, group: BindGroup, dynamicOffsets: openarray[uint32]) {.inline.} =
  wgpuRenderBundleEncoderSetBindGroup(e, groupIndex, group, dynamicOffsets.len.csize_t, cast[ptr uint32](addr dynamicOffsets))

proc setBindGroup*(e: RenderBundleEncoder, groupIndex: uint32, group: BindGroup) {.inline.} =
  wgpuRenderBundleEncoderSetBindGroup(e, groupIndex, group, 0, nil)

proc setVertexBuffer*(e: RenderBundleEncoder, slot: uint32, buffer: Buffer, offset, size: uint64) {.inline.} =
  wgpuRenderBundleEncoderSetVertexBuffer(e, slot, buffer, offset, size)

proc setIndexBuffer*(e: RenderBundleEncoder, buffer: Buffer, format: IndexFormat, offset, size: uint64) {.inline.} =
  wgpuRenderBundleEncoderSetIndexBuffer(e, buffer, format, offset, size)

proc insertDebugMarker*(e: RenderBundleEncoder, label: StringView) {.inline.} =
  wgpuRenderBundleEncoderInsertDebugMarker(e, label)

proc pushDebugGroup*(e: RenderBundleEncoder, label: StringView) {.inline.} =
  wgpuRenderBundleEncoderPushDebugGroup(e, label)

proc popDebugGroup*(e: RenderBundleEncoder) {.inline.} =
  wgpuRenderBundleEncoderPopDebugGroup(e)

proc `label=`*(e: RenderBundleEncoder, label: StringView) {.inline.} =
  wgpuRenderBundleEncoderSetLabel(e, label)

proc `label=`*(e: RenderBundle, label: StringView) {.inline.} =
  wgpuRenderBundleSetLabel(e, label)

# Procs of QuerySet
proc destroy*(qs: QuerySet) {.inline.} = wgpuQuerySetDestroy(qs)
proc count*(qs: QuerySet): uint32 {.inline.} = wgpuQuerySetGetCount(qs)
proc typ*(qs: QuerySet): QueryType {.inline.} = wgpuQuerySetGetType(qs)
proc `label=`*(qs: QuerySet, label: StringView) {.inline.} = wgpuQuerySetSetLabel(qs, label)

# Label setters for remaining types
proc `label=`*(bg: BindGroup, label: StringView) {.inline.} = wgpuBindGroupSetLabel(bg, label)
proc `label=`*(bgl: BindGroupLayout, label: StringView) {.inline.} = wgpuBindGroupLayoutSetLabel(bgl, label)
proc `label=`*(pl: PipelineLayout, label: StringView) {.inline.} = wgpuPipelineLayoutSetLabel(pl, label)
proc `label=`*(s: Sampler, label: StringView) {.inline.} = wgpuSamplerSetLabel(s, label)
proc `label=`*(sm: ShaderModule, label: StringView) {.inline.} = wgpuShaderModuleSetLabel(sm, label)
proc `label=`*(s: Surface, label: StringView) {.inline.} = wgpuSurfaceSetLabel(s, label)

# Procs of ShaderModule
proc getCompilationInfo*(sm: ShaderModule, callbackInfo: CompilationInfoCallbackInfo): WGPUFuture {.inline.} =
  wgpuShaderModuleGetCompilationInfo(sm, callbackInfo)

# Procs of Surface (continued)
proc unconfigure*(s: Surface) {.inline.} = wgpuSurfaceUnconfigure(s)

# FreeMembers procs
proc freeMembers*(sf: SupportedFeatures) {.inline.} = wgpuSupportedFeaturesFreeMembers(sf)
proc freeMembers*(sf: SupportedWGSLLanguageFeatures) {.inline.} = wgpuSupportedWGSLLanguageFeaturesFreeMembers(sf)
proc freeMembers*(sc: SurfaceCapabilities) {.inline.} = wgpuSurfaceCapabilitiesFreeMembers(sc)

# Procs of Instance (continued)
proc getWGSLLanguageFeatures*(i: Instance, features: var SupportedWGSLLanguageFeatures) {.inline.} =
  wgpuInstanceGetWGSLLanguageFeatures(i, addr features)

proc waitAny*(i: Instance, futures: var openarray[FutureWaitInfo], timeoutNS: uint64): WaitStatus {.inline.} =
  wgpuInstanceWaitAny(i, futures.len.csize_t, addr futures[0], timeoutNS)

proc getCapabilities*(capabilities: var InstanceCapabilities): bool {.inline.} =
  wgpuGetInstanceCapabilities(addr capabilities) == sSuccess

# Procs of Device (continued)
proc getAdapterInfo*(device: Device): AdapterInfo {.inline.} = wgpuDeviceGetAdapterInfo(device)
proc getLostFuture*(device: Device): WGPUFuture {.inline.} = wgpuDeviceGetLostWGPUFuture(device)

# Procs of Texture (continued)
proc usage*(texture: Texture): TextureUsage {.inline.} = wgpuTextureGetUsage(texture)
