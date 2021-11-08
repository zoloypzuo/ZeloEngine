-- forward_standard
-- created on 2021/11/7
-- author @zoloypzuo
local vertex_shader = [[
#version 430 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec2 texCoord;
layout(location = 2) in vec3 normal;
layout(location = 3) in vec3 tangent;

out vec2 texCoord0;
out vec3 worldPos0;
out mat3 tbnMatrix;

out vec3 FragPos;

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

  FragPos = vec3(World * vec4(position, 1.0));
}
]]

local fragment_shader = [[
#version 430 core

layout(std430, binding = 0) buffer LightSSBO
{
    mat4 ssbo_Lights[];
};

in vec2 texCoord0;
in vec3 worldPos0;
in mat3 tbnMatrix;

in vec3 FragPos;

out vec4 fragColor;

uniform sampler2D diffuseMap;
uniform sampler2D normalMap;
uniform sampler2D specularMap;

// ambient
uniform vec3 ambientIntensity;

// directional
uniform vec3 eyePos;
uniform float specularIntensity;
uniform float specularPower;

vec4 CalcAmbient()
{
  return texture(diffuseMap, texCoord0) * vec4(ambientIntensity, 1.0f);
}

// vec3 CalcPointLight(mat4 p_Light)
// {
//     /* Extract light information from light mat4 */
//     const vec3 lightPosition  = p_Light[0].rgb;
//     const vec3 lightColor     = UnPack(p_Light[2][0]);
//     const float intensity     = p_Light[3][3];

//     const vec3  lightDirection  = normalize(lightPosition - fs_in.FragPos);
//     const float luminosity      = LuminosityFromAttenuation(p_Light);

//     return BlinnPhong(lightDirection, lightColor, intensity * luminosity);
// }

vec3 CalcDirectionalLight(mat4 light)
{
  const vec3 lightPos = light[0].rgb;
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

  return (ambient + diffuse + specular) * color;
}

// vec3 CalcSpotLight(mat4 p_Light)
// {
//     /* Extract light information from light mat4 */
//     const vec3  lightPosition   = p_Light[0].rgb;
//     const vec3  lightForward    = p_Light[1].rgb;
//     const vec3  lightColor      = UnPack(p_Light[2][0]);
//     const float intensity       = p_Light[3][3];
//     const float cutOff          = cos(radians(p_Light[3][1]));
//     const float outerCutOff     = cos(radians(p_Light[3][1] + p_Light[3][2]));

//     const vec3  lightDirection  = normalize(lightPosition - fs_in.FragPos);
//     const float luminosity      = LuminosityFromAttenuation(p_Light);

//     /* Calculate the spot intensity */
//     const float theta           = dot(lightDirection, normalize(-lightForward));
//     const float epsilon         = cutOff - outerCutOff;
//     const float spotIntensity   = clamp((theta - outerCutOff) / epsilon, 0.0, 1.0);

//     return BlinnPhong(lightDirection, lightColor, intensity * spotIntensity * luminosity);
// }

// vec3 CalcAmbientBoxLight(mat4 p_Light)
// {
//     const vec3  lightPosition   = p_Light[0].rgb;
//     const vec3  lightColor      = UnPack(p_Light[2][0]);
//     const float intensity       = p_Light[3][3];
//     const vec3  size            = vec3(p_Light[0][3], p_Light[1][3], p_Light[2][3]);

//     return PointInAABB(fs_in.FragPos, lightPosition, size) ? g_DiffuseTexel.rgb * lightColor * intensity : vec3(0.0);
// }

// vec3 CalcAmbientSphereLight(mat4 p_Light)
// {
//     const vec3  lightPosition   = p_Light[0].rgb;
//     const vec3  lightColor      = UnPack(p_Light[2][0]);
//     const float intensity       = p_Light[3][3];
//     const float radius          = p_Light[0][3];

//     return distance(lightPosition, fs_in.FragPos) <= radius ? g_DiffuseTexel.rgb * lightColor * intensity : vec3(0.0);
// }

void main(){
  vec3 lightSum = vec3(0.0);

  for (int i = 0; i < ssbo_Lights.length(); ++i)
  {
    switch(int(ssbo_Lights[i][3][0]))
    {
      // case 0: lightSum += CalcPointLight(ssbo_Lights[i]); break;
      case 1: lightSum += CalcDirectionalLight(ssbo_Lights[i]); break;
      // case 2: lightSum += CalcSpotLight(ssbo_Lights[i]); break;
      // case 3: lightSum += CalcAmbientBoxLight(ssbo_Lights[i]); break;
      // case 4: lightSum += CalcAmbientSphereLight(ssbo_Lights[i]); break;
    }
  }

  fragColor = CalcAmbient() + vec4(lightSum, 1.0);
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}