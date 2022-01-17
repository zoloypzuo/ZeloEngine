# created on 2021/7/26
# author @zoloypzuo
add_subdirectory(OpenGL)
add_subdirectory(D3D12)

add_library(Renderer INTERFACE)
target_link_libraries(Renderer INTERFACE OpenGLRenderer D3D12Renderer)