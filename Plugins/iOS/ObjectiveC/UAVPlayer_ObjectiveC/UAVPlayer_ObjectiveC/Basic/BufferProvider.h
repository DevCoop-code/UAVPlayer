//
//  BufferProvider.h
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/06.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Matrix4.h"
@import Metal;

NS_ASSUME_NONNULL_BEGIN

@interface BufferProvider : NSObject

//Store the Number of buffers
@property(nonatomic) NSInteger inflightBufferCount;

@property(nonatomic) dispatch_semaphore_t availableResourcesSemaphore;

//Create Number of Buffers
- (void) init:(id<MTLDevice>)device
inflightBuffersCount:(NSInteger)inflightBuffersCount
sizeOfUniformsBuffer:(NSInteger)sizeOfUniformsBuffer;

- (id<MTLBuffer>) nextUniformsBuffer:(Matrix4*)projectionMatrix
                     modelViewMatrix:(Matrix4*)mvMatrix;

@end

NS_ASSUME_NONNULL_END
