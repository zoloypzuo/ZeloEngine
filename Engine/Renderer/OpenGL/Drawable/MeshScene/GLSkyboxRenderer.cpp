// GLSkyboxRenderer.cpp
// created on 2021/12/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLSkyboxRenderer.h"
#include "Core/Scene/SceneManager.h"

using namespace Zelo::Core::ECS;
using namespace Zelo::Core::Scene;
using namespace Zelo::Renderer::OpenGL;

using glm::mat4;
using glm::vec2;
using glm::vec3;
using glm::vec4;
using glm::ivec2;

namespace {
struct PerFrameData {
    mat4 model;
    mat4 mvp;
    vec4 cameraPos;
};
const GLsizeiptr kUniformBufferSize = sizeof(PerFrameData);

GLuint perFrameDataBuffer{};

const uint32_t kBufferIndex_PerFrameUniforms = 4;
}

GLSkyboxRenderer::GLSkyboxRenderer(
        Core::ECS::Entity &owner,
        std::string_view envMap,
        std::string_view envMapIrradiance,
        std::string_view brdfLUTFileName) :
        Component(owner),
        envMap_(GL_TEXTURE_CUBE_MAP, envMap.data()),
        envMapIrradiance_(GL_TEXTURE_CUBE_MAP, envMapIrradiance.data()),
        brdfLUT_(GL_TEXTURE_2D, brdfLUTFileName.data()) {
    // shader
    progCube_ = std::make_unique<GLSLShaderProgram>("cube.glsl");
    // vao
    glCreateVertexArrays(1, &dummyVAO_);
    // texture
    const GLuint pbrTextures[] = {envMap_.getHandle(), envMapIrradiance_.getHandle(), brdfLUT_.getHandle()};
    // binding points for data/shaders/PBR.sp
    glBindTextures(5, 3, pbrTextures);

    // perFrameDataBuffer
    glCreateBuffers(1, &perFrameDataBuffer);
    glNamedBufferStorage(perFrameDataBuffer, kUniformBufferSize, nullptr, GL_DYNAMIC_STORAGE_BIT);
    glBindBufferRange(GL_UNIFORM_BUFFER, kBufferIndex_PerFrameUniforms, perFrameDataBuffer, 0, kUniformBufferSize);
}

GLSkyboxRenderer::~GLSkyboxRenderer() {
    glDeleteVertexArrays(1, &dummyVAO_);
    getOwner()->SetSelfActive(false);
}

void GLSkyboxRenderer::render() const {
    auto *camera = SceneManager::getSingletonPtr()->getActiveCamera();

    const mat4 m = glm::scale(mat4(1.0f), vec3(200.0f));
    const PerFrameData perFrameData = {
            m,  camera->getProjectionMatrix() * camera->getViewMatrix() * m,
            vec4(0.0f)};
    glNamedBufferSubData(perFrameDataBuffer, 0, kUniformBufferSize, &perFrameData);

    progCube_->bind();
    glBindTextureUnit(1, envMap_.getHandle());
//    glDisable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    glDepthMask(false);
    glBindVertexArray(dummyVAO_);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glDepthMask(true);
    glCullFace(GL_BACK);
//    glEnable(GL_CULL_FACE);
}

std::string GLSkyboxRenderer::getType() {
    return "SkyBoxRenderer";
}
