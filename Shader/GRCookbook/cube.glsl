// -- Prerequisite:
// -- PerFrameData.MVP
// local vertex_shader = [[
#version 460 core

layout(std140, binding = 0) uniform PerFrameData
{
    uniform mat4 model;
    uniform mat4 MVP;
    uniform vec4 cameraPos;
};

layout (location=0) out vec3 dir;

const vec3 pos[8] = vec3[8](
    vec3(-1.0,-1.0, 1.0),
    vec3( 1.0,-1.0, 1.0),
    vec3( 1.0, 1.0, 1.0),
    vec3(-1.0, 1.0, 1.0),

    vec3(-1.0,-1.0,-1.0),
    vec3( 1.0,-1.0,-1.0),
    vec3( 1.0, 1.0,-1.0),
    vec3(-1.0, 1.0,-1.0)
);

const int indices[36] = int[36](
    /* front*/
    0, 1, 2, 2, 3, 0,
    /* right*/
    1, 5, 6, 6, 2, 1,
    /* back*/
    7, 6, 5, 5, 4, 7,
    /* left*/
    4, 0, 3, 3, 7, 4,
    /* bottom*/
    4, 5, 1, 1, 0, 4,
    /* top*/
    3, 2, 6, 6, 7, 3
);

void main()
{
    int idx = indices[gl_VertexID];
    gl_Position = MVP * vec4(pos[idx], 1.0);
    dir = pos[idx].xyz;
}
// ]]

// local fragment_shader = [[
#version 460 core

layout (location=0) in vec3 dir;

layout (location=0) out vec4 out_FragColor;

layout (binding=1) uniform samplerCube texture1;

void main()
{
    out_FragColor = texture(texture1, dir);
}
// ]]

// return {
//     vertex_shader = vertex_shader,
//     fragment_shader = fragment_shader,
// }