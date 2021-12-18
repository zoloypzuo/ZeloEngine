#pragma once

struct DrawData {
    uint32_t meshIndex{};
    uint32_t materialIndex{};
    uint32_t LOD{};
    uint32_t indexOffset{};
    uint32_t vertexOffset{};
    uint32_t transformIndex{};

    DrawData(uint32_t meshIndex_,
             uint32_t materialIndex_,
             uint32_t LOD_,
             uint32_t indexOffset_,
             uint32_t vertexOffset_,
             uint32_t transformIndex_) :
            meshIndex(meshIndex_),
            materialIndex(materialIndex_),
            LOD(LOD_),
            indexOffset(indexOffset_),
            vertexOffset(vertexOffset_),
            transformIndex(transformIndex_) {}
};

static_assert(sizeof(DrawData) == sizeof(uint32_t) * 6);
