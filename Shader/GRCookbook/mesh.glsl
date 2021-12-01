// local common_shader = [[
struct MaterialData
{
    vec4 emissiveColor_;
    vec4 albedoColor_;
    vec4 roughness_;

    float transparencyFactor_;
    float alphaTest_;
    float metallicFactor_;

    uint  flags_;

    uint64_t ambientOcclusionMap_;
    uint64_t emissiveMap_;
    uint64_t albedoMap_;
    uint64_t metallicRoughnessMap_;
    uint64_t normalMap_;
    uint64_t opacityMap_;
};
// ]]

// local vertex_shader = [[
#version 460 core

#extension GL_ARB_gpu_shader_int64 : enable

// common:

layout(std140, binding = 0) uniform PerFrameData
{
    mat4 view;
    mat4 proj;
    vec4 cameraPos;
};

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

void main()
{
    mat4 model = in_Model[gl_InstanceID];
    mat4 MVP = proj * view * model;

    gl_Position = MVP * vec4(in_Vertex, 1.0);

    v_worldPos = (view * vec4(in_Vertex, 1.0)).xyz;
    v_worldNormal = transpose(inverse(mat3(model))) * in_Normal;
    v_tc = in_TexCoord;
    matIdx = gl_BaseInstance;
}
// ]]

// local fragment_shader = [[
#version 460 core

#extension GL_ARB_bindless_texture : require
#extension GL_ARB_gpu_shader_int64 : enable

// common:

layout(std140, binding = 0) uniform PerFrameData
{
    mat4 view;
    mat4 proj;
    vec4 cameraPos;
};

layout(std430, binding = 2) restrict readonly buffer Materials
{
    MaterialData in_Materials[];
};

layout (location=0) in vec2 v_tc;
layout (location=1) in vec3 v_worldNormal;
layout (location=2) in vec3 v_worldPos;
layout (location=3) in flat uint matIdx;

layout (location=0) out vec4 out_FragColor;

layout (binding = 5) uniform samplerCube texEnvMap;
layout (binding = 6) uniform samplerCube texEnvMapIrradiance;
layout (binding = 7) uniform sampler2D texBRDF_LUT;

void runAlphaTest(float alpha, float alphaThreshold)
{
    if (alphaThreshold > 0.0)
    {
        mat4 thresholdMatrix = mat4(
        1.0  / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0  / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
        );

        alpha = clamp(alpha - 0.5 * thresholdMatrix[int(mod(gl_FragCoord.x, 4.0))][int(mod(gl_FragCoord.y, 4.0))], 0.0, 1.0);

        if (alpha < alphaThreshold)
        discard;
    }
}


struct PBRInfo
{
    float NdotL;                  	float NdotV;                  	float NdotH;                  	float LdotH;                  	float VdotH;                  	float perceptualRoughness;    	vec3 reflectance0;            	vec3 reflectance90;           	float alphaRoughness;         	vec3 diffuseColor;            	vec3 specularColor;           	vec3 n;									vec3 v;								};

const float M_PI = 3.141592653589793;

vec4 SRGBtoLINEAR(vec4 srgbIn)
{
    vec3 linOut = pow(srgbIn.xyz,vec3(2.2));

    return vec4(linOut, srgbIn.a);
}

vec3 getIBLContribution(PBRInfo pbrInputs, vec3 n, vec3 reflection)
{
    float mipCount = float(textureQueryLevels(texEnvMap));
    float lod = pbrInputs.perceptualRoughness * mipCount;
    vec2 brdfSamplePoint = clamp(vec2(pbrInputs.NdotV, 1.0-pbrInputs.perceptualRoughness), vec2(0.0, 0.0), vec2(1.0, 1.0));
    vec3 brdf = textureLod(texBRDF_LUT, brdfSamplePoint, 0).rgb;
    #ifdef VULKAN
    vec3 cm = vec3(-1.0, -1.0, 1.0);
    #else
    vec3 cm = vec3(1.0, 1.0, 1.0);
    #endif
    vec3 diffuseLight = texture(texEnvMapIrradiance, n.xyz * cm).rgb;
    vec3 specularLight = textureLod(texEnvMap, reflection.xyz * cm, lod).rgb;

    vec3 diffuse = diffuseLight * pbrInputs.diffuseColor;
    vec3 specular = specularLight * (pbrInputs.specularColor * brdf.x + brdf.y);

    return diffuse + specular;
}

vec3 diffuseBurley(PBRInfo pbrInputs)
{
    float f90 = 2.0 * pbrInputs.LdotH * pbrInputs.LdotH * pbrInputs.alphaRoughness - 0.5;

    return (pbrInputs.diffuseColor / M_PI) * (1.0 + f90 * pow((1.0 - pbrInputs.NdotL), 5.0)) * (1.0 + f90 * pow((1.0 - pbrInputs.NdotV), 5.0));
}

vec3 specularReflection(PBRInfo pbrInputs)
{
    return pbrInputs.reflectance0 + (pbrInputs.reflectance90 - pbrInputs.reflectance0) * pow(clamp(1.0 - pbrInputs.VdotH, 0.0, 1.0), 5.0);
}

float geometricOcclusion(PBRInfo pbrInputs)
{
    float NdotL = pbrInputs.NdotL;
    float NdotV = pbrInputs.NdotV;
    float rSqr = pbrInputs.alphaRoughness * pbrInputs.alphaRoughness;

    float attenuationL = 2.0 * NdotL / (NdotL + sqrt(rSqr + (1.0 - rSqr) * (NdotL * NdotL)));
    float attenuationV = 2.0 * NdotV / (NdotV + sqrt(rSqr + (1.0 - rSqr) * (NdotV * NdotV)));
    return attenuationL * attenuationV;
}

float microfacetDistribution(PBRInfo pbrInputs)
{
    float roughnessSq = pbrInputs.alphaRoughness * pbrInputs.alphaRoughness;
    float f = (pbrInputs.NdotH * roughnessSq - pbrInputs.NdotH) * pbrInputs.NdotH + 1.0;
    return roughnessSq / (M_PI * f * f);
}

vec3 calculatePBRInputsMetallicRoughness( vec4 albedo, vec3 normal, vec3 cameraPos, vec3 worldPos, vec4 mrSample, out PBRInfo pbrInputs )
{
    float perceptualRoughness = 1.0;
    float metallic = 1.0;

    perceptualRoughness = mrSample.g * perceptualRoughness;
    metallic = mrSample.b * metallic;

    const float c_MinRoughness = 0.04;

    perceptualRoughness = clamp(perceptualRoughness, c_MinRoughness, 1.0);
    metallic = clamp(metallic, 0.0, 1.0);
    float alphaRoughness = perceptualRoughness * perceptualRoughness;

    vec4 baseColor = albedo;

    vec3 f0 = vec3(0.04);
    vec3 diffuseColor = baseColor.rgb * (vec3(1.0) - f0);
    diffuseColor *= 1.0 - metallic;
    vec3 specularColor = mix(f0, baseColor.rgb, metallic);

    float reflectance = max(max(specularColor.r, specularColor.g), specularColor.b);

    float reflectance90 = clamp(reflectance * 25.0, 0.0, 1.0);
    vec3 specularEnvironmentR0 = specularColor.rgb;
    vec3 specularEnvironmentR90 = vec3(1.0, 1.0, 1.0) * reflectance90;

    vec3 n = normalize(normal);						vec3 v = normalize(cameraPos - worldPos);		vec3 reflection = -normalize(reflect(v, n));

    pbrInputs.NdotV = clamp(abs(dot(n, v)), 0.001, 1.0);
    pbrInputs.perceptualRoughness = perceptualRoughness;
    pbrInputs.reflectance0 = specularEnvironmentR0;
    pbrInputs.reflectance90 = specularEnvironmentR90;
    pbrInputs.alphaRoughness = alphaRoughness;
    pbrInputs.diffuseColor = diffuseColor;
    pbrInputs.specularColor = specularColor;
    pbrInputs.n = n;
    pbrInputs.v = v;

    vec3 color = getIBLContribution(pbrInputs, n, reflection);

    return color;
}

vec3 calculatePBRLightContribution( inout PBRInfo pbrInputs, vec3 lightDirection, vec3 lightColor )
{
    vec3 n = pbrInputs.n;
    vec3 v = pbrInputs.v;
    vec3 l = normalize(lightDirection);		vec3 h = normalize(l+v);
    float NdotV = pbrInputs.NdotV;
    float NdotL = clamp(dot(n, l), 0.001, 1.0);
    float NdotH = clamp(dot(n, h), 0.0, 1.0);
    float LdotH = clamp(dot(l, h), 0.0, 1.0);
    float VdotH = clamp(dot(v, h), 0.0, 1.0);

    pbrInputs.NdotL = NdotL;
    pbrInputs.NdotH = NdotH;
    pbrInputs.LdotH = LdotH;
    pbrInputs.VdotH = VdotH;

    vec3 F = specularReflection(pbrInputs);
    float G = geometricOcclusion(pbrInputs);
    float D = microfacetDistribution(pbrInputs);

    vec3 diffuseContrib = (1.0 - F) * diffuseBurley(pbrInputs);
    vec3 specContrib = F * G * D / (4.0 * NdotL * NdotV);
    vec3 color = NdotL * lightColor * (diffuseContrib + specContrib);

    return color;
}

mat3 cotangentFrame( vec3 N, vec3 p, vec2 uv )
{
    vec3 dp1 = dFdx( p );
    vec3 dp2 = dFdy( p );
    vec2 duv1 = dFdx( uv );
    vec2 duv2 = dFdy( uv );

    vec3 dp2perp = cross( dp2, N );
    vec3 dp1perp = cross( N, dp1 );
    vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
    vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;

    float invmax = inversesqrt( max( dot(T,T), dot(B,B) ) );

    float w = (dot(cross(N, T), B) < 0.0) ? -1.0 : 1.0;

    T = T * w;

    return mat3( T * invmax, B * invmax, N );
}

vec3 perturbNormal(vec3 n, vec3 v, vec3 normalSample, vec2 uv)
{
    vec3 map = normalize( 2.0 * normalSample - vec3(1.0) );
    mat3 TBN = cotangentFrame(n, v, uv);
    return normalize(TBN * map);
}


void main()
{
    MaterialData mtl = in_Materials[matIdx];

    vec4 albedo = mtl.albedoColor_;
    vec3 normalSample = vec3(0.0, 0.0, 0.0);

    if (mtl.albedoMap_ > 0)
    albedo = texture( sampler2D(unpackUint2x32(mtl.albedoMap_)), v_tc);
    if (mtl.normalMap_ > 0)
    normalSample = texture( sampler2D(unpackUint2x32(mtl.normalMap_)), v_tc).xyz;

    runAlphaTest(albedo.a, mtl.alphaTest_);

    vec3 n = normalize(v_worldNormal);

    if (length(normalSample) > 0.5)
    n = perturbNormal(n, normalize(cameraPos.xyz - v_worldPos.xyz), normalSample, v_tc);

    vec3 lightDir = normalize(vec3(-1.0, 1.0, 0.1));

    float NdotL = clamp( dot( n, lightDir ), 0.3, 1.0 );

    out_FragColor = vec4( albedo.rgb * NdotL, 1.0 );
}
// ]]

// return {
//     common_shader = common_shader,
//     vertex_shader = vertex_shader,
//     fragment_shader = fragment_shader,
// }