// LuaScriptManager.h
// created on 2021/5/5
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"

#pragma warning( push )
#pragma warning(disable: 4005)

#include <sol/sol.hpp>

#pragma warning(pop)

class LuaScriptManager : public sol::state, public Singleton<LuaScriptManager>, public IRuntimeModule {
public:
    static LuaScriptManager *getSingletonPtr();

public:
    void initialize() override;

    void finalize() override;

    void update() override;
};
