-- deferred.lua
-- created on 2021/5/4
-- author @zoloypzuo
local vertex_shader = [[
#version 430

layout( location = 0 ) in vec3 VertexPosition;
layout( location = 1 ) in vec3 VertexNormal;
layout( location = 2 ) in vec2 VertexTexCoord;

out vec3 Position;
out vec3 Normal;
out vec2 TexCoord;

uniform mat4 ModelViewMatrix;
uniform mat3 NormalMatrix;
uniform mat4 ProjectionMatrix;
uniform mat4 MVP;

void main()
{
    Normal = normalize( NormalMatrix * VertexNormal);
    Position = vec3( ModelViewMatrix * vec4(VertexPosition,1.0) );
    TexCoord = VertexTexCoord;
    gl_Position = MVP * vec4(VertexPosition,1.0);
}

]]

local fragment_shader = [[
#version 430

struct LightInfo {
  vec4 Position;  // Light position in eye coords.
  vec3 Intensity; // A,D,S intensity
};
uniform LightInfo Light;

struct MaterialInfo {
  vec3 Kd;            // Diffuse reflectivity
};
uniform MaterialInfo Material;

subroutine void RenderPassType();
subroutine uniform RenderPassType RenderPass;

layout(binding=0) uniform sampler2D PositionTex;
layout(binding=1) uniform sampler2D NormalTex;
layout(binding=2) uniform sampler2D ColorTex;

in vec3 Position;
in vec3 Normal;
in vec2 TexCoord;

layout (location = 0) out vec4 FragColor;
layout (location = 1) out vec3 PositionData;
layout (location = 2) out vec3 NormalData;
layout (location = 3) out vec3 ColorData;

vec3 diffuseModel( vec3 pos, vec3 norm, vec3 diff )
{
    vec3 s = normalize(vec3(Light.Position) - pos);
    float sDotN = max( dot(s,norm), 0.0 );
    vec3 diffuse = Light.Intensity * diff * sDotN;

    return diffuse;
}

subroutine (RenderPassType)
void pass1()
{
    // Store position, normal, and diffuse color in textures
    PositionData = Position;
    NormalData = Normal;
    ColorData = Material.Kd;
}

subroutine(RenderPassType)
void pass2()
{
    // Retrieve position and normal information from textures
    vec3 pos = vec3( texture( PositionTex, TexCoord ) );
    vec3 norm = vec3( texture( NormalTex, TexCoord ) );
    vec3 diffColor = vec3( texture(ColorTex, TexCoord) );

    FragColor = vec4( diffuseModel(pos,norm,diffColor), 1.0 );
}

void main() {
    // This will call either pass1 or pass2
    RenderPass();
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}