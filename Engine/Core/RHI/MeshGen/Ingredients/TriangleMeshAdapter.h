// TriangleMeshAdapter.h
// created on 2021/10/11
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"  // GLuint GLfloat
#include "Core/RHI/IMeshData.h"

class TriangleMeshAdapter : public Zelo::Core::RHI::IMeshData {
public:
    ~TriangleMeshAdapter() override = default;

public:
    std::string getId() override { return ""; }

    std::vector<Zelo::Core::RHI::Vertex> getVertices() override { return m_vertices; }

    std::vector<uint32_t> getIndices() override { return m_indices; }

protected:
    void initMeshData(
            std::vector<GLuint> *indices,
            std::vector<GLfloat> *points,
            std::vector<GLfloat> *normals,
            std::vector<GLfloat> *texCoords = nullptr,
            std::vector<GLfloat> *tangents = nullptr
    );

public:
    std::vector<Zelo::Core::RHI::Vertex> m_vertices;
    std::vector<uint32_t> m_indices;
};


