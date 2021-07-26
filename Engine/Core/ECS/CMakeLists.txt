# created on 2021/7/26
# author @zoloypzuo
add_library(ECS
        Component.cpp
        Entity.cpp
        Component/FreeMove.cpp
        Component/FreeLook.cpp
        Component/Behaviour.cpp Component/Behaviour.h Component/Behaviour.inl Component/AComponent.cpp Component/AComponent.h Actor.cpp Actor.h)