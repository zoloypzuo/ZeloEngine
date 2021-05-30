# created on 2021/3/28
# author @zoloypzuo
include_directories(./)
#add_subdirectory(Framework)
#link_libraries(Framework)
if (0)
    #if (WIN32) TODO use cotire and pch
    add_subdirectory(Platform/Windows)
    link_libraries(Windows)
endif ()

add_subdirectory(ImGui) # use my own ImGui implementation
link_libraries(ImGui)

add_subdirectory(Renderer/OpenGL)

link_libraries(OpenGLRenderer)
#add_subdirectory(Component)
#link_directories(Component)
file(GLOB CommonSrc *.cpp Component/*.cpp Util/*.c Util/*.cpp)
add_library(Common ${CommonSrc})


add_subdirectory(InGameEditor)

option(BuildSwig "BuildSwig" OFF)
message(STATUS BuildSwig=${BuildSwig})

if (BuildSwig)  # build swig in win32 release
    add_library(zelo_py SHARED
            zelo_wrapper.cxx
            )
    set_target_properties(
            zelo_py
            PROPERTIES
                OUTPUT_NAME "_zelo"
                SUFFIX ".pyd"
    )
    target_include_directories(zelo_py PRIVATE $ENV{PYTHON_INCLUDE})
    target_link_libraries(zelo_py
            $ENV{PYTHON_LIB}
            Common
            )
endif ()

option(BuildSwigLua "BuildSwigLua" OFF)
message(STATUS BuildSwigLua=${BuildSwigLua})

if (BuildSwigLua)  # build swig in win32 release
    add_library(ZeloWrapperLua SHARED
            ZeloWrapperLua.cxx
            )
    set_target_properties(
            ZeloWrapperLua
            PROPERTIES
            OUTPUT_NAME "Zelo"
            SUFFIX ".dll"
    )

    message(STATUS ${LUA_LIBRARIES})
    message(STATUS ${LUA_INCLUDE_DIR})
    target_link_libraries(ZeloWrapperLua PRIVATE ${LUA_LIBRARIES} Common)
    target_include_directories(ZeloWrapperLua PRIVATE ${LUA_INCLUDE_DIR})
endif ()

if (0)
    add_subdirectory(Physics)
endif ()
