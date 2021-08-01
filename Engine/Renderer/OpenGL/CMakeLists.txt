# created on 2021/3/29
# author @zoloypzuo
add_library(OpenGLRenderer
        Buffer/GLBuffer.cpp
        Buffer/GLVertexArray.cpp

        Resource/GLMesh.cpp
        Resource/GLTexture.cpp
        Resource/GLSLShaderProgram.cpp

        Drawable/skybox.cpp
        Drawable/MeshRenderer.cpp
        Drawable/Line.cpp

        Light.cpp
        Attenuation.cpp
        Camera.cpp
        GLUtil.cpp

        GLRenderSystem.cpp GLRenderSystem.h

        Pipeline/Renderer.h
        Pipeline/ForwardRenderer.cpp
        Pipeline/ForwardShadowRenderer.cpp
        )

# GLEW replaced by GLAD
find_package(glad CONFIG REQUIRED)
target_link_libraries(OpenGLRenderer PRIVATE glad::glad)

add_subdirectory(ingredients)
target_link_libraries(OpenGLRenderer PRIVATE ingredients)

