// LuaScriptManager.cpp
// created on 2021/5/5
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "LuaScriptManager.h"
#include "Core/Resource/ResourceManager.h"
#include "Core/ECS/Components/Behaviour.h"

using namespace Zelo::Core::Resource;
using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::ECS::Components;

void LuaBind_Main(sol::state &luaState);

extern "C" {
extern int luaopen_Zelo(lua_State *L);
}

template<> LuaScriptManager *Singleton<LuaScriptManager>::msSingleton = nullptr;

LuaScriptManager *LuaScriptManager::getSingletonPtr() {
    return msSingleton;
}

void LuaScriptManager::initialize() {
    m_logger = spdlog::default_logger()->clone("lua");

    initLuaContext();

    Behaviour::s_CreatedEvent += [this](Behaviour *behaviour) {
        behaviour->RegisterToLuaContext(*this);
    };
    Behaviour::s_CreatedEvent += [this](Behaviour *behaviour) {
        behaviour->UnregisterFromLuaContext();
    };

    auto mainLuaPath = ResourceManager::getSingletonPtr()->getScriptDir() / "Lua" / "main.lua";
    do_file(mainLuaPath.string());
}

void LuaScriptManager::initLuaContext() {
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
    require("Zelo", luaopen_Zelo);

    set("SCRIPT_DIR", ResourceManager::getSingletonPtr()->getScriptDir().string());
}

void LuaScriptManager::finalize() {

}

void LuaScriptManager::update() {

}

void LuaScriptManager::luaPrint(sol::variadic_args va) {
    auto &logger = LuaScriptManager::getSingletonPtr()->m_logger;
    for (auto v : va) {
        std::string value = v; // get argument out (implicit conversion)
        logger->debug(value);
    }
}