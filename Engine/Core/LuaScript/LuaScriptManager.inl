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
    sol::optional<sol::protected_function> pfrResult = get<sol::protected_function>(functionName);
    ZELO_ASSERT(pfrResult.has_value());
    sol::protected_function pfr = pfrResult.value();
    pfr.set_default_handler(get<sol::object>("GlobalErrorHandler"));
    luaCall(pfr, std::forward<Args>(args)...);
}
}