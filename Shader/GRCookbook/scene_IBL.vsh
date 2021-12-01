// return [[
layout(std430, binding = 1) restrict readonly buffer Matrices
{
    mat4 in_Model[];
};

layout (location=0) in vec3 in_Vertex;
layout (location=1) in vec2 in_TexCoord;
layout (location=2) in vec3 in_Normal;

layout (location=0) out vec2 v_tc;
layout (location=1) out vec3 v_worldNormal;
layout (location=2) out vec3 v_worldPos;
layout (location=3) out flat uint matIdx;
layout (location=4) out vec4 v_shadowCoord;

/* OpenGL's Z is in -1..1*/
const mat4 scaleBias = mat4(
0.5, 0.0, 0.0, 0.0,
0.0, 0.5, 0.0, 0.0,
0.0, 0.0, 0.5, 0.0,
0.5, 0.5, 0.5, 1.0 );

void main()
{
    mat4 model = in_Model[gl_BaseInstance >> 16];
    mat4 MVP = proj * view * model;

    gl_Position = MVP * vec4(in_Vertex, 1.0);

    v_worldPos = (view * vec4(in_Vertex, 1.0)).xyz;
    v_worldNormal = transpose(inverse(mat3(model))) * in_Normal;
    v_tc = in_TexCoord;
    matIdx = gl_BaseInstance & 0xffff;
    v_shadowCoord = scaleBias * light * model * vec4(in_Vertex, 1.0);
}
// ]]