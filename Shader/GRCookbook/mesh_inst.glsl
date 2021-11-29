// -- forward_standard
// -- created on 2021/11/7
// -- author @zoloypzuo
// local common_shader = [[
// ...
// ]]

// local vertex_shader = [[
#version 460 core

layout(std140, binding = 0) uniform PerFrameData
{
    mat4 view;
    mat4 proj;
    vec4 cameraPos;
};

layout(std430, binding = 2) restrict readonly buffer Matrices
{
    mat4 in_Model[];
};

layout (location=0) in vec3 pos;

layout (location=0) out vec2 uv;
layout (location=1) out vec3 wpos;

void main()
{
    mat4 MVP = proj * view * in_Model[gl_InstanceID];

    gl_Position = MVP * vec4(pos, 1.0);

    wpos = pos;

    uv = vec2(0.5, 0.5);
}
// ]]

// local geometry_shader = [[
#version 460 core

layout( triangles ) in;
layout( triangle_strip, max_vertices = 3 ) out;

layout (location=0) in vec2 uv[];
layout (location=1) in vec3 wpos[];

layout (location=0) out vec2 uvs;
layout (location=1) out vec3 barycoords;
layout (location=2) out vec3 wpos_out;

void main()
{
    const vec3 bc[3] = vec3[]
    (
    vec3(1.0, 0.0, 0.0),
    vec3(0.0, 1.0, 0.0),
    vec3(0.0, 0.0, 1.0)
    );
    for ( int i = 0; i < 3; i++ )
    {
        gl_Position = gl_in[i].gl_Position;
        uvs = uv[i];
        barycoords = bc[i];
        wpos_out = wpos[i];
        EmitVertex();
    }
    EndPrimitive();
}
// ]]

// local fragment_shader = [[
#version 460 core

layout (location=0) in vec2 uvs;
layout (location=1) in vec3 barycoords;
layout (location=2) in vec3 wpos_out;

layout (location=0) out vec4 out_FragColor;

layout (binding = 0) uniform sampler2D texture0;

float edgeFactor(float thickness)
{
    vec3 a3 = smoothstep( vec3( 0.0 ), fwidth(barycoords) * thickness, barycoords);
    return min( min( a3.x, a3.y ), a3.z );
}

void main()
{
    vec4 color = vec4(1.0);
    out_FragColor = mix( color * vec4(0.8), color, edgeFactor(1.0) );
}
// ]]

// return {
//     vertex_shader = vertex_shader,
//     fragment_shader = fragment_shader,
//     geometry_shader = geometry_shader,
//     common_shader = common_shader,
// }