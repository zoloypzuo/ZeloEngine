// GLSkyboxRenderer.cpp
// created on 2021/12/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLSkyboxRenderer.h"

using namespace Zelo::Core::ECS;
using namespace Zelo::Renderer::OpenGL;

GLSkyboxRenderer::GLSkyboxRenderer(
        Core::ECS::Entity &owner,
        std::string_view envMap,
        std::string_view envMapIrradiance,
        std::string_view brdfLUTFileName) :
        Component(owner),
        envMap_(GL_TEXTURE_CUBE_MAP, envMap.data()),
        envMapIrradiance_(GL_TEXTURE_CUBE_MAP, envMapIrradiance.data()),
        brdfLUT_(GL_TEXTURE_2D, brdfLUTFileName.data()) {
    progCube_ = std::make_unique<GLSLShaderProgram>("cube.glsl");

    glCreateVertexArrays(1, &dummyVAO_);
    const GLuint pbrTextures[] = {envMap_.getHandle(), envMapIrradiance_.getHandle(), brdfLUT_.getHandle()};
    // binding points for data/shaders/PBR.sp
    glBindTextures(5, 3, pbrTextures);
}

GLSkyboxRenderer::~GLSkyboxRenderer() {
    glDeleteVertexArrays(1, &dummyVAO_);
}

void GLSkyboxRenderer::render() const {
    progCube_->bind();
    glBindTextureUnit(1, envMap_.getHandle());
    glDepthMask(false);
    glBindVertexArray(dummyVAO_);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glDepthMask(true);
}

std::string GLSkyboxRenderer::getType() {
    return "SkyBoxRenderer";
}
