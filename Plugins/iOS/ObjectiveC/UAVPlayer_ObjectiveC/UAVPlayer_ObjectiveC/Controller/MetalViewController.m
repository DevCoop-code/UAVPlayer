//
//  MetalViewController.m
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/04.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "MetalViewController.h"
#import "Matrix4.h"

@implementation MetalViewController
{
    CADisplayLink *timer;
    CFTimeInterval lastFrameTimestamp;
    
    Matrix4 *projectionMatrix;
    
    id<MetalViewControllerDelegate> metalViewControllerDelegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initProperties];
}

- (void)initProperties
{
    lastFrameTimestamp = 0.0;
    
    _device = MTLCreateSystemDefaultDevice();
    
    projectionMatrix = [Matrix4 makePerspectiveViewAngle:85.0
                                             aspectRatio:self.view.bounds.size.width / self.view.bounds.size.height
                                                   nearZ:0.01
                                                    farZ:100];
    
    _metalLayer = [CAMetalLayer layer];
    _metalLayer.device = _device;
    _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    _metalLayer.framebufferOnly = YES;
    _metalLayer.frame = self.view.layer.frame;
    [self.view.layer addSublayer:_metalLayer];
    
    id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
    id<MTLFunction> vertexProgram = [defaultLibrary newFunctionWithName:@"basic_vertex"];
    id<MTLFunction> fragmentProgram = [defaultLibrary newFunctionWithName:@"basic_fragment"];
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction = vertexProgram;
    pipelineStateDescriptor.fragmentFunction = fragmentProgram;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    NSError *error;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if(error)
    {
        NSLog(@"Fail tto make PipelineStateDescriptor");
        return;
    }
    
    _commandQueue = [_device newCommandQueue];
    
    timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(newFrame:)];
    [timer addToRunLoop:NSRunLoop.mainRunLoop forMode:NSDefaultRunLoopMode];
}

- (void) render
{
    id<CAMetalDrawable> drawable = _metalLayer.nextDrawable;
    if(nil != drawable)
    {
        [metalViewControllerDelegate renderObject:drawable];
    }
}

- (void) newFrame:(CADisplayLink *)displayLink
{
    if(0.0 == lastFrameTimestamp)
    {
        lastFrameTimestamp = displayLink.timestamp;
    }
    
    NSTimeInterval elapsed = displayLink.timestamp - lastFrameTimestamp;
    lastFrameTimestamp = displayLink.timestamp;
    
    [self gameloop:elapsed];
}

- (void) gameloop:(CFTimeInterval)timeSinceLastUpdate
{
    @autoreleasepool
    {
        [self render];
    }
}

@end
