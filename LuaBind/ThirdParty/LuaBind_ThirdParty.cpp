#include <sol/sol.hpp>

void LuaBind_ImGui(sol::state &luaState);

void LuaBind_LuaBitOp(sol::state &luaState);

void LuaBind_ThirdParty(sol::state &luaState) {
    LuaBind_ImGui(luaState);
    LuaBind_LuaBitOp(luaState);
}