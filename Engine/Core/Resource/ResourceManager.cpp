// ResourceManager.cpp
// created on 2021/7/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ResourceManager.h"

#include <sol/sol.hpp>

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

std::filesystem::path ResourceManager::getConfigDir() {
    return m_configDir;
}

std::filesystem::path ResourceManager::getScriptDir() {
    return m_scriptDir;
}

std::filesystem::path ResourceManager::getResourceDir() {
    return m_resourceDir;
}

ResourceManager::ResourceManager(std::filesystem::path mEngineDir)
        : m_engineDir(std::move(mEngineDir)),
          m_configDir(m_engineDir / "Config"),
          m_scriptDir(m_engineDir / "Script"),
          m_resourceDir(m_engineDir / "ResourceDB") {
    auto _resourceConfigLuaPath = getResourceDir() / "resource_config.lua";
    const auto &resourceConfigPath = _resourceConfigLuaPath.string();
    sol::state luaState;
    sol::table resourceDirList = luaState.require_file(resourceConfigPath, resourceConfigPath);
    for (const auto &pair: resourceDirList) {
        std::filesystem::path resourceDir = pair.second.as<std::string>();
        auto resourceDirPath = getEngineDir() / resourceDir;
        m_resourcePathList.emplace_back(resourceDirPath);
    }
}

std::filesystem::path ResourceManager::resolvePath(const std::string &fileName) {
    // fallback search
    std::filesystem::path filePath{};

    for (const auto &resourceDir: m_resourcePathList) {
        auto resourcePath = resourceDir / fileName;
        if (std::filesystem::exists(resourcePath)) {
            filePath = resourcePath;
            break;
        };
    }

    if (filePath.empty()) {
        auto enginePath = getEngineDir() / fileName;
        ZELO_ASSERT(std::filesystem::exists(enginePath));
        filePath = enginePath;
    }

    return filePath;
}
