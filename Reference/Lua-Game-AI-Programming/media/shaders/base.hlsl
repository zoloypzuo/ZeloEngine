/**
 * Ogre Wiki Source Code Public Domain (Un)License
 * The source code on the Ogre Wiki is free and unencumbered 
 * software released into the public domain.
 * 
 * Anyone is free to copy, modify, publish, use, compile, sell, or 
 * distribute this software, either in source code form or as a compiled 
 * binary, for any purpose, commercial or non-commercial, and by any 
 * means.
 * 
 * In jurisdictions that recognize copyright laws, the author or authors 
 * of this software dedicate any and all copyright interest in the 
 * software to the public domain. We make this dedication for the benefit 
 * of the public at large and to the detriment of our heirs and 
 * successors. We intend this dedication to be an overt act of 
 * relinquishment in perpetuity of all present and future rights to this 
 * software under copyright law.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * For more information, please refer to http://unlicense.org/
 */

/**
 * The source code in this file is attributed to the Ogre wiki article at
 * http://www.ogre3d.org/tikiwiki/tiki-index.php?page=Normal+AO+Specular+Mapping+Shader&structure=Cookbook
 */

struct VIn
{
    float4 p    : POSITION;
    float3 n    : NORMAL;
    float3 t    : TANGENT;
    float2 uv   : TEXCOORD0;
};
 
struct VOut
{
    float4 p    : POSITION;
 
    float2 uv   : TEXCOORD0;
    float4 wp   : TEXCOORD1;
    float3 n    : TEXCOORD2;
    float3 t    : TEXCOORD3;
    float3 b    : TEXCOORD4;
    float4 lp   : TEXCOORD5;
    float3 sdir : TEXCOORD6;
};
 
struct PIn
{
    float2 uv   : TEXCOORD0;
    float4 wp   : TEXCOORD1;
    float3 n    : TEXCOORD2;
    float3 t    : TEXCOORD3;
    float3 b    : TEXCOORD4;
    float4 lp   : TEXCOORD5;
    float3 sdir : TEXCOORD6;
};
 
void ambient_vs(VIn IN,
    uniform float4x4 wvpMat,
    out float4 oPos : POSITION,
    out float2 oUV : TEXCOORD0)
{
    oPos = mul(wvpMat, IN.p);
    oUV = IN.uv;
}
 
float4 ambient_ps(in float2 uv : TEXCOORD0,
    uniform float3 ambient,
    uniform float4 matDif,
    uniform sampler2D dMap,
    uniform sampler2D aoMap): COLOR0
{
    return tex2D(dMap, uv) * tex2D(aoMap, uv) *
        float4(ambient, 1) * float4(matDif.rgb, 1);
}
 
VOut diffuse_vs(VIn IN,
    uniform float4x4 wMat,
    uniform float4x4 wvpMat,
    uniform float4x4 tvpMat,
    uniform float4 spotlightDir)
{
    VOut OUT;
    OUT.wp = mul(wMat, IN.p);
    OUT.p = mul(wvpMat, IN.p);
 
    OUT.uv = IN.uv;
 
    OUT.n = IN.n;
    OUT.t = IN.t;
    OUT.b = cross(IN.t, IN.n);
    OUT.sdir = mul(wMat, spotlightDir).xyz; // spotlight dir in world space
 
    OUT.lp = mul(tvpMat, OUT.wp);
 
    return OUT;
}
 
float4 diffuse_ps(
    PIn IN,
    uniform float3 lightDif0,
    uniform float4 lightPos0,
    uniform float4 lightAtt0,
    uniform float3 lightSpec0,
    uniform float4 matDif,
    uniform float4 matSpec,
    uniform float matShininess,
    uniform float3 camPos,
    uniform float4 invSMSize,
    uniform float4 spotlightParams,
    uniform float4x4 iTWMat,
    uniform sampler2D diffuseMap : TEXUNIT0,
    uniform sampler2D specMap : TEXUNIT1,
    uniform sampler2D normalMap : TEXUNIT2): COLOR0
{
    // direction
    float3 ld0 = normalize(lightPos0.xyz - (lightPos0.w * IN.wp.xyz));
 
    half lightDist = length(lightPos0.xyz - IN.wp.xyz) / lightAtt0.r;
    // attenuation
    half ila = lightDist * lightDist; // quadratic falloff
    half la = 1.0 - ila;
 
    float4 normalTex = tex2D(normalMap, IN.uv);
 
    float3x3 tbn = float3x3(IN.t, IN.b, IN.n);
    float3 normal = mul(transpose(tbn), normalTex.xyz * 2 - 1); // to object space
    normal = normalize(mul((float3x3)iTWMat, normal));
 
    float3 diffuse = max(dot(ld0, normal), 0);
 
    // calculate the spotlight effect
    float spot = (spotlightParams.x == 1 &&
        spotlightParams.y == 0 &&
        spotlightParams.z == 0 &&
        spotlightParams.w == 1 ? 1 : // if so, then it's not a spot light
        saturate(
            (dot(ld0, normalize(-IN.sdir)) - spotlightParams.y) /
            (spotlightParams.x - spotlightParams.y)));
 
    float3 camDir = normalize(camPos - IN.wp.xyz);
    float3 halfVec = normalize(ld0 + camDir);
    float3 specular = pow(max(dot(normal, halfVec), 0), matShininess);
 
    float4 diffuseTex = tex2D(diffuseMap, IN.uv);
    float4 specTex = tex2D(specMap, IN.uv);
 
    float3 diffuseContrib = (diffuse * lightDif0 * diffuseTex.rgb * matDif.rgb);
    float3 specularContrib = (specular * lightSpec0 * specTex.rgb * matSpec.rgb);
    float3 light0C = (diffuseContrib + specularContrib) * la * spot;
 
    return float4(light0C, diffuseTex.a);
}