// MeshManager.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Core/RHI/Resource/Material.h"
#include "Core/RHI/Resource/Mesh.h"

namespace Zelo::Core::RHI {
struct MeshRendererData {
    std::shared_ptr<Mesh> mesh;
    std::shared_ptr<Material> material;
};

class MeshManager : public Singleton<MeshManager> {
public:
    // TODO(Engine): need to come back and refactor this, make it load on a separate thread.
    std::map<std::string, std::vector<MeshRendererData>> sceneMeshRendererDataCache;

    static MeshManager *getSingletonPtr();

};
}

