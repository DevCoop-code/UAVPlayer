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

+ (Matrix4 *_Nonnull)makePerspectiveViewAngle:(float)angleRad
                                  aspectRatio:(float)aspect
                                        nearZ:(float)nearZ
                                         farZ:(float)farZ;

- (_Nonnull instancetype)init;
- (_Nonnull instancetype)copy;

- (void)scale:(float)x y:(float)y z:(float)z;
- (void)rotateAroundX:(float)xAngleRad y:(float)yAngleRad z:(float)zAngleRad;
- (void)translate:(float)x y:(float)y z:(float)z;
- (void)multiplyLeft:(Matrix4 *_Nonnull)matrix;

- (void *_Nonnull)raw;
+ (NSUInteger)numberOfElements;

@end

NS_ASSUME_NONNULL_END
