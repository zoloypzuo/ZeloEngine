#pragma once

#include "ZeloPrerequisites.h"

#include "Framework/Renderer/GraphicsContext.h"

struct GLFWwindow;

namespace Zelo {

class OpenGLContext : public GraphicsContext {
public:
    explicit OpenGLContext(GLFWwindow *windowHandle);

    void Init() override;

    void SwapBuffers() override;

private:
    GLFWwindow *m_WindowHandle;
};

}