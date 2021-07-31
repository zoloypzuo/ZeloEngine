// LuaScriptManager.h
// created on 2021/5/5
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"

#include <sol/sol.hpp>

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
};
}
