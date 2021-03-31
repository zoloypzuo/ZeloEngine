// MeshRenderer.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_MESHRENDERER_H
#define ZELOENGINE_MESHRENDERER_H

#include "ZeloPrerequisites.h"
#include "Component.h"
#include "Mesh.h"
#include "Material.h"
#include "Shader.h"

class MeshRenderer : public Component
{
public:
    MeshRenderer(std::shared_ptr<Mesh> mesh, std::shared_ptr<Material> material);
    virtual ~MeshRenderer();

    virtual void render(Shader *shader);

    inline virtual const char *getType() { return "MESH_RENDERER"; }

private:
    std::shared_ptr<Mesh> m_mesh;
    std::shared_ptr<Material> m_material;
};


#endif //ZELOENGINE_MESHRENDERER_H