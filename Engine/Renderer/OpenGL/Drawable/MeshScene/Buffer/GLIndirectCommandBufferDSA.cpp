// GLIndirectCommandBufferDSA.cpp.cc
// created on 2021/12/19
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLIndirectCommandBufferDSA.h"

namespace Zelo::Renderer::OpenGL {

GLIndirectCommandBufferDSA::GLIndirectCommandBufferDSA(size_t numCommands) :
        GLIndirectCommandBufferDSA(
                sizeof(DrawElementsIndirectCommand) * numCommands + sizeof(GLsizei),
                nullptr, GL_DYNAMIC_STORAGE_BIT, numCommands
        ) {}

GLIndirectCommandBufferDSA::GLIndirectCommandBufferDSA(
        uint32_t size, const void *data, uint32_t flags, size_t numCommands) :
        GLBufferDSABase(size, data, flags), m_numCommands(numCommands) {

    m_drawCommandBuffer.resize(size);

    // store the number of draw commands in the very beginning of the buffer
    memcpy(m_drawCommandBuffer.data(), &numCommands, sizeof(GLsizei));

    auto *startOffset = m_drawCommandBuffer.data() + sizeof(GLsizei);
    m_commandQueue = std::launder(reinterpret_cast<DrawElementsIndirectCommand *>(startOffset));
}

void GLIndirectCommandBufferDSA::bind() const {
    glBindBuffer(GL_DRAW_INDIRECT_BUFFER, m_RendererID);
    glBindBuffer(GL_PARAMETER_BUFFER, m_RendererID);
}

GLBufferType GLIndirectCommandBufferDSA::getType() const { return GLBufferType::DRAW_INDIRECT_BUFFER; }

void GLIndirectCommandBufferDSA::sendBlocks() {
    const auto bufferSize = static_cast<GLsizeiptr>(sizeof(uint8_t) * m_drawCommandBuffer.size());
    glNamedBufferSubData(m_RendererID, 0, bufferSize, m_drawCommandBuffer.data());
}

DrawElementsIndirectCommand *GLIndirectCommandBufferDSA::getCommandQueue() const { return m_commandQueue; }

void GLIndirectCommandBufferDSA::selectFrom(GLIndirectCommandBufferDSA &src, const Selector &predicate) {
}

void GLIndirectCommandBufferDSA::sort() {

}

}