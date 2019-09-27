# created on 2019/9/15
# author @zoloypzuo

file(GLOB SRC_LIST
        CppConfigClass_Generated/*.cpp CppConfigClass_Generated/*.h
        *.cpp *.h
        )

add_library(LuaConfig ${SRC_LIST})
target_link_libraries(LuaConfig LuaModule)