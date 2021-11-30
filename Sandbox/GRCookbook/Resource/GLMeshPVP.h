// GLMeshPVP.h
// created on 2021/11/30
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "GLBuffer.h"

class GLMeshPVP final {
public:
    GLMeshPVP(const uint32_t *indices, uint32_t indicesSize, const float *vertexData, uint32_t verticesSize);

    void draw() const;

    ~GLMeshPVP();

private:
    GLuint vao_;
    uint32_t numIndices_;

    GLBuffer bufferIndices_;
    GLBuffer bufferVertices_;
};
