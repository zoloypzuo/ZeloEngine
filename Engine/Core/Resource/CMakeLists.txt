# created on 2021/7/26
# author @zoloypzuo
add_library(Resource
        Resource.cpp
        ResourceManager.cpp
        )

target_link_libraries(Resource PRIVATE Sol2)
