// LuaScriptManager.cpp
// created on 2021/5/5
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "LuaScriptManager.h"
#include "Core/Resource/ResourceManager.h"
#include "Foundation/ZeloPlugin.h"

using namespace Zelo::Core::Resource;
using namespace Zelo::Core::LuaScript;

void LuaBind_Main(sol::state &luaState);

template<> LuaScriptManager *Singleton<LuaScriptManager>::msSingleton = nullptr;

LuaScriptManager *LuaScriptManager::getSingletonPtr() {
    return msSingleton;
}

LuaScriptManager &LuaScriptManager::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}

void LuaScriptManager::initialize() {
    m_logger = spdlog::default_logger()->clone("lua");

    initEvents();

    initLuaContext();

    loadLuaMain();
}

struct WindowSettings {
    static const int32_t DontCare = -1;
    std::string title;
    uint16_t width{};
    uint16_t height{};
    int16_t minimumWidth = DontCare;
    int16_t minimumHeight = DontCare;
    int16_t maximumWidth = DontCare;
    int16_t maximumHeight = DontCare;
    bool fullscreen = false;
    bool decorated = true;
    bool resizable = true;
    bool focused = true;
    bool maximized = false;
    bool floating = false;
    bool visible = true;
    bool autoIconify = true;
    int32_t refreshRate = WindowSettings::DontCare;
    uint32_t samples = 4;
};

REFL_AUTO(
        type(WindowSettings),
        field(DontCare),
        field(title),
        field(width),
        field(height),
        field(minimumWidth),
        field(minimumHeight),
        field(maximumWidth),
        field(maximumHeight),
        field(fullscreen),
        field(decorated),
        field(resizable),
        field(focused),
        field(maximized),
        field(floating),
        field(visible),
        field(autoIconify),
        field(refreshRate),
        field(samples)
)

void LuaScriptManager::initLuaContext() {
    set_exception_handler(luaExceptionHandler);
    set_panic(luaAtPanic);

    open_libraries(
            // print, assert, and other base functions
            sol::lib::base,
            // require and other package functions
            sol::lib::package,
            // coroutine functions and utilities
            sol::lib::coroutine,
            // string library
            sol::lib::string,
            // functionality from the OS
            sol::lib::os,
            // all things math
            sol::lib::math,
            // the table manipulator and observer functions
            sol::lib::table,
            // the debug library
            sol::lib::debug,
            // the bit library: different based on which you're using
            sol::lib::bit32,
            // input/output library
            sol::lib::io,
            // library for handling utf8: new to Lua
            sol::lib::utf8
    );

    LuaBind_Main(*this);

    registerType<WindowSettings>();
}

void LuaScriptManager::finalize() {
    luaCall("Finalize");
}

void LuaScriptManager::update() {
    luaCall("Update");
}

void LuaScriptManager::luaPrint(sol::variadic_args va) {
    auto &logger = LuaScriptManager::getSingleton().m_logger;

    // " ".join(va)
    std::vector<std::string> va_string;
    for (auto v: va) {
        va_string.push_back(v.as<std::string>());
    }

    std::ostringstream oss;
    std::copy(va_string.begin(), va_string.end(), std::ostream_iterator<std::string>(oss, " "));

    logger->debug(oss.str());
}

void LuaScriptManager::initEvents() {

}

void LuaScriptManager::loadLuaMain() {
    auto mainLuaPath = ResourceManager::getSingletonPtr()->getScriptDir() / "Lua" / "main.lua";
    doFile(mainLuaPath.string());
}

void LuaScriptManager::callLuaInitializeFn() {
    luaCall("Initialize");
}

void LuaScriptManager::callLuaPluginInitializeFn(Plugin *plugin) {
    auto klass = this->get<sol::table>(plugin->getName());
    auto init = klass.get<sol::optional<sol::protected_function>>("Initialize");
    if (init.has_value()) {
        luaCall(init.value());
    }
}

void LuaScriptManager::callLuaPluginUpdateFn(Plugin *plugin) {
    auto klass = this->get<sol::table>(plugin->getName());
    auto init = klass.get<sol::optional<sol::protected_function>>("Update");
    if (init.has_value()) {
        luaCall(init.value());
    }
}

void LuaScriptManager::doString(const std::string &luaCode) {
    sol::optional<sol::error> script_result = safe_script(luaCode);
    if (script_result.has_value()) {
        m_logger->error("failed to dostring {}\n{}", luaCode, script_result.value().what());
        throw sol::error(script_result.value().what());
    }
}

void LuaScriptManager::doFile(const std::string &luaFile) {
    sol::optional<sol::error> script_result = safe_script_file(luaFile);
    if (script_result.has_value()) {
        m_logger->error("failed to dofile {}\n{}", luaFile, script_result.value().what());
        throw sol::error(script_result.value().what());
    }
}

int LuaScriptManager::luaExceptionHandler(lua_State *L,
                                          sol::optional<const std::exception &> exception,
                                          sol::string_view description) {
    auto &logger = LuaScriptManager::getSingletonPtr()->m_logger;
    if (exception.has_value()) {
        logger->error("[sol3] An exception occurred (from exception): {}", exception->what());
    } else {
        const auto &what = std::string(description.data(), description.size());
        logger->error("[sol3] An exception occurred (from description): {}", what);
    }
    return sol::stack::push(L, description);
}

int LuaScriptManager::luaAtPanic(lua_State *L) {
    size_t message_size{};
    const char *message = lua_tolstring(L, -1, &message_size);
    if (message) {
        std::string err(message, message_size);
        lua_settop(L, 0);
        auto &logger = LuaScriptManager::getSingletonPtr()->m_logger;
        logger->error("[sol3] An error occurred and panic has been invoked: {}", err);
        throw sol::error(err);
    }
    lua_settop(L, 0);
    throw sol::error(std::string("An unexpected error occurred and panic has been invoked"));
}
