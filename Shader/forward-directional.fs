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
      specularColor = vec4(base.color, 1.0f) * (specularIntensity * specularFactor);
    }
  }

  float shadow = ShadowCalculation(FragPosLightSpace);
  return (1.0 - shadow) * (diffuseColor + specularColor);
}

vec4 calculateDirectionalLight(DirectionalLight directionalLight, vec3 normal)
{
  return calculateLight(directionalLight.base, directionalLight.direction, normal);
}

void main()
{
  vec3 normal = normalize(tbnMatrix * (255.0/128.0 * texture(normalMap, texCoord0).xyz - 1));
  vec4 color = texture(diffuseMap, texCoord0);
  fragColor = color * calculateDirectionalLight(directionalLight, normal);
}
