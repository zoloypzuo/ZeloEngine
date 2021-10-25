// ResourceManager.h
// created on 2021/7/29
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"

namespace Zelo::Core::Resource {
class ResourceManager : public Singleton<ResourceManager> {
public:
    ResourceManager(std::filesystem::path mEngineDir, std::filesystem::path mConfigDir,
                    std::filesystem::path mAssertDir, std::filesystem::path mScriptDir,
                    std::filesystem::path mResourceDir
    );

    static ResourceManager *getSingletonPtr();

    static ResourceManager &getSingleton();

public:
    std::filesystem::path getEngineDir();

    std::filesystem::path getConfigDir();

    std::filesystem::path getAssetDir();

    std::filesystem::path getScriptDir();

    std::filesystem::path getResourceDir();

private:

    std::filesystem::path m_engineDir{};
    std::filesystem::path m_configDir{};
    std::filesystem::path m_assertDir{};
    std::filesystem::path m_scriptDir{};
    std::filesystem::path m_resourceDir{};
};
}

