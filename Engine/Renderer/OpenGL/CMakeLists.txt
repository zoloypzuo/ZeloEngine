# created on 2021/3/29
# author @zoloypzuo
add_library(OpenGLRenderer
        Buffer/GLBuffer.cpp
        Buffer/GLVertexArray.cpp
        Buffer/GLFramebuffer.cpp
        Buffer/GLShadowMap.cpp

        Resource/GLMesh.cpp
        Resource/GLTexture.cpp
        Resource/GLSLShaderProgram.cpp
        Resource/GLMaterial.cpp Resource/GLMaterial.h

        Drawable/skybox.cpp
        Drawable/MeshRenderer.cpp
        Drawable/Line.cpp
        Drawable/Line.cpp
        Drawable/Frustum.cpp

        GLUtil.cpp

        GLRenderSystem.cpp GLRenderSystem.h

        Pipeline/Renderer.h
        Pipeline/ForwardRenderer.cpp
        Pipeline/ForwardRendererPost.cpp
        Pipeline/ImageProcessing/Edge.cpp
        Pipeline/ImageProcessing/Blur.cpp
        Pipeline/ImageProcessing/Bloom.cpp
        Pipeline/Shadow/ForwardShadowMap.cpp
        Pipeline/Shadow/ForwardShadowMapPcf.cpp
        )

# GLEW replaced by GLAD
find_package(glad CONFIG REQUIRED)
target_link_libraries(OpenGLRenderer PRIVATE glad::glad)
