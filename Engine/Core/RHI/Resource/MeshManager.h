// MeshManager.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Core/RHI/Resource/MeshRendererData.h"

namespace Zelo::Core::RHI {
class MeshManager : public Singleton<MeshManager> {
public:
    static MeshManager *getSingletonPtr();

    // TODO(Engine): need to come back and refactor this, make it load on a separate thread.
    std::map<std::string, std::vector<MeshRendererData>> sceneMeshRendererDataCache;
};
}
