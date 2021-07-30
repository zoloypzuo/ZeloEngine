// MeshRenderer.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_MESHRENDERER_H
#define ZELOENGINE_MESHRENDERER_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/ECS/Entity.h"
#include "GLMesh.h"
#include "Material.h"
#include "GLSLShaderProgram.h"

class MeshRenderer : public Component {
public:
    MeshRenderer(std::shared_ptr<GLMesh> mesh, std::shared_ptr<Material> material);

    virtual ~MeshRenderer();

    void render(GLSLShaderProgram *shader) override;

    inline const char *getType() override { return "MESH_RENDERER"; }

private:
    std::shared_ptr<GLMesh> m_mesh;
    std::shared_ptr<Material> m_material;
};


#endif //ZELOENGINE_MESHRENDERER_H