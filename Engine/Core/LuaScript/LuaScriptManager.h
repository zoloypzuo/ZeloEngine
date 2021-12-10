// LuaScriptManager.h
// created on 2021/5/5
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Foundation/ZeloSingleton.h"

#include <sol/sol.hpp> // sol::state
#include <spdlog/spdlog.h>  // logger

namespace Zelo {
class Plugin;
}

namespace Zelo::Core::LuaScript {
class LuaScriptManager :
        public sol::state,
        public Singleton<LuaScriptManager>,
        public IRuntimeModule {
public:
    static LuaScriptManager *getSingletonPtr();

    static LuaScriptManager &getSingleton();

public:
    void initialize() override;

    void finalize() override;

    void update() override;

public:
    static void luaPrint(sol::variadic_args va);

public:
    void callLuaInitializeFn();

    void callLuaPluginInitializeFn(Plugin *plugin);

    void callLuaPluginUpdateFn(Plugin *plugin);

    void doString(const std::string &luaCode);

    void doFile(const std::string &luaFile);

    template<typename... Args>
    void luaCall(sol::protected_function pfr, Args &&... args);

    template<typename... Args>
    void luaCall(const std::string &functionName, Args &&... args);

private:
    void initEvents();

    void initLuaContext();

    void loadLuaMain();

private:
    static int luaExceptionHandler(lua_State *L, sol::optional<const std::exception &>, sol::string_view what);

    static int luaAtPanic(lua_State *L);

private:
    std::shared_ptr<spdlog::logger> m_logger{};
};
}

#include "Core/LuaScript/LuaScriptManager.inl"