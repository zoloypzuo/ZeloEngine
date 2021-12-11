// LuaScriptManager.h
// created on 2021/5/5
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Foundation/ZeloSingleton.h"

#include <sol/sol.hpp> // sol::state
#include <spdlog/spdlog.h>  // logger
#include <refl.hpp>

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

    template<typename TypeToRegister>
    void registerType() noexcept;

    template<typename TypeToRegister>
    void registerEnumType() noexcept;

    template<typename T>
    T *loadConfig(const std::string &configName);

private:
    void initEvents();

    void initLuaContext();

    void loadLuaMain();

    template<typename TypeToRegister, typename... Members>
    void registerTypeImpl(refl::type_list<Members...>) noexcept;

private:
    static int luaExceptionHandler(lua_State *L,
                                   sol::optional<const std::exception &> exception,
                                   sol::string_view description);

    static int luaAtPanic(lua_State *L);

private:
    std::shared_ptr<spdlog::logger> m_logger{};
};
}

#include "Core/LuaScript/LuaScriptManager.inl"