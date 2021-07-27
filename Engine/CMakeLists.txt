# created on 2021/3/28
# author @zoloypzuo

# build engine
include_directories(./)

add_subdirectory(Core)
link_libraries(
        ECS
        EventSystem
        Game
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
        Window
)

add_subdirectory(Renderer)
link_libraries(OpenGLRenderer)

file(GLOB CommonSrc *.cpp *.cxx)
add_library(Engine ${CommonSrc})
