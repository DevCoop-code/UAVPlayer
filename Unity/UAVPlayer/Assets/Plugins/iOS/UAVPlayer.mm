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
    
//    CADisplayLink* timer;
//    CFTimeInterval lastFrameTimestamp;
    
    CMTime curTime;
    CMTime curFrameTimestamp;
    CMTime lastFrameTimestamp;
    
    CVPixelBufferRef pixelBuffer;
    
    id<MTLTexture> texture;
    MTLTextureType target;
    
    size_t width;
    size_t height;
}
- (void)playVideo:(NSURL*)url;
- (void)onPlayerReady;
- (void)onPlayerDidFinishPlayingVideo;
- (Boolean)canOutputTexture:(NSString*)videoPath;
- (id<MTLTexture>)outputFrameTexture;
- (size_t)getTextureWidth;
- (size_t)getTextureHeight;

@end

@implementation UAVPlayer
- (void)playVideo:(NSURL*)url
{
    NSLog(@"play video path : %@", url);
    
    [self initProperties];
    
    avPlayer = [[AVPlayer alloc] init];
    
    [self addObserver:self forKeyPath:@"avPlayer.currentItem.status" options:NSKeyValueObservingOptionNew context:AVPlayerItemStatusContext];
    
    [self startToPlay:url];
}

- (void)initProperties
{
    device = MTLCreateSystemDefaultDevice();
    
    commandQueue = [device newCommandQueue];
    
//    timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(newFrame:)];
//    [timer addToRunLoop:NSRunLoop.mainRunLoop forMode:NSDefaultRunLoopMode];
    
    NSDictionary* pixelBuffAtttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(/*kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange*/kCVPixelFormatType_32BGRA)};
    videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixelBuffAtttributes];

    width = 0;
    height = 0;

    curTime = kCMTimeZero;
    curFrameTimestamp = kCMTimeZero;
    lastFrameTimestamp = kCMTimeZero;
}

- (void)newFrame:(CADisplayLink*)displayLink
{
//    CMTime outputItemTime = kCMTimeInvalid;
//
//    //Calculate the nextVsync time which is when the screen will be refreshed next
//    CFTimeInterval nextVSync = ([displayLink timestamp] + [displayLink duration]);
//    outputItemTime = [videoOutput itemTimeForHostTime:nextVSync];
//
//    pixelBuffer = NULL;
//    if([videoOutput hasNewPixelBufferForItemTime:outputItemTime])
//    {
//        pixelBuffer = [videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
//    }
//
//    //loadtexture
//    [self loadTexture];
//
//    if(nil != pixelBuffer)
//    {
//        CFRelease(pixelBuffer);
//    }
}

- (void)loadTexture
{
//    CGImageRef image = nil;
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//
//    if(pixelBuffer != nil)
//    {
//        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, NULL, &image);
//
//        width = CGImageGetWidth(image);
//        height = CGImageGetHeight(image);
//
//        NSUInteger rowBytes = width * 4;    //width * bytesPerPixel(4)
//
//        //Create Bitmap Image Context
//        CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, rowBytes, colorSpace, kCGImageAlphaPremultipliedLast);
//
//        MTLTextureDescriptor* texDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
//                                                                                                 width:width
//                                                                                                height:height
//                                                                                             mipmapped:YES];
//        target = texDescriptor.textureType;
//        texture = [device newTextureWithDescriptor:texDescriptor];
//
//        //Returns a pointer to the image data associated with a bitmap context
//        void* pixelData = CGBitmapContextGetData(context);
//        //Returns a 2D, rectangular region for image or texture data
//        MTLRegion region = MTLRegionMake2D(0, 0, width, height);
//
//        //Copies a block of pixels into a section of texture slice
//        [texture replaceRegion:region mipmapLevel:0 withBytes:pixelData bytesPerRow:rowBytes];
//
//        //Generate mipmap
//        id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
//        id<MTLBlitCommandEncoder> blitCommandEncoder = [commandBuffer blitCommandEncoder];
//        [blitCommandEncoder generateMipmapsForTexture:texture];
//        [blitCommandEncoder endEncoding];
//
//        [commandBuffer commit];
//    }
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

- (id<MTLTexture>)outputFrameTexture
{
    CMTime time = [avPlayer currentTime];
    
    if(CMTimeCompare(time, curTime) == 0)
        return texture;
    curTime = time;
    
    NSLog(@"curTime: %f", CMTimeGetSeconds(time));
    
    pixelBuffer = NULL;
    if([videoOutput hasNewPixelBufferForItemTime:curTime])
    {
        pixelBuffer = [videoOutput copyPixelBufferForItemTime:curTime itemTimeForDisplay:NULL];
        
        CGImageRef image = nil;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        if(pixelBuffer != nil)
        {
            VTCreateCGImageFromCVPixelBuffer(pixelBuffer, NULL, &image);
            
            width = CGImageGetWidth(image);
            height = CGImageGetHeight(image);
            
            NSUInteger rowBytes = width * 4;
            
            CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, rowBytes, colorSpace, kCGImageAlphaPremultipliedLast);
            
            MTLTextureDescriptor* texDescriptor;
            OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
            switch (pixelFormat) {
                case kCVPixelFormatType_32BGRA:     //32bit BGRA
                    if (@available(iOS 11.0, *)) {
                        texDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGR10A2Unorm
                                                                                           width:width
                                                                                          height:height
                                                                                       mipmapped:YES];
//                        NSLog(@"bgra 32");
                    } else {
                        NSLog(@"Unsupported iOS Version");
                    }
                    break;
                case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
                    texDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
                                                                                       width:width
                                                                                      height:height
                                                                                   mipmapped:YES];
                    break;
                default:
                    NSLog(@"unexpected pixel format %u", (unsigned int)pixelFormat);
                    break;
            }
            
            texture = [device newTextureWithDescriptor:texDescriptor];
            
            void* pixelData = CGBitmapContextGetData(context);
            MTLRegion region = MTLRegionMake2D(0, 0, width, height);
            
            [texture replaceRegion:region mipmapLevel:0 withBytes:pixelData bytesPerRow:rowBytes];
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

extern "C" void UAVP_VideoExtents(int* w, int* h)
{
    *w = static_cast<int>([_GetPlayer() getTextureWidth]);
    *h = static_cast<int>([_GetPlayer() getTextureHeight]);
}

extern "C" intptr_t UAVP_CurFrameTexture()
{
    return (uintptr_t)(__bridge void*)([_GetPlayer() outputFrameTexture]);
}

extern "C" void UAVP_PlayVideo(const char* filename)
{
    [_GetPlayer() playVideo:_GetUrl(filename)];
}
