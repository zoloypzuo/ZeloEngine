# created on 2021/3/28
# author @zoloypzuo

# build engine
include_directories(./)

add_subdirectory(Core)

add_subdirectory(Renderer)

add_library(Engine
        Engine.cpp
        ZeloStringUtil.cpp
        )

target_include_directories(Engine PUBLIC ${CMAKE_SOURCE_DIR}/Engine)
target_link_libraries(Engine PUBLIC Core OpenGLRenderer)

set_target_properties(Engine PROPERTIES FOLDER "Main")
