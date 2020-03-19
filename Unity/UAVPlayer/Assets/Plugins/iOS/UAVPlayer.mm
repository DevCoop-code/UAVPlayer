#if UNITY_VERSION < 450
    #include "iPhone_View.h"
#endif

#include <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>

#include <stdlib.h>
#include <string.h>
#include <stdint.h>

@interface UAVPlayer: NSObject
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

extern "C" bool UAVP_CanOutputToTexture(const char* filename)
{
    printf("CanOutputToTexture called");
    return NO;
}

extern "C" bool UAVP_PlayerReady()
{
    printf("PlayerReady called");
    return NO;
}

extern "C" float UAVP_DurationSeconds()
{
    printf("DurationSeconds called");
    return 0;
}

extern "C" void UAVP_VideoExtents(int* w, int* h)
{
    printf("VideoExtents called");
    *w = 0;
    *h = 0;
}

extern "C" intptr_t UAVP_CurFrameTexture()
{
    printf("CurFrameTexture called");
    return NO;
}

extern "C" void UAVP_PlayVideo(const char* filename)
{
    printf("PlayVideo called");
}
