# created on 2021/3/29
# author @zoloypzuo
add_library(OpenGLRenderer
        GLManager.cpp
        ForwardRenderer.cpp
        ForwardShadowRenderer.cpp
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
        Renderer.cpp Renderer.h
        GLUtil.cpp
        skybox.cpp
        DeferredRenderer.cpp
        )

# GLEW replaced by GLAD
find_package(glad CONFIG REQUIRED)
target_link_libraries(OpenGLRenderer PRIVATE glad::glad)
target_link_libraries(OpenGLRenderer PRIVATE SDL2::SDL2 SDL2::SDL2main)
