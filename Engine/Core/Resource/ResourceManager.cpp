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

std::filesystem::path ResourceManager::getEngineDir() {
    return m_engineDir;
}

std::filesystem::path ResourceManager::getAssetDir() {
    return m_assertDir;
}

std::filesystem::path ResourceManager::getConfigDir() {
    return m_configDir;
}

std::filesystem::path ResourceManager::getScriptDir() {
    return m_scriptDir;
}