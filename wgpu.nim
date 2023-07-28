import yasync
when defined(wasm):
  import wasmrt
  export wasmrt.isNil

  type
    Adapter* = object of JSObj
    BindGroup* = object of JSObj
    BindGroupLayout* = object of JSObj
    Buffer* = object of JSObj
    CommandBuffer* = object of JSObj
    CommandEncoder* = object of JSObj
    ComputePassEncoder* = object of JSObj
    ComputePipeline* = object of JSObj
    Device* = object of JSObj
    Instance* = object of JSObj
    PipelineLayout* = object of JSObj
    QuerySet* = object of JSObj
    Queue* = object of JSObj
    RenderBundle* = object of JSObj
    RenderBundleEncoder* = object of JSObj
    RenderPassEncoder* = object of JSObj
    RenderPipeline* = object of JSObj
    Sampler* = object of JSObj
    ShaderModule* = object of JSObj
    Surface* = object of JSObj
    SwapChain* = object of JSObj
    Texture* = object of JSObj
    TextureView* = object of JSObj
else:
  type
    Adapter* = ptr object
    BindGroup* = ptr object
    BindGroupLayout* = ptr object
    Buffer* = ptr object
    CommandBuffer* = ptr object
    CommandEncoder* = ptr object
    ComputePassEncoder* = ptr object
    ComputePipeline* = ptr object
    Device* = ptr object
    Instance* = ptr object
    PipelineLayout* = ptr object
    QuerySet* = ptr object
    Queue* = ptr object
    RenderBundle* = ptr object
    RenderBundleEncoder* = ptr object
    RenderPassEncoder* = ptr object
    RenderPipeline* = ptr object
    Sampler* = ptr object
    ShaderModule* = ptr object
    Surface* = ptr object
    SwapChain* = ptr object
    Texture* = ptr object
    TextureView* = ptr object

type
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
    btNull = 0x00000000,
    btWebGPU = 0x00000001,
    btD3D11 = 0x00000002,
    btD3D12 = 0x00000003,
    btMetal = 0x00000004,
    btVulkan = 0x00000005,
    btOpenGL = 0x00000006,
    btOpenGLES = 0x00000007,

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

  ErrorType* {.size: sizeof(cint).} = enum
    etNoError = 0x00000000,
    etValidation = 0x00000001,
    etOutOfMemory = 0x00000002,
    etUnknown = 0x00000003,
    etDeviceLost = 0x00000004,

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
    pmImmediate = 0x00000000,
    pmMailbox = 0x00000001,
    pmFifo = 0x00000002,

  PrimitiveTopology* {.size: sizeof(cint).} = enum
    ptPointList = 0x00000000,
    ptLineList = 0x00000001,
    ptLineStrip = 0x00000002,
    ptTriangleList = 0x00000003,
    ptTriangleStrip = 0x00000004,

  QueryType* {.size: sizeof(cint).} = enum
    qtOcclusion = 0x00000000,
    qtPipelineStatistics = 0x00000001,
    qtTimestamp = 0x00000002,

  QueueWorkDoneStatus* {.size: sizeof(cint).} = enum
    qwdsSuccess = 0x00000000,
    qwdsError = 0x00000001,
    qwdsUnknown = 0x00000002,
    qwdsDeviceLost = 0x00000003,

  RenderPassTimestampLocation* {.size: sizeof(cint).} = enum
    rptlBeginning = 0x00000000,
    rptlEnd = 0x00000001,

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

  StoreOp* {.size: sizeof(cint).} = enum
    soUndefined = 0x00000000,
    soStore = 0x00000001,
    soDiscard = 0x00000002,

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

  TextureUsage* {.size: sizeof(cint).} = enum
    # none = 0x00000000,
    copySrc# = 0x00000001,
    copyDst# = 0x00000002,
    textureBinding# = 0x00000004,
    storageBinding# = 0x00000008,
    renderAttachment# = 0x00000010,

  ChainedStruct* {.inheritable, pure.} = object
    next*: ptr ChainedStruct
    sType*: SType

  PipelineLayoutDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    bindGroupLayoutCount*: uint32
    bindGroupLayouts*: BindGroupLayout

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
    maxDynamicUniformBuffersPerPipelineLayout*: uint32
    maxDynamicStorageBuffersPerPipelineLayout*: uint32
    maxSampledTexturesPerShaderStage*: uint32
    maxSamplersPerShaderStage*: uint32
    maxStorageBuffersPerShaderStage*: uint32
    maxStorageTexturesPerShaderStage*: uint32
    maxUniformBuffersPerShaderStage*: uint32
    maxUniformBufferBindingSize*: uint32
    maxStorageBufferBindingSize*: uint32
    minUniformBufferOffsetAlignment*: uint32
    minStorageBufferOffsetAlignment*: uint32
    maxVertexBuffers*: uint32
    maxVertexAttributes*: uint32
    maxVertexBufferArrayStride*: uint32
    maxInterStageShaderComponents*: uint32
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
    alphaToCoverageEnabled*: bool

  RequiredLimits* = object
    nextInChain*: ptr ChainedStruct
    limits*: Limits

  ShaderModuleDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    hintCount*: uint32
    hints*: ptr ShaderModuleCompilationHint

  ConstantEntry* = object
    nextInChain*: ptr ChainedStruct
    key*: cstring
    value*: float

  InstanceDescriptor* = object
    nextInChain*: ptr ChainedStruct

  RenderPassDepthStencilAttachment* = object
    view*: TextureView
    depthLoadOp*: LoadOp
    depthStoreOp*: StoreOp
    depthClearValue*: float32
    depthReadOnly*: bool
    stencilLoadOp*: LoadOp
    stencilStoreOp*: StoreOp
    stencilClearValue*: uint32
    stencilReadOnly*: bool

  RenderPassTimestampWrite* = object
    querySet*: QuerySet
    queryIndex*: uint32
    location*: RenderPassTimestampLocation

  RequestAdapterOptions* = object
    nextInChain*: ptr ChainedStruct
    compatibleSurface*: Surface # nullable
    powerPreference*: PowerPreference
    forceFallbackAdapter*: bool

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

  SurfaceDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable

  BlendComponent* = object
    operation*: BlendOperation
    srcFactor*: BlendFactor
    dstFactor*: BlendFactor

  BufferDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    usage*: set[BufferUsage]
    size*: uint64
    mappedAtCreation*: bool

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

  VertexBufferLayout* = object
    arrayStride*: uint64
    stepMode*: VertexStepMode
    attributeCount*: uint32
    attributes*: ptr VertexAttribute

  ColorTargetState* = object
    nextInChain*: ptr ChainedStruct
    format*: TextureFormat
    blend*: ptr BlendState # nullable
    writeMask*: set[ColorWriteMask]

  DeviceDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    requiredFeaturesCount*: uint32
    requiredFeatures*: ptr FeatureName
    requiredLimits*: ptr RequiredLimits # nullable
    defaultQueue*: QueueDescriptor

  RenderPassColorAttachment* = object
    view*: TextureView # nullable
    resolveTarget*: TextureView # nullable
    loadOp*: LoadOp
    storeOp*: StoreOp
    clearValue*: Color

  RenderPassDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    colorAttachmentCount*: uint32
    colorAttachments*: ptr RenderPassColorAttachment
    depthStencilAttachment*: ptr RenderPassDepthStencilAttachment #nullable
    occlusionQuerySet*: QuerySet # nullable
    timestampWriteCount*: uint32
    timestampWrites*: RenderPassTimestampWrite

  SurfaceDescriptorFromXlibWindow* = object of ChainedStruct
    display*: pointer
    window*: uint32

  SwapChainDescriptor* = object
    nextInChain*: ptr ChainedStruct
    label*: cstring # nullable
    usage*: set[TextureUsage]
    format*: TextureFormat
    width*: uint32
    height*: uint32
    presentMode*: PresentMode

  VertexAttribute* = object
    format*: VertexFormat
    offset*: uint64
    shaderLocation*: uint32

  BlendState* = object
    color*: BlendComponent
    alpha*: BlendComponent

  DepthStencilState* = object
    nextInChain*: ptr ChainedStruct
    format*: TextureFormat
    depthWriteEnabled*: bool
    depthCompare*: CompareFunction
    stencilFront*: StencilFaceState
    stencilBack*: StencilFaceState
    stencilReadMask*: uint32
    stencilWriteMask*: uint32
    depthBias*: int32
    depthBiasSlopeScale*: float32
    depthBiasClamp*: float32

  VertexState* = object
    nextInChain*: ptr ChainedStruct
    module*: ShaderModule
    entryPoint*: cstring
    constantCount*: uint32
    constants*: ptr ConstantEntry
    bufferCount*: uint32
    buffers*: ptr VertexBufferLayout

  FragmentState* = object
    nextInChain*: ptr ChainedStruct
    module*: ShaderModule
    entryPoint*: cstring
    constantCount*: uint32
    constants*: ptr ConstantEntry
    targetCount*: uint32
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

  ErrorCallback* = proc(e: ErrorType, message: cstring, userdata: pointer) {.cdecl.}
  RequestAdapterCallback* = proc(status: RequestAdapterStatus, adapter: Adapter, message: cstring, userdata: pointer) {.cdecl.}
  RequestDeviceCallback* = proc(status: RequestDeviceStatus, device: Device, message: cstring, userdata: pointer) {.cdecl.}

const
  cwmAll* = {cwmRed, cwmGreen, cwmBlue, cwmAlpha}

when defined(wasm):
  proc init() {.importwasmraw: """
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
""".}
  init()
elif defined(linux):
  when defined(amd64):
    {.pragma: w, dynlib: "./wgpu/linux-x86_64/libwgpu.so", importc.}
  elif defined(i386):
    {.pragma: w, dynlib: "./wgpu/linux-i686/libwgpu.so", importc.}

when defined(wasm):
  proc createInstance*(): Instance {.importwasmp: "navigator['gpu'] || null".}
  proc getPreferredCanvasFormat*(i: Instance): TextureFormat {.importwasmraw: "return _nimwct.indexOf(_nimo[$0].getPreferredCanvasFormat())"}

else:
  proc wgpuCreateInstance(descriptor: ptr InstanceDescriptor): Instance {.w.}
  proc createInstance*(): Instance {.inline.} =
    var d: InstanceDescriptor
    wgpuCreateInstance(addr d)

  proc createInstance*(descriptor: InstanceDescriptor): Instance {.inline.} = wgpuCreateInstance(addr descriptor)


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
    delete(adapter)

else:
  proc wgpuInstanceRequestAdapter(instance: Instance, options: ptr RequestAdapterOptions, callback: RequestAdapterCallback, userdata: pointer) {.w.}

  proc requestAdapterCallback(status: RequestAdapterStatus, adapter: Adapter, message: cstring, env: pointer) {.cdecl.} =
    let env = cast[Future[Adapter]](env)
    GC_unref(env)
    env.complete(adapter)

proc requestAdapter(instance: Instance, options: ptr RequestAdapterOptions): Future[Adapter] =
  result.new()
  GC_ref(result)
  let env = cast[pointer](result)
  wgpuInstanceRequestAdapter(instance, options, requestAdapterCallback, env)

proc requestAdapter*(instance: Instance, options: RequestAdapterOptions): Future[Adapter] {.inline.} = instance.requestAdapter(addr options)


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
  proc wgpuInstanceCreateSurface(instance: Instance, descriptor: ptr SurfaceDescriptor): Surface {.w.}
  proc createSurface*(instance: Instance, descriptor: SurfaceDescriptor): Surface {.inline.} = wgpuInstanceCreateSurface(instance, addr descriptor)

  proc wgpuAdapterRequestDevice(adapter: Adapter, descriptor: ptr DeviceDescriptor, callback: RequestDeviceCallback, userdata: pointer) {.w.}

  proc requestDeviceCallback(status: RequestDeviceStatus, device: Device, message: cstring, env: pointer) {.cdecl.} =
    let env = cast[Future[Device]](env)
    GC_unref(env)
    env.complete(device)

proc requestDevice(adapter: Adapter, options: ptr DeviceDescriptor): Future[Device] =
  result.new()
  GC_ref(result)
  let env = cast[pointer](result)
  wgpuAdapterRequestDevice(adapter, options, requestDeviceCallback, env)

proc requestDevice*(adapter: Adapter, options: DeviceDescriptor): Future[Device] {.inline.} = adapter.requestDevice(addr options)


# Methods of Device
when defined(wasm):
  proc createBuffer(device: Device, usage: uint32, size: uint32, mappedAtCreation: bool): Buffer {.importwasmraw: """
  return _nimok(_nimo[$0].createBuffer({usage: $1, size: $2, mappedAtCreation: $3}))
  """.}
  proc createBuffer*(device: Device, d: BufferDescriptor): Buffer {.inline.} =
    createBuffer(device, cast[uint32](d.usage), d.size.uint32, d.mappedAtCreation)
else:
  proc wgpuDeviceCreateBuffer(device: Device, descriptor: ptr BufferDescriptor): Buffer {.w.}
  proc createBuffer*(device: Device, descriptor: BufferDescriptor): Buffer {.inline.} =
    wgpuDeviceCreateBuffer(device, addr descriptor)

when defined(wasm):
  proc getQueue*(device: Device): Queue {.importwasmp: "queue".}
else:
  proc getQueue*(device: Device): Queue {.w, importc: "wgpuDeviceGetQueue".}

  proc wgpuDeviceSetUncapturedErrorCallback(device: Device, callback: ErrorCallback, userdata: pointer) {.w.}
  proc setUncapturedErrorCallback*(device: Device, callback: ErrorCallback, userdata: pointer = nil) {.inline.} =
    wgpuDeviceSetUncapturedErrorCallback(device, callback, userdata)

when defined(wasm):
  proc createCommandEncoder*(device: Device): CommandEncoder {.importwasmm.}
  proc wgpuDeviceCreateCommandEncoder(device: Device, descriptor: ptr CommandEncoderDescriptor): CommandEncoder {.inline.} =
    device.createCommandEncoder()
else:
  proc wgpuDeviceCreateCommandEncoder(device: Device, descriptor: ptr CommandEncoderDescriptor): CommandEncoder {.w.}
  proc createCommandEncoder*(device: Device): CommandEncoder {.inline.} =
    wgpuDeviceCreateCommandEncoder(device, nil)

proc createCommandEncoder*(device: Device, descriptor: CommandEncoderDescriptor): CommandEncoder {.inline.} =
  wgpuDeviceCreateCommandEncoder(device, addr descriptor)

template ptrArrayElem[T](p: ptr T, i: int): ptr T =
  addr cast[ptr UncheckedArray[T]](p)[i]


when defined(wasm):
  proc createPipeline(device: Device, layout: PipelineLayout, vsModule: ShaderModule, vsEntry: cstring, buffers, fsState: JSObj, topology: PrimitiveTopology, stripIndexFormat: IndexFormat, frontFace: FrontFace, cullMode: CullMode): RenderPipeline {.importwasmp: """
  createRenderPipeline({layout: _nimo[$1]||'auto', vertex: {module: _nimo[$2], entryPoint: _nimsj($3), buffers: _nimo[$4]}, fragment: _nimo[$5]||undefined, primitive: {topology: _nimwcp[$6], stripIndexFormat: _nimwci[$7], frontFace: _nimwcf[$8], cullMode: _nimwcc[$9]}})
  """.}

  proc makeFsState(m: ShaderModule, e: cstring, targets: JSObj): JSObj {.importwasmraw: """
  return _nimok({module: _nimo[$0], entryPoint: _nimsj($1), targets: _nimo[$2]})
  """}

  proc makeJsArray(count: uint32): JSObj {.importwasmf: "new Array".}

  proc addTarget(t: JSObj, idx: int32, format: TextureFormat) {.importwasmraw: "_nimo[$0][$1] = {format: _nimwct[$2]}".}
  proc addBufferLayout(t: JSObj, idx: int32, arrayStride: uint32, attrs: JSObj) {.importwasmraw: "_nimo[$0][$1] = {arrayStride: $2, attributes: _nimo[$3]}".}
  proc addAttribute(t: JSObj, idx: int32, fmt, offset, shaderLoc: uint32) {.importwasmraw: "_nimo[$0][$1] = {format: _nimwcv[$2], offset: $3, shaderLocation: $4}".}

  proc wgpuDeviceCreateRenderPipeline(device: Device, d: ptr RenderPipelineDescriptor): RenderPipeline =
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
      addBufferLayout(buffers, i.int32, tt.arrayStride.uint32, attributes)

    result = createPipeline(device, d.layout, d.vertex.module, d.vertex.entryPoint, buffers, fsState, d.primitive.topology, d.primitive.stripIndexFormat, d.primitive.frontFace, d.primitive.cullMode)
else:
  proc wgpuDeviceCreateSwapChain(device: Device, surface: Surface, descriptor: ptr SwapChainDescriptor): SwapChain {.w.}
  proc createSwapChain*(device: Device, surface: Surface, descriptor: SwapChainDescriptor): SwapChain {.inline.} =
    wgpuDeviceCreateSwapChain(device, surface, addr descriptor)

  proc wgpuDeviceCreateRenderPipeline(device: Device, descriptor: ptr RenderPipelineDescriptor): RenderPipeline {.w.}

proc createRenderPipeline*(device: Device, descriptor: RenderPipelineDescriptor): RenderPipeline {.inline.} =
  wgpuDeviceCreateRenderPipeline(device, addr descriptor)

when defined(wasm):
  proc createShaderModule*(device: Device, code: cstring): ShaderModule {.importwasmp: "createShaderModule({code:_nimsj($1)})".}
else:
  proc wgpuDeviceCreateShaderModule(device: Device, descriptor: ptr ShaderModuleDescriptor): ShaderModule {.w.}
  proc createShaderModule*(device: Device, descriptor: ShaderModuleDescriptor): ShaderModule {.inline.} =
    wgpuDeviceCreateShaderModule(device, addr descriptor)
  proc createShaderModule*(device: Device, code: cstring): ShaderModule {.inline.} =
    var shaderDesc: ShaderModuleDescriptor
    var shaderCodeDesc: ShaderModuleWGSLDescriptor
    shaderCodeDesc.sType = stShaderModuleWGSLDescriptor
    shaderCodeDesc.code = code
    shaderDesc.nextInChain = addr shaderCodeDesc
    createShaderModule(device, shaderDesc)

when defined(wasm):
  proc createPipelineLayout*(device: Device): PipelineLayout {.importwasmp: "createPipelineLayout({bindGroupLayouts:[]})".}
else:
  proc wgpuDeviceCreatePipelineLayout(device: Device, descriptor: ptr PipelineLayoutDescriptor): PipelineLayout {.w.}

  proc createPipelineLayout*(device: Device, descriptor: PipelineLayoutDescriptor): PipelineLayout {.inline.} =
    wgpuDeviceCreatePipelineLayout(device, addr descriptor)
  proc createPipelineLayout*(device: Device): PipelineLayout {.inline.} =
    var d: PipelineLayoutDescriptor
    wgpuDeviceCreatePipelineLayout(device, addr d)

# Methods of Queue
# # WGPU_EXPORT void wgpuQueueOnSubmittedWorkDone(WGPUQueue queue, WGPUQueueWorkDoneCallback callback, void * userdata);
# proc setLabel*(queue: Queue, label: cstring) {.w, importc: "wgpuQueueSetLabel".}

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
  proc wgpuQueueSubmit(queue: Queue, commandCount: uint32, commands: ptr CommandBuffer) {.w.}
  proc submit*(queue: Queue, commandCount: int, commands: ptr CommandBuffer) {.inline.} =
    wgpuQueueSubmit(queue, commandCount.uint32, commands)
  proc submit*(queue: Queue, command: CommandBuffer) {.inline.} = wgpuQueueSubmit(queue, 1, addr command)
  proc submit*(queue: Queue, commands: openarray[CommandBuffer]) {.inline.} = submit(queue, commands.len, cast[ptr CommandBuffer](addr commands))

when defined(wasm):
  proc writeBuffer*(queue: Queue, buffer: Buffer, bufferOffset: int, data: pointer, size: int) {.importwasmraw: """
  _nimo[$0].writeBuffer(_nimo[$1], $2, _nima.buffer, $3, $4)
  """.}
else:
  proc wgpuQueueWriteBuffer(queue: Queue, buffer: Buffer, bufferOffset: uint64, data: pointer, size: csize_t) {.w.}
  proc writeBuffer*(queue: Queue, buffer: Buffer, bufferOffset: int, data: pointer, size: int) {.inline.} =
    wgpuQueueWriteBuffer(queue, buffer, bufferOffset.uint64, data, size.csize_t)

# # WGPU_EXPORT void wgpuQueueWriteTexture(WGPUQueue queue, WGPUImageCopyTexture const * destination, void const * data, size_t dataSize, WGPUTextureDataLayout const * dataLayout, WGPUExtent3D const * writeSize);

# Methods of CommandEncoder
# WGPU_EXPORT WGPUComputePassEncoder wgpuCommandEncoderBeginComputePass(WGPUCommandEncoder commandEncoder, WGPUComputePassDescriptor const * descriptor /* nullable */);
when defined(wasm):
  proc beginRenderPass(e: CommandEncoder, c: JSObj): RenderPassEncoder {.importwasmp: """beginRenderPass({colorAttachments: _nimo[$1]})""".}

  proc addColorAttachment(a: JSObj, i: int32, tv: TextureView, cr, cg, cb, ca: float) {.importwasmraw: """
  _nimo[$0][$1] = {view: _nimo[$2], clearValue: {r: $3, g: $4, b: $5, a: $6}, loadOp: 'clear', storeOp: 'store'}
  """}
  proc wgpuCommandEncoderBeginRenderPass(commandEncoder: CommandEncoder, d: ptr RenderPassDescriptor): RenderPassEncoder =
    let colorAttachments = makeJsArray(d.colorAttachmentCount)
    let tt = cast[ptr UncheckedArray[RenderPassColorAttachment]](d.colorAttachments)
    for i in 0 ..< d.colorAttachmentCount.int:
      addColorAttachment(colorAttachments, i.int32, tt[i].view, tt[i].clearValue.r, tt[i].clearValue.g, tt[i].clearValue.b, tt[i].clearValue.a)
    beginRenderPass(commandEncoder, colorAttachments)
else:
  proc wgpuCommandEncoderBeginRenderPass(commandEncoder: CommandEncoder, descriptor: ptr RenderPassDescriptor): RenderPassEncoder {.w.}
proc beginRenderPass*(commandEncoder: CommandEncoder, descriptor: RenderPassDescriptor): RenderPassEncoder {.inline.} =
  wgpuCommandEncoderBeginRenderPass(commandEncoder, addr descriptor)

# # WGPU_EXPORT void wgpuCommandEncoderClearBuffer(WGPUCommandEncoder commandEncoder, WGPUBuffer buffer, uint64_t offset, uint64_t size);
# # WGPU_EXPORT void wgpuCommandEncoderCopyBufferToBuffer(WGPUCommandEncoder commandEncoder, WGPUBuffer source, uint64_t sourceOffset, WGPUBuffer destination, uint64_t destinationOffset, uint64_t size);
# # WGPU_EXPORT void wgpuCommandEncoderCopyBufferToTexture(WGPUCommandEncoder commandEncoder, WGPUImageCopyBuffer const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize);
# # WGPU_EXPORT void wgpuCommandEncoderCopyTextureToBuffer(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const * source, WGPUImageCopyBuffer const * destination, WGPUExtent3D const * copySize);
# # WGPU_EXPORT void wgpuCommandEncoderCopyTextureToTexture(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize);
when defined(wasm):
  proc finish*(commandEncoder: CommandEncoder): CommandBuffer {.importwasmm.}
else:
  proc wgpuCommandEncoderFinish(commandEncoder: CommandEncoder, descriptor: ptr CommandBufferDescriptor): CommandBuffer {.w.}
  proc finish*(commandEncoder: CommandEncoder, descriptor: CommandBufferDescriptor): CommandBuffer {.inline.} =
    wgpuCommandEncoderFinish(commandEncoder, addr descriptor)
  proc finish*(commandEncoder: CommandEncoder): CommandBuffer {.inline.} = wgpuCommandEncoderFinish(commandEncoder, nil)

# proc insertDebugMarker*(commandEncoder: CommandEncoder, markerLabel: cstring) {.w, importc: "wgpuCommandEncoderInsertDebugMarker".}
# # WGPU_EXPORT void wgpuCommandEncoderPopDebugGroup(WGPUCommandEncoder commandEncoder);
# # WGPU_EXPORT void wgpuCommandEncoderPushDebugGroup(WGPUCommandEncoder commandEncoder, char const * groupLabel);
# # WGPU_EXPORT void wgpuCommandEncoderResolveQuerySet(WGPUCommandEncoder commandEncoder, WGPUQuerySet querySet, uint32_t firstQuery, uint32_t queryCount, WGPUBuffer destination, uint64_t destinationOffset);
# # WGPU_EXPORT void wgpuCommandEncoderSetLabel(WGPUCommandEncoder commandEncoder, char const * label);
# # WGPU_EXPORT void wgpuCommandEncoderWriteTimestamp(WGPUCommandEncoder commandEncoder, WGPUQuerySet querySet, uint32_t queryIndex);

# # Methods of Surface
when defined(wasm):
  discard
else:
  proc getPreferredFormat*(surface: Surface, adapter: Adapter): TextureFormat {.w, importc: "wgpuSurfaceGetPreferredFormat".}

  # Methods of SwapChain
  proc getCurrentTextureView*(swapChain: SwapChain): TextureView {.w, importc: "wgpuSwapChainGetCurrentTextureView".}
  proc present*(swapChain: SwapChain) {.w, importc: "wgpuSwapChainPresent".}

  proc wgpuTextureViewDrop*(t: TextureView) {.w.}

# # Methods of RenderPassEncoder
# # WGPU_EXPORT void wgpuRenderPassEncoderBeginOcclusionQuery(WGPURenderPassEncoder renderPassEncoder, uint32_t queryIndex);
# # WGPU_EXPORT void wgpuRenderPassEncoderBeginPipelineStatisticsQuery(WGPURenderPassEncoder renderPassEncoder, WGPUQuerySet querySet, uint32_t queryIndex);
when defined(wasm):
  proc draw*(renderPassEncoder: RenderPassEncoder, vertexCount, instanceCount, firstVertex, firstInstance: uint32) {.importwasmm.}
else:
  proc draw*(renderPassEncoder: RenderPassEncoder, vertexCount, instanceCount, firstVertex, firstInstance: uint32) {.w, importc: "wgpuRenderPassEncoderDraw".}

# # WGPU_EXPORT void wgpuRenderPassEncoderDrawIndexed(WGPURenderPassEncoder renderPassEncoder, uint32_t indexCount, uint32_t instanceCount, uint32_t firstIndex, int32_t baseVertex, uint32_t firstInstance);
# # WGPU_EXPORT void wgpuRenderPassEncoderDrawIndexedIndirect(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
# # WGPU_EXPORT void wgpuRenderPassEncoderDrawIndirect(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
when defined(wasm):
  proc finish*(renderPassEncoder: RenderPassEncoder) {.importwasmm: "end".}
else:
  proc finish*(renderPassEncoder: RenderPassEncoder) {.w, importc: "wgpuRenderPassEncoderEnd".}
# # WGPU_EXPORT void wgpuRenderPassEncoderEndOcclusionQuery(WGPURenderPassEncoder renderPassEncoder);
# # WGPU_EXPORT void wgpuRenderPassEncoderEndPipelineStatisticsQuery(WGPURenderPassEncoder renderPassEncoder);
# # WGPU_EXPORT void wgpuRenderPassEncoderExecuteBundles(WGPURenderPassEncoder renderPassEncoder, uint32_t bundlesCount, WGPURenderBundle const * bundles);
# # WGPU_EXPORT void wgpuRenderPassEncoderInsertDebugMarker(WGPURenderPassEncoder renderPassEncoder, char const * markerLabel);
# # WGPU_EXPORT void wgpuRenderPassEncoderPopDebugGroup(WGPURenderPassEncoder renderPassEncoder);
# # WGPU_EXPORT void wgpuRenderPassEncoderPushDebugGroup(WGPURenderPassEncoder renderPassEncoder, char const * groupLabel);
# # WGPU_EXPORT void wgpuRenderPassEncoderSetBindGroup(WGPURenderPassEncoder renderPassEncoder, uint32_t groupIndex, WGPUBindGroup group, uint32_t dynamicOffsetCount, uint32_t const * dynamicOffsets);
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
  proc setVertexBuffer*(renderPassEncoder: RenderPassEncoder, slot: uint32, buffer: Buffer, offset, size: uint64) {.w, importc: "wgpuRenderPassEncoderSetVertexBuffer".}

# # WGPU_EXPORT void wgpuRenderPassEncoderSetViewport(WGPURenderPassEncoder renderPassEncoder, float x, float y, float width, float height, float minDepth, float maxDepth);
