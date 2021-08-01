# created on 2021/3/29
# author @zoloypzuo
add_library(OpenGLRenderer
        GLRenderSystem.cpp
        ForwardRenderer.cpp
        ForwardShadowRenderer.cpp
        Resource/GLMesh.cpp
        Resource/Material.cpp
        Resource/GLTexture.cpp
        MeshRenderer.cpp
        Resource/GLSLShaderProgram.cpp
        Light.cpp
        Attenuation.cpp
        Camera.cpp
        Resource/MeshLoader.cpp
        Line.cpp
        Resource/MeshManager.cpp
        Renderer.cpp Renderer.h
        GLUtil.cpp
        skybox.cpp
        DeferredRenderer.cpp
        #        ImGuiManager.cpp/
        Buffer/GLBuffer.cpp
        Buffer/GLVertexArray.cpp
        )

#target_link_libraries(OpenGLRenderer PRIVATE SDL2::SDL2 SDL2::SDL2main)

# GLEW replaced by GLAD
find_package(glad CONFIG REQUIRED)
target_link_libraries(OpenGLRenderer PRIVATE glad::glad)

add_subdirectory(ingredients)
target_link_libraries(OpenGLRenderer PRIVATE ingredients)

