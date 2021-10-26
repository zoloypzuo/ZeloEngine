// GLRenderCommand.inl
// created on 2021/8/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLRenderSystem.h"
#include "GLUtil.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;

void GLRenderSystem::clear(bool colorBuffer, bool depthBuffer, bool stencilBuffer) {
    glClear((colorBuffer ? GL_COLOR_BUFFER_BIT : 0) |
            (depthBuffer ? GL_DEPTH_BUFFER_BIT : 0) |
            (stencilBuffer ? GL_STENCIL_BUFFER_BIT : 0));
}

void GLRenderSystem::setClearColor(const glm::vec4 &color) {
    glClearColor(color.r, color.g, color.b, color.a);
}

void GLRenderSystem::setViewport(int32_t x, int32_t y, int32_t width, int32_t height) {
    glViewport(x, y, width, height);
}

void GLRenderSystem::drawIndexed(const std::shared_ptr<Zelo::VertexArray> &vertexArray, int32_t indexCount) {
    int32_t count = indexCount ? indexCount : vertexArray->getIndexBuffer()->getCount();
    glDrawElements(GL_TRIANGLES, count, GL_UNSIGNED_INT, nullptr);
    glBindTexture(GL_TEXTURE_2D, 0);
}

void GLRenderSystem::drawArray(const std::shared_ptr<Zelo::VertexArray> &vertexArray, int32_t start, int32_t count) {
    count = count ? count : vertexArray->getIndexBuffer()->getCount();
    glDrawArrays(GL_TRIANGLES, start, count);
}

void GLRenderSystem::setBlendEnabled(bool enabled) {
    if (enabled)
        glEnable(GL_BLEND);
    else
        glDisable(GL_BLEND);
}

void GLRenderSystem::setBlendFunc() {
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

void GLRenderSystem::setCullFaceEnabled(bool enabled) {
    if (enabled)
        glEnable(GL_CULL_FACE);
    else
        glDisable(GL_CULL_FACE);
}

void GLRenderSystem::setDepthTestEnabled(bool enabled) {
    if (enabled)
        glEnable(GL_DEPTH_TEST);
    else
        glDisable(GL_DEPTH_TEST);
}

void GLRenderSystem::setCapabilityEnabled(ERenderingCapability capability, bool value) {
    (value ? glEnable : glDisable)(static_cast<GLenum>(capability));
}

bool GLRenderSystem::getCapabilityEnabled(ERenderingCapability capability) {
    return glIsEnabled(static_cast<GLenum>(capability));
}

void GLRenderSystem::setStencilAlgorithm(EComparaisonAlgorithm algorithm, int32_t reference, uint32_t mask) {
    glStencilFunc(static_cast<GLenum>(algorithm), reference, mask);
}

void GLRenderSystem::setDepthAlgorithm(EComparaisonAlgorithm algorithm) {
    glDepthFunc(static_cast<GLenum>(algorithm));
}

void GLRenderSystem::setStencilMask(uint32_t mask) {
    glStencilMask(mask);
}

void GLRenderSystem::setStencilOperations(EOperation stencilFail, EOperation depthFail, EOperation bothPass) {
    glStencilOp(static_cast<GLenum>(stencilFail), static_cast<GLenum>(depthFail), static_cast<GLenum>(bothPass));
}

void GLRenderSystem::setCullFace(ECullFace cullFace) {
    glCullFace(static_cast<GLenum>(cullFace));
}

void GLRenderSystem::setDepthWriting(bool enable) {
    glDepthMask(enable);
}

void GLRenderSystem::setColorWriting(bool enableRed, bool enableGreen, bool enableBlue, bool enableAlpha) {
    glColorMask(enableRed, enableGreen, enableBlue, enableAlpha);
}

void GLRenderSystem::setColorWriting(bool enable) {
    glColorMask(enable, enable, enable, enable);
}

void GLRenderSystem::readPixels(uint32_t x, uint32_t y, uint32_t width, uint32_t height, EPixelDataFormat format,
                                EPixelDataType type, void *data) {
    glReadPixels(static_cast<GLint>(x), static_cast<GLint>(y),
                 static_cast<GLint>(width), static_cast<GLint>(height),
                 static_cast<GLenum>(format), static_cast<GLenum>(type), data);
}

bool GLRenderSystem::getBool(uint32_t parameter) {
    GLboolean result = 0;
    glGetBooleanv(parameter, &result);
    return static_cast<bool>(result);
}

bool GLRenderSystem::getBool(uint32_t parameter, uint32_t index) {
    GLboolean result = 0;
    glGetBooleani_v(parameter, index, &result);
    return static_cast<bool>(result);
}

int GLRenderSystem::getInt(uint32_t parameter) {
    GLint result = 0;
    glGetIntegerv(parameter, &result);
    return static_cast<int>(result);
}

int GLRenderSystem::getInt(uint32_t parameter, uint32_t index) {
    GLint result = 0;
    glGetIntegeri_v(parameter, index, &result);
    return static_cast<int>(result);
}

float GLRenderSystem::getFloat(uint32_t parameter) {
    GLfloat result{};
    glGetFloatv(parameter, &result);
    return static_cast<float>(result);
}

float GLRenderSystem::getFloat(uint32_t parameter, uint32_t index) {
    GLfloat result{};
    glGetFloati_v(parameter, index, &result);
    return static_cast<float>(result);
}

double GLRenderSystem::getDouble(uint32_t parameter) {
    GLdouble result{};
    glGetDoublev(parameter, &result);
    return static_cast<double>(result);
}

double GLRenderSystem::getDouble(uint32_t parameter, uint32_t index) {
    GLdouble result{};
    glGetDoublei_v(parameter, index, &result);
    return static_cast<double>(result);
}

int64_t GLRenderSystem::getInt64(uint32_t parameter) {
    GLint64 result{};
    glGetInteger64v(parameter, &result);
    return static_cast<int64_t>(result);
}

int64_t GLRenderSystem::getInt64(uint32_t parameter, uint32_t index) {
    GLint64 result{};
    glGetInteger64i_v(parameter, index, &result);
    return static_cast<int64_t>(result);
}

std::string GLRenderSystem::getString(uint32_t parameter) {
    const GLubyte *result = glGetString(parameter);
    return result ? reinterpret_cast<const char *>(result) : std::string();
}

std::string GLRenderSystem::getString(uint32_t parameter, uint32_t index) {
    const GLubyte *result = glGetStringi(parameter, index);
    return result ? reinterpret_cast<const char *>(result) : std::string();
}

uint8_t GLRenderSystem::fetchGLState() {
    uint8_t result = 0;

    GLboolean cMask[4];
    glGetBooleanv(GL_COLOR_WRITEMASK, cMask);

    if (getBool(GL_DEPTH_WRITEMASK)) result |= 0b0000'0001;
    if (cMask[0]) result |= 0b0000'0010;
    if (getCapabilityEnabled(ERenderingCapability::BLEND)) result |= 0b0000'0100;
    if (getCapabilityEnabled(ERenderingCapability::CULL_FACE)) result |= 0b0000'1000;
    if (getCapabilityEnabled(ERenderingCapability::DEPTH_TEST)) result |= 0b0001'0000;

    switch (static_cast<ECullFace>(getInt(GL_CULL_FACE))) {
        case ECullFace::BACK:
            result |= 0b0010'0000;
            break;
        case ECullFace::FRONT:
            result |= 0b0100'0000;
            break;
        case ECullFace::FRONT_AND_BACK:
            result |= 0b0110'0000;
            break;
    }

    return result;
}

void GLRenderSystem::applyStateMask(uint8_t mask) {
    if (mask != m_state) {
        if ((mask & 0x01) != (m_state & 0x01)) setDepthWriting(mask & 0x01);
        if ((mask & 0x02) != (m_state & 0x02)) setColorWriting(mask & 0x02);
        if ((mask & 0x04) != (m_state & 0x04)) setCapabilityEnabled(ERenderingCapability::BLEND, mask & 0x04);
        if ((mask & 0x08) != (m_state & 0x08)) setCapabilityEnabled(ERenderingCapability::CULL_FACE, mask & 0x8);
        if ((mask & 0x10) != (m_state & 0x10)) setCapabilityEnabled(ERenderingCapability::DEPTH_TEST, mask & 0x10);

        if ((mask & 0x08) && ((mask & 0x20) != (m_state & 0x20) || (mask & 0x40) != (m_state & 0x40))) {
            int backBit = mask & 0x20;
            int frontBit = mask & 0x40;
            setCullFace(backBit &&
                        frontBit ?
                        ECullFace::FRONT_AND_BACK :
                        (backBit ? ECullFace::BACK : ECullFace::FRONT));
        }

        m_state = mask;
    }
}
