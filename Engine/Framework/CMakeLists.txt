# created on 2021/3/29
# author @zoloypzuo
file(GLOB_RECURSE FrameworkSrc Renderer/*.cpp OpenGL/*.cpp Scene/*.cpp ImGui/*.cpp)
add_library(Framework ${FrameworkSrc})
