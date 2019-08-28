// color.fx
// created on 2019/8/28
// author @zoloypzuo

cbuffer cbPerObject
{
    float4x4 gWorldViewProj;
}

struct VertexIn
{
    float PosL : POSITION;
    float Color : COLOR;
}

struct VertexOut
{
    float4 PosH : SV_POSITION;
    float4 Color : COLOR;
}

VertexOut VS(VertexIn vin)
{
    VertexOut vout;
    vout.PosH = mul(float4(vin.PosL, 1.0f), gWorldViewProj);
    vout.Color = vin.Color;
    return vout;
}

float4 PS(VertexOut pin) : SV_Target
{
    return pin.Color;
}

technique11 ColorTech
{
    pass P0
    {
        SetVertexShader(CompileShader(vs_5_0, VS());
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, PS());
    }
}