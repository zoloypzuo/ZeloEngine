local vertex_shader = [[
#version 120

uniform mat4 matrix;

attribute vec4 position;
attribute vec3 normal;
attribute vec2 uv;

varying vec2 fragment_uv;

void main() {
    gl_Position = matrix * position;
    fragment_uv = uv;
}
]]

local fragment_shader = [[
#version 120

uniform sampler2D sampler;
uniform float timer;

varying vec2 fragment_uv;

void main() {
    vec2 uv = vec2(timer, fragment_uv.t);
    gl_FragColor = texture2D(sampler, uv);
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}