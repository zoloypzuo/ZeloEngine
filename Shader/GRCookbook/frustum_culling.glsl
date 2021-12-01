// local compute_shader = [[
#version 460 core

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

layout(std140, binding = 0) uniform PerFrameData
{
    mat4 view;
    mat4 proj;
    mat4 light;
    vec4 cameraPos;
    vec4 frustumPlanes[6];
    vec4 frustumCorners[8];
    uint numShapesToCull;
};

struct AABB
{
    float pt[6];
};

layout(std430, binding = 1) buffer BoundingBoxes
{
    AABB in_AABBs[];
};

struct DrawCommand
{
    uint count;
    uint instanceCount;
    uint firstIndex;
    uint baseVertex;
    uint baseInstance;
};

layout(std430, binding = 2) buffer DrawCommands
{
    DrawCommand in_DrawCommands[];
};

layout(std430, binding = 3) buffer NumVisibleMeshes
{
    uint numVisibleMeshes;
};

#define Box_min_x box.pt[0]
#define Box_min_y box.pt[1]
#define Box_min_z box.pt[2]
#define Box_max_x box.pt[3]
#define Box_max_y box.pt[4]
#define Box_max_z box.pt[5]

bool isAABBinFrustum(AABB box)
{
    for (int i = 0; i < 6; i++) {
        int r = 0;
        r += ( dot( frustumPlanes[i], vec4(Box_min_x, Box_min_y, Box_min_z, 1.0f) ) < 0.0 ) ? 1 : 0;
        r += ( dot( frustumPlanes[i], vec4(Box_max_x, Box_min_y, Box_min_z, 1.0f) ) < 0.0 ) ? 1 : 0;
        r += ( dot( frustumPlanes[i], vec4(Box_min_x, Box_max_y, Box_min_z, 1.0f) ) < 0.0 ) ? 1 : 0;
        r += ( dot( frustumPlanes[i], vec4(Box_max_x, Box_max_y, Box_min_z, 1.0f) ) < 0.0 ) ? 1 : 0;
        r += ( dot( frustumPlanes[i], vec4(Box_min_x, Box_min_y, Box_max_z, 1.0f) ) < 0.0 ) ? 1 : 0;
        r += ( dot( frustumPlanes[i], vec4(Box_max_x, Box_min_y, Box_max_z, 1.0f) ) < 0.0 ) ? 1 : 0;
        r += ( dot( frustumPlanes[i], vec4(Box_min_x, Box_max_y, Box_max_z, 1.0f) ) < 0.0 ) ? 1 : 0;
        r += ( dot( frustumPlanes[i], vec4(Box_max_x, Box_max_y, Box_max_z, 1.0f) ) < 0.0 ) ? 1 : 0;
        if ( r == 8 ) return false;
    }

    int r = 0;
    r = 0; for ( int i = 0; i < 8; i++ ) r += ( (frustumCorners[i].x > Box_max_x) ? 1 : 0 ); if ( r == 8 ) return false;
    r = 0; for ( int i = 0; i < 8; i++ ) r += ( (frustumCorners[i].x < Box_min_x) ? 1 : 0 ); if ( r == 8 ) return false;
    r = 0; for ( int i = 0; i < 8; i++ ) r += ( (frustumCorners[i].y > Box_max_y) ? 1 : 0 ); if ( r == 8 ) return false;
    r = 0; for ( int i = 0; i < 8; i++ ) r += ( (frustumCorners[i].y < Box_min_y) ? 1 : 0 ); if ( r == 8 ) return false;
    r = 0; for ( int i = 0; i < 8; i++ ) r += ( (frustumCorners[i].z > Box_max_z) ? 1 : 0 ); if ( r == 8 ) return false;
    r = 0; for ( int i = 0; i < 8; i++ ) r += ( (frustumCorners[i].z < Box_min_z) ? 1 : 0 ); if ( r == 8 ) return false;

    return true;
}

void main()
{
    const uint idx = gl_GlobalInvocationID.x;

    /* skip items beyond sceneData.shapes_.size()*/
    if (idx < numShapesToCull)
    {
        AABB box = in_AABBs[in_DrawCommands[idx].baseInstance >> 16];
        uint numInstances = isAABBinFrustum(box) ? 1 : 0;
        in_DrawCommands[idx].instanceCount = numInstances;
        atomicAdd(numVisibleMeshes, numInstances);
    }
    else
    {
        in_DrawCommands[idx].instanceCount = 1;
    }
}
// ]]

// return {
//     compute_shader = compute_shader,
// }