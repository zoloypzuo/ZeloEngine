// Mesh.cpp
// created on 2021/3/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Mesh.h"

MeshData::MeshData(Vertex vertices[], int vertSize, unsigned int indices[], int indexSize) {
    createMesh(vertices, vertSize, indices, indexSize);
}

MeshData::~MeshData() {
    glDeleteBuffers(1, &m_vbo);
#if !defined(GLES2)
    glDeleteVertexArrays(1, &m_vao);
#endif
}

void MeshData::createMesh(Vertex *vertices, int vertSize, unsigned int *indices, int indexSize) {
    m_vertSize = vertSize;
    m_indexSize = indexSize;

#if !defined(GLES2)
    glGenVertexArrays(1, &m_vao);
    glBindVertexArray(m_vao);
#endif

    glGenBuffers(1, &m_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, m_vbo);
    glBufferData(GL_ARRAY_BUFFER, vertSize * sizeof(Vertex), vertices, GL_STATIC_DRAW);

    glGenBuffers(1, &m_ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_ibo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexSize * sizeof(unsigned int), indices, GL_STATIC_DRAW);

#if !defined(GLES2)
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);

    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *) sizeof(glm::vec3));

    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *) (sizeof(glm::vec3) + sizeof(glm::vec2)));

    glEnableVertexAttribArray(3);
    glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex),
                          (GLvoid *) (sizeof(glm::vec3) + sizeof(glm::vec2) + sizeof(glm::vec3)));

    glBindVertexArray(0);
#endif
}

void MeshData::render() const {
#if defined(GLES2)
    glBindBuffer(GL_ARRAY_BUFFER, m_vbo);

  glEnableVertexAttribArray(0);
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);

  glEnableVertexAttribArray(1);
  glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)sizeof(glm::vec3));

  glEnableVertexAttribArray(2);
  glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)(sizeof(glm::vec3) + sizeof(glm::vec2)));

  glEnableVertexAttribArray(3);
  glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)(sizeof(glm::vec3) + sizeof(glm::vec2) + sizeof(glm::vec3)));

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_ibo);
  glDrawElements(GL_TRIANGLES, m_indexSize, GL_UNSIGNED_INT, (void*)0);

  glDisableVertexAttribArray(0);
  glDisableVertexAttribArray(1);
  glDisableVertexAttribArray(2);
  glDisableVertexAttribArray(3);
#else
    glBindVertexArray(m_vao);
    glDrawElements(GL_TRIANGLES, m_indexSize, GL_UNSIGNED_INT, (void *) 0);
    glBindVertexArray(0);
#endif
}

std::map<std::string, std::weak_ptr<MeshData>> m_meshCache;

Mesh::Mesh(std::string identifier, Vertex vertices[], int vertSize, unsigned int indices[], int indexSize) {
    auto it = m_meshCache.find(identifier);

    if (it == m_meshCache.end() || !(m_meshData = it->second.lock())) {
        m_meshData = std::make_shared<MeshData>(vertices, vertSize, indices, indexSize);
        m_meshCache[identifier] = m_meshData;
    }
}

Mesh::~Mesh() {
}

void Mesh::render() const {
    m_meshData->render();
}
