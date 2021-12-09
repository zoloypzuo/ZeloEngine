# created on 2021/7/26
# author @zoloypzuo
add_subdirectory(OpenGL)

add_library(Renderer INTERFACE)
target_link_libraries(Renderer INTERFACE GLLoader OpenGLRenderer)