// GLSkyboxRenderer.cpp
// created on 2021/12/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLSkyboxRenderer.h"

GLSkyboxRenderer::GLSkyboxRenderer(const char *envMap, const char *envMapIrradiance)
        : envMap_(GL_TEXTURE_CUBE_MAP, envMap)
        , envMapIrradiance_(GL_TEXTURE_CUBE_MAP, envMapIrradiance)
{
    progCube_ = std::make_unique<GLSLShaderProgram>("cube.glsl");

    glCreateVertexArrays(1, &dummyVAO_);
    const GLuint pbrTextures[] = { envMap_.getHandle(), envMapIrradiance_.getHandle(), brdfLUT_.getHandle() };
    // binding points for data/shaders/PBR.sp
    glBindTextures(5, 3, pbrTextures);
}

GLSkyboxRenderer::~GLSkyboxRenderer() {
    glDeleteVertexArrays(1, &dummyVAO_);
}

void GLSkyboxRenderer::draw() {
    progCube_.useProgram();
    glBindTextureUnit(1, envMap_.getHandle());
    glDepthMask(false);
    glBindVertexArray(dummyVAO_);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glDepthMask(true);
}
