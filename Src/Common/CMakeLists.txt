# created on 2019/8/26
# author @zoloypzuo

add_subdirectory(LogModule)

set(SRC_LIST
        D3DApp.cpp D3DApp.h
        LuaUtil.cpp LuaUtil.h
        MathHelper.h MathHelper.cpp
        GameTimer.cpp GameTimer.h
#        LogModule/guicon.cpp LogModule/guicon.h
        )

# create Common lib
add_library(Common ${SRC_LIST})

# LuaConfig
target_link_libraries(Common
        LuaConfig
#        LogModule
        )
