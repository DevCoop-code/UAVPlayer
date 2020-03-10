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

//MARK: Matrix transformation
- (void)scale:(float)x y:(float)y z:(float)z
{
    glkMatrix = GLKMatrix4Scale(glkMatrix, x, y, z);
}

- (void)rotateAroundX:(float)xAngleRad y:(float)yAngleRad z:(float)zAngleRad
{
    glkMatrix = GLKMatrix4Rotate(glkMatrix, xAngleRad, 1, 0, 0);
    glkMatrix = GLKMatrix4Rotate(glkMatrix, yAngleRad, 0, 1, 0);
    glkMatrix = GLKMatrix4Rotate(glkMatrix, zAngleRad, 0, 0, 1);
}

- (void)translate:(float)x y:(float)y z:(float)z
{
    glkMatrix = GLKMatrix4Translate(glkMatrix, x, y, z);
}

- (void)multiplyLeft:(Matrix4 *)matrix
{
    glkMatrix = GLKMatrix4Multiply(matrix->glkMatrix, glkMatrix);
}

//MARK: Helping Methods
- (void *)raw
{
    return glkMatrix.m;
}

- (void)printMatrixElements
{
    float *matrixElements = glkMatrix.m;
    NSLog(@"==========[Matrix Elements]==========");
    for(int i = 0; i < 16; i++)
    {
        float element = matrixElements[i];
        printf("%.0f ", element);
        if(i % 4 == 3)
        {
            printf("\n");
        }
    }
    NSLog(@"=====================================");
}

+ (float)degreesToRad:(float)degrees
{
    return GLKMathDegreesToRadians(degrees);
}

+ (NSUInteger)numberOfElements
{
    return 16;
}
@end
