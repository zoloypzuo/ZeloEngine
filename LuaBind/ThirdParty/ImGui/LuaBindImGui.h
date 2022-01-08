// LuaBindImGui.h
// created on 2022/1/8
// author @zoloypzuo
#pragma once

#include <imgui.h>
#include <sol/sol.hpp>

// ImVec2
inline bool sol_lua_check(sol::types<ImVec2>, lua_State *L, int index,
                          std::function<sol::check_handler_type> handler,
                          sol::stack::record &tracking) {
    // use sol's method for checking
    // specifically for a table
    return sol::stack::check<sol::lua_table>(
            L, index, handler, tracking);
}

inline ImVec2 sol_lua_get(sol::types<ImVec2>, lua_State *L, int index, sol::stack::record &tracking) {
    sol::lua_table vec4table
            = sol::stack::get<sol::lua_table>(L, index, tracking);
    float x = vec4table["x"];
    float y = vec4table["y"];
    return ImVec2{x, y};
}

inline int sol_lua_push(sol::types<ImVec2>, lua_State *L, const ImVec2 &v) {
    // create table
    sol::state_view lua(L);
    sol::table vec4table = sol::table::create_with(
            L, "x", v.x, "y", v.y);
    // use base sol method to
    // push the table
    int amount = sol::stack::push(L, vec4table);
    // return # of things pushed onto stack
    return amount;
}

// ImVec4
// NOTE ImVec4 is used as Color rgba
inline bool sol_lua_check(sol::types<ImVec4>, lua_State *L, int index,
                          std::function<sol::check_handler_type> handler,
                          sol::stack::record &tracking) {
    // use sol's method for checking
    // specifically for a table
    return sol::stack::check<sol::lua_table>(
            L, index, handler, tracking);
}

inline ImVec4 sol_lua_get(sol::types<ImVec4>, lua_State *L, int index, sol::stack::record &tracking) {
    sol::lua_table vec4table
            = sol::stack::get<sol::lua_table>(L, index, tracking);
    float x = vec4table["r"];
    float y = vec4table["g"];
    float z = vec4table["b"];
    float w = vec4table["a"];
    return ImVec4{x, y, z, w};
}

inline int sol_lua_push(sol::types<ImVec4>, lua_State *L, const ImVec4 &v) {
    // create table
    sol::state_view lua(L);
    sol::table vec4table = sol::table::create_with(
            L, "r", v.x, "g", v.y, "b", v.z, "a", v.w);
    // use base sol method to
    // push the table
    int amount = sol::stack::push(L, vec4table);
    // return # of things pushed onto stack
    return amount;
}
