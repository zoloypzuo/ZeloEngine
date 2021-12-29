// ResourceManager.cpp
// created on 2021/7/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ResourceManager.h"

#include <sol/sol.hpp>

using namespace Zelo::Core::Resource;

template<> ResourceManager *Zelo::Singleton<ResourceManager>::msSingleton = nullptr;

namespace Zelo::Core::Resource {
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

ResourceManager::ResourceManager(std::filesystem::path &engineDir)
        : m_engineDir(std::move(engineDir)),
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
        m_resourceLocations.emplace_back(resourceDirPath);
    }
}

std::filesystem::path ResourceManager::resolvePath(const std::string &fileName) {
    // fallback search
    std::filesystem::path filePath{};

    for (const auto &resourceDir: m_resourceLocations) {
        auto resourcePath = resourceDir / fileName;
        if (std::filesystem::exists(resourcePath)) {
            filePath = resourcePath;
            break;
        };
    }

    if (filePath.empty()) {
        auto enginePath = getEngineDir() / fileName;
        ZELO_ASSERT(std::filesystem::exists(enginePath), fileName);
        filePath = enginePath;
    }

    return filePath;
}

std::filesystem::path ResourceManager::resolvePath(const std::string &fileName, const std::string &defaultPath) {
    // fallback search
    std::filesystem::path filePath{};

    for (const auto &resourceDir: m_resourceLocations) {
        auto resourcePath = resourceDir / fileName;
        if (std::filesystem::exists(resourcePath)) {
            filePath = resourcePath;
            break;
        };
    }

    if (filePath.empty()) {
        auto enginePath = getEngineDir() / fileName;
        if (std::filesystem::exists(enginePath)) {
            filePath = enginePath;
        }
    }

    if (filePath.empty()) {
        filePath = defaultPath;
    }

    return filePath;
}

void ResourceManager::addResourceLocation(const std::string &resourceLocation) {
    m_resourceLocations.emplace_back(resourceLocation);
}

std::string ZELO_PATH(const std::string &fileName) {
    return ResourceManager::getSingletonPtr()->resolvePath(fileName).string();
}

std::string ZELO_PATH(const std::string &fileName, const std::string &defaultPath) {
    return ResourceManager::getSingletonPtr()->resolvePath(fileName, defaultPath).string();
}
}