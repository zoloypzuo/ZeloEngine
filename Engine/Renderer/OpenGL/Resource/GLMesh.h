// GLMesh.h
// created on 2021/3/30
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/RHI/Resource/Mesh.h"
#include "Core/RHI/Buffer/Vertex.h"
#include "Core/RHI/IMeshData.h"
#include "Renderer/OpenGL/Buffer/GLVertexArray.h"

namespace Zelo::Renderer::OpenGL {
class GLMesh : public Core::RHI::Mesh {
public:
    GLMesh(Core::RHI::Vertex vertices[], size_t vertSize,
           uint32_t indices[], size_t indexSize);

    explicit GLMesh(Core::RHI::IMeshData &iMeshGen);

    virtual ~GLMesh();

    void render()  override;

private:
    GLVertexArray m_vao{};
};
}
