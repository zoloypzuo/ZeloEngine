-- # Property
-- Width : The width of the screen window in pixels
-- Height : The height of the screen window in pixels
-- EdgeThreshold : The minimum value of g squared required to be considered "on an edge"
-- RenderTex : The texture associated with the FBO

local vertex_shader = [[
#version 430

layout (location = 0) in vec3 VertexPosition;
layout (location = 1) in vec3 VertexNormal;

out vec3 Position;
out vec3 Normal;

uniform mat4 ModelViewMatrix;
uniform mat3 NormalMatrix;
uniform mat4 ProjectionMatrix;
uniform mat4 MVP;

void main()
{
    Normal = normalize( NormalMatrix * VertexNormal);
    Position = vec3( ModelViewMatrix * vec4(VertexPosition,1.0) );

    gl_Position = MVP * vec4(VertexPosition,1.0);
}
]]

local fragment_shader = [[
#version 430

in vec3 Position;

layout( binding=0 ) uniform sampler2D RenderTex;

uniform float EdgeThreshold;
uniform int Pass;

uniform struct LightInfo {
    vec4 Position;  // Light position in eye coords.
    vec3 L;  // D,S intensity
    vec3 La; // amb 
} Light;

uniform struct MaterialInfo {
    vec3 Ka;            // Ambient reflectivity
    vec3 Kd;            // Diffuse reflectivity
    vec3 Ks;            // Specular reflectivity
    float Shininess;    // Specular shininess factor
} Material;

layout( location = 0 ) out vec4 FragColor;
const vec3 lum = vec3(0.2126, 0.7152, 0.0722);


float luminance( vec3 color ) {
    return dot(lum,color);
}

vec4 pass2()
{
    ivec2 pix = ivec2(gl_FragCoord.xy);

    float s00 = luminance(texelFetchOffset(RenderTex, pix, 0, ivec2(-1,1)).rgb);
    float s10 = luminance(texelFetchOffset(RenderTex, pix, 0, ivec2(-1,0)).rgb);
    float s20 = luminance(texelFetchOffset(RenderTex, pix, 0, ivec2(-1,-1)).rgb);
    float s01 = luminance(texelFetchOffset(RenderTex, pix, 0, ivec2(0,1)).rgb);
    float s21 = luminance(texelFetchOffset(RenderTex, pix, 0, ivec2(0,-1)).rgb);
    float s02 = luminance(texelFetchOffset(RenderTex, pix, 0, ivec2(1,1)).rgb);
    float s12 = luminance(texelFetchOffset(RenderTex, pix, 0, ivec2(1,0)).rgb);
    float s22 = luminance(texelFetchOffset(RenderTex, pix, 0, ivec2(1,-1)).rgb);

    float sx = s00 + 2 * s10 + s20 - (s02 + 2 * s12 + s22);
    float sy = s00 + 2 * s01 + s02 - (s20 + 2 * s21 + s22);

    float g = sx * sx + sy * sy;

    if( g > EdgeThreshold )
        return vec4(1.0);
    else
        return vec4(0.0,0.0,0.0,1.0);
}

void main()
{
    if( Pass == 1 ) FragColor = pass1();
    if( Pass == 2 ) FragColor = pass2();
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}