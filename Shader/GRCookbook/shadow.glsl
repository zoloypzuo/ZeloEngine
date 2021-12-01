// local vertex_shader = [[
#version 460 core

layout(std140, binding = 0) uniform PerFrameData
{
    mat4 view;
    mat4 proj;
    mat4 light;
    vec4 cameraPos;
    vec4 frustumPlanes[6];
    vec4 frustumCorners[8];
    uint numShapesToCull;
};

layout(std430, binding = 1) restrict readonly buffer Matrices
{
    mat4 in_Model[];
};

layout (location=0) in vec3 in_Vertex;

void main()
{
    mat4 model = in_Model[gl_BaseInstance >> 16];

    gl_Position = proj * view * model * vec4(in_Vertex, 1.0);
}

// ]]

// local fragment_shader = [[
#version 460 core

layout (location=0) out vec4 out_FragColor;

void main()
{
    out_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
// ]]

// return {
//     vertex_shader = vertex_shader,
//     fragment_shader = fragment_shader,
// }