//
//  Matrix4.m
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/05.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "Matrix4.h"

@implementation Matrix4

//MARK: Matrix creation
+ (Matrix4 *_Nonnull)makePerspectiveViewAngle:(float)angleRad
                                  aspectRatio:(float)aspect
                                        nearZ:(float)nearZ
                                         farZ:(float)farZ
{
    Matrix4 *matrix = [[Matrix4 alloc] init];
    matrix->glkMatrix = GLKMatrix4MakePerspective(angleRad, aspect, nearZ, farZ);
    return matrix;
}

- (instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        glkMatrix = GLKMatrix4Identity;
    }
    return self;
}

//MARK: Helping Methods
- (void *)raw
{
    return glkMatrix.m;
}

+ (NSUInteger)numberOfElements
{
    return 16;
}
@end
