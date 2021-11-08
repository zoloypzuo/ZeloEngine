// TriangleMeshAdapter.cpp
// created on 2021/10/11
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "TriangleMeshAdapter.h"

void TriangleMeshAdapter::initMeshData(std::vector<GLuint> *indices,
                                       std::vector<GLfloat> *points,
                                       std::vector<GLfloat> *normals,
                                       std::vector<GLfloat> *texCoords,
                                       std::vector<GLfloat> *tangents) {
    // Must have data for indices, points, and normals
    if (indices == nullptr || points == nullptr || normals == nullptr) {
        ZELO_ERROR("Must have data for indices, points, and normals");
        return;
    }

    auto nVerts = indices->size(); // Number of vertices
    for (int i = 0; i < nVerts; ++i) {
        //    glm::vec3 position{};
        //    glm::vec2 texCoord{};
        //    glm::vec3 normal{};
        //    glm::vec3 tangent{};
        int i0 = 3 * i;
        int i1 = 3 * i + 1;
        int i2 = 3 * i + 2;

        glm::vec3 position = glm::vec3((*points)[i0], (*points)[i1], (*points)[i2]);
        glm::vec3 normal = glm::vec3((*normals)[i0], (*normals)[i1], (*normals)[i2]);

        glm::vec2 texCoord;
        if (texCoords != nullptr) {
            texCoord = glm::vec2((*texCoords)[2 * i], (*texCoords)[2 * i + 1]);
        } else {
            texCoord = glm::vec2(0, 0);
        }

        glm::vec3 tangent;
        if (tangents != nullptr) {
            tangent = glm::vec3((*tangents)[i0], (*tangents)[i0], (*tangents)[i0]);
        } else {
            tangent = glm::vec3(1, 0, 0);
        }

        m_vertices.emplace_back(
                position,
                texCoord,
                normal,
                tangent
        );
    }

    std::transform(indices->begin(), indices->end(), m_indices.begin(),
                   [](GLuint i) { return static_cast<uint32_t >(i); });
}
