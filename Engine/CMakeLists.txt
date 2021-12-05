# created on 2021/3/28
# author @zoloypzuo

# build engine
include_directories(./)

add_subdirectory(Core)
link_libraries(
        ECS
        EventSystem
        Scene
        #ImGui
        Input
        Interface
        LuaScript
        Math
        OS
        Parser
        #Physics
        Plugin
        Profiler
        Resource
        RHI
        UI
        Window
)

add_subdirectory(Renderer)
link_libraries(OpenGLRenderer)

file(GLOB CommonSrc *.cpp *.cxx *.h)
add_library(Engine ${CommonSrc})

set_target_properties(Engine PROPERTIES FOLDER "Main")
