// GLMesh.cpp
// created on 2021/3/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLMesh.h"

GLMeshData::GLMeshData(Zelo::Core::RHI::Vertex vertices[], int vertSize, unsigned int indices[], int indexSize) {
    createMesh(vertices, vertSize, indices, indexSize);
}

GLMeshData::~GLMeshData() {
    glDeleteBuffers(1, &m_vbo);
    glDeleteVertexArrays(1, &m_vao);
}

void GLMeshData::createMesh(Zelo::Core::RHI::Vertex *vertices, int vertSize, unsigned int *indices, int indexSize) {
    m_vertSize = vertSize;
    m_indexSize = indexSize;

    glGenVertexArrays(1, &m_vao);
    glBindVertexArray(m_vao);

    glGenBuffers(1, &m_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, m_vbo);
    glBufferData(GL_ARRAY_BUFFER, vertSize * sizeof(Zelo::Core::RHI::Vertex), vertices, GL_STATIC_DRAW);

    glGenBuffers(1, &m_ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_ibo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexSize * sizeof(unsigned int), indices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Zelo::Core::RHI::Vertex), 0);

    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(Zelo::Core::RHI::Vertex), (GLvoid *) sizeof(glm::vec3));

    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, sizeof(Zelo::Core::RHI::Vertex), (GLvoid *) (sizeof(glm::vec3) + sizeof(glm::vec2)));

    glEnableVertexAttribArray(3);
    glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, sizeof(Zelo::Core::RHI::Vertex),
                          (GLvoid *) (sizeof(glm::vec3) + sizeof(glm::vec2) + sizeof(glm::vec3)));

    glBindVertexArray(0);
}

void GLMeshData::render() const {
    glBindVertexArray(m_vao);
    glDrawElements(GL_TRIANGLES, m_indexSize, GL_UNSIGNED_INT, (void *) 0);
    glBindVertexArray(0);
}

std::map<std::string, std::weak_ptr<GLMeshData>> m_meshCache;

GLMesh::GLMesh(const std::string &identifier, Zelo::Core::RHI::Vertex vertices[], int vertSize, unsigned int indices[], int indexSize) {
    auto it = m_meshCache.find(identifier);

    if (it == m_meshCache.end() || !(m_meshData = it->second.lock())) {
        m_meshData = std::make_shared<GLMeshData>(vertices, vertSize, indices, indexSize);
        m_meshCache[identifier] = m_meshData;
    }
}

GLMesh::~GLMesh() {
}

void GLMesh::render() const {
    m_meshData->render();
}


