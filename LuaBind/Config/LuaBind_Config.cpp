// LuaBind_Config.cpp.cc
// created on 2021/12/11
// author @zoloypzuo
#include <sol/sol.hpp>
#include <refl.hpp>

#include "Core/LuaScript/LuaScriptManager.h"

#include "ConfigDecl.inl"

void LuaBind_Config(sol::state &luaState) {
    auto *L = static_cast<Zelo::Core::LuaScript::LuaScriptManager *>(&luaState);

#include "ConfigImpl.inl"
}