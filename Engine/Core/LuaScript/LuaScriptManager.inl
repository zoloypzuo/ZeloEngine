// LuaScriptManager.inl
// created on 2021/8/16
// author @zoloypzuo
#pragma once

namespace Zelo::Core::LuaScript {
template<typename... Args>
void LuaScriptManager::luaCall(sol::protected_function pfr, Args &&... args) {
    pfr.set_default_handler(get<sol::object>("GlobalErrorHandler"));
    auto pfrResult = pfr.call(std::forward<Args>(args)...);
    if (!pfrResult.valid()) {
        sol::error err = pfrResult;
        ZELO_CORE_ERROR(err.what());
    }
}

template<typename... Args>
void LuaScriptManager::luaCall(const std::string &functionName, Args &&... args) {
    sol::optional<sol::protected_function> pfr = get<sol::protected_function>("GlobalErrorHandler");
    ZELO_ASSERT(pfr.has_value());
    luaCall(pfr, std::forward<Args>(args)...);
}
}