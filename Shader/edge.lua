-- # Property
-- Width : The width of the screen window in pixels
-- Height : The height of the screen window in pixels
-- EdgeThreshold : The minimum value of g squared required to be considered "on an edge"
-- RenderTex : The texture associated with the FBO

local vertex_shader = [[
#version 330 core
layout (location = 0) in vec3 position;
layout (location = 1) in vec2 texCoord;

out vec2 texCoord0;

void main()
{
    texCoord0 = texCoord;
    gl_Position = vec4(position, 1.0);
}
]]

local fragment_shader = [[
#version 330 core
out vec4 FragColor;

in vec2 texCoord0;

uniform sampler2D RenderTex;
uniform float EdgeThreshold;

const vec3 lum = vec3(0.2126, 0.7152, 0.0722);

float luminance( vec3 color ) {
    return dot(lum,color);
}

vec4 edge()
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
    FragColor = edge();
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}
