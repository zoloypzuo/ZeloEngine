# created on 2021/3/29
# author @zoloypzuo
add_library(OpenGLRenderer
        Buffer/GLBuffer.cpp
        Buffer/GLVertexArray.cpp
        Buffer/GLFramebuffer.cpp
        Buffer/GLShadowMap.cpp
        Buffer/GLUniformBuffer.cpp
        Buffer/GLShaderStorageBuffer.cpp
        Buffer/GLVertexArrayDSA.cpp
        Buffer/GLBufferDSA.cpp
        Buffer/GLShaderStorageBufferDSA.cpp

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
        Drawable/MeshScene/Material/Material.cpp
        Drawable/MeshScene/Scene/Scene.cpp
        Drawable/MeshScene/Texture/GLTexture.cpp
        Drawable/MeshScene/Util/Utils.cpp
        Drawable/MeshScene/Util/UtilsCubemap.cpp

        GLUtil.cpp
        GLLoader.cpp

        GLRenderSystem.cpp

        Pipeline/ForwardStandardPipeline.cpp
        Pipeline/SimplePipeline.cpp Pipeline/SimplePipeline.h
        )

option(ZeloGLTracer "ZeloGLTracer" ON)
if (ZeloGLTracer)
    target_compile_definitions(OpenGLRenderer PUBLIC ZELO_GL_TRACER)
    target_sources(OpenGLRenderer PRIVATE Tracer/GLTracerImpl.cpp Tracer/GLTracer.cpp)
endif ()

target_link_libraries(OpenGLRenderer PUBLIC Core)
target_link_libraries(OpenGLRenderer PRIVATE SDL)
target_link_libraries(OpenGLRenderer PRIVATE glad::glad)
target_include_directories(OpenGLRenderer PRIVATE ${STB_INCLUDE_DIRS})

set_target_properties(OpenGLRenderer PROPERTIES FOLDER "OpenGL")
