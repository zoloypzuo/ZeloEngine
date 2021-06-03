// GLMesh.h
// created on 2021/3/30
// author @zoloypzuo

#ifndef ZELOENGINE_GLMESH_H
#define ZELOENGINE_GLMESH_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

struct Vertex {
    glm::vec3 position{};
    glm::vec2 texCoord{};
    glm::vec3 normal{};
    glm::vec3 tangent{};

    explicit Vertex(
            const glm::vec3 &position,
            const glm::vec2 &texCoord = glm::vec2(0, 0),
            const glm::vec3 &normal = glm::vec3(0, 0, 0),
            const glm::vec3 &tangent = glm::vec3(0, 0, 0)) {
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

    GLuint m_vao{};
    GLuint m_vbo{};
    GLuint m_ibo{};

    int m_indexSize{}, m_vertSize{};
};

class GLMesh {
public:
    GLMesh(const std::string &identifier, Vertex vertices[], int vertSize, unsigned int indices[], int indexSize);

    virtual ~GLMesh();

    void render() const;

private:
    std::shared_ptr<MeshData> m_meshData;
};

class Plane {
public:
    Plane();

    ~Plane() = default;

    static std::shared_ptr<GLMesh> getMesh();
};


#endif //ZELOENGINE_GLMESH_H