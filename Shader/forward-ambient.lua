-- forward-ambient
-- created on 2021/4/30
-- author @zoloypzuo

local vertex_shader = [[
#version 330

layout(location = 0) in vec3 position;
layout(location = 1) in vec2 texCoord;

out vec2 texCoord0;

uniform mat4 View;
uniform mat4 Proj;
uniform mat4 World;

void main()
{
  gl_Position = Proj * View * World * vec4(position, 1.0);
  texCoord0 = texCoord;
}
]]

local fragment_shader = [[
#version 330

in  vec2 texCoord0;
out vec4 fragColor;

uniform vec3 ambientIntensity;

uniform sampler2D diffuseMap;

void main()
{
  fragColor = texture(diffuseMap, texCoord0) * vec4(ambientIntensity, 1.0f);
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}