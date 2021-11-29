// Grid.h
// created on 2021/11/29
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

class Grid {
public:
    Grid ();

    void render() const;

private:
    GLuint m_vao{};
    std::unique_ptr<GLSLShaderProgram> m_gridShader{};
};

