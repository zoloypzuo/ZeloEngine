// ResourceManager.h
// created on 2021/7/29
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"

namespace Zelo::Core::Resource {
class ResourceManager : public Singleton<ResourceManager> {
public:
    static ResourceManager *getSingletonPtr();

    static ResourceManager &getSingleton();

    static void ProvideAssetPaths(const std::string &projectAssetsPath, const std::string &engineAssetsPath);

private:
    inline static std::string PROJECT_ASSETS_PATH;
    inline static std::string ENGINE_ASSETS_PATH;
};
}


