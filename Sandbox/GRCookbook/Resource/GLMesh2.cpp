// GLMesh2.cpp
// created on 2021/12/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLMesh2.h"

struct DrawElementsIndirectCommand {
    GLuint count_;
    GLuint instanceCount_;
    GLuint firstIndex_;
    GLuint baseVertex_;
    GLuint baseInstance_;
};

GLMesh::GLMesh(const GLSceneData &data) :
        numIndices_(data.header_.indexDataSize / sizeof(uint32_t)),
        bufferIndices_(data.header_.indexDataSize, data.meshData_.indexData_.data(), 0),
        bufferVertices_(data.header_.vertexDataSize, data.meshData_.vertexData_.data(), 0),
        bufferMaterials_(sizeof(MaterialDescription) * data.materials_.size(), data.materials_.data(), 0),
        bufferIndirect_(sizeof(DrawElementsIndirectCommand) * data.shapes_.size() + sizeof(GLsizei),
                        nullptr, GL_DYNAMIC_STORAGE_BIT),
        bufferModelMatrices_(sizeof(glm::mat4) * data.shapes_.size(), nullptr, GL_DYNAMIC_STORAGE_BIT) {
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

    std::vector<uint8_t> drawCommands;

    drawCommands.resize(sizeof(DrawElementsIndirectCommand) * data.shapes_.size() + sizeof(GLsizei));

    // store the number of draw commands in the very beginning of the buffer
    const GLsizei numCommands = (GLsizei) data.shapes_.size();
    memcpy(drawCommands.data(), &numCommands, sizeof(numCommands));

    DrawElementsIndirectCommand *cmd = std::launder(
            reinterpret_cast<DrawElementsIndirectCommand *>(drawCommands.data() + sizeof(GLsizei))
    );

    // prepare indirect commands buffer
    for (size_t i = 0; i != data.shapes_.size(); i++) {
        const uint32_t meshIdx = data.shapes_[i].meshIndex;
        const uint32_t lod = data.shapes_[i].LOD;
        *cmd++ = {
                .count_ = data.meshData_.meshes_[meshIdx].getLODIndicesCount(lod),
                .instanceCount_ = 1,
                .firstIndex_ = data.shapes_[i].indexOffset,
                .baseVertex_ = data.shapes_[i].vertexOffset,
                .baseInstance_ = data.shapes_[i].materialIndex
        };
    }

    glNamedBufferSubData(bufferIndirect_.getHandle(), 0, drawCommands.size(), drawCommands.data());

    std::vector<glm::mat4> matrices(data.shapes_.size());
    size_t i = 0;
    for (const auto &c: data.shapes_)
        matrices[i++] = data.scene_.globalTransform_[c.transformIndex];

    glNamedBufferSubData(bufferModelMatrices_.getHandle(), 0, matrices.size() * sizeof(mat4), matrices.data());
}

void GLMesh::draw(const GLSceneData &data) const {
    glBindVertexArray(vao_);
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, kBufferIndex_Materials, bufferMaterials_.getHandle());
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, kBufferIndex_ModelMatrices, bufferModelMatrices_.getHandle());
    glBindBuffer(GL_DRAW_INDIRECT_BUFFER, bufferIndirect_.getHandle());
    glBindBuffer(GL_PARAMETER_BUFFER, bufferIndirect_.getHandle());
    glMultiDrawElementsIndirectCount(GL_TRIANGLES, GL_UNSIGNED_INT, (const void *) sizeof(GLsizei), 0,
                                     (GLsizei) data.shapes_.size(), 0);
}

GLMesh::~GLMesh() {
    glDeleteVertexArrays(1, &vao_);
}
