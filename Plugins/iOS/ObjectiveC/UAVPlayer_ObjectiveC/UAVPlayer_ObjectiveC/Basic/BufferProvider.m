//
//  BufferProvider.m
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/06.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "BufferProvider.h"

@implementation BufferProvider
{
    //Store the Buffers themselves
    NSMutableArray<MTLBuffer> *_uniformsBuffers;
    //Index of the next available buffer
    NSInteger _availableBufferIndex;
}

//Create Number of Buffers
- (instancetype) init:(id<MTLDevice>)device
 inflightBuffersCount:(NSInteger)inflightBuffersCount
 sizeOfUniformsBuffer:(NSInteger)sizeOfUniformsBuffer
{
    _availableResourcesSemaphore = dispatch_semaphore_create(inflightBuffersCount);
    
    _inflightBufferCount = inflightBuffersCount;
    _uniformsBuffers = (id)[NSMutableArray new];
    
    for(int i = 0; i < inflightBuffersCount; i++)
    {
        id<MTLBuffer> uniformsBuffer = [device newBufferWithLength:sizeOfUniformsBuffer options:MTLResourceCPUCacheModeWriteCombined];
        [_uniformsBuffers addObject:uniformsBuffer];
    }
    
    return self;
}

- (id<MTLBuffer>) nextUniformsBuffer:(Matrix4 *)projectionMatrix
                     modelViewMatrix:(Matrix4 *)mvMatrix
{
    //Fetch MTLBuffer from the array at specific index
    id<MTLBuffer> buffer = _uniformsBuffers[_availableBufferIndex];
    
    //Get void* pointer
    void *bufferPointer = buffer.contents;
    
    //Copy the passed-in matrices data into the buffer using memcpy
    memcpy(bufferPointer, [mvMatrix raw], sizeof(Float32) * [Matrix4 numberOfElements]);
    memcpy(bufferPointer + (sizeof(Float32) * [Matrix4 numberOfElements]),
           [projectionMatrix raw],
           sizeof(Float32) * [Matrix4 numberOfElements]);
    
    _availableBufferIndex += 1;
    if(_availableBufferIndex == _inflightBufferCount)
    {
        _availableBufferIndex = 0;
    }
    return buffer;
}

- (void)dealloc
{
    for(int i = 0; i < _inflightBufferCount - 1; i++)
    {
        dispatch_semaphore_signal(_availableResourcesSemaphore);
    }
}

@end
