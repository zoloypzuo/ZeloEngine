# created on 2021/7/26
# author @zoloypzuo

add_subdirectory(Components)
add_library(ECS
        Entity.cpp
        Component/FreeMove.cpp
        Component/FreeLook.cpp

        Actor.cpp Actor.h Actor.inl
        )
target_link_libraries(ECS PRIVATE ECS_Components)