-- # Property
-- Width : The width of the screen window in pixels
-- Height : The height of the screen window in pixels
-- EdgeThreshold : The minimum value of g squared required to be considered "on an edge"
-- RenderTex : The texture associated with the FBO

local vertex_shader = [[
#version 330 core
layout (location = 0) in vec3 position;
layout (location = 1) in vec2 texCoord;

out vec2 texCoord0;

void main()
{
    texCoord0 = texCoord;
    gl_Position = vec4(position, 1.0);
}
]]

local fragment_shader = [[
#version 330 core
out vec4 FragColor;

in vec2 texCoord0;

uniform int Pass;   // Pass number

uniform sampler2D HdrTex;
uniform sampler2D BlurTex1;
uniform sampler2D BlurTex2;

uniform float LumThresh;  // Luminance threshold
uniform float PixOffset[10] = float[](0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0);
uniform float Weight[10];

// XYZ/RGB conversion matrices from:
// http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html

uniform mat3 rgb2xyz = mat3(
  0.4124564, 0.2126729, 0.0193339,
  0.3575761, 0.7151522, 0.1191920,
  0.1804375, 0.0721750, 0.9503041 );

uniform mat3 xyz2rgb = mat3(
  3.2404542, -0.9692660, 0.0556434,
  -1.5371385, 1.8760108, -0.2040259,
  -0.4985314, 0.0415560, 1.0572252 );

uniform float Exposure = 0.35;
uniform float White = 0.928;
uniform float AveLum;

float luminance( vec3 color ) {
    return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
}

// Bright-pass filter (write to BlurTex1)
vec4 pass2() {
    vec4 val = texture(HdrTex, TexCoord);
    if( luminance(val.rgb) > LumThresh )
        return val;
    else
        return vec4(0.0);
}

// First blur pass (read from BlurTex1, write to BlurTex2)
vec4 pass3() {
    float dy = 1.0 / (textureSize(BlurTex1,0)).y;

    vec4 sum = texture(BlurTex1, TexCoord) * Weight[0];
    for( int i = 1; i < 10; i++ )
    {
         sum += texture( BlurTex1, TexCoord + vec2(0.0,PixOffset[i]) * dy ) * Weight[i];
         sum += texture( BlurTex1, TexCoord - vec2(0.0,PixOffset[i]) * dy ) * Weight[i];
    }
    return sum;
}

// Second blur (read from BlurTex2, write to BlurTex1)
vec4 pass4() {
    float dx = 1.0 / (textureSize(BlurTex2,0)).x;

    vec4 sum = texture(BlurTex2, TexCoord) * Weight[0];
    for( int i = 1; i < 10; i++ )
    {
       sum += texture( BlurTex2, TexCoord + vec2(PixOffset[i],0.0) * dx ) * Weight[i];
       sum += texture( BlurTex2, TexCoord - vec2(PixOffset[i],0.0) * dx ) * Weight[i];
    }
    return sum;
}

// Composite pass, apply tone map to HDR image,
// then combine with the blurred bright-pass filter.
// (Read from BlurTex1 and HdrTex, write to default buffer).
vec4 pass5() {
    /////////////// Tone mapping ///////////////
    // Retrieve high-res color from texture
    vec4 color = texture( HdrTex, TexCoord );

    // Convert to XYZ
    vec3 xyzCol = rgb2xyz * vec3(color);

    // Convert to xyY
    float xyzSum = xyzCol.x + xyzCol.y + xyzCol.z;
    vec3 xyYCol = vec3( xyzCol.x / xyzSum, xyzCol.y / xyzSum, xyzCol.y);

    // Apply the tone mapping operation to the luminance (xyYCol.z or xyzCol.y)
    float L = (Exposure * xyYCol.z) / AveLum;
    L = (L * ( 1 + L / (White * White) )) / ( 1 + L );

    // Using the new luminance, convert back to XYZ
    xyzCol.x = (L * xyYCol.x) / (xyYCol.y);
    xyzCol.y = L;
    xyzCol.z = (L * (1 - xyYCol.x - xyYCol.y))/xyYCol.y;

    // Convert back to RGB
    vec4 toneMapColor = vec4( xyz2rgb * xyzCol, 1.0);

    ///////////// Combine with blurred texture /////////////
    // We want linear filtering on this texture access so that
    // we get additional blurring.
    vec4 blurTex = texture(BlurTex1, TexCoord);

   // ivec2 blurSize = textureSize(BlurTex1, 0);
   // if( gl_FragCoord.x < blurSize.x && gl_FragCoord.y < blurSize.y )
   //    return texture( BlurTex1, vec2(gl_FragCoord.x / blurSize.x,
   //    gl_FragCoord.y / blurSize.y ) );
  //  else
     return toneMapColor + blurTex;
}

void main()
{
  if(Pass == 2) FragColor = pass2();
  else if(Pass == 3) FragColor = pass3();
  else if(Pass == 4) FragColor = pass4();
  else if(Pass == 5) FragColor = pass5();
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}
