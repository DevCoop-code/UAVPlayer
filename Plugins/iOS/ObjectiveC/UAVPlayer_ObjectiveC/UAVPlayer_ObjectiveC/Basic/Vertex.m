//
//  Vertex.m
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/06.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "Vertex.h"

@implementation Vertex

+ (float*)floatBuffer:(VertexStruct)vertex
{
    float vertexArray[9] = {vertex.x, vertex.y, vertex.z, vertex.r, vertex.g, vertex.b, vertex.a, vertex.s, vertex.t};
    return vertexArray;
}

@end
