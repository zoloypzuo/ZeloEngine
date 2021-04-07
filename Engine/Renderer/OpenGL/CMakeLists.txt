# created on 2021/3/29
# author @zoloypzuo
add_library(OpenGLRenderer
        GLManager.cpp
        ForwardRenderer.cpp
        Mesh.cpp
        Material.cpp
        Texture.cpp
        Asset.cpp
        MeshRenderer.cpp
        Shader.cpp
        Light.cpp
        Attenuation.cpp
        Camera.cpp
        MeshLoader.cpp
        Line.cpp
        MeshManager.cpp
        Renderer.cpp Renderer.h)

find_package(GLEW REQUIRED)
target_link_libraries(OpenGLRenderer PRIVATE GLEW::GLEW)
target_link_libraries(OpenGLRenderer PRIVATE SDL2::SDL2 SDL2::SDL2main)
