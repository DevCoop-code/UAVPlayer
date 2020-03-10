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
+ (Matrix4 *_Nonnull)makePerspectiveViewAngle:(Float32)angleRad
                                  aspectRatio:(Float32)aspect
                                        nearZ:(Float32)nearZ
                                         farZ:(Float32)farZ
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
- (void)scale:(Float32)x y:(Float32)y z:(Float32)z
{
    glkMatrix = GLKMatrix4Scale(glkMatrix, x, y, z);
}

- (void)rotateAroundX:(Float32)xAngleRad y:(Float32)yAngleRad z:(Float32)zAngleRad
{
    glkMatrix = GLKMatrix4Rotate(glkMatrix, xAngleRad, 1, 0, 0);
    glkMatrix = GLKMatrix4Rotate(glkMatrix, yAngleRad, 0, 1, 0);
    glkMatrix = GLKMatrix4Rotate(glkMatrix, zAngleRad, 0, 0, 1);
}

- (void)translate:(Float32)x y:(Float32)y z:(Float32)z
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
    Float32 *matrixElements = glkMatrix.m;
    printf("==========[Matrix Elements]==========\n");
    for(int i = 0; i < 16; i++)
    {
        Float32 element = matrixElements[i];
        printf("%.0f ", element);
        if(i % 4 == 3)
        {
            printf("\n");
        }
    }
    printf("=====================================\n");
}

+ (Float32)degreesToRad:(Float32)degrees
{
    return GLKMathDegreesToRadians(degrees);
}

+ (NSUInteger)numberOfElements
{
    return 16;
}
@end
