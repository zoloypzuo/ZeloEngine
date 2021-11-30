// GLMeshPVP.cpp
// created on 2021/11/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLMeshPVP.h"

GLMeshPVP::GLMeshPVP(const uint32_t *indices, uint32_t indicesSize, const float *vertexData, uint32_t verticesSize)
        : numIndices_(indicesSize / sizeof(uint32_t)), bufferIndices_(indicesSize, indices, 0),
          bufferVertices_(verticesSize, vertexData, 0) {
    glCreateVertexArrays(1, &vao_);
    glVertexArrayElementBuffer(vao_, bufferIndices_.getHandle());
}

GLMeshPVP::~GLMeshPVP() {
    glDeleteVertexArrays(1, &vao_);
}

void GLMeshPVP::draw() const {
    glBindVertexArray(vao_);
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, bufferVertices_.getHandle());
    glDrawElements(GL_TRIANGLES, static_cast<GLsizei>(numIndices_), GL_UNSIGNED_INT, nullptr);
}
