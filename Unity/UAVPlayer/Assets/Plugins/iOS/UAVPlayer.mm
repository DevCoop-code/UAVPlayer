#if UNITY_VERSION < 450
    #include "iPhone_View.h"
#endif

#include <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>

#include <stdlib.h>
#include <string.h>
#include <stdint.h>

static void* AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface UAVPlayer: NSObject<AVPlayerItemOutputPullDelegate>
{
    @public BOOL playerReady;
    
    AVPlayer* avPlayer;
    AVPlayerItemVideoOutput* videoOutput;
    
    CFTimeInterval lastFrameTimestamp;
}
- (void)playVideo:(NSURL*)url;
- (void)onPlayerReady;
- (void)onPlayerDidFinishPlayingVideo;
- (Boolean)canOutputTexture:(NSString*)videoPath;

@end

@implementation UAVPlayer
- (void)playVideo:(NSURL*)url
{
    NSLog(@"play video path : %@", url);
    
    avPlayer = [[AVPlayer alloc] init];
    
    [self addObserver:self forKeyPath:@"avPlayer.currentItem.status" options:NSKeyValueObservingOptionNew context:AVPlayerItemStatusContext];
    
    [self startToPlay:url];
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
    [avPlayer pause];
    
    [self setupPlaybackForURL:url];
}

- (void)setupPlaybackForURL:(NSURL*)URL
{
    AVPlayerItem* item = [[AVPlayerItem alloc] initWithURL:URL];
    AVAsset* asset = [item asset];
    
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        if([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [avPlayer replaceCurrentItemWithPlayerItem:item];
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
    return NO;
}

extern "C" float UAVP_DurationSeconds()
{
    return 0;
}

extern "C" void UAVP_VideoExtents(int* w, int* h)
{
    *w = 0;
    *h = 0;
}

extern "C" intptr_t UAVP_CurFrameTexture()
{
    return NO;
}

extern "C" void UAVP_PlayVideo(const char* filename)
{
    [_GetPlayer() playVideo:_GetUrl(filename)];
}
