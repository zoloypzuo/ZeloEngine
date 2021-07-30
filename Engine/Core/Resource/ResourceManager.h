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

    static void ProvideAssetPaths(const std::string &p_projectAssetsPath, const std::string &p_engineAssetsPath);

private:
    inline static std::string __PROJECT_ASSETS_PATH = "";
    inline static std::string __ENGINE_ASSETS_PATH = "";
};
}


