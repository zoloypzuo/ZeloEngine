#include <sol/sol.hpp>

extern "C" {
LUALIB_API int luaopen_bit(lua_State *L);
}

void LuaBind_ImGui(sol::state &luaState) {
    luaState.require("bit", luaopen_bit);
}