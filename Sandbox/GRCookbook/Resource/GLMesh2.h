// GLMesh2.h
// created on 2021/12/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "shared/scene/VtxData.h"

#include "Resource/GLBuffer.h"
#include "shared/glFramework/GLSceneData.h"

const GLuint kBufferIndex_ModelMatrices = 1;
const GLuint kBufferIndex_Materials = 2;

class GLMesh final {
public:
    explicit GLMesh(const GLSceneData &data);

    void draw(const GLSceneData &data) const;

    ~GLMesh();

    GLMesh(const GLMesh &) = delete;

    GLMesh(GLMesh &&) = default;

private:
    GLuint vao_;
    uint32_t numIndices_;

    GLBuffer bufferIndices_;
    GLBuffer bufferVertices_;
    GLBuffer bufferMaterials_;

    GLBuffer bufferIndirect_;

    GLBuffer bufferModelMatrices_;
};
