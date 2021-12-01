// Grid.cpp
// created on 2021/11/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Grid.h"

Grid::Grid() {
    glGenVertexArrays(1, &m_vao);
    m_gridShader = std::make_unique<GLSLShaderProgram>("grid.glsl");
    m_gridShader->link();
}

void Grid::render() const {
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_CULL_FACE);
    m_gridShader->bind();
    glBindVertexArray(m_vao);
    glDrawArraysInstancedBaseInstance(GL_TRIANGLES, 0, 6, 1, 0);
    glEnable(GL_CULL_FACE);
    glDisable(GL_BLEND);
}
