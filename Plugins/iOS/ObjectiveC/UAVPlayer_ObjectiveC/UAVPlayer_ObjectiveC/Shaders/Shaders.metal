//
//  Shaders.metal
//  UAVPlayer_ObjectiveC
//
//  Created by HanGyo Jeong on 2020/03/05.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn
{
    packed_float3 position;
    packed_float4 color;
    packed_float2 texCoord;
};

struct VertexOut
{
    float4 position [[position]];
    float4 color;
    float2 texCoord;
};

struct Uniforms
{
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
};

vertex VertexOut basic_vertex(
                              const device VertexIn* vertex_array[[buffer(0)]],
                              const device Uniforms& uniforms[[buffer(1)]],
                              unsigned int vid[[vertex_id]])
{
    float4x4 mv_Matrix = uniforms.modelMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    
    VertexIn VertexIn = vertex_array[vid];
    
    VertexOut VertexOut;
    VertexOut.position = proj_Matrix * mv_Matrix * float4(VertexIn.position, 1);
    VertexOut.color = VertexIn.color;
    
    VertexOut.texCoord = VertexIn.texCoord;
    
    return VertexOut;
}

fragment float4 basic_fragment(
                               VertexOut interpolated [[stage_in]],
                               texture2d<float> tex2D [[texture(0)]],   //Receive Texture
                               sampler sampler2D [[sampler(0)]])        //Receive Sampler
{
    float4 color = tex2D.sample(sampler2D, interpolated.texCoord);
    return color;
}
