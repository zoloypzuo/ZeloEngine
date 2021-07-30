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

void ResourceManager::ProvideAssetPaths(const std::string &projectAssetsPath, const std::string &engineAssetsPath) {
    PROJECT_ASSETS_PATH	= projectAssetsPath;
    ENGINE_ASSETS_PATH	= engineAssetsPath;
}
