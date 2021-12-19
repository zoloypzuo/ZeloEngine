// GLUniformBufferDSA.cpp
// created on 2021/10/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLUniformBufferDSA.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

using namespace Zelo;
using namespace Zelo::Core::RHI;

namespace Zelo::Renderer::OpenGL {
GLUniformBufferDSA::GLUniformBufferDSA(
        uint32_t bindingPoint, uint32_t size, const void *data, uint32_t flags) :
        GLBufferDSABase(size, data, flags) {
    glBindBufferRange(GL_UNIFORM_BUFFER, bindingPoint, m_RendererID, 0, size);
}
}
