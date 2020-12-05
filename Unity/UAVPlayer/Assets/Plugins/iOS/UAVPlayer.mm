#if UNITY_VERSION < 450
    #include "iPhone_View.h"
#endif

#include <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>
#include <Metal/Metal.h>
#include <VideoToolbox/VTUtilities.h>

#include <stdlib.h>
#include <string.h>
#include <stdint.h>

# define ONE_FRAME_DURATION 0.03

static void* AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface UAVPlayer: NSObject<AVPlayerItemOutputPullDelegate>
{
    id<MTLDevice> device;
    id<MTLCommandQueue> commandQueue;
    
    @public BOOL playerReady;
    
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
}
- (void)initPlayer;
- (void)openVideo:(NSURL*)url;
- (void)playVideo;
- (void)pauseVideo;
- (void)resumeVideo;
- (void)onPlayerReady;
- (void)onPlayerDidFinishPlayingVideo;
- (Boolean)canOutputTexture:(NSString*)videoPath;
- (id<MTLTexture>)outputFrameTexture;
- (size_t)getTextureWidth;
- (size_t)getTextureHeight;
- (void)releasePlayer;

@end

@implementation UAVPlayer

typedef void ( *UAVPTimeListener )(int, float);
static UAVPTimeListener g_uavpTimeListener = NULL;

- (void)initPlayer
{
    NSLog(@"Init UAVP");

    [self initProperties];
    
    avPlayer = [[AVPlayer alloc] init];
    
    [self addObserver:self forKeyPath:@"avPlayer.currentItem.status" options:NSKeyValueObservingOptionNew context:AVPlayerItemStatusContext];
}

- (void)openVideo:(NSURL*)url
{
    NSLog(@"Open media path : %@", url);

    if(url != nil)
    {
        [self startToPlay:url];
    }
    else
    {
        NSLog(@"Problem in video path : %@", url);
    }
}

- (void)playVideo
{    
    [avPlayer play];
}

- (void)initProperties
{
    device = MTLCreateSystemDefaultDevice();
    
    commandQueue = [device newCommandQueue];
    
    NSDictionary* pixelBuffAtttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixelBuffAtttributes];

    width = 0;
    height = 0;

    curTime = kCMTimeZero;
    curFrameTimestamp = kCMTimeZero;
    lastFrameTimestamp = kCMTimeZero;

    textureCache = nil;
}

- (void)onPlayerReady
{
    NSLog(@"player ready");
}

- (void)onPlayerDidFinishPlayingVideo
{
    NSLog(@"player did finish playing video");
}

- (Boolean)canOutputTexture:(NSString*)videoPath
{
    //Playback HLS
    if([videoPath rangeOfString:@".m3u8"].location != NSNotFound)
    {
        return YES;
    }
    else    //Playback LocalVideo
    {
        NSURL* fileURL = [NSURL fileURLWithPath:[[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:videoPath]];
        return [fileURL isFileURL];
    }
}

- (void)startToPlay:(NSURL*)url
{   
    [self setupPlaybackForURL:url];
}

- (id<MTLTexture>)outputFrameTexture
{
    CMTime time = [avPlayer currentTime];
    
    if(CMTimeCompare(time, curTime) == 0)
        return texture;
    curTime = time;
    
    pixelBuffer = NULL;
    if([videoOutput hasNewPixelBufferForItemTime:curTime])
    {
        pixelBuffer = [videoOutput copyPixelBufferForItemTime:curTime itemTimeForDisplay:NULL];
        
        width = CVPixelBufferGetWidth(pixelBuffer);
        height = CVPixelBufferGetHeight(pixelBuffer);
        
        if(textureCache == nil)
        {
            CVMetalTextureRef textureOut;
            
            CVReturn result = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache);
            
            if(result == kCVReturnSuccess)
            {
                CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                          textureCache,
                                                          pixelBuffer,
                                                          nil,
                                                          MTLPixelFormatBGRA8Unorm,
                                                          width,
                                                          height,
                                                          0,
                                                          &textureOut);
                texture = CVMetalTextureGetTexture(textureOut);
            }
            else
            {
                NSLog(@"Failed to make texture Cache");
            }
            
            if(textureCache != nil)
            {
                CFRelease(textureCache);
                textureCache = nil;
            }
            if(textureOut != nil)
            {
                CVBufferRelease(textureOut);
                textureOut = nil;
            }
        }
    }
    
    if(nil != pixelBuffer)
    {
        CFRelease(pixelBuffer);
    }
    return texture;
}

- (size_t)getTextureWidth
{
    return width;
}

- (size_t)getTextureHeight
{
    return height;
}

- (void)releasePlayer
{
    if(avPlayer != nil)
    {
        avPlayer = nil;
    }

    curTime = kCMTimeZero;
    curFrameTimestamp = kCMTimeZero;
    lastFrameTimestamp = kCMTimeZero;

    if(textureCache != nil)
    {
        CFRelease(textureCache);
        textureCache = nil;
    }
    width = 0;
    height = 0;
}

- (void)setupPlaybackForURL:(NSURL*)URL
{
    //Remove video outtput from old item
    [[avPlayer currentItem] removeOutput:videoOutput];
    
    AVPlayerItem* item = [[AVPlayerItem alloc] initWithURL:URL];
    AVAsset* asset = [item asset];
    
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        if([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [item addOutput:videoOutput];
                [avPlayer replaceCurrentItemWithPlayerItem:item];
                [videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ONE_FRAME_DURATION];
                [avPlayer play];
            });
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if(context == AVPlayerItemStatusContext)
    {
        AVPlayerStatus status = (AVPlayerStatus)[change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusUnknown:
                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                CMTime mediaTotalTime = [[[avPlayer currentItem]asset]duration];
                g_uavpTimeListener(0, CMTimeGetSeconds(mediaTotalTime));
            }
                break;
            case AVPlayerItemStatusFailed:
                break;
            default:
                break;
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end


/*
 =====Interface=====
 */
static UAVPlayer* _GetPlayer()
{
    static UAVPlayer* _player = nil;
    if(!_player)
    {
        _player = [[UAVPlayer alloc] init];
    }
    return _player;
}

static NSURL* _GetUrl(const char* filename)
{
    NSURL* url = nil;
    if(::strstr(filename, "://"))
    {
        url = [NSURL URLWithString:[NSString stringWithUTF8String:filename]];
    }
    else
    {
        url = [NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithUTF8String:filename]]];
    }
    
    return url;
}


extern "C" bool UAVP_CanOutputToTexture(const char* filename)
{
    return [_GetPlayer() canOutputTexture:[NSString stringWithUTF8String:filename]];
}

extern "C" bool UAVP_PlayerReady()
{
    return YES;
}

extern "C" float UAVP_DurationSeconds()
{
    return 0;
}

extern "C" float UAVP_CurrentSeconds()
{
    return 0;
}

extern "C" void UAVP_VideoExtents(int* w, int* h)
{
    *w = static_cast<int>([_GetPlayer() getTextureWidth]);
    *h = static_cast<int>([_GetPlayer() getTextureHeight]);
}

extern "C" intptr_t UAVP_CurFrameTexture()
{
    return (uintptr_t)(__bridge void*)([_GetPlayer() outputFrameTexture]);
}

extern "C" int UAVP_InitPlayer()
{
    [_GetPlayer() initPlayer];
    
    return 0;
}

extern "C" void UAVP_OpenVideo(const char* filename)
{
    [_GetPlayer() openVideo:_GetUrl(filename)];
}

extern "C" void UAVP_PlayVideo()
{
    [_GetPlayer() playVideo];
}

extern "C" void UAVP_PauseVideo()
{

}

extern "C" void UAVP_ResumeVideo()
{

}

extern "C" void UAVP_ReleasePlayer()
{

}

extern "C" void UAVP_setUAVPTimeListener(UAVPTimeListener listener)
{
    g_uavpTimeListener = listener;
}
