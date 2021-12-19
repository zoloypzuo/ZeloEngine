// GLIndirectCommandBufferDSA.cpp.cc
// created on 2021/12/19
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLIndirectCommandBufferDSA.h"

namespace Zelo::Renderer::OpenGL {

GLIndirectCommandBufferCountDSA::GLIndirectCommandBufferCountDSA(size_t numCommands) :
        GLIndirectCommandBufferCountDSA(
                sizeof(DrawElementsIndirectCommand) * numCommands + sizeof(GLsizei),
                nullptr, GL_DYNAMIC_STORAGE_BIT, numCommands
        ) {}

GLIndirectCommandBufferCountDSA::GLIndirectCommandBufferCountDSA(
        uint32_t size, const void *data, uint32_t flags, size_t numCommands) :
        GLBufferDSABase(size, data, flags), m_numCommands(numCommands) {

    m_drawCommandBuffer.resize(size);

    // store the number of draw commands in the very beginning of the buffer
    memcpy(m_drawCommandBuffer.data(), &numCommands, sizeof(GLsizei));

    auto *startOffset = m_drawCommandBuffer.data() + sizeof(GLsizei);
    m_commandQueue = std::launder(reinterpret_cast<DrawElementsIndirectCommand *>(startOffset));
}

void GLIndirectCommandBufferCountDSA::bind() const {
    glBindBuffer(GL_DRAW_INDIRECT_BUFFER, m_RendererID);
    glBindBuffer(GL_PARAMETER_BUFFER, m_RendererID);
}

GLBufferType GLIndirectCommandBufferCountDSA::getType() const { return GLBufferType::DRAW_INDIRECT_BUFFER; }

void GLIndirectCommandBufferCountDSA::sendBlocks() {
    const auto bufferSize = static_cast<GLsizeiptr>(sizeof(uint8_t) * m_drawCommandBuffer.size());
    glNamedBufferSubData(m_RendererID, 0, bufferSize, m_drawCommandBuffer.data());
}

DrawElementsIndirectCommand *GLIndirectCommandBufferCountDSA::getCommandQueue() const { return m_commandQueue; }

GLIndirectCommandBufferDSA::GLIndirectCommandBufferDSA(size_t numCommands) :
        GLBufferDSABase(sizeof(DrawElementsIndirectCommand) * numCommands, nullptr, GL_DYNAMIC_STORAGE_BIT) {
    m_commandQueue.resize(numCommands);
}

GLIndirectCommandBufferDSA::GLIndirectCommandBufferDSA(std::vector<DrawElementsIndirectCommand> &commandQueue) :
        GLBufferDSABase(sizeof(DrawElementsIndirectCommand) * commandQueue.size(), commandQueue.data(), 0),
        m_commandQueue(commandQueue) {
}

GLBufferType GLIndirectCommandBufferDSA::getType() const { return GLBufferType::DRAW_INDIRECT_BUFFER; }

void GLIndirectCommandBufferDSA::sendBlocks() {
    glNamedBufferSubData(m_RendererID, 0,
                         sizeof(DrawElementsIndirectCommand) * m_commandQueue.size(), m_commandQueue.data());
}

const GLIndirectCommandBufferDSA::CommandQueue &GLIndirectCommandBufferDSA::getCommandQueue() const {
    return m_commandQueue;
}

GLIndirectCommandBufferDSA::CommandQueue &GLIndirectCommandBufferDSA::getCommandQueue() {
    return m_commandQueue;
}

size_t GLIndirectCommandBufferDSA::getDrawCount() const { return m_commandQueue.size(); }
}