// ResourceManager.h
// created on 2021/7/29
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Foundation/ZeloSingleton.h"

namespace Zelo::Core::Resource {
class ResourceManager : public Singleton<ResourceManager> {
public:
    ResourceManager(std::filesystem::path mEngineDir, std::filesystem::path mConfigDir,
                    std::filesystem::path mScriptDir, std::filesystem::path mResourceDir);

    static ResourceManager *getSingletonPtr();

    static ResourceManager &getSingleton();

public:
    std::filesystem::path getEngineDir();

    std::filesystem::path getConfigDir();

    std::filesystem::path getScriptDir();

    std::filesystem::path getResourceDir();

    std::filesystem::path resolvePath(const std::string &fileName);

private:
    std::filesystem::path m_engineDir{};
    std::filesystem::path m_configDir{};
    std::filesystem::path m_scriptDir{};
    std::filesystem::path m_resourceDir{};

    std::vector<std::filesystem::path> m_resourcePathList{};
};
}

