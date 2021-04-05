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

if (BuildSwig)  # build swig in win32 release
    add_library(cyclone_py SHARED
            cyclone_wrapper.cxx
            )

    target_include_directories(cyclone_py PRIVATE $ENV{PYTHON_INCLUDE})
    target_link_libraries(cyclone_py
            $ENV{PYTHON_LIB}
            cyclone
            )
endif ()

option(BuildDemo "BuildDemo" OFF)
message(STATUS BuildDemo=${BuildDemo})
if (BuildDemo)
    add_subdirectory(demos)
endif ()
