//
//  Node.m
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/06.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "Node.h"

@implementation Node
{
    BufferProvider *bufferProvider;
    
    float positionX, positionY, positionZ;
    float rotationX, rotationY, rotationZ;
    float scale;
    
    id<MTLSamplerState> samplerState;
}

- (void)init:(NSString *)name
      vertex:(NSArray<Vertex *> *)vertices
      device:(id<MTLDevice>)device
     texture:(id<MTLTexture>)texture
{
    [self initProperty];
    samplerState = [self defaultSampler:device];
    
    NSMutableArray *vertexDataArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [vertices count]; i++)
    {
        Vertex * vertexData = (Vertex *)[vertices objectAtIndex:i];;
        [vertexDataArray addObject:vertexData];
    }
    
    NSUInteger dataSize = [vertexDataArray count] * sizeof([vertexDataArray objectAtIndex:0]);
    _vertexBuffer = [device newBufferWithBytes:(__bridge const void * _Nonnull)(vertexDataArray) length:dataSize options:nil];
    
    _name = name;
    _device = device;
    _vertexCount = [vertices count];
    _texture = texture;
    
    bufferProvider = [[BufferProvider alloc] init:device
                             inflightBuffersCount:3
                             sizeOfUniformsBuffer:sizeof(float) * [Matrix4 numberOfElements] * 2];
    
}

- (void)initProperty
{
    positionX, positionY, positionZ = 0.0;
    rotationX, rotationY, rotationZ = 0.0;
    scale = 0.0;
}

- (void) render:(id<MTLCommandQueue>)commandQueue
renderPipelineState:(id<MTLRenderPipelineState>)pipelineState
       drawable:(id<CAMetalDrawable>)drawable
       mvMatrix:(Matrix4 *)parentModelViewMatrix
projectionMatrix:(Matrix4 *)projectionMatrix
     clearColor:(MTLClearColor)clearColor
{
    //Make CPU wait
    dispatch_semaphore_wait([bufferProvider availableResourcesSemaphore], DISPATCH_TIME_FOREVER);
    
    MTLRenderPassDescriptor *renderPassDescriptor = [[MTLRenderPassDescriptor alloc]init];
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 104.0/255.0, 5.0/255.0, 1.0);
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    //Signal the semaphore when the resource becomes available
    //When the GPU finishes rendering, it executes a completion handler to signal tthe semaphore the bumps its count back up again
    //addCompletedHandler: Registers a block of code that Metal calls immediately after the GPU finishes executing the commands in the command buffer
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull commandbuffer) {
        dispatch_semaphore_signal([bufferProvider availableResourcesSemaphore]);
    }];
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderEncoder setCullMode:MTLCullModeFront];
    [renderEncoder setRenderPipelineState:pipelineState];
    [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
    [renderEncoder setFragmentTexture:_texture atIndex:0];  //Passes the texture and sampler to the shaders
    
    if(nil != samplerState)
    {
        [renderEncoder setFragmentSamplerState:samplerState atIndex:0];
    }
    
    Matrix4 *nodeModelMatrix = [self modelMatrix];
    [nodeModelMatrix multiplyLeft:parentModelViewMatrix];
    
    id<MTLBuffer> uniformBuffer = [bufferProvider nextUniformsBuffer:projectionMatrix modelViewMatrix:nodeModelMatrix];
    
    [renderEncoder setVertexBuffer:uniformBuffer offset:0 atIndex:1];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_vertexCount instanceCount:_vertexCount/3];
    [renderEncoder endEncoding];
    
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

- (Matrix4 *)modelMatrix
{
    Matrix4 *matrix = [[Matrix4 alloc]init];
    [matrix translate:positionX y:positionY z:positionZ];
    [matrix rotateAroundX:rotationX y:rotationY z:rotationZ];
    [matrix scale:scale y:scale z:scale];
    
    return matrix;
}

- (id<MTLSamplerState>)defaultSampler:(id<MTLDevice>)device
{
    MTLSamplerDescriptor *sampler = [MTLSamplerDescriptor new];
    sampler.minFilter = MTLSamplerMinMagFilterNearest;
    sampler.magFilter = MTLSamplerMinMagFilterNearest;
    sampler.mipFilter = MTLSamplerMipFilterNearest;
    sampler.maxAnisotropy = 1;
    sampler.sAddressMode = MTLSamplerAddressModeClampToEdge;
    sampler.tAddressMode = MTLSamplerAddressModeClampToEdge;
    sampler.rAddressMode = MTLSamplerAddressModeClampToEdge;
    sampler.normalizedCoordinates = YES;
    sampler.lodMinClamp = 0;
    sampler.lodMaxClamp = FLT_MAX;
    
    return [device newSamplerStateWithDescriptor:sampler];
}

@end
