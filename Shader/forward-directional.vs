#version 330

layout(location = 0) in vec3 position;
layout(location = 1) in vec2 texCoord;
layout(location = 2) in vec3 normal;
layout(location = 3) in vec3 tangent;

out vec2 texCoord0;
out vec3 worldPos0;
out mat3 tbnMatrix;

// shadow
out vec3 FragPos;
out vec4 FragPosLightSpace;


uniform mat4 View;
uniform mat4 Proj;
uniform mat4 World;

// shadow
uniform mat4 lightSpaceMatrix;

void main()
{
  gl_Position = Proj * View * World * vec4(position, 1.0);
  texCoord0 = texCoord;
  worldPos0 = (World * vec4(position, 1.0f)).xyz;

  vec3 n = normalize((World * vec4(normal, 0.0)).xyz);
  vec3 t = normalize((World * vec4(tangent, 0.0)).xyz);
  t = normalize(t - dot(t, n) * n);

  vec3 biTangent = cross(t, n);
  tbnMatrix = mat3(t, biTangent, n);

  // shadow
  FragPos = vec3(World * vec4(position, 1.0));
  FragPosLightSpace = lightSpaceMatrix * vec4(FragPos, 1.0);
}
