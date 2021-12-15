// GLMesh.cpp
// created on 2021/3/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLMesh.h"

#include "Core/Parser/MeshLoader.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;

GLMesh::GLMesh(const std::string &identifier, Vertex vertices[], size_t vertSize, unsigned int indices[],
               size_t indexSize) {
    m_vertSize = vertSize;
    m_indexSize = indexSize;

    glGenVertexArrays(1, &m_vao);
    glBindVertexArray(m_vao);

    glGenBuffers(1, &m_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, m_vbo);
    glBufferData(GL_ARRAY_BUFFER, vertSize * sizeof(Vertex), vertices, GL_STATIC_DRAW);

    glGenBuffers(1, &m_ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_ibo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexSize * sizeof(unsigned int), indices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);

    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex),
                          (GLvoid *) sizeof(glm::vec3));

    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex),
                          (GLvoid *) (sizeof(glm::vec3) + sizeof(glm::vec2)));

    glEnableVertexAttribArray(3);
    glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex),
                          (GLvoid *) (sizeof(glm::vec3) + sizeof(glm::vec2) + sizeof(glm::vec3)));

    glBindVertexArray(0);
}

GLMesh::GLMesh(Zelo::Core::Interface::IMeshData &iMeshGen) :
        GLMesh(iMeshGen.getId(),
               &iMeshGen.getVertices()[0],
               iMeshGen.getVertices().size(),
               &iMeshGen.getIndices()[0],
               iMeshGen.getIndices().size()) {
}

GLMesh::~GLMesh() {
    glDeleteBuffers(1, &m_vbo);
    glDeleteVertexArrays(1, &m_vao);
};

void GLMesh::render() const {
    glBindVertexArray(m_vao);
    glDrawElements(GL_TRIANGLES, m_indexSize, GL_UNSIGNED_INT, (void *) 0);
    glBindVertexArray(0);
}

