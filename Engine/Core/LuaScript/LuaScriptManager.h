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

private:
    void initLuaContext();

    static void luaPrint(sol::variadic_args va);

    std::shared_ptr<spdlog::logger> m_logger{};
};
}
