# created on 2021/3/28
# author @zoloypzuo

# build engine
include_directories(./)

add_subdirectory(Foundation)
add_subdirectory(Core)
add_subdirectory(Renderer)

add_library(Engine
        Engine.cpp
        )

target_include_directories(Engine PUBLIC ./Engine)
target_link_libraries(Engine PUBLIC Foundation Core Renderer)
target_link_libraries(Engine PRIVATE Optick Whereami)

set_target_properties(Engine PROPERTIES FOLDER "Main")
