-- imgui.lua
-- created on 2021/6/5
-- author @zoloypzuo

-- FIXME-OPT: clip at vertex level
local vertex_shader = [[
#version 330

uniform mat4 MVP;

layout(location = 0) in vec2 i_pos;
layout(location = 1) in vec2 i_uv;
layout(location = 2) in vec4 i_col;

out vec4 col;
out vec2 pixel_pos;
out vec2 uv;

void main() {
   col = i_col;
   pixel_pos = i_pos;
   uv = i_uv;
   gl_Position = MVP * vec4(i_pos.x, i_pos.y, 0.0f, 1.0f);
};
]]

local fragment_shader = [[
#version 330

uniform sampler2D Tex;
uniform vec4 ClipRect;

in vec4 col;
in vec2 pixel_pos;
in vec2 uv;

out vec4 o_col;

void main() {
   o_col = texture(Tex, uv) * col;
//   if (pixel_pos.x < ClipRect.x || pixel_pos.y < ClipRect.y || pixel_pos.x > ClipRect.z || pixel_pos.y > ClipRect.w) discard;                                               // Clipping: using discard
//   if (step(ClipRect.x,pixel_pos.x) * step(ClipRect.y,pixel_pos.y) * step(pixel_pos.x,ClipRect.z) * step(pixel_pos.y,ClipRect.w) < 1.0f) discard;   // Clipping: using discard and step
   o_col.w *= (step(ClipRect.x,pixel_pos.x) * step(ClipRect.y,pixel_pos.y) * step(pixel_pos.x,ClipRect.z) * step(pixel_pos.y,ClipRect.w));                    // Clipping: branch-less, set alpha 0.0f
};
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}