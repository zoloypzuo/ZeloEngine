#include "MeshData.h"

#include <algorithm>

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
