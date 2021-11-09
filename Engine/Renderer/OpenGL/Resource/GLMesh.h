// GLMesh.h
// created on 2021/3/30
// author @zoloypzuo
#ifndef ZELOENGINE_GLMESH_H
#define ZELOENGINE_GLMESH_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Buffer/Vertex.h"
#include "Core/RHI/Resource/Mesh.h"
#include "Core/Interface/IMeshData.h"

class GLMeshData {
public:
    GLMeshData(Zelo::Core::RHI::Vertex vertices[], int vertSize, unsigned int indices[], int indexSize);

    virtual ~GLMeshData();

    void render() const;

private:

    GLuint m_vao{};
    GLuint m_vbo{};
    GLuint m_ibo{};

    int m_indexSize{}, m_vertSize{};
};

class GLMesh : public Zelo::Core::RHI::Mesh {
public:
    GLMesh(const std::string &identifier, Zelo::Core::RHI::Vertex vertices[], int vertSize, unsigned int indices[],
           int indexSize);

    explicit GLMesh(Zelo::Core::Interface::IMeshData &iMeshGen);

    virtual ~GLMesh();

    void render() const override;

private:
    std::shared_ptr<GLMeshData> m_meshData;
};

#endif //ZELOENGINE_GLMESH_H