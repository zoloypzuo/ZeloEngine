// GLMesh22.h
// created on 2021/12/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "GRCookbook/VtxData.h"

#include "Resource/GLBuffer.h"
#include "GLSceneData.h"

class GLMesh2 final {
public:
    const GLuint kBufferIndex_ModelMatrices = 1;
    const GLuint kBufferIndex_Materials = 2;

public:
    explicit GLMesh2(GLSceneData &data);

    void draw() const;

    ~GLMesh2();

    GLMesh2(const GLMesh2 &) = delete;

    GLMesh2(GLMesh2 &&) = default;

private:
    GLuint vao_{};
    uint32_t numIndices_;

    GLBuffer bufferIndices_;
    GLBuffer bufferVertices_;
    GLBuffer bufferMaterials_;

    GLBuffer bufferIndirect_;

    GLBuffer bufferModelMatrices_;

    GLSceneData &m_data;
};
