//
//  ViewController.m
//  UAVP_MacOS
//
//  Created by HanGyo Jeong on 2020/12/11.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController {
    id<MTLDevice> device;
    id<MTLCommandQueue> commandQueue;
    
    AVPlayer* avPlayer;
    AVPlayerItemVideoOutput* videoOutput;
    
    CVMetalTextureCacheRef textureCache;
    CVPixelBufferRef pixelBuffer;
    
    id<MTLTexture> texture;
    MTLTextureType target;
    
    size_t width, height;
    
    CMTime curTime, curFrameTimestamp, lastFrameTimestamp;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initProperties];
    
    avPlayer = [[AVPlayer alloc] init];
    [self addObserver:self forKeyPath:@"avPlayer.currentItem.status" options:NSKeyValueObservingOptionNew context:AVPlayerItemStatusContext];
    [self addPeriodicTimeObserver];
    
    // Remove Video Output from old item
    [[avPlayer currentItem] removeOutput:videoOutput];
    AVPlayerItem* item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:@"https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"]];
    AVAsset* asset = [item asset];
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        if([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [item addOutput:self->videoOutput];
                [self->avPlayer replaceCurrentItemWithPlayerItem:item];
                [self->videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ONE_FRAME_DURAATION];
                [self->avPlayer play];
            });
        }
    }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)initProperties
{
    device = MTLCreateSystemDefaultDevice();
    commandQueue = [device newCommandQueue];
    
    NSDictionary* pixelBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixelBuffAttributes];
    
    width = height = 0;
    curTime = curFrameTimestamp = lastFrameTimestamp = kCMTimeZero;
    textureCache = nil;
}

- (void)addPeriodicTimeObserver
{
    // Invoke callback every half second
    CMTime interval = CMTimeMakeWithSeconds(0.4, NSEC_PER_SEC);
    // Queue on which to invoke the callback
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    // Aadd time observer
    [avPlayer addPeriodicTimeObserverForInterval:interval
                                           queue:mainQueue
                                      usingBlock:^(CMTime time) {
        // Use weak reference to self
    }];
}

// KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if(context == AVPlayerItemStatusContext)
    {
        AVPlayerStatus status = (AVPlayerStatus)[change[NSKeyValueChangeNewKey] integerValue];
        switch(status)
        {
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
