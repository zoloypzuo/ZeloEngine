// MeshRenderer.h
// created on 2021/3/31
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/ECS/Entity.h"
#include "Renderer/OpenGL/Resource/GLMesh.h"
#include "Core/RHI/Resource/Material.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

namespace Zelo::Core::RHI {
class MeshRenderer : public Zelo::Core::ECS::Component {
public:
    explicit MeshRenderer(Core::ECS::Entity &owner);

    ~MeshRenderer() override;

    inline std::string getType() override { return "MESH_RENDERER"; }

public:
    ZELO_SCRIPT_API Mesh &GetMesh() { return *m_mesh; }

    ZELO_SCRIPT_API Material &GetMaterial() { return *m_material; }

    ZELO_SCRIPT_API void SetMesh(Mesh &mesh);

    ZELO_SCRIPT_API void SetMaterial(Material &material);

private:
    Mesh *m_mesh{};
    Material *m_material{};
};
}
