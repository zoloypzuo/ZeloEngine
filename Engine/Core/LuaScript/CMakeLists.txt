# created on 2021/7/26
# author @zoloypzuo
add_subdirectory(LuaBind)
link_libraries(LuaBind)
add_library(LuaScript LuaScriptManager.cpp LuaScriptManager.h LuaScriptManager.inl)