# created on 2021/3/28
# author @zoloypzuo

# build engine
include_directories(./)

add_subdirectory(Core)
link_libraries(
        ECS
        #ImGui
        Input
        Interface
        Math
        #Physics
        Profiler
        Resource
        RHI
        Window
)

add_subdirectory(Renderer/OpenGL)
link_libraries(OpenGLRenderer)

file(GLOB CommonSrc *.cpp *.cxx Util/*.cpp)
add_library(Engine ${CommonSrc})
