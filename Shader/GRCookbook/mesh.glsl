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
// ]]

// local vertex_shader = [[
#version 460 core

#extension GL_ARB_gpu_shader_int64 : enable

// common:

layout(std140, binding = 0) uniform PerFrameData
{
    mat4 view;
    mat4 proj;
    vec4 cameraPos;
};

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

void main()
{
    mat4 model = in_Model[gl_InstanceID];
    mat4 MVP = proj * view * model;

    gl_Position = MVP * vec4(in_Vertex, 1.0);

    v_worldPos = (view * vec4(in_Vertex, 1.0)).xyz;
    v_worldNormal = transpose(inverse(mat3(model))) * in_Normal;
    v_tc = in_TexCoord;
    matIdx = gl_BaseInstance;
}
// ]]

// local fragment_shader = [[
#version 460 core

#extension GL_ARB_bindless_texture : require
#extension GL_ARB_gpu_shader_int64 : enable

// common:

layout(std140, binding = 0) uniform PerFrameData
{
    mat4 view;
    mat4 proj;
    vec4 cameraPos;
};

layout(std430, binding = 2) restrict readonly buffer Materials
{
    MaterialData in_Materials[];
};

layout (location=0) in vec2 v_tc;
layout (location=1) in vec3 v_worldNormal;
layout (location=2) in vec3 v_worldPos;
layout (location=3) in flat uint matIdx;

layout (location=0) out vec4 out_FragColor;

layout (binding = 5) uniform samplerCube texEnvMap;
layout (binding = 6) uniform samplerCube texEnvMapIrradiance;
layout (binding = 7) uniform sampler2D texBRDF_LUT;

void runAlphaTest(float alpha, float alphaThreshold)
{
    if (alphaThreshold > 0.0)
    {
        mat4 thresholdMatrix = mat4(
        1.0  / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0  / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
        );

        alpha = clamp(alpha - 0.5 * thresholdMatrix[int(mod(gl_FragCoord.x, 4.0))][int(mod(gl_FragCoord.y, 4.0))], 0.0, 1.0);

        if (alpha < alphaThreshold)
        discard;
    }
}

#include "pbr_sp.fsh"

void main()
{
    MaterialData mtl = in_Materials[matIdx];

    vec4 albedo = mtl.albedoColor_;
    vec3 normalSample = vec3(0.0, 0.0, 0.0);

    if (mtl.albedoMap_ > 0)
    albedo = texture( sampler2D(unpackUint2x32(mtl.albedoMap_)), v_tc);
    if (mtl.normalMap_ > 0)
    normalSample = texture( sampler2D(unpackUint2x32(mtl.normalMap_)), v_tc).xyz;

    runAlphaTest(albedo.a, mtl.alphaTest_);

    vec3 n = normalize(v_worldNormal);

    if (length(normalSample) > 0.5)
    n = perturbNormal(n, normalize(cameraPos.xyz - v_worldPos.xyz), normalSample, v_tc);

    vec3 lightDir = normalize(vec3(-1.0, 1.0, 0.1));

    float NdotL = clamp( dot( n, lightDir ), 0.3, 1.0 );

    out_FragColor = vec4( albedo.rgb * NdotL, 1.0 );
}
// ]]

// return {
//     common_shader = common_shader,
//     vertex_shader = vertex_shader,
//     fragment_shader = fragment_shader,
// }