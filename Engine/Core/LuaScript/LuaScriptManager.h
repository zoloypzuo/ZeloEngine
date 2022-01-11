// LuaScriptManager.h
// created on 2021/5/5
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Foundation/ZeloSingleton.h"

#include <refl.hpp>
#include <sol/sol.hpp> // sol::state
#include <spdlog/spdlog.h>  // logger

namespace Zelo {
class Engine;

class Plugin;

class ProjectHub;
}

namespace Zelo::Core::LuaScript {
class LuaScriptManager :
        public sol::state,
        public Singleton<LuaScriptManager>,
        public IRuntimeModule {
public:
    friend class Zelo::Engine;  // initBoot
    friend class Zelo::ProjectHub;  // initBoot

public:
    LuaScriptManager();

    static LuaScriptManager *getSingletonPtr();

    static LuaScriptManager &getSingleton();

public:
    void initialize() override;

    void finalize() override;

    void update() override;

public:
    ZELO_SCRIPT_API static void luaLogDebug(sol::variadic_args va);

    ZELO_SCRIPT_API static void luaLogError(sol::variadic_args va);

public:

    void callLuaPluginInitializeFn(Plugin *plugin);

    void callLuaPluginUpdateFn(Plugin *plugin);

    void doString(const std::string &luaCode);

    void doFile(const std::string &luaFile);

    /// fail if key does not exist
    /// \tparam T
    /// \param key
    /// \return sol::optional<T>
    template<typename T>
    decltype(auto) get_safe(const std::string &key) const;

    template<typename... Args>
    void luaCall(sol::protected_function pfr, Args &&... args);

    template<typename... Args>
    void luaCall(const std::string &functionName, Args &&... args);

    template<typename TypeToRegister>
    void registerType() noexcept;

    template<typename TypeToRegister>
    void registerEnumType() noexcept;

    template<typename T>
    T &loadConfig(const std::string &configName);

private:
    void initBoot();

    template<typename TypeToRegister, typename... Members>
    void registerTypeImpl(refl::type_list<Members...>) noexcept;

private:
    static int luaExceptionHandler(lua_State *L,
                                   sol::optional<const std::exception &> exception,
                                   sol::string_view description);

    static int luaAtPanic(lua_State *L);

    static std::string vaToString(sol::variadic_args &va);

private:
    std::shared_ptr<spdlog::logger> m_logger{};
    std::string m_bootLuaPath{};  // boot.lua
    std::string m_mainLuaPath{};  // main.lua
};

template<typename T>
T &ZELO_CONFIG(const std::string &configName);
}

#include "Core/LuaScript/LuaScriptManager.inl"