// local compute_shader = [[
#version 460 core

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(rgba16f, binding = 0) uniform readonly  image2D imgLuminancePrev;
layout(rgba16f, binding = 1) uniform readonly  image2D imgLuminanceCurr;
layout(rgba16f, binding = 2) uniform writeonly image2D imgLuminanceAdapted;

layout(std140, binding = 0) uniform HDRParams
{
    float exposure;
    float maxWhite;
    float bloomStrength;
    float adaptationSpeed;
};

void main()
{
    float lumPrev = imageLoad(imgLuminancePrev, ivec2(0, 0)).x;
    float lumCurr = imageLoad(imgLuminanceCurr, ivec2(0, 0)).x;

    float newAdaptation = lumPrev + (lumCurr - lumPrev) * (1.0 - pow(0.98, 30.0 * adaptationSpeed));

    imageStore(imgLuminanceAdapted, ivec2(0, 0), vec4(vec3(newAdaptation), 1.0));
}
// ]]

// return {
//     compute_shader = compute_shader,
// }