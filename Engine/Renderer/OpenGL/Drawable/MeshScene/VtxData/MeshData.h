#pragma once

#include <stdint.h>

#include <glm/glm.hpp>

#include "Renderer/OpenGL/Drawable/MeshScene/Util/Utils.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Util/UtilsMath.h"

#include "Mesh.h"
#include "VtxData/MeshFileHeader.h"

struct MeshData {
    std::vector<uint32_t> indexData_;
    std::vector<float> vertexData_;
    std::vector<Mesh> meshes_;
    std::vector<BoundingBox> boxes_;
};
static_assert(sizeof(BoundingBox) == sizeof(float) * 6);

MeshFileHeader loadMeshData(const char *meshFile, MeshData &out);

void saveMeshData(const char *fileName, const MeshData &m);

void recalculateBoundingBoxes(MeshData &m);
