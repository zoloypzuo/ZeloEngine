// LuaScriptManager.cpp.cc
// created on 2021/5/5
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "LuaScriptManager.h"
#include "Engine.h"

extern "C" {
extern int luaopen_Zelo(lua_State *L);
}

template<> LuaScriptManager *Singleton<LuaScriptManager>::msSingleton = nullptr;

LuaScriptManager *LuaScriptManager::getSingletonPtr() {
    return msSingleton;
}

void LuaScriptManager::initialize() {
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
    require("Zelo", luaopen_Zelo);
    auto mainLuaPath = Engine::getSingletonPtr()->getScriptDir() / "Lua" / "main.lua";
    do_file(mainLuaPath.string());
}

void LuaScriptManager::finalize() {

}

void LuaScriptManager::update() {

}
