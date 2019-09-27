# created on 2019/9/24
# author @zoloypzuo

add_library(Main Zelo.h)

#
# link libraray
#
target_link_libraries(Main
        Common
        LuaConfig
        LuaModule
        )
link_libraries(Main)
cotire(Main)