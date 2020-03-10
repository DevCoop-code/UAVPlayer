//
//  Node.h
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/06.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BufferProvider.h"
#import "Vertex.h"
#import "Matrix4.h"

@import QuartzCore;
@import Metal;

NS_ASSUME_NONNULL_BEGIN

@interface Node : NSObject

@property(nonatomic) id<MTLDevice> device;
@property(nonatomic) NSString *name;
@property(nonatomic) NSInteger vertexCount;
@property(nonatomic) id<MTLBuffer> vertexBuffer;
@property(nonatomic) CFTimeInterval time;
@property(nonatomic) id<MTLTexture> texture;

- (instancetype) init:(NSString *)name
       vertex:(NSArray<Vertex *>*)vertices
       device:(id<MTLDevice>)device
      texture:(id<MTLTexture>)texture;
- (void) render:(id<MTLCommandQueue>)commandQueue
renderPipelineState:(id<MTLRenderPipelineState>) pipelineState
       drawable:(id<CAMetalDrawable>) drawable
       mvMatrix: (Matrix4*)parentModelViewMatrix
projectionMatrix:(Matrix4*)projectionMatrix
     clearColor:(MTLClearColor *)clearColor;

@end

NS_ASSUME_NONNULL_END
