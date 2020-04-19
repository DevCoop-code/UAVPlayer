//
//  MetalViewController.h
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/04.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

@import UIKit;
@import MetalKit;
#include "Matrix4.h"
#include <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MetalViewControllerDelegate <NSObject>

- (void) updateLogic:(CFTimeInterval) timeSinceLastUpdate;
- (void)renderObject:(id<CAMetalDrawable>)drawable pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

@interface MetalViewController : UIViewController <AVPlayerItemOutputPullDelegate>

@property(nonatomic) id<MTLDevice>              device;
@property(nonatomic) CAMetalLayer               *metalLayer;
@property(nonatomic) id<MTLRenderPipelineState> pipelineState;
@property(nonatomic) id<MTLCommandQueue>        commandQueue;
@property(nonatomic) id<MetalViewControllerDelegate> metalViewControllerDelegate;
@property(nonatomic) Matrix4 *projectionMatrix;

//For Video player
@property(nonatomic) AVPlayer* avPlayer;
@property(nonatomic) AVPlayerItemVideoOutput* videoOutput;

- (void)startToPlay:(NSString*)assetURL;
- (void)pausePlayer;
- (void)resumePlayer;

@end

NS_ASSUME_NONNULL_END
