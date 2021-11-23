local vertex_shader = [[
#version 120

uniform mat4 matrix;

attribute vec4 position;

void main() {
    gl_Position = matrix * position;
}
]]

local fragment_shader = [[
#version 120

void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}