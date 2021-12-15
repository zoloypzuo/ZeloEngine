#include "MeshData.h"
#include "VtxData/MeshFileHeader.h"

#include <algorithm>
#include <assert.h>
#include <stdio.h>

MeshFileHeader loadMeshData(const char *meshFile, MeshData &out) {
    MeshFileHeader header;

    FILE *f = fopen(meshFile, "rb");

    assert(f); // Did you forget to run "Ch5_Tool05_MeshConvert"?

    if (!f) {
        printf("Cannot open %s. Did you forget to run \"Ch5_Tool05_MeshConvert\"?\n", meshFile);
        exit(EXIT_FAILURE);
    }

    if (fread(&header, 1, sizeof(header), f) != sizeof(header)) {
        printf("Unable to read mesh file header\n");
        exit(EXIT_FAILURE);
    }

    out.meshes_.resize(header.meshCount);
    if (fread(out.meshes_.data(), sizeof(Mesh), header.meshCount, f) != header.meshCount) {
        printf("Could not read mesh descriptors\n");
        exit(EXIT_FAILURE);
    }
    out.boxes_.resize(header.meshCount);
    if (fread(out.boxes_.data(), sizeof(BoundingBox), header.meshCount, f) != header.meshCount) {
        printf("Could not read bounding boxes\n");
        exit(255);
    }

    out.indexData_.resize(header.indexDataSize / sizeof(uint32_t));
    out.vertexData_.resize(header.vertexDataSize / sizeof(float));

    if ((fread(out.indexData_.data(), 1, header.indexDataSize, f) != header.indexDataSize) ||
        (fread(out.vertexData_.data(), 1, header.vertexDataSize, f) != header.vertexDataSize)) {
        printf("Unable to read index/vertex data\n");
        exit(255);
    }

    fclose(f);

    return header;
}

void saveMeshData(const char *fileName, const MeshData &m) {
    FILE *f = fopen(fileName, "wb");

    const MeshFileHeader header = {
            0x12345678,
            (uint32_t) m.meshes_.size(),
            (uint32_t) (sizeof(MeshFileHeader) + m.meshes_.size() * sizeof(Mesh)),
            (uint32_t) (m.indexData_.size() * sizeof(uint32_t)),
            (uint32_t) (m.vertexData_.size() * sizeof(float))
    };

    fwrite(&header, 1, sizeof(header), f);
    fwrite(m.meshes_.data(), sizeof(Mesh), header.meshCount, f);
    fwrite(m.boxes_.data(), sizeof(BoundingBox), header.meshCount, f);
    fwrite(m.indexData_.data(), 1, header.indexDataSize, f);
    fwrite(m.vertexData_.data(), 1, header.vertexDataSize, f);

    fclose(f);
}

void saveBoundingBoxes(const char *fileName, const std::vector<BoundingBox> &boxes) {
    FILE *f = fopen(fileName, "wb");

    if (!f) {
        printf("Error opening bounding boxes file for writing\n");
        exit(255);
    }

    const uint32_t sz = (uint32_t) boxes.size();
    fwrite(&sz, 1, sizeof(sz), f);
    fwrite(boxes.data(), sz, sizeof(BoundingBox), f);

    fclose(f);
}

void loadBoundingBoxes(const char *fileName, std::vector<BoundingBox> &boxes) {
    FILE *f = fopen(fileName, "rb");

    if (!f) {
        printf("Error opening bounding boxes file\n");
        exit(255);
    }

    uint32_t sz;
    fread(&sz, 1, sizeof(sz), f);

    // TODO: check file size, divide by bounding box size
    boxes.resize(sz);
    fread(boxes.data(), sz, sizeof(BoundingBox), f);

    fclose(f);
}

void recalculateBoundingBoxes(MeshData &m) {
    m.boxes_.clear();

    for (const auto &mesh : m.meshes_) {
        const auto numIndices = mesh.getLODIndicesCount(0);

        glm::vec3 vmin(std::numeric_limits<float>::max());
        glm::vec3 vmax(std::numeric_limits<float>::lowest());

        for (auto i = 0; i != numIndices; i++) {
            auto vtxOffset = m.indexData_[mesh.indexOffset + i] + mesh.vertexOffset;
            const float *vf = &m.vertexData_[vtxOffset * kMaxStreams];
            vmin = glm::min(vmin, vec3(vf[0], vf[1], vf[2]));
            vmax = glm::max(vmax, vec3(vf[0], vf[1], vf[2]));
        }

        m.boxes_.emplace_back(vmin, vmax);
    }
}
