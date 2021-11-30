// GLMesh11.h
// created on 2021/11/30
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "shared/scene/VtxData.h"

#include "Resource/GLBuffer.h"

struct DrawElementsIndirectCommand {
    GLuint count_;
    GLuint instanceCount_;
    GLuint firstIndex_;
    GLuint baseVertex_;
    GLuint baseInstance_;
};

class GLMesh1 final {
public:
    GLMesh1(const MeshFileHeader &header, const Mesh *meshes, const uint32_t *indices, const float *vertexData);

    void draw(const MeshFileHeader &header) const;

    ~GLMesh1();

    GLMesh1(const GLMesh1 &) = delete;

    GLMesh1(GLMesh1 &&) = default;

private:
    GLuint vao_{};
    uint32_t numIndices_;

    GLBuffer bufferIndices_;
    GLBuffer bufferVertices_;
    GLBuffer bufferIndirect_;
};
