// Engine.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_ENGINE_H
#define ZELOENGINE_ENGINE_H

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Game.h"
#include "Core/Window/Window.h"
#include "Renderer/OpenGL/GLManager.h"
#include "Renderer/OpenGL/ForwardRenderer.h"
#include "Util/IniReader.h"
#include "Core/Plugin/Plugin.h"
#include "Core/LuaScript/LuaScriptManager.h"
#include <rttr/rttr_enable.h>

class Engine :
        public Singleton<Engine>,
        public IRuntimeModule,
        public Zelo::Core::Interface::ISerializable {
public:
    typedef std::vector<std::unique_ptr<Plugin>> PluginInstanceList;

public:
    Engine();

    explicit Engine(Game *game);

    Engine(
            Game *game,
            const std::string &engineDir,
            const std::string &configDir,
            const std::string &assetDir
    );

    ~Engine() override;

    void initialize() override;

    void finalize() override;

    void update() override;

    void start();

    const std::chrono::microseconds &getDeltaTime();

    Window *getWindow();

    INIReader *getConfig();

    std::filesystem::path getEngineDir();

    std::filesystem::path getConfigDir();

    std::filesystem::path getAssetDir();

    std::filesystem::path getScriptDir();


    /** Install a new plugin.
    @remarks
        This installs a new extension to OGRE. The plugin itself may be loaded
        from a DLL / DSO, or it might be statically linked into your own
        application. Either way, something has to call this method to get
        it registered and functioning. You should only call this method directly
        if your plugin is not in a DLL that could otherwise be loaded with
        loadPlugin, since the DLL function dllStartPlugin should call this
        method when the DLL is loaded.
    */
    void installPlugin(Plugin *plugin);

    /** Uninstall an existing plugin.
    @remarks
        This uninstalls an extension to OGRE. Plugins are automatically
        uninstalled at shutdown but this lets you remove them early.
        If the plugin was loaded from a DLL / DSO you should call unloadPlugin
        which should result in this method getting called anyway (if the DLL
        is well behaved).
    */
    void uninstallPlugin(Plugin *plugin);

    /** Gets a read-only list of the currently installed plugins. */
    const PluginInstanceList &getInstalledPlugins() const { return mPlugins; }

public:
    static Engine *getSingletonPtr();

    static Engine &getSingleton();

protected:
    std::unique_ptr<Window> m_window;
    std::unique_ptr<Game> m_game;
    std::unique_ptr<GLManager> m_glManager;
    std::unique_ptr<Renderer> m_renderer;
    std::unique_ptr<INIReader> m_config;
//    std::unique_ptr<ImGuiManager> m_imguiManager;
    std::chrono::high_resolution_clock::time_point m_time, m_lastTime;
    std::chrono::microseconds m_deltaTime{};
    std::filesystem::path m_engineDir{};
    std::filesystem::path m_configDir{};
    std::filesystem::path m_assertDir{};
    std::filesystem::path m_scriptDir{};
    bool m_fireRay{};
    std::vector<std::unique_ptr<Plugin>> mPlugins;
    bool mIsInitialised{};
    bool m_configInitialized{};

    std::unique_ptr<LuaScriptManager> m_luaScriptManager{};

protected:
    void initConfig();

    /** Initialise all loaded plugins - allows plugins to perform actions
        once the renderer is initialised.
    */
    void initialisePlugins();

    /** Shuts down all loaded plugins - allows things to be tidied up whilst
        all plugins are still loaded.
    */
    void shutdownPlugins();

RTTR_ENABLE()
};

#endif //ZELOENGINE_ENGINE_H