-- forward-directional
-- created on 2021/4/30
-- author @zoloypzuo
local vertex_shader = [[
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
]]

local fragment_shader = [[
#version 330
// TODO copy paste fs code
// TODO change C++ code with shader
in vec2 texCoord0;
in vec3 worldPos0;
in mat3 tbnMatrix;

// shadow
in vec3 FragPos;  // TODO remove it
in vec4 FragPosLightSpace;

out vec4 fragColor;

struct BaseLight
{
  vec3 color;
  float intensity;
};

struct DirectionalLight
{
  BaseLight base;
  vec3 direction;
};

uniform vec3 eyePos;
uniform float specularIntensity;
uniform float specularPower;

uniform DirectionalLight directionalLight;

uniform sampler2D diffuseMap;
uniform sampler2D normalMap;
uniform sampler2D specularMap;

// shadow
uniform sampler2D shadowMap;
uniform vec3 lightPos;

float ShadowCalculation(vec4 fragPosLightSpace)
{
    // perform perspective divide
    vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
    // transform to [0,1] range
    projCoords = projCoords * 0.5 + 0.5;
    // get closest depth value from light's perspective (using [0,1] range fragPosLight as coords)
    float closestDepth = texture(shadowMap, projCoords.xy).r;
    // get depth of current fragment from light's perspective
    float currentDepth = projCoords.z;
    // check whether current frag pos is in shadow
    float shadow = currentDepth > closestDepth  ? 1.0 : 0.0;

    return shadow;
}


void main()
{
  vec3 normal = normalize(tbnMatrix * (255.0/128.0 * texture(normalMap, texCoord0).xyz - 1));
  vec3 color = texture(diffuseMap, texCoord0).rgb;
  vec3 lightColor = vec3(0.3);
  // ambient
  vec3 ambient = 0.3 * color;
  // diffuse
  vec3 lightDir = normalize(lightPos - FragPos);
  float diff = max(dot(lightDir, normal), 0.0);
  vec3 diffuse = diff * lightColor;
  // specular
  vec3 viewDir = normalize(eyePos - FragPos);
  vec3 reflectDir = reflect(-lightDir, normal);
  float spec = 0.0;
  vec3 halfwayDir = normalize(lightDir + viewDir);
  spec = pow(max(dot(normal, halfwayDir), 0.0), 64.0);
  vec3 specular = spec * lightColor;
  // calculate shadow
  float shadow = ShadowCalculation(FragPosLightSpace);
  vec3 lighting = (ambient + (1.0 - shadow) * (diffuse + specular)) * color;

  fragColor = vec4(lighting, 1.0);
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}