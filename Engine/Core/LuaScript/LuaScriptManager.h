// LuaScriptManager.h
// created on 2021/5/5
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"

#include <sol/sol.hpp> // sol::state
#include <spdlog/spdlog.h>  // logger

namespace Zelo::Core::LuaScript {
class LuaScriptManager :
        public sol::state,
        public Singleton<LuaScriptManager>,
        public IRuntimeModule {
public:
    static LuaScriptManager *getSingletonPtr();

public:
    void initialize() override;

    void finalize() override;

    void update() override;

public:
    static void luaPrint(sol::variadic_args va);

private:
    void initEvents();
    void initLuaContext();

    void loadLuaMain();

    void initHookFromLua();

    std::shared_ptr<spdlog::logger> m_logger{};

    sol::function m_luaInitializeFn{};
    sol::function m_luaFinalizeFn{};
    sol::function m_luaUpdateFn{};
};
}
