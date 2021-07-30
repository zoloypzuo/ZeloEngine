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

ResourceManager::ResourceManager(std::filesystem::path mEngineDir, std::filesystem::path mConfigDir,
                                 std::filesystem::path mAssertDir, std::filesystem::path mScriptDir)
        : m_engineDir(std::move(mEngineDir)), m_configDir(std::move(mConfigDir)),
        m_assertDir(std::move(mAssertDir)), m_scriptDir(std::move(mScriptDir)) {

}
