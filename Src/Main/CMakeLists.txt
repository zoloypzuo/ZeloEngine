# created on 2019/9/24
# author @zoloypzuo

file(GLOB SRC_LIST *.cpp *.h)

add_library(Main ${SRC_LIST})

#
# link libraray
#
target_link_libraries(Main
        Common
        LuaConfig
        LuaModule
        )
link_libraries(Main)
#cotire(Main)