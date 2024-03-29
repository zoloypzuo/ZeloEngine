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

        Drawable/MeshScene/Buffer/GLBufferDSA.cpp
        Drawable/MeshScene/Buffer/GLShaderStorageBufferDSA.cpp
        Drawable/MeshScene/Buffer/GLUniformBufferDSA.cpp
        Drawable/MeshScene/Buffer/GLVertexArrayDSA.cpp

        Drawable/MeshScene/VtxData/MeshData.cpp
        Drawable/MeshScene/Scene/SceneGraph.cpp
        Drawable/MeshScene/Texture/GLTexture.cpp
        Drawable/MeshScene/Util/Utils.cpp
        Drawable/MeshScene/Util/UtilsCubemap.cpp

        Drawable/MeshScene/MeshSceneSimple.cpp
        Drawable/MeshScene/MeshSceneFinal.cpp
        Drawable/MeshScene/MeshSceneWireFrame.cpp
        Drawable/MeshScene/GLSkyboxRenderer.cpp
        Drawable/MeshScene/Buffer/GLFramebufferDSA.cpp

        GLUtil.cpp
        GLLoader.cpp

        GLRenderSystem.cpp

        Pipeline/ForwardStandardPipeline.cpp
        Pipeline/SimplePipeline.cpp Pipeline/SimplePipeline.h

        Drawable/MeshScene/Buffer/GLIndirectCommandBufferDSA.cpp
        Drawable/MeshScene/Buffer/GLAtomicCounterDSA.cpp

        Drawable/MeshScene/MeshScene_fb.cpp)

option(ZELO_GL_TRACER "ZeloGLTracer" ON)
if (ZELO_GL_TRACER)
    target_compile_definitions(OpenGLRenderer PUBLIC ZELO_GL_TRACER)
    target_sources(OpenGLRenderer PRIVATE Tracer/GLTracerImpl.cpp Tracer/GLTracer.cpp)
endif ()

target_link_libraries(OpenGLRenderer PUBLIC Core)
target_link_libraries(OpenGLRenderer PRIVATE SDL)
target_link_libraries(OpenGLRenderer PRIVATE glad::glad)
target_include_directories(OpenGLRenderer PRIVATE ${STB_INCLUDE_DIRS})

set_target_properties(OpenGLRenderer PROPERTIES FOLDER "OpenGL")

find_package(glfw3 CONFIG REQUIRED)
find_package(gli CONFIG REQUIRED)
find_package(RapidJSON CONFIG REQUIRED)
find_package(Taskflow CONFIG REQUIRED)


target_link_libraries(OpenGLRenderer PUBLIC gli)
target_link_libraries(OpenGLRenderer PRIVATE Taskflow::Taskflow)
