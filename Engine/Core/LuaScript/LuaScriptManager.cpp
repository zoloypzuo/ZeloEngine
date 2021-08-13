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

template<> LuaScriptManager *Singleton<LuaScriptManager>::msSingleton = nullptr;

LuaScriptManager *LuaScriptManager::getSingletonPtr() {
    return msSingleton;
}

LuaScriptManager &LuaScriptManager::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}

void LuaScriptManager::initialize() {
    m_logger = spdlog::default_logger()->clone("lua");

    initEvents();

    initLuaContext();

    loadLuaMain();
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
}

void LuaScriptManager::finalize() {
    doString("Finalize()");
}

void LuaScriptManager::update() {
    doString("Update()");
}

void LuaScriptManager::luaPrint(sol::variadic_args va) {
    auto &logger = LuaScriptManager::getSingletonPtr()->m_logger;
    for (auto v : va) {
        std::string value = v; // get argument out (implicit conversion)
        logger->debug(value);
    }
}

void LuaScriptManager::initEvents() {
    Behaviour::s_CreatedEvent += [this](Behaviour *behaviour) {
        behaviour->RegisterToLuaContext(*this);
    };
    Behaviour::s_CreatedEvent += [this](Behaviour *behaviour) {
        behaviour->UnregisterFromLuaContext();
    };
}

void LuaScriptManager::loadLuaMain() {
    auto mainLuaPath = ResourceManager::getSingletonPtr()->getScriptDir() / "Lua" / "main.lua";
    doFile(mainLuaPath.string());
}

void LuaScriptManager::callLuaInitializeFn() {
    // m_luaInitializeFn();
    doString("Initialize()");
}

void LuaScriptManager::doString(const std::string &luaCode) {
    sol::optional<sol::error> script_result = safe_script(luaCode);
    if (script_result.has_value()) {
        m_logger->error("failed to dostring {}\n{}", luaCode, script_result.value().what());
        throw sol::error(script_result.value().what());
    }
}

void LuaScriptManager::doFile(const std::string &luaFile) {
    sol::optional<sol::error> script_result = safe_script_file(luaFile);
    if (script_result.has_value()) {
        m_logger->error("failed to dofile {}\n{}", luaFile, script_result.value().what());
        throw sol::error(script_result.value().what());
    }
}
