# created on 2019/8/26
# author @zoloypzuo

set(SRC_LIST
        D3DApp.cpp D3DApp.h
        LuaUtil.cpp LuaUtil.h
        MathHelper.h MathHelper.cpp
        GameTimer.cpp GameTimer.h
        )

# create Common lib
add_library(Common ${SRC_LIST})

# Config
target_link_libraries(Common Config)