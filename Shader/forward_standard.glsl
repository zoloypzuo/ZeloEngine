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
// ]]

// local vertex_shader = [[
#version 430 core

layout(location = 0) in vec3 v_position;
layout(location = 1) in vec2 v_texCoord;
layout(location = 2) in vec3 v_normal;
layout(location = 3) in vec3 v_tangent;

// common:

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

out vec4 FRAGMENT_COLOR;

vec3 g_Normal;
vec2 g_TexCoords;
vec3 g_ViewDir;
vec4 g_DiffuseTexel;
vec4 g_SpecularTexel;
vec4 g_HeightTexel;
vec4 g_NormalTexel;

vec2 ParallaxMapping(vec3 p_ViewDir)
{
  const vec2 parallax = p_ViewDir.xy * u_HeightScale * texture(u_HeightMap, g_TexCoords).r;
  return g_TexCoords - vec2(parallax.x, 1.0 - parallax.y);
}

vec3 BlinnPhong(vec3 p_LightDir, vec3 p_LightColor, float p_Luminosity)
{
  const vec3  halfwayDir          = normalize(p_LightDir + g_ViewDir);
  const float diffuseCoefficient  = max(dot(g_Normal, p_LightDir), 0.0);
  const float specularCoefficient = pow(max(dot(g_Normal, halfwayDir), 0.0), u_Shininess * 2.0);

  return p_LightColor * g_DiffuseTexel.rgb * diffuseCoefficient * p_Luminosity + 
    ((p_Luminosity > 0.0) ? (p_LightColor * g_SpecularTexel.rgb * specularCoefficient * p_Luminosity) : vec3(0.0));
}

float LuminosityFromAttenuation(mat4 p_Light)
{
  const vec3  lightPosition   = p_Light[0].rgb;
  const float constant        = p_Light[0][3];
  const float linear          = p_Light[1][3];
  const float quadratic       = p_Light[2][3];

  const float distanceToLight = length(lightPosition - vary.fragPos);
  const float attenuation     = (constant + linear * distanceToLight + quadratic * (distanceToLight * distanceToLight));
  return 1.0 / attenuation;
}

vec3 CalcPointLight(mat4 p_Light)
{
  /* Extract light information from light mat4 */
  const vec3 lightPosition  = p_Light[0].rgb;
  const vec3 lightColor     = p_Light[2].rgb;
  const float intensity     = p_Light[3][3];

  const vec3  lightDirection  = normalize(lightPosition - vary.fragPos);
  const float luminosity      = LuminosityFromAttenuation(p_Light);

  return BlinnPhong(lightDirection, lightColor, intensity * luminosity);
}

vec3 CalcDirectionalLight(mat4 light)
{
  return BlinnPhong(-light[1].rgb, light[2].rgb, light[3][3]);
}

vec3 CalcSpotLight(mat4 p_Light)
{
  /* Extract light information from light mat4 */
  const vec3  lightPosition   = p_Light[0].rgb;
  const vec3  lightForward    = p_Light[1].rgb;
  const vec3  lightColor      = p_Light[2].rgb;
  const float intensity       = p_Light[3][3];
  const float cutOff          = cos(radians(p_Light[3][1]));
  const float outerCutOff     = cos(radians(p_Light[3][1] + p_Light[3][2]));

  const vec3  lightDirection  = normalize(lightPosition - vary.fragPos);
  const float luminosity      = LuminosityFromAttenuation(p_Light);

  /* Calculate the spot intensity */
  const float theta           = dot(lightDirection, normalize(-lightForward));
  const float epsilon         = cutOff - outerCutOff;
  const float spotIntensity   = clamp((theta - outerCutOff) / epsilon, 0.0, 1.0);

  return BlinnPhong(lightDirection, lightColor, intensity * spotIntensity * luminosity);
}

vec3 CalcAmbientBoxLight(mat4 p_Light)
{
  const vec3  lightPosition   = p_Light[0].rgb;
  const vec3  lightColor      = p_Light[2].rgb;
  const float intensity       = p_Light[3][3];
  const vec3  size            = vec3(p_Light[0][3], p_Light[1][3], p_Light[2][3]);

  return PointInAABB(vary.fragPos, lightPosition, size) ? 
    g_DiffuseTexel.rgb * lightColor * intensity : vec3(0.0);
}

vec3 CalcAmbientSphereLight(mat4 p_Light)
{
  const vec3  lightPosition   = p_Light[0].rgb;
  const vec3  lightColor      = p_Light[2].rgb;
  const float intensity       = p_Light[3][3];
  const float radius          = p_Light[0][3];

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

    for (int i = 0; i < ssbo_Lights.length(); ++i)
    {
      switch(int(ssbo_Lights[i][3][0]))
      {
        case 0: lightSum += CalcPointLight(ssbo_Lights[i]);         break;
        case 1: lightSum += CalcDirectionalLight(ssbo_Lights[i]);   break;
        case 2: lightSum += CalcSpotLight(ssbo_Lights[i]);          break;
        case 3: lightSum += CalcAmbientBoxLight(ssbo_Lights[i]);    break;
        case 4: lightSum += CalcAmbientSphereLight(ssbo_Lights[i]); break;
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