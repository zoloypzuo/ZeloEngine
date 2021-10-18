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

uniform sampler2D Texture0;
uniform float Weight[5];

vec4 pass3() {
    ivec2 pix = ivec2( gl_FragCoord.xy );
    vec4 sum = texelFetch(Texture0, pix, 0) * Weight[0];
    sum += texelFetchOffset( Texture0, pix, 0, ivec2(1,0) ) * Weight[1];
    sum += texelFetchOffset( Texture0, pix, 0, ivec2(-1,0) ) * Weight[1];
    sum += texelFetchOffset( Texture0, pix, 0, ivec2(2,0) ) * Weight[2];
    sum += texelFetchOffset( Texture0, pix, 0, ivec2(-2,0) ) * Weight[2];
    sum += texelFetchOffset( Texture0, pix, 0, ivec2(3,0) ) * Weight[3];
    sum += texelFetchOffset( Texture0, pix, 0, ivec2(-3,0) ) * Weight[3];
    sum += texelFetchOffset( Texture0, pix, 0, ivec2(4,0) ) * Weight[4];
    sum += texelFetchOffset( Texture0, pix, 0, ivec2(-4,0) ) * Weight[4];
    return sum;
}

void main()
{
    FragColor = pass3();
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}
