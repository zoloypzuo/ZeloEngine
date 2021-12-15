// GLMesh.h
// created on 2021/3/30
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Resource/Mesh.h"
#include "Core/RHI/Buffer/Vertex.h"
#include "Core/Interface/IMeshData.h"

namespace Zelo::Renderer::OpenGL {
class GLMesh : public Core::RHI::Mesh {
public:
    GLMesh(const std::string &identifier,
           Core::RHI::Vertex vertices[], int vertSize,
           unsigned int indices[], int indexSize);

    explicit GLMesh(Core::Interface::IMeshData &iMeshGen);

    virtual ~GLMesh();

    void render() const override;

private:
    GLuint m_vao{};
    GLuint m_vbo{};
    GLuint m_ibo{};

    int m_indexSize{}, m_vertSize{};
};
}
