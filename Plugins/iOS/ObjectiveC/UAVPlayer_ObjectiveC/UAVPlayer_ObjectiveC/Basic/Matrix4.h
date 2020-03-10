//
//  Matrix4.h
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/05.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKMath.h>

NS_ASSUME_NONNULL_BEGIN

@interface Matrix4 : NSObject
{
@public GLKMatrix4 glkMatrix;
}

+ (Matrix4 *_Nonnull)makePerspectiveViewAngle:(Float32)angleRad
                                  aspectRatio:(Float32)aspect
                                        nearZ:(Float32)nearZ
                                         farZ:(Float32)farZ;

- (_Nonnull instancetype)init;
- (_Nonnull instancetype)copy;

- (void)scale:(Float32)x y:(Float32)y z:(Float32)z;
- (void)rotateAroundX:(Float32)xAngleRad y:(Float32)yAngleRad z:(Float32)zAngleRad;
- (void)translate:(Float32)x y:(Float32)y z:(Float32)z;
- (void)multiplyLeft:(Matrix4 *_Nonnull)matrix;

- (void *_Nonnull)raw;
- (void)printMatrixElements;

+ (Float32)degreesToRad:(Float32)degrees;
+ (NSUInteger)numberOfElements;

@end

NS_ASSUME_NONNULL_END
