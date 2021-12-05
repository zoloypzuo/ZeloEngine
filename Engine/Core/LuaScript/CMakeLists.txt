# created on 2021/7/26
# author @zoloypzuo
add_library(LuaScript LuaScriptManager.cpp LuaScriptManager.h LuaScriptManager.inl)

target_link_libraries(LuaScript PUBLIC Lua PUBLIC Sol2)
target_link_libraries(LuaScript PRIVATE LuaBind)
