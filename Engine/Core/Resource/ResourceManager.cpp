// ResourceManager.cpp
// created on 2021/7/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ResourceManager.h"

using namespace Zelo::Core::Resource;

template<> ResourceManager *Singleton<ResourceManager>::msSingleton = nullptr;

ResourceManager *ResourceManager::getSingletonPtr() {
    return msSingleton;
}

ResourceManager &ResourceManager::getSingleton() {
    ZELO_ASSERT(msSingleton);
    return *msSingleton;
}

void ResourceManager::ProvideAssetPaths(const std::string &p_projectAssetsPath, const std::string &p_engineAssetsPath) {
    __PROJECT_ASSETS_PATH	= p_projectAssetsPath;
    __ENGINE_ASSETS_PATH	= p_engineAssetsPath;
}
