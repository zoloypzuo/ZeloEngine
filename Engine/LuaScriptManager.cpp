// LuaScriptManager.cpp.cc
// created on 2021/5/5
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "LuaScriptManager.h"

extern "C" {
extern int luaopen_Zelo(lua_State *L);
}

template<> LuaScriptManager *Singleton<LuaScriptManager>::msSingleton = nullptr;

LuaScriptManager *LuaScriptManager::getSingletonPtr() {
    return msSingleton;
}

void LuaScriptManager::initialize() {
    open_libraries(sol::lib::package, sol::lib::base);
    require("Zelo", luaopen_Zelo);
}

void LuaScriptManager::finalize() {

}

void LuaScriptManager::update() {

}
