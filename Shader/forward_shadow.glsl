// -- forward_standard
// -- created on 2021/11/7
// -- author @zoloypzuo
// local common_shader = [[
layout (std140) uniform EngineUBO
{
  mat4 ubo_model;
  mat4 ubo_view;
  mat4 ubo_projection;
  vec3 ubo_viewPos;
  /* float ubo_time; */
};

varying VaryingVariables
{
  vec3 fragPos;
  vec2 texCoord0;
  mat3 TBN;
  vec3 normal;
  flat vec3 tangentViewPos;
  vec3 tangentFragPos;
  /* shadow */
  vec4 fragPosLightSpace;
} vary;

bool PointInAABB(vec3 point, vec3 aabbCenter, vec3 aabbHalfSize)
{
  return
  (
    point.x > aabbCenter.x - aabbHalfSize.x && point.x < aabbCenter.x + aabbHalfSize.x &&
    point.y > aabbCenter.y - aabbHalfSize.y && point.y < aabbCenter.y + aabbHalfSize.y &&
    point.z > aabbCenter.z - aabbHalfSize.z && point.z < aabbCenter.z + aabbHalfSize.z
  );
}

vec3 saturate(vec3 color)
{
  return clamp(color, 0.0, 1.0);
}
// ]]

// local vertex_shader = [[
#version 430 core

layout(location = 0) in vec3 v_position;
layout(location = 1) in vec2 v_texCoord;
layout(location = 2) in vec3 v_normal;
layout(location = 3) in vec3 v_tangent;

// common:

/* shadow */
uniform mat4 u_LightSpaceMatrix;

void main()
{
  vec3 fragPos = vec3(ubo_model * vec4(v_position, 1.0));
  vary.fragPos = fragPos;
  vary.texCoord0 = v_texCoord;

  /* compute TBN
   * if bitangent is precomputed in vertex attribute, a nicer computation
   *   can be written as follows:
   * TBN = mat3
   * (
   *   normalize(vec3(ubo_Model * vec4(geo_Tangent,   0.0))),
   *   normalize(vec3(ubo_Model * vec4(geo_Bitangent, 0.0))),
   *   normalize(vec3(ubo_Model * vec4(geo_Normal,    0.0)))
   * );
  */
  vec3 n = normalize((ubo_model * vec4(v_normal, 0.0)).xyz);
  vec3 t = normalize((ubo_model * vec4(v_tangent, 0.0)).xyz);
  t = normalize(t - dot(t, n) * n);
  vec3 b = cross(t, n);
  mat3 TBN = mat3(t, b, n);
  vary.TBN = TBN;

  mat3 TBNi = transpose(TBN);

  vary.normal = normalize(mat3(transpose(inverse(ubo_model))) * v_normal);
  vary.tangentViewPos = TBNi * ubo_viewPos;
  vary.tangentFragPos = TBNi * fragPos;

  /* shadow */
  vary.fragPosLightSpace = u_LightSpaceMatrix * vec4(fragPos, 1.0);

  gl_Position = ubo_projection * ubo_view * vec4(fragPos, 1.0);
}
// ]]

// local fragment_shader = [[
#version 430 core

// common:

layout(std430, binding = 0) buffer LightSSBO
{
  mat4 ssbo_Lights[];
};

uniform vec2        u_TextureTiling           = vec2(1.0, 1.0);
uniform vec2        u_TextureOffset           = vec2(0.0, 0.0);
uniform vec4        u_Diffuse                 = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec3        u_Specular                = vec3(1.0, 1.0, 1.0);
uniform float       u_Shininess               = 100.0;
uniform float       u_HeightScale             = 0.0;
uniform bool        u_EnableNormalMapping     = true;
uniform sampler2D   u_DiffuseMap;
uniform sampler2D   u_SpecularMap;
uniform sampler2D   u_NormalMap;
uniform sampler2D   u_HeightMap;
uniform sampler2D   u_MaskMap;

/* shadow */
uniform sampler2DShadow u_ShadowMap;

out vec4 FRAGMENT_COLOR;

vec3 g_Normal;
vec2 g_TexCoords;
vec3 g_ViewDir;
vec4 g_DiffuseTexel;
vec4 g_SpecularTexel;
vec4 g_HeightTexel;
vec4 g_NormalTexel;

vec2 ParallaxMapping(vec3 viewDir)
{
  const vec2 parallax = viewDir.xy * u_HeightScale * texture(u_HeightMap, g_TexCoords).r;
  return g_TexCoords - vec2(parallax.x, 1.0 - parallax.y);
}

vec3 BlinnPhong(vec3 lightDir, vec3 lightColor, float luminosity)
{
  const vec3  halfwayDir          = normalize(lightDir + g_ViewDir);
  const float diffuseCoefficient  = max(dot(g_Normal, lightDir), 0.0);
  const float specularCoefficient = pow(max(dot(g_Normal, halfwayDir), 0.0), u_Shininess * 2.0);

  return lightColor * g_DiffuseTexel.rgb * diffuseCoefficient * luminosity + 
    ((luminosity > 0.0) ? (lightColor * g_SpecularTexel.rgb * specularCoefficient * luminosity) : vec3(0.0));
}

float LuminosityFromAttenuation(mat4 light)
{
  const vec3  lightPosition   = light[0].rgb;
  const float constant        = light[3][0];
  const float linear          = light[3][1];
  const float quadratic       = light[3][2];

  const float distanceToLight = length(lightPosition - vary.fragPos);
  const float attenuation     = (constant + linear * distanceToLight + quadratic * (distanceToLight * distanceToLight));
  return 1.0 / attenuation;
}

vec3 CalcPointLight(mat4 light)
{
  /* Extract light information from light mat4 */
  const vec3 lightPosition  = light[0].rgb;
  const vec3 lightColor     = light[2].rgb;
  const float intensity     = light[3][3];

  const vec3  lightDirection  = normalize(lightPosition - vary.fragPos);
  const float luminosity      = LuminosityFromAttenuation(light);

  return BlinnPhong(lightDirection, lightColor, intensity * luminosity);
}

vec3 CalcDirectionalLight(mat4 light)
{
  /* Extract light information from light mat4 */
  const vec3 lightDirection = -light[1].rgb;
  const vec3 lightColor     = light[2].rgb;
  const float intensity     = light[3][3];
  float shadow = textureProj(u_ShadowMap, vary.fragPosLightSpace);
  return shadow * BlinnPhong(lightDirection, lightColor, intensity);
}

vec3 CalcSpotLight(mat4 light)
{
  /* Extract light information from light mat4 */
  const vec3  lightPosition   = light[0].rgb;
  const vec3  lightForward    = light[1].rgb;
  const vec3  lightColor      = light[2].rgb;
  const float intensity       = light[3][3];
  const float cutOff          = cos(radians(light[3][1]));
  const float outerCutOff     = cos(radians(light[3][1] + light[3][2]));

  const vec3  lightDirection  = normalize(lightPosition - vary.fragPos);
  const float luminosity      = LuminosityFromAttenuation(light);

  /* Calculate the spot intensity */
  const float theta           = dot(lightDirection, normalize(-lightForward));
  const float epsilon         = cutOff - outerCutOff;
  const float spotIntensity   = clamp((theta - outerCutOff) / epsilon, 0.0, 1.0);

  return BlinnPhong(lightDirection, lightColor, intensity * spotIntensity * luminosity);
}

vec3 CalcAmbientBoxLight(mat4 light)
{
  const vec3  lightPosition   = light[0].rgb;
  const vec3  lightColor      = light[2].rgb;
  const float intensity       = light[3][3];
  const vec3  size            = vec3(light[0][3], light[1][3], light[2][3]);

  return PointInAABB(vary.fragPos, lightPosition, size) ? 
    g_DiffuseTexel.rgb * lightColor * intensity : vec3(0.0);
}

vec3 CalcAmbientSphereLight(mat4 light)
{
  const vec3  lightPosition   = light[0].rgb;
  const vec3  lightColor      = light[2].rgb;
  const float intensity       = light[3][3];
  const float radius          = light[0][3];

  return distance(lightPosition, vary.fragPos) <= radius ?
    g_DiffuseTexel.rgb * lightColor * intensity : vec3(0.0);
}

void main()
{
  g_TexCoords = u_TextureOffset + vec2(
    mod(vary.texCoord0.x * u_TextureTiling.x, 1), 
    mod(vary.texCoord0.y * u_TextureTiling.y, 1));

  /* Apply parallax mapping */
  if (u_HeightScale > 0)
    g_TexCoords = ParallaxMapping(normalize(vary.tangentViewPos - vary.tangentFragPos));

  /* Apply color mask */
  if (texture(u_MaskMap, g_TexCoords).r != 0.0)
  {
    g_ViewDir           = normalize(ubo_viewPos - vary.fragPos);
    g_DiffuseTexel      = texture(u_DiffuseMap,  g_TexCoords) * u_Diffuse;
    g_SpecularTexel     = texture(u_SpecularMap, g_TexCoords) * vec4(u_Specular, 1.0);

    if (u_EnableNormalMapping)
    {
      g_Normal = texture(u_NormalMap, g_TexCoords).rgb;
      g_Normal = normalize(g_Normal * 2.0 - 1.0);
      g_Normal = normalize(vary.TBN * g_Normal);
    }
    else
    {
      g_Normal = normalize(vary.normal);
    }

    vec3 lightSum = vec3(0.0);
    /* saturate avoid negative light contribution */
    for (int i = 0; i < ssbo_Lights.length(); ++i)
    {
      switch(int(ssbo_Lights[i][3][0]))
      {
        case 0: lightSum += saturate(CalcPointLight(ssbo_Lights[i]));         break;
        case 1: lightSum += saturate(CalcDirectionalLight(ssbo_Lights[i]));   break;
        case 2: lightSum += saturate(CalcSpotLight(ssbo_Lights[i]));          break;
        case 3: lightSum += saturate(CalcAmbientBoxLight(ssbo_Lights[i]));    break;
        case 4: lightSum += saturate(CalcAmbientSphereLight(ssbo_Lights[i])); break;
      }
    }

    FRAGMENT_COLOR = vec4(lightSum, g_DiffuseTexel.a);
  }
  else
  {
    FRAGMENT_COLOR = vec4(0.0);
  }
}
// ]]

// return {
//     vertex_shader = vertex_shader,
//     fragment_shader = fragment_shader,
//     common_shader = common_shader,
// }