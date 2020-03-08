//
//  Vertex.m
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/06.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "Vertex.h"

@implementation Vertex

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
