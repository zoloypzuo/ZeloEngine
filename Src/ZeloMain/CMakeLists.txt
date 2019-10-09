# created on 2019/9/24
# author @zoloypzuo

file(GLOB SRC_LIST *.cpp *.h)

add_library(ZeloMain ${SRC_LIST})

#
# link libraray
#
target_link_libraries(ZeloMain
        Common
        LuaConfig
        LuaModule
        )
link_libraries(ZeloMain)
#cotire(Main)