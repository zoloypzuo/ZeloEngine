#include "ZeloPreCompiledHeader.h"
#include "Framework/OpenGL/OpenGLContext.h"


namespace Zelo {

OpenGLContext::OpenGLContext(GLFWwindow *windowHandle)
        : m_WindowHandle(windowHandle) {
    ZELO_CORE_ASSERT(windowHandle, "Window handle is null!");
}

void OpenGLContext::Init() {
    ZELO_PROFILE_FUNCTION();

    // TODO
//    glfwMakeContextCurrent(m_WindowHandle);
//    int status = gladLoadGLLoader((GLADloadproc) glfwGetProcAddress);
//    ZELO_CORE_ASSERT(status, "Failed to initialize Glad!");

    ZELO_CORE_INFO("OpenGL Info:");
    ZELO_CORE_INFO("  Vendor: {0}", glGetString(GL_VENDOR));
    ZELO_CORE_INFO("  Renderer: {0}", glGetString(GL_RENDERER));
    ZELO_CORE_INFO("  Version: {0}", glGetString(GL_VERSION));

    // TODO
//    ZELO_CORE_ASSERT(GLVersion.major > 4 || (GLVersion.major == 4 && GLVersion.minor >= 5),
//                   "Zelo requires at least OpenGL version 4.5!");
}

void OpenGLContext::SwapBuffers() {
    ZELO_PROFILE_FUNCTION();
// TODO
//    glfwSwapBuffers(m_WindowHandle);
}

}
