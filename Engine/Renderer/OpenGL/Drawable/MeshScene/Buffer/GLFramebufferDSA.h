#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Texture/GLTexture.h"

namespace Zelo::Renderer::OpenGL {
class GLFramebufferDSA {
public:
    /// The constructor takes dimensions of the framebuffer and texture formats
    /// for color and depth buffers. Whenever a texture format is set to 0, no
    /// corresponding buffer is created. This is handy when we need color-only
    /// framebuffers for fullscreen rendering or depth-only framebuffers for
    /// shadow map rendering
    /// \param width
    /// \param height
    /// \param formatColor glTextureStorage2D, set 0 to disable
    /// \param formatDepth glTextureStorage2D, set 0 to disable
    GLFramebufferDSA(int width, int height, GLenum formatColor, GLenum formatDepth);

    ~GLFramebufferDSA();

    GLFramebufferDSA(const GLFramebufferDSA &) = delete;

    GLFramebufferDSA(GLFramebufferDSA &&) = default;

    GLuint getHandle() const { return handle_; }

    const GLTexture &getTextureColor() const { return *texColor_; }

    const GLTexture &getTextureDepth() const { return *texDepth_; }

    void bind() const;

    void unbind();

private:
    int width_;
    int height_;
    GLuint handle_ = 0;

    std::unique_ptr<GLTexture> texColor_;
    std::unique_ptr<GLTexture> texDepth_;
};
}
