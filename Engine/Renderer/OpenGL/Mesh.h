// Mesh.h
// created on 2021/3/30
// author @zoloypzuo

#ifndef ZELOENGINE_MESH_H
#define ZELOENGINE_MESH_H

#include "ZeloPrerequisites.h"

#if defined(GLES2)
#include <GLES2/gl2.h>
#elif defined(GLES3)
#include <GLES3/gl3.h>
#else

#include <GL/glew.h>

#endif


struct Vertex {
    glm::vec3 position;
    glm::vec2 texCoord;
    glm::vec3 normal;
    glm::vec3 tangent;

    Vertex(const glm::vec3 &position, const glm::vec2 &texCoord = glm::vec2(0, 0),
           const glm::vec3 &normal = glm::vec3(0, 0, 0), const glm::vec3 &tangent = glm::vec3(0, 0, 0)) {
        this->position = position;
        this->texCoord = texCoord;
        this->normal = normal;
        this->tangent = tangent;
    }
};


class MeshData {
public:
    MeshData(Vertex vertices[], int vertSize, unsigned int indices[], int indexSize);

    virtual ~MeshData();

    void render() const;

private:
    void createMesh(Vertex vertices[], int vertSize, unsigned int indices[], int indexSize);

#if !defined(GLES2)
    GLuint m_vao;
#endif
    GLuint m_vbo;
    GLuint m_ibo;

    int m_indexSize, m_vertSize;
};

class Mesh {
public:
    Mesh(std::string identifier, Vertex vertices[], int vertSize, unsigned int indices[], int indexSize);

    virtual ~Mesh();

    void render() const;

private:
    std::shared_ptr<MeshData> m_meshData;
};


#endif //ZELOENGINE_MESH_H