//
//  UAVP.h
//  UAVPOSX
//
//  Created by HanGyo Jeong on 2020/12/11.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AVFoundation/AVFoundation.h>
#include <Metal/Metal.h>
#include <VideoToolbox/VTUtilities.h>

#include <stdlib.h>
#include <string.h>
#include <stdint.h>

NS_ASSUME_NONNULL_BEGIN

# define ONE_FRAME_DURATION 0.03

typedef void ( *UAVPTimeListener )(int, float);
static void* AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface UAVP : NSObject {
    id<MTLDevice> device;
    id<MTLCommandQueue> commandQueue;
    
    @public BOOL playerReady;
    BOOL autoplay;
    BOOL loop;
    BOOL mute;
    
    AVPlayer* avPlayer;
    AVPlayerItemVideoOutput* videoOutput;
    
    CMTime curTime;
    CMTime curFrameTimestamp;
    CMTime lastFrameTimestamp;
    
    CVMetalTextureCacheRef textureCache;
    CVPixelBufferRef pixelBuffer;
    
    id<MTLTexture> texture;
    MTLTextureType target;
    
    size_t width;
    size_t height;
    
    id timeObserver;
}

- (void)initPlayer;
- (void)openVideo:(NSURL*)url;
- (void)playVideo;
- (void)pauseVideo;
- (void)seekVideo:(int)time;
- (void)resumeVideo;
- (void)onPlayerReady;
- (void)onPlayerDidFinishPlayingVideo;
- (Boolean)canOutputTexture:(NSString*)videoPath;
- (id<MTLTexture>)outputFrameTexture;
- (size_t)getTextureWidth;
- (size_t)getTextureHeight;
- (void)releasePlayer;
- (void)setProperty:(int)type value:(int)param;

@end

NS_ASSUME_NONNULL_END
