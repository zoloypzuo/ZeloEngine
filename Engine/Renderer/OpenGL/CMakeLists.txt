# created on 2021/3/29
# author @zoloypzuo
add_library(GLLoader GLLoader.cpp)

target_link_libraries(GLLoader PRIVATE Window)

add_library(OpenGLRenderer
        Buffer/GLBuffer.cpp
        Buffer/GLVertexArray.cpp
        Buffer/GLFramebuffer.cpp
        Buffer/GLShadowMap.cpp
        Buffer/GLUniformBuffer.cpp
        Buffer/GLShaderStorageBuffer.cpp

        Resource/GLMesh.cpp
        Resource/GLTexture.cpp
        Resource/GLSLShaderProgram.cpp
        Resource/GLMaterial.cpp Resource/GLMaterial.h

        Drawable/skybox.cpp
        Drawable/MeshRenderer.cpp
        Drawable/Line.cpp
        Drawable/Line.cpp
        Drawable/Frustum.cpp
        Drawable/Grid.cpp

        GLUtil.cpp

        GLRenderSystem.cpp

        Pipeline/ForwardPipeline.cpp
        Pipeline/SimplePipeline.cpp Pipeline/SimplePipeline.h
        )


target_link_libraries(OpenGLRenderer PUBLIC Core)
target_link_libraries(OpenGLRenderer PRIVATE GLLoader)

target_link_libraries(OpenGLRenderer PRIVATE glad::glad)

