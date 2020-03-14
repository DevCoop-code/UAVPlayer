//
//  Vertex.m
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/06.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "Vertex.h"

@implementation Vertex

- (instancetype)init:(Float32)x
                   y:(Float32)y
                   z:(Float32)z
                   r:(Float32)r
                   g:(Float32)g
                   b:(Float32)b
                   a:(Float32)a
                   s:(Float32)s
                   t:(Float32)t
{
    _vertex.x = x;
    _vertex.y = y;
    _vertex.z = z;
    _vertex.r = r;
    _vertex.g = g;
    _vertex.b = b;
    _vertex.a = a;
    _vertex.s = s;
    _vertex.t = t;
    
    self = [super init];
    return self;
}

- (Float32*)floatBuffer
{
    Float32 vertexArray[9] = {_vertex.x, _vertex.y, _vertex.z, _vertex.r, _vertex.g, _vertex.b, _vertex.a, _vertex.s, _vertex.t};
    
    return vertexArray;
}

@end
