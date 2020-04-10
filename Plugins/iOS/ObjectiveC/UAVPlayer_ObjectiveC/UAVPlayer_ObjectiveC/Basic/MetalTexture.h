//
//  MetalTexture.h
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/08.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Metal;
@import UIKit;
@import VideoToolbox;
@import CoreVideo;

NS_ASSUME_NONNULL_BEGIN

@interface MetalTexture : NSObject

@property(nonatomic) id<MTLTexture> ytexture;
@property(nonatomic) id<MTLTexture> cbcrtexture;
@property(nonatomic) MTLTextureType target;
@property(nonatomic) size_t width;
@property(nonatomic) size_t height;
@property(nonatomic) NSInteger depth;
@property(nonatomic) MTLPixelFormat format;
@property(nonatomic) Boolean hasAlpha;
@property(nonatomic) NSString *path;
@property(nonatomic) Boolean isMipmaped;

@property(nonatomic) NSInteger bytesPerPixel;
@property(nonatomic) NSInteger bitsPerComponent;

- (instancetype) init:(Boolean)mipmaped;
- (void) loadVideoTexture:(id<MTLDevice>)device
                 commandQ:(id<MTLCommandQueue>)commandQ
              pixelBuffer:(CVPixelBufferRef)pixelBuffer
                     flip:(Boolean)flip;
- (void) generateMipMapLayersUsingSystemFunc:(id<MTLTexture>)texture
                                      device:(id<MTLDevice>)device
                                    commandQ:(id<MTLCommandQueue>)commandQ
                                       block:(MTLCommandBufferHandler)block;
@end

NS_ASSUME_NONNULL_END
