// Engine.h
// created on 2021/3/28
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Foundation/ZeloSingleton.h"
#include "Core/LogM/LogManager.h"
#include "Core/LuaScript/LuaScriptManager.h"
#include "Core/OS/Time.h"
#include "Core/OS/Window.h"
#include "Core/OS/Input.h"
#include "Core/RHI/RenderSystem.h"
#include "Core/Resource/ResourceManager.h"
#include "Core/Scene/SceneManager.h"

namespace Zelo {
class Engine :
        public Singleton<Engine>,
        public IRuntimeModule {
public:
    typedef std::vector<Plugin *> PluginInstanceList;

public:
    Engine();

    ~Engine() override;

    void initialize() override;

    void finalize() override;

    void update() override;

    /// after bootstrap, you can load resource, load config, print log
    void bootstrap();

    void start();

    void installPlugin(Plugin *plugin);

    void uninstallPlugin(Plugin *plugin);

    const PluginInstanceList &getInstalledPlugins() const { return m_plugins; }

public:
    static Engine *getSingletonPtr();

    static Engine &getSingleton();

protected:
    std::unique_ptr<Core::Log::LogManager> m_logManager{};
    std::unique_ptr<Core::OS::Time> m_timeSystem{};
    std::unique_ptr<Core::OS::Input> m_input{};
    std::unique_ptr<Core::OS::Window> m_window{};
    std::unique_ptr<Core::LuaScript::LuaScriptManager> m_luaScriptManager{};
    std::unique_ptr<Core::Resource::ResourceManager> m_resourceManager{};
    std::unique_ptr<Core::Scene::SceneManager> m_sceneManager;
    std::unique_ptr<Core::RHI::RenderSystem> m_renderSystem{};

    std::vector<Plugin *> m_plugins;

    bool m_isInitialised{};

    uint32_t m_frameCounter{};

private:
    std::filesystem::path loadBootConfig();

    void initializePlugins();

    void finalizePlugins();

    void updatePlugins();

    void renderPlugins();

    void initBootLogger() const;
};
}
