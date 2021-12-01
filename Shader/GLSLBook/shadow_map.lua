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
#version 330 core

void main()
{
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}