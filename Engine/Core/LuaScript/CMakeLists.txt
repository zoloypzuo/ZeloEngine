# created on 2021/7/26
# author @zoloypzuo
add_library(LuaScript LuaScriptManager.cpp LuaScriptManager.h LuaScriptManager.inl)

target_link_libraries(LuaScript PUBLIC Sol2)
target_link_libraries(LuaScript PRIVATE LuaBind)
find_path(REFL_CPP_INCLUDE_DIRS "refl.hpp")
target_include_directories(LuaScript PUBLIC ${REFL_CPP_INCLUDE_DIRS})
find_package(magic_enum CONFIG REQUIRED)
target_link_libraries(LuaScript PUBLIC magic_enum::magic_enum)
target_link_libraries(LuaScript PUBLIC TupleUtils)