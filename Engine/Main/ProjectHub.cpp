// ProjectHub.cpp.cc
// created on 2022/1/9
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ProjectHub.h"
#include "Foundation/ZeloPlugin.h"
#include "Foundation/ZeloProfiler.h"
#include "Renderer/OpenGL/GLRenderSystem.h"

#include <optick.h>
#include <whereami.h>

using namespace Zelo;
using namespace Zelo::Core::Log;
using namespace Zelo::Core::OS;
using namespace Zelo::Core::Resource;
using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;
using namespace Zelo::Core::UI;
using namespace Zelo::Core::Scene;

void ProjectHub::initialize() {
    bootstrap();

    m_logManager = std::make_unique<LogManager>();
    m_luaScriptManager->initialize();
    m_window = std::make_unique<Window>();
    m_input = std::make_unique<Input>();
    m_window->initialize();
    m_renderSystem = std::make_unique<GLRenderSystem>();
    m_renderSystem->initialize();
    m_sceneManager = std::make_unique<SceneManager>();
    m_sceneManager->initialize();
    m_luaScriptManager->callLuaInitializeFn();

    m_window->makeCurrentContext();

    m_timeSystem = std::make_unique<Time>();
    m_timeSystem->initialize();

    initializePlugins();

    m_isInitialised = true;
}

void ProjectHub::bootstrap() {
    // init config and logger first
    initBootLogger();
    auto engineDir = loadBootConfig();

    m_resourceManager = std::make_unique<ResourceManager>(engineDir);
    m_luaScriptManager = std::make_unique<LuaScriptManager>();
    m_luaScriptManager->initBoot();
}

void ProjectHub::initBootLogger() const {
    auto logger = spdlog::default_logger()->clone("boot");
    logger->set_level(spdlog::level::debug);  // show all log
    logger->set_pattern("[%T.%e] [%n] [%^%l%$] %v");  // remove datetime in ts
    spdlog::set_default_logger(logger);
}

void ProjectHub::finalize() {
    finalizePlugins();

    m_timeSystem->finalize();
    m_sceneManager->finalize();
    m_renderSystem->finalize();
    m_window->finalize();
    m_luaScriptManager->finalize();
}

void ProjectHub::update() {
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

void ProjectHub::start() {
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

ProjectHub::ProjectHub() = default;

ProjectHub::~ProjectHub() = default;

template<> ProjectHub *Zelo::Singleton<ProjectHub>::msSingleton = nullptr;

ProjectHub *ProjectHub::getSingletonPtr() {
    return msSingleton;
}

ProjectHub &ProjectHub::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}

std::filesystem::path ProjectHub::loadBootConfig() {
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
        return "";
    }
    return bootConfig->GetString("boot", "engineDir", "");
}

void ProjectHub::initializePlugins() {
    for (auto &plugin: m_plugins) {
        plugin->initialize();
    }
    for (auto &plugin: m_plugins) {
        m_luaScriptManager->callLuaPluginInitializeFn(plugin);
    }
}

void ProjectHub::finalizePlugins() {
    for (auto &plugin: m_plugins) {
        plugin->finalize();
    }
}

void ProjectHub::updatePlugins() {
    for (auto &plugin: m_plugins) {
        plugin->update();
    }
    for (auto &plugin: m_plugins) {
        m_luaScriptManager->callLuaPluginUpdateFn(plugin);
    }
}

void ProjectHub::renderPlugins() {
    for (auto &plugin: m_plugins) {
        plugin->render();
    }
}

void ProjectHub::installPlugin(Plugin *plugin) {
    spdlog::debug("installing plugin: {}", plugin->getName());

    m_plugins.push_back(plugin);
    plugin->install();

    // if rendersystem is already initialised, call rendersystem init too
    if (m_isInitialised) {
        plugin->initialize();
    }

    spdlog::debug("plugin installed successfully: {}", plugin->getName());
}

void ProjectHub::uninstallPlugin(Plugin *plugin) {
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

void ProjectHub::install(Plugin *plugin) {
    ProjectHub::getSingleton().installPlugin(plugin);
}
