//
//  UAVP.m
//  UAVPOSX
//
//  Created by HanGyo Jeong on 2020/12/11.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "UAVP.h"
#import "UAVPOSX_prefix.h"

@implementation UAVP

static UAVPTimeListener g_uavpTimeListener = NULL;

- (void)initPlayer {
    NSLog(@"Init UAVP OSX Plugin");

    [self initProperties];
    
    avPlayer = [[AVPlayer alloc] init];
    
    [self addObserver:self forKeyPath:@"avPlayer.currentItem.status" options:NSKeyValueObservingOptionNew context:AVPlayerItemStatusContext];
    
    [self addPeriodicTimeObserver];
}

- (void)openVideo:(NSURL*)url {
    NSLog(@"Open media path : %@", url);

    if(url != nil) {
        [self startToPlay:url];
    }
    else {
        NSLog(@"Problem in video path : %@", url);
    }
}

- (void)playVideo {
    [avPlayer play];
}

- (void)pauseVideo {
    [avPlayer pause];
}

- (void)seekVideo:(int)time {
    CMTime seekTime = CMTimeMake(time, 1);
    [avPlayer seekToTime:seekTime];
}

- (void)resumeVideo {
    
}

- (void)onPlayerReady {
    
}

- (void)onPlayerDidFinishPlayingVideo {
    
}

- (Boolean)canOutputTexture:(NSString*)videoPath {
    //Playback HLS
    if([videoPath rangeOfString:@".m3u8"].location != NSNotFound) {
        return YES;
    }
    else {  //Playback LocalVideo
        NSURL* fileURL = [NSURL fileURLWithPath:[[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:videoPath]];
        return [fileURL isFileURL];
    }
}
- (id<MTLTexture>)outputFrameTexture {
    CMTime time = [avPlayer currentTime];
    
    if(CMTimeCompare(time, curTime) == 0)
        return texture;
    curTime = time;
    
    pixelBuffer = NULL;
    if([videoOutput hasNewPixelBufferForItemTime:curTime]) {
        pixelBuffer = [videoOutput copyPixelBufferForItemTime:curTime itemTimeForDisplay:NULL];
        
        width = CVPixelBufferGetWidth(pixelBuffer);
        height = CVPixelBufferGetHeight(pixelBuffer);
        
        if(textureCache == nil) {
            CVMetalTextureRef textureOut = nil;
            
            CVReturn result = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache);
            
            if(result == kCVReturnSuccess) {
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
            else {
                NSLog(@"Failed to make texture Cache");
            }
            
            if(textureCache != nil) {
                CFRelease(textureCache);
                textureCache = nil;
            }
            if(textureOut != nil) {
                CVBufferRelease(textureOut);
                textureOut = nil;
            }
        }
    }
    
    if(nil != pixelBuffer) {
        CFRelease(pixelBuffer);
    }
    return texture;
}
- (size_t)getTextureWidth {
    return width;
}

- (size_t)getTextureHeight {
    return height;
}

- (void)releasePlayer {
    if(avPlayer != nil) {
        [avPlayer removeTimeObserver:self->timeObserver];
        [[avPlayer currentItem]removeOutput:videoOutput];
        avPlayer = nil;
    }

    curTime = kCMTimeZero;
    curFrameTimestamp = kCMTimeZero;
    lastFrameTimestamp = kCMTimeZero;

    if(textureCache != nil) {
        CFRelease(textureCache);
        textureCache = nil;
    }
    width = 0;
    height = 0;
}

- (void)setProperty:(int)type value:(int)param {
    switch (type) {
        case 0:
            if (param == 1) {
                autoplay = true;
            }
            else {
                autoplay = false;
            }
            break;
        case 1:
            if (param == 1) {
                loop = true;
            }
            else {
                loop = false;
            }
            break;
        case 2:
            if (param == 1) {
                mute = true;
            }
            else {
                mute = false;
            }
            break;
        default:
            break;
    }
}

- (void)startToPlay:(NSURL*)url {
    [self setupPlaybackForURL:url];
}

- (void)initProperties {
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

- (void)setupPlaybackForURL:(NSURL*)URL {
    //Remove video outtput from old item
    [[avPlayer currentItem] removeOutput:videoOutput];
    
    AVPlayerItem* item = [[AVPlayerItem alloc] initWithURL:URL];
    AVAsset* asset = [item asset];
    
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        if([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [item addOutput:self->videoOutput];
                [self->avPlayer replaceCurrentItemWithPlayerItem:item];
                [self->videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ONE_FRAME_DURATION];
                if (self->autoplay)
                    [self->avPlayer play];
            });
        }
    }];
}

- (void)addPeriodicTimeObserver {
    // Invoke callback every half second
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    // Queue on which to invoke the callback
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    // Add time observer
    self->timeObserver = [avPlayer addPeriodicTimeObserverForInterval:interval
                                              queue:mainQueue
                                         usingBlock:^(CMTime time) {
        // Use weak reference to self
        g_uavpTimeListener(1, CMTimeGetSeconds(time));
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
 MARK: Interface
 */
static UAVP* _GetPlayer() {
    static UAVP* _player = nil;
    if(!_player) {
        _player = [[UAVP alloc]init];
    }
    return _player;
}
static NSURL* _GetUrl(const char* filename)
{
    NSURL* url = nil;
    if(strstr(filename, "://"))
    {
        url = [NSURL URLWithString:[NSString stringWithUTF8String:filename]];
    }
    else
    {
        url = [NSURL URLWithString:[NSString stringWithUTF8String:filename]];
        
//        url = [NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithUTF8String:filename]]];
        
//        NSString* filePath = [NSString stringWithUTF8String:filename];
//        NSArray* arrString = [filePath componentsSeparatedByString:@"."];
//        NSString* streamingAssetFilePath = [NSString stringWithFormat:@"%@%@", @"StreamingAssets/", [arrString objectAtIndex:0]];
//        NSLog(@"File Name %@", [arrString objectAtIndex:0]);
//        url = [[NSBundle mainBundle]URLForResource:[arrString objectAtIndex:0] withExtension:@".mp4"];
    }
    
    return url;
}

bool UAVP_CanOutputToTexture(const char* filename) {
    return [_GetPlayer() canOutputTexture:[NSString stringWithUTF8String:filename]];
}

bool UAVP_PlayerReady() {
    return YES;
}

float UAVP_DurationSeconds() {
    return 0;
}

float UAVP_CurrentSeconds() {
    return 0;
}

void UAVP_VideoExtents(int* w, int* h) {
    *w = (int)([_GetPlayer() getTextureWidth]);
    *h = (int)([_GetPlayer() getTextureHeight]);
}

intptr_t UAVP_CurFrameTexture() {
    return (uintptr_t)(__bridge void*)([_GetPlayer() outputFrameTexture]);
}

int UAVP_InitPlayer() {
    [_GetPlayer() initPlayer];
    
    return 0;
}

int UAVP_OpenVideo(const char* filename) {
    [_GetPlayer() openVideo:_GetUrl(filename)];
    
    return 0;
}

int UAVP_PlayVideo() {
    [_GetPlayer() playVideo];
    
    return 0;
}

int UAVP_PauseVideo() {
    [_GetPlayer() pauseVideo];
    
    return 0;
}

void UAVP_SeekVideo(int time) {
    [_GetPlayer() seekVideo:time];
}

void UAVP_ReleasePlayer() {
    [_GetPlayer() releasePlayer];
}

void UAVP_setUAVPTimeListener(UAVPTimeListener listener) {
    g_uavpTimeListener = listener;
}

void UAVP_setUAVPProperty(int type, int param) {
    [_GetPlayer() setProperty:type value:param];
}
