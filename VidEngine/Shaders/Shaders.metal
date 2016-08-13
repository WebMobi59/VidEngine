//
//  Shaders.metal
//
//  Created by David Gavilan on 3/31/16.
//  Copyright © 2016 David Gavilan. All rights reserved.
//

#include <metal_stdlib>
#include "ShaderCommon.h"
//#include "ShaderMath.h"

using namespace metal;

struct VertexInOut {
    float4  position [[position]];
    float4  color;
};

struct TexturedVertex
{
    packed_float3 position [[attribute(0)]];
    packed_float3 normal [[attribute(1)]];
    packed_float2 texCoords [[attribute(2)]];
};

vertex VertexInOut passVertexRaindrop(uint vid [[ vertex_id ]],
                                      constant packed_float4* position  [[ buffer(0) ]])
{
    VertexInOut outVertex;
    
    float4 posAndVelocity = position[vid];
    outVertex.position = float4(posAndVelocity.xy, 0, 1);
    outVertex.color    = float4(vid % 2, 1, 1, 0.1 + 0.5 * (vid % 2));
    return outVertex;
};

vertex VertexInOut passGeometry(uint vid [[ vertex_id ]],
                                constant TexturedVertex* vdata [[ buffer(0) ]],
                                constant Uniforms& uniforms  [[ buffer(1) ]])
{
    VertexInOut outVertex;
    /*
    float4x4 m = float4x4(float4(2.4,0.03,0.02,0.02), // 1st column
                  float4(-0.04,1.6,-0.02,-0.02), // 2nd col
                  float4(0.05,-0.03,-1,-1),
                  float4(0, 0, 19.8, 20));
     */
    float4x4 viewMatrix = float4x4(
        float4(1,0,0,0),
        float4(0,1,0,0),
        float4(0,0,1,0),
        float4(0,0,-4,1)
    );
    float4x4 m = uniforms.projectionMatrix * viewMatrix;
    TexturedVertex v = vdata[vid];
    outVertex.position = m * float4(v.position, 1.0);
    outVertex.color = float4(v.normal, 1);
    return outVertex;
}

fragment half4 passThroughFragment(VertexInOut inFrag [[stage_in]])
{
    return half4(inFrag.color);
};
