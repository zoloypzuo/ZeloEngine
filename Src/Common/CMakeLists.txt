# created on 2019/8/26
# author @zoloypzuo

file(GLOB SRC_LIST *.cpp *.h)

# create Common lib
add_library(Common ${SRC_LIST})

# LuaConfig
target_link_libraries(Common
        LuaConfig
#        LogModule
        )
