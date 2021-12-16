# created on 2021/3/29
# author @zoloypzuo
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
        Resource/GLMaterial.cpp

        Drawable/SkyBox.cpp
        Drawable/Line.cpp
        Drawable/Line.cpp
        Drawable/Frustum.cpp
        Drawable/Grid.cpp
        Drawable/MeshScene/MeshScene.cpp

        GLUtil.cpp
        GLLoader.cpp

        GLRenderSystem.cpp

        Pipeline/ForwardStandardPipeline.cpp
        Pipeline/SimplePipeline.cpp Pipeline/SimplePipeline.h
        )


target_link_libraries(OpenGLRenderer PUBLIC Core)
target_link_libraries(OpenGLRenderer PRIVATE SDL glad::glad)
target_include_directories(OpenGLRenderer PRIVATE ${STB_INCLUDE_DIRS})

set_target_properties(OpenGLRenderer PROPERTIES FOLDER "OpenGL")
