//
//  MetalTexture.m
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/08.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "MetalTexture.h"

@implementation MetalTexture
{
    CGColorSpaceRef colorSpace;
    
    CVMetalTextureCacheRef textureCache;
}

- (instancetype)init:(Boolean)mipmaped
{
    _width = 0;
    _height = 0;
    _depth = 1;
    _ytexture = nil;
    _cbcrtexture = nil;
    _isMipmaped = mipmaped;
    
    self = [super init];
    return self;
}

- (void)loadVideoTexture:(id<MTLDevice>)device
                commandQ:(id<MTLCommandQueue>)commandQ
             pixelBuffer:(nonnull CVPixelBufferRef)pixelBuffer
                    flip:(Boolean)flip
{
    _width = CVPixelBufferGetWidth(pixelBuffer);
    _height = CVPixelBufferGetHeight(pixelBuffer);
    
    if(textureCache == nil)
    {
        CVMetalTextureCacheRef yTextureCache, cbcrTextureCache;
        CVMetalTextureRef yTextureOut, cbcrTextureOut;
        
        CVReturn yresult = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &yTextureCache);
        
        if(yresult == kCVReturnSuccess)
        {
            textureCache = yTextureCache;
        }
        else
        {
            NSLog(@"Unable to allocate luma texture cache");
        }
        
        CVReturn yresultAboutTexture = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                  textureCache,
                                                  pixelBuffer,
                                                  nil,
                                                  MTLPixelFormatR8Unorm,
                                                  _width,
                                                  _height,
                                                  0,
                                                  &yTextureOut);
        if(yresultAboutTexture != kCVReturnSuccess)
        {
            NSLog(@"Fail to make texture %d", yresultAboutTexture);
        }
        _ytexture = CVMetalTextureGetTexture(yTextureOut);

        CVReturn cbcrresult = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &cbcrTextureCache);
        
        if(cbcrresult == kCVReturnSuccess)
        {
            textureCache = cbcrTextureCache;
        }
        else
        {
            NSLog(@"Unable to allocate chroma texture cache");
        }
        
        CVReturn cbcrresultAboutTexture = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                  textureCache,
                                                  pixelBuffer,
                                                  nil,
                                                  MTLPixelFormatRG8Unorm,
                                                  _width / 2,
                                                  _height / 2,
                                                  1,
                                                  &cbcrTextureOut);
        if(cbcrresultAboutTexture != kCVReturnSuccess)
        {
            NSLog(@"Fail to make texture %d", cbcrresultAboutTexture);
        }
        _cbcrtexture = CVMetalTextureGetTexture(cbcrTextureOut);
        
        if(yTextureCache != nil)
        {
            CFRelease(yTextureCache);
            yTextureCache = nil;
        }
        
        if(textureCache != nil)
        {
            CFRelease(textureCache);
            textureCache = nil;
        }
        
        if(cbcrTextureCache != nil)
        {
            cbcrTextureCache = nil;
        }
        
        if(yTextureOut != nil)
        {
            CVBufferRelease(yTextureOut);
            yTextureOut = nil;
        }
        if(cbcrTextureOut != nil)
        {
            CVBufferRelease(cbcrTextureOut);
            cbcrTextureOut = nil;
        }
    }
    
    //Legacy Code
    /*
    CGImageRef image = nil;
    VTCreateCGImageFromCVPixelBuffer(pixelBuffer, NULL, &image);
    
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

    if(context != nil)
    {
        CFRelease(context);
    }
    if(texDescriptor != nil)
    {
        texDescriptor = nil;
    }
    
    if(image != nil)
    {
        CFRelease(image);
    }
     */
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
