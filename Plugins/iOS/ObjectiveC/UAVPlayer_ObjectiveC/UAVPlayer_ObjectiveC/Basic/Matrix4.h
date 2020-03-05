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

@end

NS_ASSUME_NONNULL_END
