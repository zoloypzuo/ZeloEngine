// GLMesh.h
// created on 2021/3/30
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Resource/Mesh.h"
#include "Core/RHI/Buffer/Vertex.h"
#include "Core/Interface/IMeshData.h"

#include "Renderer/OpenGL/Buffer/GLVertexArray.h"

namespace Zelo::Renderer::OpenGL {
class GLMesh : public Core::RHI::Mesh {
public:
    GLMesh(Core::RHI::Vertex vertices[], size_t vertSize,
           unsigned int indices[], size_t indexSize);

    explicit GLMesh(Core::Interface::IMeshData &iMeshGen);

    virtual ~GLMesh();

    void render() const override;

private:
    GLuint m_vao{};
    GLuint m_vbo{};
    GLuint m_ibo{};

    int m_indexSize{}, m_vertSize{};

    GLVertexArray m_va{};
};
}
