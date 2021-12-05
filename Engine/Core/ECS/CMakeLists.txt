# created on 2021/7/26
# author @zoloypzuo

add_library(ECS
        Entity.cpp
        )

target_link_libraries(ECS PUBLIC LuaScript)
