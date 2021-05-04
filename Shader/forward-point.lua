-- forward-point
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

uniform mat4 View;
uniform mat4 Proj;
uniform mat4 World;

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
}
]]

local fragment_shader = [[
#version 330

in vec2 texCoord0;
in vec3 worldPos0;
in mat3 tbnMatrix;

out vec4 fragColor;

struct BaseLight
{
  vec3 color;
  float intensity;
};

struct Attenuation
{
  float constant;
  float linear;
  float exponent;
};

struct PointLight
{
  BaseLight base;
  Attenuation attenuation;
  vec3 position;
  float range;
};

uniform vec3 eyePos;
uniform float specularIntensity;
uniform float specularPower;

uniform PointLight pointLight;

uniform sampler2D diffuseMap;
uniform sampler2D normalMap;
uniform sampler2D specularMap;

vec4 calculateLight(BaseLight base, vec3 direction, vec3 normal)
{
  float diffuseFactor = dot(normal, -direction);

  vec4 diffuseColor = vec4(0.0f, 0.0f, 0.0f, 0.0f);
  vec4 specularColor = vec4(0.0f, 0.0f, 0.0f, 0.0f);

  if (diffuseFactor > 0.0f)
  {
    diffuseColor = vec4(base.color, 1.0f) * base.intensity * diffuseFactor;

    vec3 directionToEye = normalize(eyePos - worldPos0);
    vec3 reflectDirection = normalize(reflect(direction, normal));

    float specularFactor = dot(directionToEye, reflectDirection);
    specularFactor = pow(specularFactor, specularPower);

    if (specularFactor > 0.0f)
    {
      specularColor = vec4(base.color, 1.0f) * (texture(specularMap, texCoord0).r * specularFactor);
    }
  }

  return diffuseColor + specularColor;
}

vec4 calculatePointLight(PointLight pointLight, vec3 normal)
{
  vec3 lightDirection = worldPos0 - pointLight.position;
  float distanceToPoint = length(lightDirection);

  if (distanceToPoint > pointLight.range)
    return vec4(0, 0, 0, 0);

  lightDirection = normalize(lightDirection);

  vec4 color = calculateLight(pointLight.base, lightDirection, normal);

  float attenuation = pointLight.attenuation.constant
                      + pointLight.attenuation.linear * distanceToPoint
                      + pointLight.attenuation.exponent * distanceToPoint * distanceToPoint
                      + 0.0001;

  return color / attenuation;
}

void main()
{
  vec3 normal = normalize(tbnMatrix * (255.0/128.0 * texture(normalMap, texCoord0).xyz - 1));
  fragColor = texture(diffuseMap, texCoord0) * calculatePointLight(pointLight, normal);
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}