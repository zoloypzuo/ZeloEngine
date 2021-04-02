# created on 2021/3/28
# author @zoloypzuo
include_directories(./)
add_subdirectory(Framework)
link_libraries(Framework)
if (0)
#if (WIN32) TODO use cotire and pch
    add_subdirectory(Platform/Windows)
    link_libraries(Windows)
endif ()
add_subdirectory(Renderer/OpenGL)
link_libraries(OpenGLRenderer)
#add_subdirectory(Component)
#link_directories(Component)
add_library(Common
        Engine.cpp
        Window.cpp
        Input.cpp
        Game.cpp
        Engine.cpp
        Entity.cpp
        Component.cpp
        Transform.cpp
        Util/whereami.c
        GuiManager.cpp
        Component/FreeLook.cpp
        Component/FreeMove.cpp
        Mathf.cpp
        )

option(BuildSwig "BuildSwig" OFF)
message(STATUS BuildSwig=${BuildSwig})

if (BuildSwig)  # build swig in win32 release
    add_library(zelo_py SHARED
            zelo_wrapper.cxx
            )

    target_include_directories(zelo_py PRIVATE $ENV{PYTHON_INCLUDE})
    target_link_libraries(zelo_py
            $ENV{PYTHON_LIB}
            Common
            )
endif ()
if (0)
    add_subdirectory(cyclone-physics)
endif ()