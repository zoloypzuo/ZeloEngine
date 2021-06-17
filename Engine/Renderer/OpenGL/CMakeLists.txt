# created on 2021/3/29
# author @zoloypzuo
add_library(OpenGLRenderer
        GLManager.cpp
        ForwardRenderer.cpp
        ForwardShadowRenderer.cpp
        GLMesh.cpp
        Material.cpp
        GLTexture.cpp
        MeshRenderer.cpp
        GLSLShaderProgram.cpp
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
        ImGuiManager.cpp
        GLBuffer.cpp
        GLVertexArray.cpp
        )

#target_link_libraries(OpenGLRenderer PRIVATE SDL2::SDL2 SDL2::SDL2main)

# GLEW replaced by GLAD
find_package(glad CONFIG REQUIRED)
target_link_libraries(OpenGLRenderer PRIVATE glad::glad)

add_subdirectory(ingredients)
target_link_libraries(OpenGLRenderer PRIVATE ingredients)

