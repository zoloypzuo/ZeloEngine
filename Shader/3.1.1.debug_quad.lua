-- 3.1.1.debug_quad
-- created on 2021/4/30
-- author @zoloypzuo
return {
    vertex_shader = [[
#version 330 core
layout (location = 0) in vec3 position;
layout (location = 1) in vec2 texCoord;

out vec2 texCoord0;

void main()
{
    texCoord0 = texCoord;
    gl_Position = vec4(position, 1.0);
}
]];
    fragment_shader = [[
#version 330 core
out vec4 FragColor;

in vec2 texCoord0;

uniform sampler2D depthMap;
uniform float near_plane;
uniform float far_plane;

// required when using a perspective projection matrix
float LinearizeDepth(float depth)
{
    float z = depth * 2.0 - 1.0; // Back to NDC
    return (2.0 * near_plane * far_plane) / (far_plane + near_plane - z * (far_plane - near_plane));
}

void main()
{
    float depthValue = texture(depthMap, texCoord0).r;
    FragColor = vec4(vec3(depthValue), 1.0); // orthographic
}
]];
}
