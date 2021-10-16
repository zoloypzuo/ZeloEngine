-- 3.1.1.shadow_mapping_depth
-- created on 2021/4/30
-- author @zoloypzuo
local vertex_shader = [[
#version 330 core
layout (location = 0) in vec3 position;

uniform mat4 lightSpaceMatrix;
uniform mat4 World;

void main()
{
    gl_Position = lightSpaceMatrix * World * vec4(position, 1.0);
}
]]

local fragment_shader = [[
#version 330 core

void main()
{
    // gl_FragDepth = gl_FragCoord.z;
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}