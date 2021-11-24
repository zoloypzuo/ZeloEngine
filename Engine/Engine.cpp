// Engine.cpp
// created on 2021/3/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Engine.h"
#include "Core/OS/whereami.h"
#include "Core/Profiler/Profiler.h"
#include "Renderer/OpenGL/GLRenderSystem.h"
#include "Core/Plugin/Plugin.h"

// enable vld
#ifdef DETECT_MEMORY_LEAK

#include <vld.h>

#endif

#include "optick.h"

using namespace Zelo;
using namespace Zelo::Core::OS;
using namespace Zelo::Core::Resource;
using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;
using namespace Zelo::Core::UI;
using namespace Zelo::Core::Scene;

void Engine::initialize() {
    // init config and logger first
    spdlog::set_level(spdlog::level::debug);  // show all log
    spdlog::set_pattern("[%T.%e] [%n] [%^%l%$] %v");  // remove datetime in ts

    // set logger name
    auto logger = spdlog::default_logger()->clone("root");
    spdlog::set_default_logger(logger);

    if (!m_configInitialized) {
        initConfig();
    }
    m_configInitialized = true;

    m_resourceManager = std::make_unique<ResourceManager>(
            m_engineDir, m_configDir, m_scriptDir, m_resourceDir
    );
    m_luaScriptManager = std::make_unique<LuaScriptManager>();
    m_luaScriptManager->initialize();
    m_window = std::make_unique<Window>(m_config->GetSection("Window"));
    m_window->initialize();
    m_renderSystem = std::make_unique<GLRenderSystem>(m_config->GetSection("RenderSystem"));
    m_renderSystem->initialize();
    m_sceneManager = std::make_unique<SceneManager>();
    m_sceneManager->initialize();
    m_luaScriptManager->callLuaInitializeFn();

    m_window->makeCurrentContext();

    initializePlugins();

    m_timeSystem = std::make_unique<Time>();
    m_timeSystem->initialize();

    m_isInitialised = true;
}

void Engine::finalize() {
    m_timeSystem->finalize();
    finalizePlugins();
    m_sceneManager->finalize();
    m_renderSystem->finalize();
    m_window->finalize();
    m_luaScriptManager->finalize();
}

void Engine::update() {
    OPTICK_EVENT();
    {
        m_timeSystem->update();
    }
    {
        OPTICK_CATEGORY("UpdateInput", Optick::Category::Input);
        m_window->update();  // input poll events
    }
    {
        OPTICK_CATEGORY("UpdateLogic", Optick::Category::GameLogic);
        m_sceneManager->update();
        m_luaScriptManager->update();
        updatePlugins();
    }
    {
        OPTICK_CATEGORY("Draw", Optick::Category::Rendering);
        m_renderSystem->update();
    }
    {
        OPTICK_CATEGORY("DrawPlugins", Optick::Category::Rendering);
        renderPlugins();
    }
    {
        OPTICK_CATEGORY("SwapBuffer", Optick::Category::Rendering);
        m_window->swapBuffer();  // swap buffer
    }
}

void Engine::start() {
    // Setting memory allocators
    OPTICK_SET_MEMORY_ALLOCATOR(
            [](size_t size) -> void * { return operator new(size); },
            [](void *p) { operator delete(p); },
            []() { /* Do some TLS initialization here if needed */ }
    );

    ZELO_PROFILE_BEGIN_SESSION("Startup", "ZeloProfile-Startup.json");
    initialize();
    ZELO_PROFILE_END_SESSION();

    ZELO_PROFILE_BEGIN_SESSION("Runtime", "ZeloProfile-Runtime.json");
    while (!m_window->shouldQuit()) {
        OPTICK_FRAME("MainThread");
        update();
    }
    ZELO_PROFILE_END_SESSION();

    ZELO_PROFILE_BEGIN_SESSION("Shutdown", "ZeloProfile-Shutdown.json");
    finalize();
    ZELO_PROFILE_END_SESSION();
    OPTICK_SHUTDOWN();
}

Engine::Engine() = default;

Engine::~Engine() = default;

template<> Engine *Singleton<Engine>::msSingleton = nullptr;

Engine *Engine::getSingletonPtr() {
    return msSingleton;
}

Engine &Engine::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}

void Engine::initConfig() {
    char exePathRaw[256];
    auto length = 256;
    wai_getExecutablePath(exePathRaw, length, &length);
    exePathRaw[length] = '\0';

    std::filesystem::path exePath(exePathRaw);
    auto bootIniPath = exePath / "boot.ini";
    auto bootConfig = std::make_unique<INIReader>(bootIniPath.string());
    if (bootConfig->ParseError()) {
        spdlog::error("boot.ini not found, path={}", bootIniPath.string());
        ZELO_CORE_ASSERT(false, "boot.ini not found");
        return;
    }
    m_engineDir = bootConfig->GetString("boot", "engineDir", "").c_str();
    m_configDir = m_engineDir / "Config";
    m_scriptDir = m_engineDir / "Script";
    m_resourceDir = m_engineDir / "ResourceDB";

    auto engineIniPath = m_configDir / "engine_boot.ini";
    m_config = std::make_unique<INIReader>(engineIniPath.string());
    if (m_config->ParseError()) {
        spdlog::error("engine_boot.ini not found, path={}", engineIniPath.string());
        ZELO_CORE_ASSERT(false, "engine_boot.ini not found");
        return;
    }
}

void Engine::initializePlugins() {
    for (auto &plugin: m_plugins) {
        plugin->initialize();
    }
    for (auto &plugin: m_plugins) {
        m_luaScriptManager->callLuaPluginInitializeFn(plugin);
    }
}

void Engine::finalizePlugins() {
    for (auto &plugin: m_plugins) {
        plugin->finalize();
    }
}

void Engine::updatePlugins() {
    for (auto &plugin: m_plugins) {
        plugin->update();
    }
    for (auto &plugin: m_plugins) {
        m_luaScriptManager->callLuaPluginUpdateFn(plugin);
    }
}

void Engine::renderPlugins() {
    for (auto &plugin: m_plugins) {
        plugin->render();
    }
}

void Engine::installPlugin(Plugin *plugin) {
    spdlog::debug("installing plugin: {}", plugin->getName());

    m_plugins.push_back(plugin);
    plugin->install();

    // if rendersystem is already initialised, call rendersystem init too
    if (m_isInitialised) {
        plugin->initialize();
    }

    spdlog::debug("plugin installed successfully: {}", plugin->getName());
}

void Engine::uninstallPlugin(Plugin *plugin) {
    spdlog::debug("uninstalling plugin: {}", plugin->getName());

    auto i = std::find_if(
            m_plugins.begin(), m_plugins.end(),
            [&](auto &item) { return item->getName() == plugin->getName(); });
    if (i != m_plugins.end()) {
        if (m_isInitialised) {
            plugin->finalize();
        }
        plugin->uninstall();
    }

    spdlog::debug("plugin uninstalled successfully: {}", plugin->getName());
}

//#include <rttr/registration>

//RTTR_REGISTRATION {
//    rttr::registration::class_<Engine>("Zelo::Engine")
//            .constructor<>()
//            .property_readonly("engine_dir", &Engine::getEngineDir)
//            .method("start", &Engine::start);
//
//}

//void test_rttr() {
//    // get type
//    auto t = rttr::type::get<Engine>();
//    auto t1 = rttr::type::get_by_name("Zelo::Engine");
//    auto e0 = Engine();
//    auto t2 = rttr::type::get(e0);
//
//    // ctor
//    auto e = t.create();
//    auto name = e.get_type().get_name();
//
//    auto ctor = t.get_constructor();
//    auto e2 = ctor.invoke();
//
//    // call method
//    auto m = t.get_method("start");
//    m.invoke(e);
//
//    // iterate member
//    for (const auto &prop:t.get_properties()) {
//        spdlog::error("name: {}", prop.get_name().to_string());
//    }
//
//    for (const auto &meth:t.get_methods()) {
//        spdlog::error("name: {}", meth.get_name().to_string());
//    }
//}