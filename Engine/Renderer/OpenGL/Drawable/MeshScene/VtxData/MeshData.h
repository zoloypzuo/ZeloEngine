#pragma once

#include <stdint.h>

#include <glm/glm.hpp>

#include "Renderer/OpenGL/Drawable/MeshScene/Util/Utils.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Util/UtilsMath.h"

#include "Mesh.h"

namespace Zelo::Renderer::OpenGL {
struct MeshData {
    std::vector<uint32_t> indexData_;
    std::vector<float> vertexData_;
    std::vector<Mesh> meshes_;
    std::vector<BoundingBox> boxes_;

    /* Number of mesh descriptors following this header */
    uint32_t meshCount() const;

    /* How much space index data takes */
    uint32_t indexDataSize() const;

    /* How much space vertex data takes */
    uint32_t vertexDataSize() const;
};

static_assert(sizeof(BoundingBox) == sizeof(float) * 6);

void loadMeshData(const char *fileName, MeshData &out);

void saveMeshData(const char *fileName, const MeshData &m);

void recalculateBoundingBoxes(MeshData &m);
}