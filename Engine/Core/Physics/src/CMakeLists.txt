# created on 2020/2/18
# author @zoloypzuo

add_library(cyclone
        body.cpp
        collide_coarse.cpp
        collide_fine.cpp
        contacts.cpp
        core.cpp
        fgen.cpp
        joints.cpp
        particle.cpp
        pcontacts.cpp
        pfgen.cpp
        plinks.cpp
        pworld.cpp
        random.cpp
        world.cpp
        )

if (BuildCycloneDemo)
    add_subdirectory(demos)
endif ()
