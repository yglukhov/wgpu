proc wgpuCreateInstance*(descriptor: ptr InstanceDescriptor): InstancePtr {.w.}
proc wgpuGetInstanceCapabilities*(capabilities: ptr InstanceCapabilities): Status {.w.}
proc wgpuAdapterGetFeatures*(adapter: Adapter, features: ptr SupportedFeatures) {.w.}
proc wgpuAdapterGetInfo*(adapter: Adapter, info: ptr AdapterInfo): Status {.w.}
proc wgpuAdapterGetLimits*(adapter: Adapter, limits: ptr Limits): Status {.w.}
proc wgpuAdapterHasFeature*(adapter: Adapter, feature: FeatureName): Bool {.w.}
proc wgpuAdapterRequestDevice*(adapter: Adapter, descriptor: ptr DeviceDescriptor, callbackInfo {.bycopy.}: RequestDeviceCallbackInfo): WGPUFuture {.w.}
proc wgpuAdapterInfoFreeMembers*(adapterInfo: AdapterInfo) {.w.}
proc wgpuBindGroupSetLabel*(bindGroup: BindGroup, label: StringView) {.w.}
proc wgpuBindGroupLayoutSetLabel*(bindGroupLayout: BindGroupLayout, label: StringView) {.w.}
proc wgpuBufferDestroy*(buffer: Buffer) {.w.}
proc wgpuBufferGetConstMappedRange*(buffer: Buffer, offset, size: csize_t): pointer {.w.}
proc wgpuBufferGetMapState*(buffer: Buffer): BufferMapState {.w.}
proc wgpuBufferGetMappedRange*(buffer: Buffer, offset, size: csize_t): pointer {.w.}
proc wgpuBufferGetSize*(buffer: Buffer): uint64 {.w.}
proc wgpuBufferGetUsage*(buffer: Buffer): set[BufferUsage] {.w.}
proc wgpuBufferMapAsync*(buffer: Buffer, mode: set[MapMode], offset, size: csize_t, callbackInfo {.bycopy.}: BufferMapCallbackInfo): WGPUFuture {.w.}
proc wgpuBufferSetLabel*(buffer: Buffer, label: StringView) {.w.}
proc wgpuBufferUnmap*(buffer: Buffer) {.w.}
proc wgpuCommandBufferSetLabel*(commandBuffer: CommandBuffer, label: StringView) {.w.}
proc wgpuCommandEncoderBeginComputePass*(commandEncoder: CommandEncoder, descriptor: ptr ComputePassDescriptor): ComputePassEncoderPtr {.w.}
proc wgpuCommandEncoderBeginRenderPass*(commandEncoder: CommandEncoder, descriptor: ptr RenderPassDescriptor): RenderPassEncoderPtr {.w.}
proc wgpuCommandEncoderClearBuffer*(commandEncoder: CommandEncoder, buffer: Buffer, offset, size: uint64) {.w.}
proc wgpuCommandEncoderCopyBufferToBuffer*(commandEncoder: CommandEncoder, source: Buffer, sourceOffset: uint64, destination: Buffer, destinationOffset, size: uint64) {.w.}
proc wgpuCommandEncoderCopyBufferToTexture*(commandEncoder: CommandEncoder, source: ptr TexelCopyBufferInfo, destination: ptr TexelCopyTextureInfo, copySize: ptr Extent3D) {.w.}
proc wgpuCommandEncoderCopyTextureToBuffer*(commandEncoder: CommandEncoder, source: ptr TexelCopyTextureInfo, destination: ptr TexelCopyBufferInfo, copySize: ptr Extent3D) {.w.}
proc wgpuCommandEncoderCopyTextureToTexture*(commandEncoder: CommandEncoder, source, destination: ptr TexelCopyTextureInfo, copySize: ptr Extent3D) {.w.}
proc wgpuCommandEncoderFinish*(commandEncoder: CommandEncoder, descriptor: ptr CommandBufferDescriptor): CommandBufferPtr {.w.}
proc wgpuCommandEncoderInsertDebugMarker*(commandEncoder: CommandEncoder, markerLabel: StringView) {.w.}
proc wgpuCommandEncoderPopDebugGroup*(commandEncoder: CommandEncoder) {.w.}
proc wgpuCommandEncoderPushDebugGroup*(commandEncoder: CommandEncoder, groupLabel: StringView) {.w.}
proc wgpuCommandEncoderResolveQuerySet*(commandEncoder: CommandEncoder, querySet: QuerySet, firstQuery, queryCount: uint32, destination: Buffer, destinationOffset: uint64) {.w.}
proc wgpuCommandEncoderSetLabel*(commandEncoder: CommandEncoder, label: StringView) {.w.}
proc wgpuCommandEncoderWriteTimestamp*(commandEncoder: CommandEncoder, querySet: QuerySet, queryIndex: uint32) {.w.}
proc wgpuComputePassEncoderDispatchWorkgroups*(computePassEncoder: ComputePassEncoder, workgroupCountX, workgroupCountY, workgroupCountZ: uint32) {.w.}
proc wgpuComputePassEncoderDispatchWorkgroupsIndirect*(computePassEncoder: ComputePassEncoder, indirectBuffer: Buffer, indirectOffset: uint64) {.w.}
proc wgpuComputePassEncoderEnd*(computePassEncoder: ComputePassEncoder) {.w.}
proc wgpuComputePassEncoderInsertDebugMarker*(computePassEncoder: ComputePassEncoder, markerLabel: StringView) {.w.}
proc wgpuComputePassEncoderPopDebugGroup*(computePassEncoder: ComputePassEncoder) {.w.}
proc wgpuComputePassEncoderPushDebugGroup*(computePassEncoder: ComputePassEncoder, groupLabel: StringView) {.w.}
proc wgpuComputePassEncoderSetBindGroup*(computePassEncoder: ComputePassEncoder, groupIndex: uint32, group: BindGroup, dynamicOffsetCount: csize_t, dynamicOffsets: ptr uint32) {.w.}
proc wgpuComputePassEncoderSetLabel*(computePassEncoder: ComputePassEncoder, label: StringView) {.w.}
proc wgpuComputePassEncoderSetPipeline*(computePassEncoder: ComputePassEncoder, pipeline: ComputePipeline) {.w.}
proc wgpuComputePipelineGetBindGroupLayout*(computePipeline: ComputePipeline, groupIndex: uint32): BindGroupLayoutPtr {.w.}
proc wgpuComputePipelineSetLabel*(computePipeline: ComputePipeline, label: StringView) {.w.}
proc wgpuDeviceCreateBindGroup*(device: Device, descriptor: ptr BindGroupDescriptor): BindGroupPtr {.w.}
proc wgpuDeviceCreateBindGroupLayout*(device: Device, descriptor: ptr BindGroupLayoutDescriptor): BindGroupLayoutPtr {.w.}
proc wgpuDeviceCreateBuffer*(device: Device, descriptor: ptr BufferDescriptor): BufferPtr {.w.}
proc wgpuDeviceCreateCommandEncoder*(device: Device, descriptor: ptr CommandEncoderDescriptor): CommandEncoderPtr {.w.}
proc wgpuDeviceCreateComputePipeline*(device: Device, descriptor: ptr ComputePipelineDescriptor): ComputePipelinePtr {.w.}
proc wgpuDeviceCreateComputePipelineAsync*(device: Device, descriptor: ptr ComputePipelineDescriptor, callbackInfo {.bycopy.}: CreateComputePipelineAsyncCallbackInfo): WGPUFuture {.w.}
proc wgpuDeviceCreatePipelineLayout*(device: Device, descriptor: ptr PipelineLayoutDescriptor): PipelineLayoutPtr {.w.}
proc wgpuDeviceCreateQuerySet*(device: Device, descriptor: ptr QuerySetDescriptor): QuerySet {.w.}
proc wgpuDeviceCreateRenderBundleEncoder*(device: Device, descriptor: ptr RenderBundleEncoderDescriptor): RenderBundleEncoder {.w.}
proc wgpuDeviceCreateRenderPipeline*(device: Device, descriptor: ptr RenderPipelineDescriptor): RenderPipelinePtr {.w.}
proc wgpuDeviceCreateRenderPipelineAsync*(device: Device, descriptor: ptr RenderPipelineDescriptor, callbackInfo {.bycopy.}: CreateRenderPipelineAsyncCallbackInfo): WGPUFuture {.w.}
proc wgpuDeviceCreateSampler*(device: Device, descriptor: ptr SamplerDescriptor): SamplerPtr {.w.}
proc wgpuDeviceCreateShaderModule*(device: Device, descriptor: ptr ShaderModuleDescriptor): ShaderModulePtr {.w.}
proc wgpuDeviceCreateTexture*(device: Device, descriptor: ptr TextureDescriptor): TexturePtr {.w.}
proc wgpuDeviceDestroy*(device: Device) {.w.}
proc wgpuDeviceGetAdapterInfo*(device: Device): AdapterInfo {.w.}
proc wgpuDeviceGetFeatures*(device: Device, features: ptr SupportedFeatures) {.w.}
proc wgpuDeviceGetLimits*(device: Device, limits: ptr Limits): Status {.w.}
proc wgpuDeviceGetLostWGPUFuture*(device: Device): WGPUFuture {.w.}
proc wgpuDeviceGetQueue*(device: Device): QueuePtr {.w.}
proc wgpuDeviceHasFeature*(device: Device, feature: FeatureName): Bool {.w.}
proc wgpuDevicePopErrorScope*(device: Device, callbackInfo {.bycopy.}: PopErrorScopeCallbackInfo): WGPUFuture {.w.}
proc wgpuDevicePushErrorScope*(device: Device, filter: ErrorFilter) {.w.}
proc wgpuDeviceSetLabel*(device: Device, label: StringView) {.w.}
proc wgpuInstanceCreateSurface*(instance: Instance, descriptor: ptr SurfaceDescriptor): SurfacePtr {.w.}
proc wgpuInstanceGetWGSLLanguageFeatures*(instance: Instance, features: ptr SupportedWGSLLanguageFeatures) {.w.}
proc wgpuInstanceHasWGSLLanguageFeature*(instance: Instance, feature: WGSLLanguageFeatureName): Bool {.w.}
proc wgpuInstanceProcessEvents*(instance: Instance) {.w.}
proc wgpuInstanceRequestAdapter*(instance: Instance, options: ptr RequestAdapterOptions, callbackInfo {.bycopy.}: RequestAdapterCallbackInfo): WGPUFuture {.w.}
proc wgpuInstanceWaitAny*(instance: Instance, futureCount: csize_t, futures: ptr FutureWaitInfo, timeoutNS: uint64): WaitStatus {.w.}
proc wgpuPipelineLayoutSetLabel*(pipelineLayout: PipelineLayout, label: StringView) {.w.}
proc wgpuQuerySetDestroy*(querySet: QuerySet) {.w.}
proc wgpuQuerySetGetCount*(querySet: QuerySet): uint32 {.w.}
proc wgpuQuerySetGetType*(querySet: QuerySet): QueryType {.w.}
proc wgpuQuerySetSetLabel*(querySet: QuerySet, label: StringView) {.w.}
proc wgpuQueueOnSubmittedWorkDone*(queue: Queue, callbackInfo {.bycopy.}: QueueWorkDoneCallbackInfo): WGPUFuture {.w.}
proc wgpuQueueSetLabel*(queue: Queue, label: StringView) {.w.}
proc wgpuQueueSubmit*(queue: Queue, commandCount: csize_t, commands: ptr CommandBufferPtr) {.w.}
proc wgpuQueueWriteBuffer*(queue: Queue, buffer: Buffer, bufferOffset: uint64, data: pointer, size: csize_t) {.w.}
proc wgpuQueueWriteTexture*(queue: Queue, destination: ptr TexelCopyTextureInfo, data: pointer, dataSize: csize_t, dataLayout: ptr TexelCopyBufferLayout, writeSize: ptr Extent3D) {.w.}
proc wgpuRenderBundleSetLabel*(renderBundle: RenderBundle, label: StringView) {.w.}
proc wgpuRenderBundleEncoderDraw*(renderBundleEncoder: RenderBundleEncoder, vertexCount, instanceCount, firstVertex, firstInstance: uint32) {.w.}
proc wgpuRenderBundleEncoderDrawIndexed*(renderBundleEncoder: RenderBundleEncoder, indexCount, instanceCount, firstIndex: uint32, baseVertex: int32, firstInstance: uint32) {.w.}
proc wgpuRenderBundleEncoderDrawIndexedIndirect*(renderBundleEncoder: RenderBundleEncoder, indirectBuffer: Buffer, indirectOffset: uint64) {.w.}
proc wgpuRenderBundleEncoderDrawIndirect*(renderBundleEncoder: RenderBundleEncoder, indirectBuffer: Buffer, indirectOffset: uint64) {.w.}
proc wgpuRenderBundleEncoderFinish*(renderBundleEncoder: RenderBundleEncoder, descriptor: ptr RenderBundleDescriptor): RenderBundle {.w.}
proc wgpuRenderBundleEncoderInsertDebugMarker*(renderBundleEncoder: RenderBundleEncoder, markerLabel: StringView) {.w.}
proc wgpuRenderBundleEncoderPopDebugGroup*(renderBundleEncoder: RenderBundleEncoder) {.w.}
proc wgpuRenderBundleEncoderPushDebugGroup*(renderBundleEncoder: RenderBundleEncoder, groupLabel: StringView) {.w.}
proc wgpuRenderBundleEncoderSetBindGroup*(renderBundleEncoder: RenderBundleEncoder, groupIndex: uint32, group: BindGroup, dynamicOffsetCount: csize_t, dynamicOffsets: ptr uint32) {.w.}
proc wgpuRenderBundleEncoderSetIndexBuffer*(renderBundleEncoder: RenderBundleEncoder, buffer: Buffer, format: IndexFormat, offset, size: uint64) {.w.}
proc wgpuRenderBundleEncoderSetLabel*(renderBundleEncoder: RenderBundleEncoder, label: StringView) {.w.}
proc wgpuRenderBundleEncoderSetPipeline*(renderBundleEncoder: RenderBundleEncoder, pipeline: RenderPipeline) {.w.}
proc wgpuRenderBundleEncoderSetVertexBuffer*(renderBundleEncoder: RenderBundleEncoder, slot: uint32, buffer: Buffer, offset, size: uint64) {.w.}
proc wgpuRenderPassEncoderBeginOcclusionQuery*(renderPassEncoder: RenderPassEncoder, queryIndex: uint32) {.w.}
proc wgpuRenderPassEncoderDraw*(renderPassEncoder: RenderPassEncoder, vertexCount, instanceCount, firstVertex, firstInstance: uint32) {.w.}
proc wgpuRenderPassEncoderDrawIndexed*(renderPassEncoder: RenderPassEncoder, indexCount, instanceCount, firstIndex: uint32, baseVertex: int32, firstInstance: uint32) {.w.}
proc wgpuRenderPassEncoderDrawIndexedIndirect*(renderPassEncoder: RenderPassEncoder, indirectBuffer: Buffer, indirectOffset: uint64) {.w.}
proc wgpuRenderPassEncoderDrawIndirect*(renderPassEncoder: RenderPassEncoder, indirectBuffer: Buffer, indirectOffset: uint64) {.w.}
proc wgpuRenderPassEncoderEnd*(renderPassEncoder: RenderPassEncoder) {.w.}
proc wgpuRenderPassEncoderEndOcclusionQuery*(renderPassEncoder: RenderPassEncoder) {.w.}
proc wgpuRenderPassEncoderExecuteBundles*(renderPassEncoder: RenderPassEncoder, bundleCount: csize_t, bundles: ptr RenderBundle) {.w.}
proc wgpuRenderPassEncoderInsertDebugMarker*(renderPassEncoder: RenderPassEncoder, markerLabel: StringView) {.w.}
proc wgpuRenderPassEncoderPopDebugGroup*(renderPassEncoder: RenderPassEncoder) {.w.}
proc wgpuRenderPassEncoderPushDebugGroup*(renderPassEncoder: RenderPassEncoder, groupLabel: StringView) {.w.}
proc wgpuRenderPassEncoderSetBindGroup*(renderPassEncoder: RenderPassEncoder, groupIndex: uint32, group: BindGroup, dynamicOffsetCount: csize_t, dynamicOffsets: ptr uint32) {.w.}
proc wgpuRenderPassEncoderSetBlendConstant*(renderPassEncoder: RenderPassEncoder, color: ptr Color) {.w.}
proc wgpuRenderPassEncoderSetIndexBuffer*(renderPassEncoder: RenderPassEncoder, buffer: Buffer, format: IndexFormat, offset, size: uint64) {.w.}
proc wgpuRenderPassEncoderSetLabel*(renderPassEncoder: RenderPassEncoder, label: StringView) {.w.}
proc wgpuRenderPassEncoderSetPipeline*(renderPassEncoder: RenderPassEncoder, pipeline: RenderPipeline) {.w.}
proc wgpuRenderPassEncoderSetScissorRect*(renderPassEncoder: RenderPassEncoder, x, y, width, height: uint32) {.w.}
proc wgpuRenderPassEncoderSetStencilReference*(renderPassEncoder: RenderPassEncoder, reference: uint32) {.w.}
proc wgpuRenderPassEncoderSetVertexBuffer*(renderPassEncoder: RenderPassEncoder, slot: uint32, buffer: Buffer, offset, size: uint64) {.w.}
proc wgpuRenderPassEncoderSetViewport*(renderPassEncoder: RenderPassEncoder, x, y, width, height, minDepth, maxDepth: cfloat) {.w.}
proc wgpuRenderPipelineGetBindGroupLayout*(renderPipeline: RenderPipeline, groupIndex: uint32): BindGroupLayoutPtr {.w.}
proc wgpuRenderPipelineSetLabel*(renderPipeline: RenderPipeline, label: StringView) {.w.}
proc wgpuSamplerSetLabel*(sampler: Sampler, label: StringView) {.w.}
proc wgpuShaderModuleGetCompilationInfo*(shaderModule: ShaderModule, callbackInfo {.bycopy.}: CompilationInfoCallbackInfo): WGPUFuture {.w.}
proc wgpuShaderModuleSetLabel*(shaderModule: ShaderModule, label: StringView) {.w.}
proc wgpuSupportedFeaturesFreeMembers*(supportedFeatures: SupportedFeatures) {.w.}
proc wgpuSupportedWGSLLanguageFeaturesFreeMembers*(supportedWGSLLanguageFeatures: SupportedWGSLLanguageFeatures) {.w.}
proc wgpuSurfaceConfigure*(surface: Surface, config: ptr SurfaceConfiguration) {.w.}
proc wgpuSurfaceGetCapabilities*(surface: Surface, adapter: Adapter, capabilities: ptr SurfaceCapabilities): Status {.w.}
proc wgpuSurfaceGetCurrentTexture*(surface: Surface, surfaceTexture: ptr SurfaceTexture) {.w.}
proc wgpuSurfacePresent*(surface: Surface): Status {.w.}
proc wgpuSurfaceSetLabel*(surface: Surface, label: StringView) {.w.}
proc wgpuSurfaceUnconfigure*(surface: Surface) {.w.}
proc wgpuSurfaceCapabilitiesFreeMembers*(surfaceCapabilities: SurfaceCapabilities) {.w.}
proc wgpuTextureCreateView*(texture: Texture, descriptor: ptr TextureViewDescriptor): TextureViewPtr {.w.}
proc wgpuTextureDestroy*(texture: Texture) {.w.}
proc wgpuTextureGetDepthOrArrayLayers*(texture: Texture): uint32 {.w.}
proc wgpuTextureGetDimension*(texture: Texture): TextureDimension {.w.}
proc wgpuTextureGetFormat*(texture: Texture): TextureFormat {.w.}
proc wgpuTextureGetHeight*(texture: Texture): uint32 {.w.}
proc wgpuTextureGetMipLevelCount*(texture: Texture): uint32 {.w.}
proc wgpuTextureGetSampleCount*(texture: Texture): uint32 {.w.}
proc wgpuTextureGetUsage*(texture: Texture): TextureUsage {.w.}
proc wgpuTextureGetWidth*(texture: Texture): uint32 {.w.}
proc wgpuTextureSetLabel*(texture: Texture, label: StringView) {.w.}
proc wgpuTextureViewSetLabel*(textureView: TextureView, label: StringView) {.w.}
