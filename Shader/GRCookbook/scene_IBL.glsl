// local common_shader = [[
struct MaterialData
{
    vec4 emissiveColor_;
    vec4 albedoColor_;
    vec4 roughness_;

    float transparencyFactor_;
    float alphaTest_;
    float metallicFactor_;

    uint  flags_;

    uint64_t ambientOcclusionMap_;
    uint64_t emissiveMap_;
    uint64_t albedoMap_;
    uint64_t metallicRoughnessMap_;
    uint64_t normalMap_;
    uint64_t opacityMap_;
};

layout(std140, binding = 0) uniform PerFrameData
{
    uniform mat4 model;
    uniform mat4 MVP;
    uniform vec4 cameraPos;
};

struct Vertex
{
    float p[3];
    float n[3];
    float tc[2];
};

layout(std430, binding = 1) restrict readonly buffer Vertices
{
    Vertex in_Vertices[];
};
// ]]

// local vertex_shader = [[
#version 460 core

#extension GL_ARB_gpu_shader_int64 : enable

#include <data/shaders/chapter07/MaterialData.h>
#include <data/shaders/chapter10/GLBufferDeclarations.h>

layout(std430, binding = 1) restrict readonly buffer Matrices
{
    mat4 in_Model[];
};

layout (location=0) in vec3 in_Vertex;
layout (location=1) in vec2 in_TexCoord;
layout (location=2) in vec3 in_Normal;

layout (location=0) out vec2 v_tc;
layout (location=1) out vec3 v_worldNormal;
layout (location=2) out vec3 v_worldPos;
layout (location=3) out flat uint matIdx;
layout (location=4) out vec4 v_shadowCoord;

/* OpenGL's Z is in -1..1*/
const mat4 scaleBias = mat4(
0.5, 0.0, 0.0, 0.0,
0.0, 0.5, 0.0, 0.0,
0.0, 0.0, 0.5, 0.0,
0.5, 0.5, 0.5, 1.0 );

void main()
{
    mat4 model = in_Model[gl_BaseInstance >> 16];
    mat4 MVP = proj * view * model;

    gl_Position = MVP * vec4(in_Vertex, 1.0);

    v_worldPos = (view * vec4(in_Vertex, 1.0)).xyz;
    v_worldNormal = transpose(inverse(mat3(model))) * in_Normal;
    v_tc = in_TexCoord;
    matIdx = gl_BaseInstance & 0xffff;
    v_shadowCoord = scaleBias * light * model * vec4(in_Vertex, 1.0);
}
// ]]

// local fragment_shader = [[
#version 460 core

#extension GL_ARB_bindless_texture : require
#extension GL_ARB_gpu_shader_int64 : enable

#include <common_shader>

layout(std430, binding = 2) restrict readonly buffer Materials
{
    MaterialData in_Materials[];
};

layout (location=0) in vec2 v_tc;
layout (location=1) in vec3 v_worldNormal;
layout (location=2) in vec3 v_worldPos;
layout (location=3) in flat uint matIdx;
layout (location=4) in vec4 v_shadowCoord;

layout (location=0) out vec4 out_FragColor;

layout (binding = 4) uniform sampler2D textureShadow;

layout (binding = 5) uniform samplerCube texEnvMap;
layout (binding = 6) uniform samplerCube texEnvMapIrradiance;
layout (binding = 7) uniform sampler2D   texBRDF_LUT; /* not used, but required to include PBR.sp*/

#include <data/shaders/chapter07/AlphaTest.h>
#include "pbr_sp.fsh"

float PCF(int kernelSize, vec2 shadowCoord, float depth)
{
    float size = 1.0 / float( textureSize(textureShadow, 0 ).x );
    float shadow = 0.0;
    int range = kernelSize / 2;
    for ( int v=-range; v<=range; v++ ) for ( int u=-range; u<=range; u++ )
    shadow += (depth >= texture( textureShadow, shadowCoord + size * vec2(u, v) ).r) ? 1.0 : 0.0;
    return shadow / (kernelSize * kernelSize);
}

float shadowFactor(vec4 shadowCoord)
{
    /* check if shadows are disabled*/
    if (light[3][3] == 0.0)
    return 1.0;

    vec4 shadowCoords4 = shadowCoord / shadowCoord.w;

    if (shadowCoords4.z > -1.0 && shadowCoords4.z < 1.0)
    {
        float depthBias = -0.001;
        float shadowSample = PCF( 13, shadowCoords4.xy, shadowCoords4.z + depthBias );
        return mix(1.0, 0.3, shadowSample);
    }

    return 1.0;
}

void main()
{
    MaterialData mtl = in_Materials[matIdx];

    vec4 albedo = mtl.albedoColor_;
    vec3 normalSample = vec3(0.0, 0.0, 0.0);

    /* fetch albedo*/
    if (mtl.albedoMap_ > uint64_t(0))
    albedo = texture( sampler2D(unpackUint2x32(mtl.albedoMap_)), v_tc);
    if (mtl.normalMap_ > uint64_t(0))
    normalSample = texture( sampler2D(unpackUint2x32(mtl.normalMap_)), v_tc).xyz;

    runAlphaTest(albedo.a, mtl.alphaTest_);

    /* world-space normal*/
    vec3 n = normalize(v_worldNormal);

    /* normal mapping: skip missing normal maps*/
    if (length(normalSample) > 0.5)
    n = perturbNormal(n, normalize(cameraPos.xyz - v_worldPos.xyz), normalSample, v_tc);

    /* image-based lighting (diffuse only)*/
    vec3 f0 = vec3(0.04);
    vec3 diffuseColor = albedo.rgb * (vec3(1.0) - f0);
    vec3 diffuse = texture(texEnvMapIrradiance, n.xyz).rgb * diffuseColor;

    out_FragColor = vec4( diffuse * shadowFactor(v_shadowCoord), 1.0 );
}
// ]]

// return {
//     common_shader = common_shader,
//     vertex_shader = vertex_shader,
//     fragment_shader = fragment_shader,
// }