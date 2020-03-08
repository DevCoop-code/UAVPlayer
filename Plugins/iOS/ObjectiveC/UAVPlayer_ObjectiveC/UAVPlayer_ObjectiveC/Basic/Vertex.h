//
//  Vertex.h
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/06.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct VertexStruct
{
    float x,y,z;
    float r,g,b,a;
    float s,t;
}VertexStruct;

@interface Vertex : NSObject
@property(nonatomic) VertexStruct vertex;
- (void)setBuffer:(VertexStruct)vertex;
- (float*)floatBuffer;
@end

NS_ASSUME_NONNULL_END
