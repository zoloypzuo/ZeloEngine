# created on 2021/3/29
# author @zoloypzuo
add_library(OpenGLRenderer
        Buffer/GLBuffer.cpp
        Buffer/GLVertexArray.cpp

        Resource/GLMesh.cpp
        Resource/Material.cpp
        Resource/MeshLoader.cpp
        Resource/MeshManager.cpp
        Resource/GLTexture.cpp
        Resource/GLSLShaderProgram.cpp

        MeshRenderer.cpp
        Light.cpp
        Attenuation.cpp
        Camera.cpp
        Line.cpp
        GLUtil.cpp
        skybox.cpp

        GLRenderSystem.cpp GLRenderSystem.h

        Renderer.h
        ForwardRenderer.cpp
        ForwardShadowRenderer.cpp
        )

# GLEW replaced by GLAD
find_package(glad CONFIG REQUIRED)
target_link_libraries(OpenGLRenderer PRIVATE glad::glad)

add_subdirectory(ingredients)
target_link_libraries(OpenGLRenderer PRIVATE ingredients)

