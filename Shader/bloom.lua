-- # Property
-- Width : The width of the screen window in pixels
-- Height : The height of the screen window in pixels
-- EdgeThreshold : The minimum value of g squared required to be considered "on an edge"
-- RenderTex : The texture associated with the FBO

local vertex_shader = [[
#version 330 core
layout (location = 0) in vec3 position;
layout (location = 1) in vec2 texCoord;

out vec2 TexCoord;

void main()
{
    TexCoord = texCoord;
    gl_Position = vec4(position, 1.0);
}
]]

local fragment_shader = [[
#version 330 core
out vec4 FragColor;

in vec2 TexCoord;

subroutine vec4 RenderPassType();
subroutine uniform RenderPassType RenderPass;

uniform sampler2D RenderTex;
uniform sampler2D BlurTex;

uniform int Width;
uniform int Height;
uniform float LumThresh;  // Luminance threshold

uniform float PixOffset[10] = float[](0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0);
uniform float Weight[10];

float luminance( vec3 color ) {
    return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
}

// Pass to extract the bright parts
subroutine( RenderPassType )
vec4 pass2()
{
    vec4 val = texture(RenderTex, TexCoord);
    if( luminance(val.rgb) > LumThresh )
        return val * 0.5;
    else
        return vec4(0.0);
}

// First blur pass
subroutine( RenderPassType )
vec4 pass3()
{
    float dy = 1.0 / float(Height);

    vec4 sum = texture(BlurTex, TexCoord) * Weight[0];
    for( int i = 1; i < 10; i++ )
    {
         sum += texture( BlurTex, TexCoord + vec2(0.0,PixOffset[i]) * dy ) * Weight[i];
         sum += texture( BlurTex, TexCoord - vec2(0.0,PixOffset[i]) * dy ) * Weight[i];
    }
    return sum;
}

// Second blur and add to original
subroutine( RenderPassType )
vec4 pass4()
{
    float dx = 1.0 / float(Width);

    vec4 val = texture(RenderTex, TexCoord);
    vec4 sum = texture(BlurTex, TexCoord) * Weight[0];
    for( int i = 1; i < 10; i++ )
    {
       sum += texture( BlurTex, TexCoord + vec2(PixOffset[i],0.0) * dx ) * Weight[i];
       sum += texture( BlurTex, TexCoord - vec2(PixOffset[i],0.0) * dx ) * Weight[i];
    }
    return val + (sum * sum.a);
}

void main()
{
    // This will call either pass1(), pass2(), pass3(), or pass4()
    FragColor = RenderPass();
}
]]

return {
    vertex_shader = vertex_shader,
    fragment_shader = fragment_shader,
}
