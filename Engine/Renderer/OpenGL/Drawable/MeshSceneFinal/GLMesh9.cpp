// GLMesh9.cpp
// created on 2021/12/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLMesh9.h"

namespace Zelo::Renderer::OpenGL {
const GLuint kBufferIndex_PerFrameUniforms = 0;
const GLuint kBufferIndex_ModelMatrices = 1;
const GLuint kBufferIndex_Materials = 2;


GLMesh9::GLMesh9(const GLSceneDataLazy &data)
        : numIndices_(data.header_.indexDataSize / sizeof(uint32_t)),
          bufferIndices_(data.header_.indexDataSize, data.meshData_.indexData_.data(), 0),
          bufferVertices_(data.header_.vertexDataSize, data.meshData_.vertexData_.data(), 0),
          bufferMaterials_(sizeof(MaterialDescription) * data.materials_.size(), data.materials_.data(),
                           GL_DYNAMIC_STORAGE_BIT),
          bufferModelMatrices_(sizeof(glm::mat4) * data.shapes_.size(), nullptr, GL_DYNAMIC_STORAGE_BIT),
          bufferIndirect_(data.shapes_.size()) {
    glCreateVertexArrays(1, &vao_);
    glVertexArrayElementBuffer(vao_, bufferIndices_.getHandle());
    glVertexArrayVertexBuffer(vao_, 0, bufferVertices_.getHandle(), 0, sizeof(vec3) + sizeof(vec3) + sizeof(vec2));
    // position
    glEnableVertexArrayAttrib(vao_, 0);
    glVertexArrayAttribFormat(vao_, 0, 3, GL_FLOAT, GL_FALSE, 0);
    glVertexArrayAttribBinding(vao_, 0, 0);
    // uv
    glEnableVertexArrayAttrib(vao_, 1);
    glVertexArrayAttribFormat(vao_, 1, 2, GL_FLOAT, GL_FALSE, sizeof(vec3));
    glVertexArrayAttribBinding(vao_, 1, 0);
    // normal
    glEnableVertexArrayAttrib(vao_, 2);
    glVertexArrayAttribFormat(vao_, 2, 3, GL_FLOAT, GL_TRUE, sizeof(vec3) + sizeof(vec2));
    glVertexArrayAttribBinding(vao_, 2, 0);

    std::vector<glm::mat4> matrices(data.shapes_.size());

    // prepare indirect commands buffer
    for (size_t i = 0; i != data.shapes_.size(); i++) {
        const uint32_t meshIdx = data.shapes_[i].meshIndex;
        const uint32_t lod = data.shapes_[i].LOD;
        bufferIndirect_.getCommandQueue()[i] = {
                data.meshData_.meshes_[meshIdx].getLODIndicesCount(lod),
                1,
                data.shapes_[i].indexOffset,
                data.shapes_[i].vertexOffset,
                data.shapes_[i].materialIndex + (uint32_t(i) << 16)
        };
        matrices[i] = data.scene_.globalTransform_[data.shapes_[i].transformIndex];
    }

    bufferIndirect_.sendBlocks();

    glNamedBufferSubData(bufferModelMatrices_.getHandle(), 0, matrices.size() * sizeof(glm::mat4), matrices.data());
}

void GLMesh9::updateMaterialsBuffer(const GLSceneDataLazy &data) {
    glNamedBufferSubData(bufferMaterials_.getHandle(), 0, sizeof(MaterialDescription) * data.materials_.size(),
                         data.materials_.data());
}

void GLMesh9::draw(const GLIndirectCommandBufferDSA &buffer) const {
    glBindVertexArray(vao_);
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, kBufferIndex_Materials, bufferMaterials_.getHandle());
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, kBufferIndex_ModelMatrices, bufferModelMatrices_.getHandle());
    buffer.bind();

    GLsizei numDrawCommands = (GLsizei) buffer.getDrawCount();
    glMultiDrawElementsIndirect(GL_TRIANGLES, GL_UNSIGNED_INT, nullptr, numDrawCommands, 0);
}

GLMesh9::~GLMesh9() {
    glDeleteVertexArrays(1, &vao_);
}
}