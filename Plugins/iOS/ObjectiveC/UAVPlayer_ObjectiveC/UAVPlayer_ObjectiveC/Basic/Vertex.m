//
//  Vertex.m
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/06.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "Vertex.h"

@implementation Vertex

- (instancetype)init:(float)x
                   y:(float)y
                   z:(float)z
                   r:(float)r
                   g:(float)g
                   b:(float)b
                   a:(float)a
                   s:(float)s
                   t:(float)t
{
    VertexStruct vertex;
    vertex.x = x;
    vertex.y = y;
    vertex.z = z;
    vertex.r = r;
    vertex.g = g;
    vertex.b = b;
    vertex.a = a;
    vertex.s = s;
    vertex.t = t;
    
    self = [super init];
    return self;
}

- (void)setBuffer:(VertexStruct)vertex
{
    _vertex = vertex;
}

- (float*)floatBuffer
{
    float vertexArray[9] = {_vertex.x, _vertex.y, _vertex.z, _vertex.r, _vertex.g, _vertex.b, _vertex.a, _vertex.s, _vertex.t};
    return vertexArray;
}

@end
