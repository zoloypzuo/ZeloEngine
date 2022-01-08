#pragma once

#include <glm/glm.hpp>
#include <sol/sol.hpp>

// glm::vec3
inline bool sol_lua_check(sol::types<glm::vec3>, lua_State *L, int index,
                          std::function<sol::check_handler_type> handler,
                          sol::stack::record &tracking) {
    // use sol's method for checking
    // specifically for a table
    return sol::stack::check<sol::lua_table>(
            L, index, handler, tracking);
}

inline glm::vec3 sol_lua_get(sol::types<glm::vec3>, lua_State *L, int index, sol::stack::record &tracking) {
    sol::lua_table vec3table
            = sol::stack::get<sol::lua_table>(L, index, tracking);
    float x = vec3table["x"];
    float y = vec3table["y"];
    float z = vec3table["z"];
    return glm::vec3{x, y, z};
}

inline int sol_lua_push(sol::types<glm::vec3>, lua_State *L, const glm::vec3 &v) {
    // create table
    sol::state_view lua(L);
    sol::table vec3table = sol::table::create_with(
            L, "x", v.x, "y", v.y, "z", v.z);
    // use base sol method to
    // push the table
    int amount = sol::stack::push(L, vec3table);
    // return # of things pushed onto stack
    return amount;
}

// glm::vec2
inline bool sol_lua_check(sol::types<glm::vec2>, lua_State *L, int index,
                          std::function<sol::check_handler_type> handler,
                          sol::stack::record &tracking) {
    // use sol's method for checking
    // specifically for a table
    return sol::stack::check<sol::lua_table>(
            L, index, handler, tracking);
}

inline glm::vec2 sol_lua_get(sol::types<glm::vec2>, lua_State *L, int index, sol::stack::record &tracking) {
    sol::lua_table vec2table
            = sol::stack::get<sol::lua_table>(L, index, tracking);
    float x = vec2table["x"];
    float y = vec2table["y"];
    return glm::vec2{x, y};
}

inline int sol_lua_push(sol::types<glm::vec2>, lua_State *L, const glm::vec2 &v) {
    // create table
    sol::state_view lua(L);
    sol::table vec2table = sol::table::create_with(
            L, "x", v.x, "y", v.y);
    // use base sol method to
    // push the table
    int amount = sol::stack::push(L, vec2table);
    // return # of things pushed onto stack
    return amount;
}

// glm::vec4
inline bool sol_lua_check(sol::types<glm::vec4>, lua_State *L, int index,
                          std::function<sol::check_handler_type> handler,
                          sol::stack::record &tracking) {
    // use sol's method for checking
    // specifically for a table
    return sol::stack::check<sol::lua_table>(
            L, index, handler, tracking);
}

inline glm::vec4 sol_lua_get(sol::types<glm::vec4>, lua_State *L, int index, sol::stack::record &tracking) {
    sol::lua_table vec4table
            = sol::stack::get<sol::lua_table>(L, index, tracking);
    float x = vec4table["x"];
    float y = vec4table["y"];
    float z = vec4table["z"];
    float w = vec4table["w"];
    return glm::vec4{x, y, z, w};
}

inline int sol_lua_push(sol::types<glm::vec4>, lua_State *L, const glm::vec4 &v) {
    // create table
    sol::state_view lua(L);
    sol::table vec4table = sol::table::create_with(
            L, "x", v.x, "y", v.y, "z", v.z, "w", v.w);
    // use base sol method to
    // push the table
    int amount = sol::stack::push(L, vec4table);
    // return # of things pushed onto stack
    return amount;
}
