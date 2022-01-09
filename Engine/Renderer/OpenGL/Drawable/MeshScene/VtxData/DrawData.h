#pragma once

/// contains information for rendering a mesh instance with a specific material.
struct DrawData {
    /// offsets into GPU buffers
    uint32_t meshIndex{};
    /// offsets into GPU buffers
    uint32_t materialIndex{};
    /// the relative offset to the vertex data
    uint32_t LOD{};
    /// byte offsets into the mesh index and geometry buffers
    uint32_t indexOffset{};
    /// byte offsets into the mesh index and geometry buffers
    uint32_t vertexOffset{};
    /// the index of the global object-to-world-space transformation that's calculated by scene graph routines
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
