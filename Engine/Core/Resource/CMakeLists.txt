# created on 2021/7/26
# author @zoloypzuo
add_library(Resource
        Resource.cpp
        ResourceManager.cpp ResourceManager.h)

target_link_libraries(Resource PRIVATE LuaScript)