//
// Created by zuoyiping01 on 2021/4/1.
//

#ifndef ZELOENGINE_MESHMANAGER_H
#define ZELOENGINE_MESHMANAGER_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "ZeloSingleton.h"
#include "GLMesh.h"
#include "Material.h"

struct MeshRendererData {
    std::shared_ptr<GLMesh> mesh;
    std::shared_ptr<Material> material;
};

class MeshManager : public Singleton<MeshManager> {
public:
    // TODO(Engine): need to come back and refactor this, make it load on a separate thread.
    std::map<std::string, std::vector<MeshRendererData>> sceneMeshRendererDataCache;

    static MeshManager *getSingletonPtr();

};

#endif //ZELOENGINE_MESHMANAGER_H
