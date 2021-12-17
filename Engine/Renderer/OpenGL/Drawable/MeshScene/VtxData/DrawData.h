#pragma once

struct DrawData {
    uint32_t meshIndex;
    uint32_t materialIndex;
    uint32_t LOD;
    uint32_t indexOffset;
    uint32_t vertexOffset;
    uint32_t transformIndex;
};
static_assert(sizeof(DrawData) == sizeof(uint32_t) * 6);
