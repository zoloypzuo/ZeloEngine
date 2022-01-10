// GLIndirectCommandBufferDSA.h
// created on 2021/12/19
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "GLBufferDSA.h"

namespace Zelo::Renderer::OpenGL {
struct DrawElementsIndirectCommand {
    GLuint count_;
    GLuint instanceCount_;
    GLuint firstIndex_;
    GLuint baseVertex_;
    GLuint baseInstance_;
};

// glMultiDrawElementsIndirectCount
class GLIndirectCommandBufferCountDSA : public GLBufferDSABase {
public:
    explicit GLIndirectCommandBufferCountDSA(size_t numCommands);

    void bind() const override;

    ~GLIndirectCommandBufferCountDSA() override = default;

    GLBufferType getType() const override;

    void sendBlocks();

    DrawElementsIndirectCommand *getCommandQueue() const;

private:
    GLIndirectCommandBufferCountDSA(uint32_t size, const void *data, uint32_t flags, size_t numCommands);

    // num of commands, followed by command queue
    std::vector<uint8_t> m_drawCommandBuffer{};
    // start offset of command queue
    DrawElementsIndirectCommand *m_commandQueue{};
    size_t m_numCommands{};
};

// glMultiDrawElementsIndirect
class GLIndirectCommandBufferDSA : public GLBufferDSABase {
public:
    using CommandQueue = std::vector<DrawElementsIndirectCommand>;

public:
    // alloc size, fill data then
    explicit GLIndirectCommandBufferDSA(size_t numCommands);

    // fill data directly
    explicit GLIndirectCommandBufferDSA(std::vector<DrawElementsIndirectCommand> &commandQueue);

    ~GLIndirectCommandBufferDSA() override = default;

    GLBufferType getType() const override;

    void sendBlocks();

    const CommandQueue &getCommandQueue() const;

    CommandQueue &getCommandQueue();

    size_t getDrawCount() const;

private:
    CommandQueue m_commandQueue{};
};
}