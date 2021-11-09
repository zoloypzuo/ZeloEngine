// MeshRenderer.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_MESHRENDERER_H
#define ZELOENGINE_MESHRENDERER_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/ECS/Entity.h"
#include "Renderer/OpenGL/Resource/GLMesh.h"
#include "Core/RHI/Resource/Material.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

class MeshRenderer : public Zelo::Core::ECS::Component {
public:
    explicit MeshRenderer(Zelo::Core::ECS::Entity &owner);

    ~MeshRenderer() override;

    void render();

    inline std::string getType() override { return "MESH_RENDERER"; }

public:
    ZELO_SCRIPT_API GLMesh &GetMesh() { return *m_mesh; }

    ZELO_SCRIPT_API Zelo::Core::RHI::Material &GetMaterial() { return *m_material; }

    ZELO_SCRIPT_API void SetMesh(GLMesh &mesh);

    ZELO_SCRIPT_API void SetMaterial(Zelo::Core::RHI::Material &material);

private:
    GLMesh *m_mesh{};
    Zelo::Core::RHI::Material *m_material{};
};

#endif //ZELOENGINE_MESHRENDERER_H