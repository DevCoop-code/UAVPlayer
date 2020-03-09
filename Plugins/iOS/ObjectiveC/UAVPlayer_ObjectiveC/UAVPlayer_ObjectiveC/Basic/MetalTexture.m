//
//  MetalTexture.m
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/08.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "MetalTexture.h"

@implementation MetalTexture

- (instancetype)init:(NSString *)resourceName ext:(NSString *)ext mipmaped:(Boolean)mipmaped
{
    _bytesPerPixel = 4;
    _bitsPerComponent = 8;
    
    _path = [[NSBundle mainBundle] pathForResource:resourceName ofType:ext];
    _width = 0;
    _height = 0;
    _depth = 1;
    _format = MTLPixelFormatRGBA8Unorm;
    _target = MTLTextureType2D;
    _texture = nil;
    _isMipmaped = mipmaped;
    
    self = [super init];
    return self;
}

// Actually creates MTLTexture
- (void)loadTexture:(id<MTLDevice>)device commandQ:(id<MTLCommandQueue>)commandQ flip:(Boolean)flip
{
    CGImageRef image = [[UIImage imageWithContentsOfFile:_path]CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    _width = CGImageGetWidth(image);
    _height = CGImageGetHeight(image);
    
    NSUInteger rowBytes = _width * _bytesPerPixel;
    
    //Create Bitmap Image Context
    CGContextRef context = CGBitmapContextCreate(nil,
                                                 _width,
                                                 _height,
                                                 _bitsPerComponent,
                                                 rowBytes,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    CGRect bounds = CGRectMake(0, 0, _width, _height);
    
    //Paints a transparent rectangle
    CGContextClearRect(context, bounds);
    
    //Draws an image in the specified area
    CGContextDrawImage(context, bounds, image);
    
    MTLTextureDescriptor *texDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                       width:_width
                                                      height:_height
                                                   mipmapped:_isMipmaped];
    _target = texDescriptor.textureType;
    _texture = [device newTextureWithDescriptor:texDescriptor];
    
    //Returns a pointer to the image data associated with a bitmap context
    void *pixelsData = CGBitmapContextGetData(context);
    //Returns a 2D, rectangular region for image or texture data
    MTLRegion region = MTLRegionMake2D(0, 0, _width, _height);
    
    //Copies a block of pixels into a section of texture slice
    [_texture replaceRegion:region mipmapLevel:0 withBytes:pixelsData bytesPerRow:rowBytes];
    
    if(_isMipmaped == YES)
    {
        [self generateMipMapLayersUsingSystemFunc:_texture device:device commandQ:commandQ block:^(id<MTLCommandBuffer> _Nonnull buffer) {
            NSLog(@"mips generated");
        }];
    }
    NSLog(@"mipCount:%lu", (unsigned long)_texture.mipmapLevelCount);
}

- (void)generateMipMapLayersUsingSystemFunc:(id<MTLTexture>)texture
                                     device:(id<MTLDevice>)device
                                   commandQ:(id<MTLCommandQueue>)commandQ
                                      block:(MTLCommandBufferHandler)block
{
    id<MTLCommandBuffer> commandBuffer = [commandQ commandBuffer];
    
    [commandBuffer addCompletedHandler:block];
    
    id<MTLBlitCommandEncoder> blitCommandEncoder = [commandBuffer blitCommandEncoder];
    [blitCommandEncoder generateMipmapsForTexture:texture];
    [blitCommandEncoder endEncoding];
    
    [commandBuffer commit];
}

@end