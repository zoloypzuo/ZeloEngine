// GLSkyboxRenderer.h
// created on 2021/12/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "GLBuffer.h"
#include "GLTexture.h"

#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

class GLSkyboxRenderer {
public:
    GLSkyboxRenderer(
            const char *envMap,
            const char *envMapIrradiance,
            const char *brdfLUTFileName
            );

    ~GLSkyboxRenderer();

    void draw();

private:
    // https://hdrihaven.com/hdri/?h=immenstadter_horn
    GLTexture envMap_;
    GLTexture envMapIrradiance_;
    GLTexture brdfLUT_;
    std::unique_ptr<GLSLShaderProgram> progCube_;
    GLuint dummyVAO_;
};
