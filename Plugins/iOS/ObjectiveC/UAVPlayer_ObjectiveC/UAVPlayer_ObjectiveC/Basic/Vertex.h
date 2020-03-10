//
//  Vertex.h
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/06.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef struct VertexStruct
{
    Float32 x,y,z;
    Float32 r,g,b,a;
    Float32 s,t;
}VertexStruct;

@interface Vertex : NSObject

@property(nonatomic) VertexStruct vertex;

- (instancetype)init:(Float32)x y:(Float32)y z:(Float32)z r:(Float32)r g:(Float32)g b:(Float32)b a:(Float32)a s:(Float32)s t:(Float32)t;
- (void)setBuffer:(VertexStruct)vertex;
- (Float32 *)floatBuffer;

@end

NS_ASSUME_NONNULL_END
