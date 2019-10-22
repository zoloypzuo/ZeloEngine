/**
 * Ogre Wiki Source Code Public Domain (Un)License
 * The source code on the Ogre Wiki is free and unencumbered 
 * software released into the public domain.
 * 
 * Anyone is free to copy, modify, publish, use, compile, sell, or 
 * distribute this software, either in source code form or as a compiled 
 * binary, for any purpose, commercial or non-commercial, and by any 
 * means.
 * 
 * In jurisdictions that recognize copyright laws, the author or authors 
 * of this software dedicate any and all copyright interest in the 
 * software to the public domain. We make this dedication for the benefit 
 * of the public at large and to the detriment of our heirs and 
 * successors. We intend this dedication to be an overt act of 
 * relinquishment in perpetuity of all present and future rights to this 
 * software under copyright law.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * For more information, please refer to http://unlicense.org/
 */

/**
 * The source code in this file is attributed to the Ogre wiki article at
 * http://www.ogre3d.org/tikiwiki/tiki-index.php?page=Normal+Mapping+with+Hardware+Skinning+and+Specular&structure=Cookbook
 */

void animated_vs(
    float4 position : POSITION,
    float2 uv       : TEXCOORD0, 
    float3 normal   : NORMAL,
    float3 tangent  : TANGENT0,

    float4 blendIdx : BLENDINDICES,
    float4 blendWgt : BLENDWEIGHT,

    out float4 oPosition    : POSITION,
    out float2 oUV          : TEXCOORD0,
    out float3 oLightVector : TEXCOORD1,
    out float3 oHalfAngle   : TEXCOORD2,

    uniform float4 light_position,
    uniform float4 eye_position,
    uniform float3x4 worldMatrix3x4Array[60],
    uniform float4x4 viewProjectionMatrix,
    uniform float4x4 invworldmatrix)
{
    // Calculate the pixel position using the perspective matrix.
    oUV = uv;   

    // transform by indexed matrix
    float4 blendPos = float4(0,0,0,0);
    int i;
    for (i = 0; i < 3; ++i)
    {
        blendPos += float4(mul(worldMatrix3x4Array[blendIdx[i]], position).xyz, 1.0) * blendWgt[i];
    }
    // view / projection
    oPosition = mul(viewProjectionMatrix, blendPos);

    // transform normal
    float3 newnormal = float3(0,0,0);
    for (i = 0; i < 3; ++i)
    {
        newnormal += mul((float3x3)worldMatrix3x4Array[blendIdx[i]], normal) * blendWgt[i];
    }
    newnormal = mul((float3x3)invworldmatrix, newnormal); 
    newnormal = normalize(newnormal);

    // transform tangent
    float3 newtangent = float3(0,0,0);
    for (i = 0; i < 3; ++i)
    {
        newtangent += mul((float3x3)worldMatrix3x4Array[blendIdx[i]], tangent) * blendWgt[i];
    }
    newtangent = mul((float3x3)invworldmatrix, newtangent); 
    newtangent = normalize(newtangent);

    float3 binormal = cross(newtangent, newnormal);
    float3x3 rotation = float3x3(newtangent, binormal, newnormal);

    // Calculate the light vector in object space,
    // and then transform it into texture space.
    float3 temp_lightDir0 = normalize(light_position.xyz -  (blendPos * light_position.w));
    oLightVector = normalize(mul(rotation, temp_lightDir0));

    // Calculate the view vector in object space,
    // and then transform it into texture space.
    float3 eyeDir = normalize(eye_position - blendPos);
    eyeDir = normalize(mul(rotation, eyeDir.xyz));

    // Calculate the half angle
    oHalfAngle = oLightVector + eyeDir;
}

struct PS_INPUT_STRUCT
{
   float2 uv: TEXCOORD0;
   float3 light_vector: TEXCOORD1;
   float3 half_angle: TEXCOORD2;
};

float4 animated_fs(
    PS_INPUT_STRUCT psInStruct,
    uniform float4 ambient,
    uniform float3 lightDif0,
    uniform float3 lightSpec0,
    uniform float4 matDif,
    uniform float4 matSpec,
    uniform float matShininess,
    uniform sampler2D diffuseMap : TEXUNIT0,
    uniform sampler2D specMap : TEXUNIT1,
    uniform sampler2D normalMap : TEXUNIT2,
    uniform sampler2D emissiveMap : TEXUNIT3): COLOR0
{
    float3 base = tex2D( diffuseMap, psInStruct.uv ) * matDif.rgb;
    float3 bump = tex2D( normalMap, psInStruct.uv );
    float4 specular = tex2D(specMap, psInStruct.uv);

    //normalise
    float3 normalized_light_vector = normalize( psInStruct.light_vector );
    float3 normalized_half_angle = normalize( psInStruct.half_angle );

    bump = normalize( ( bump * 2.0f ) - 1.0f );

    // These dot products are used for the lighting model
    // equations.  The surface normal dotted with the light
    // vector is denoted by n_dot_l.  The normal vector
    // dotted with the half angle vector is denoted by n_dot_h.
    float4 n_dot_l = dot( bump, normalized_light_vector );
    float4 n_dot_h = dot( bump, normalized_half_angle );

    // Calculate the resulting pixel color,
    // based on our lighting model.
    // Ambient + Diffuse + Specular
    float3 light0C =
        max(tex2D( emissiveMap, psInStruct.uv), ( base * ambient)) +
        ( base * lightDif0 * max( 0, n_dot_l ) ) +
        ( lightSpec0 * specular.rgb * pow( max( 0, n_dot_h ), matShininess ) );

    return float4(light0C, 1.0f);
}

