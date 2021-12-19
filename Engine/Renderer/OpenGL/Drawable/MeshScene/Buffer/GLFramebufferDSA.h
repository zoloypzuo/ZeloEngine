#pragma once

#include "ZeloGLPrerequisites.h"
#include <memory>
#include "Renderer/OpenGL/Drawable/MeshScene/Texture/GLTexture.h"

namespace Zelo::Renderer::OpenGL {
class GLFramebufferDSA {
public:
    GLFramebufferDSA(int width, int height, GLenum formatColor, GLenum formatDepth);

    ~GLFramebufferDSA();

    GLFramebufferDSA(const GLFramebufferDSA &) = delete;

    GLFramebufferDSA(GLFramebufferDSA &&) = default;

    GLuint getHandle() const { return handle_; }

    const GLTexture &getTextureColor() const { return *texColor_.get(); }

    const GLTexture &getTextureDepth() const { return *texDepth_.get(); }

    void bind();

    void unbind();

private:
    int width_;
    int height_;
    GLuint handle_ = 0;

    std::unique_ptr<GLTexture> texColor_;
    std::unique_ptr<GLTexture> texDepth_;
};
}
