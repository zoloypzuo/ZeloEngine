/**
 * Copyright (c) 2010 Robin Southern                                             
 *                                                                              
 * Permission is hereby granted, free of charge, to any person obtaining a copy  
 * of this software and associated documentation files (the "Software"), to deal 
 * in the Software without restriction, including without limitation the rights  
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     
 * copies of the Software, and to permit persons to whom the Software is         
 * furnished to do so, subject to the following conditions:                      
 *                                                                               
 * The above copyright notice and this permission notice shall be included in    
 * all copies or substantial portions of the Software.                           
 *                                                                               
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN     
 * THE SOFTWARE.
 */
void main_vp(
    in float4 position : POSITION,
    in float2 uv : TEXCOORD0,
    in float4 color : COLOR0,

    out float4 oPosition : POSITION,
    out float2 oUv : TEXCOORD0,
    out float4 oColor : TEXCOORD1)
{
    oPosition = position; 
    oUv = uv;
    oColor = color;
}

float4 main_fp(
    float2 texCoord : TEXCOORD0,
    float4 color : TEXCOORD1,
    sampler2D atlas : register(s0)) : COLOR
{
    return tex2D(atlas, texCoord) * color;
}