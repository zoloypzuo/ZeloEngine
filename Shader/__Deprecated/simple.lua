-- simple
-- created on 2021/4/30
-- author @zoloypzuo
local vertex_shader = [[
#version 330

layout(location = 0) in vec3 position;

uniform mat4 View;
uniform mat4 Proj;
uniform mat4 World;

void main()
{
  gl_Position = Proj * View * World * vec4(position, 1.0);
}
]]

local fragment_shader = [[
#version 330

out vec4 fragColor;

void main()
{
  fragColor = vec4(1.0f, 0.0f, 0.0f, 1.0f);
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}