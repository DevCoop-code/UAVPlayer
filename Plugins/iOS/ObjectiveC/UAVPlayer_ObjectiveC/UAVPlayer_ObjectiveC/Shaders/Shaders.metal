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
                               texture2d<float> ytex2D [[texture(0)]],   //Receive Texture
                               texture2d<float> cbcrtex2d [[texture(1)]],
                               sampler sampler2D [[sampler(0)]])        //Receive Sampler
{

    const float4x4 ycbcrToRGBTransform = float4x4(
        float4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
        float4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
        float4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
        float4(-0.7010f, +0.5291f, -0.8860f, +1.0000f)
    );
    
    float4 ycbcr = float4(ytex2D.sample(sampler2D, interpolated.texCoord).r, cbcrtex2d.sample(sampler2D, interpolated.texCoord).rg, 1.0);
    
    return ycbcrToRGBTransform * ycbcr;
}
