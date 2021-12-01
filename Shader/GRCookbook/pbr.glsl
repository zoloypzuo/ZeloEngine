// local vertex_shader = [[
#version 460 core

layout(std140, binding = 0) uniform PerFrameData
{
    mat4 view;
    mat4 proj;
    vec4 cameraPos;
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

layout(std430, binding = 2) restrict readonly buffer Matrices
{
    mat4 in_Model[];
};

vec3 getPosition(int i)
{
    return vec3(in_Vertices[i].p[0], in_Vertices[i].p[1], in_Vertices[i].p[2]);
}

vec3 getNormal(int i)
{
    return vec3(in_Vertices[i].n[0], in_Vertices[i].n[1], in_Vertices[i].n[2]);
}

vec2 getTexCoord(int i)
{
    return vec2(in_Vertices[i].tc[0], in_Vertices[i].tc[1]);
}

layout (location=0) out vec2 tc;
layout (location=1) out vec3 normal;
layout (location=2) out vec3 worldPos;

void main()
{
    mat4 model = in_Model[gl_DrawID];
    mat4 MVP = proj * view * model;

    vec3 pos = getPosition(gl_VertexID);
    gl_Position = MVP * vec4(pos, 1.0);

    tc = getTexCoord(gl_VertexID);

    mat3 normalMatrix = transpose( inverse(mat3(model)) );

    normal = normalMatrix  * getNormal(gl_VertexID);
    worldPos = ( in_Model[gl_DrawID] * vec4(pos, 1.0) ).xyz;
}
// ]]

// local fragment_shader = [[
#version 460 core

layout(std140, binding = 0) uniform PerFrameData
{
    mat4 view;
    mat4 proj;
    vec4 cameraPos;
};

layout (location=0) in vec2 tc;
layout (location=1) in vec3 normal;
layout (location=2) in vec3 worldPos;

layout (location=0) out vec4 out_FragColor;

layout (binding = 0) uniform sampler2D texAO;
layout (binding = 1) uniform sampler2D texEmissive;
layout (binding = 2) uniform sampler2D texAlbedo;
layout (binding = 3) uniform sampler2D texMetalRoughness;
layout (binding = 4) uniform sampler2D texNormal;

layout (binding = 5) uniform samplerCube texEnvMap;
layout (binding = 6) uniform samplerCube texEnvMapIrradiance;
layout (binding = 7) uniform sampler2D texBRDF_LUT;

#include "pbr_sp.fsh"

void main()
{
    vec4 Kao = texture(texAO, tc);
    vec4 Ke  = texture(texEmissive, tc);
    vec4 Kd  = texture(texAlbedo, tc);
    vec2 MeR = texture(texMetalRoughness, tc).yz;

    /* world-space normal*/
    vec3 n = normalize(normal);

    vec3 normalSample = texture(texNormal, tc).xyz;

    /* normal mapping*/
    n = perturbNormal(n, normalize(cameraPos.xyz - worldPos), normalSample, tc);

    vec4 mrSample = texture(texMetalRoughness, tc);

    PBRInfo pbrInputs;
    Ke.rgb = SRGBtoLINEAR(Ke).rgb;
    /* image-based lighting*/
    vec3 color = calculatePBRInputsMetallicRoughness(Kd, n, cameraPos.xyz, worldPos, mrSample, pbrInputs);
    /* one hardcoded light source*/
    color += calculatePBRLightContribution( pbrInputs, normalize(vec3(-1.0, -1.0, -1.0)), vec3(1.0) );
    /* ambient occlusion*/
    color = color * ( Kao.r < 0.01 ? 1.0 : Kao.r );
    /* emissive*/
    color = pow( Ke.rgb + color, vec3(1.0/2.2) );

    out_FragColor = vec4(color, 1.0);

    /*	out_FragColor = vec4((n + vec3(1.0))*0.5, 1.0);*/
    /*	out_FragColor = Kao;*/
    /*	out_FragColor = Ke;*/
    /*	out_FragColor = Kd;*/
    /*	out_FragColor = vec4(MeR, 0.0, 1.0);*/
}

// ]]

// return {
//     vertex_shader = vertex_shader,
//     fragment_shader = fragment_shader,
// }