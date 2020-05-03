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

typedef enum
{
    unknownStatus = 0,
    openStatus = 1,
    playStatus = 2,
    pauseStatus = 3,
    releaseStatus = 4
} playerStatus;

typedef enum
{
    local = 0,
    hls_streaming = 1,
    dash_streaming
} mediaType;

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

@property(nonatomic) playerStatus p_Status;
@property(nonatomic) mediaType m_Type;
@property(nonatomic) CMTime currentPlayingTime;
@property(nonatomic) CMTime totalPlayTime;

- (void)startToPlay:(NSString*)assetURL;

@end

NS_ASSUME_NONNULL_END
