# created on 2021/3/28
# author @zoloypzuo
include_directories(./)
add_subdirectory(Framework)
link_libraries(Framework)
add_subdirectory(Renderer/OpenGL)
link_libraries(OpenGLRenderer)
add_library(zelo
        zelo.cpp
        Engine.cpp
        Window.cpp
        Input.cpp
        Game.cpp
        Engine.cpp
        Entity.cpp
        Component.cpp
        Transform.cpp
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
            zelo
            )
endif ()
