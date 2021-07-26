# created on 2021/3/28
# author @zoloypzuo

# build engine
include_directories(./)

add_subdirectory(Core)
link_libraries(Core)

if (PlayImGui)
    add_subdirectory(Core/ImGui) # use my own ImGui implementation
    link_libraries(ImGui)
else ()
    find_package(imgui CONFIG REQUIRED)
    link_libraries(imgui::imgui)
endif ()

add_subdirectory(Renderer/OpenGL)
link_libraries(OpenGLRenderer)

file(GLOB CommonSrc *.cpp *.cxx Component/*.cpp Util/*.cpp)
add_library(Engine ${CommonSrc})

if (BuildCyclone)  # not used for now
    add_subdirectory(Core/Physics)
endif ()
