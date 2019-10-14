# created on 2019/9/24
# author @zoloypzuo

file(GLOB SRC_LIST *.cpp *.h)

add_library(ZeloMain ${SRC_LIST})

target_link_libraries(ZeloMain
        Common
        ResourceManager
        LuaModule
        )
link_libraries(ZeloMain)
#cotire(Main)