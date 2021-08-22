// Window.cpp
// created on 2021/3/28
// author @zoloypzuo
#include <SDL_syswm.h>
#include "ZeloPreCompiledHeader.h"
#include "Window.h"

Window::Window(const INIReader::Section &windowConfig) : m_windowConfig(windowConfig) {
}

Window::~Window() = default;

void Window::initialize() {
    spdlog::info("start initialize window");

    if (SDL_Init(SDL_INIT_EVERYTHING & ~(SDL_INIT_TIMER | SDL_INIT_HAPTIC)) != 0) {
        spdlog::error("SDL_Init error: {}", SDL_GetError());
    }

    SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE, 8 * 4);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 8 * 2);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 4);

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_DEBUG_FLAG);

#if defined(GLES3)
    spdlog::info("Using GLES 3");
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
#elif defined(GLES2)
    spdlog::info("Using GLES 2");
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
#elif defined(EMSCRIPTEN)
    spdlog::info("Using GLES 2");
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
#else
    spdlog::info("Using GL 3");
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
#endif

    m_fullscreen = m_windowConfig.GetBoolean("fullscreen");

    uint32_t flags = SDL_WINDOW_OPENGL;

    if (m_fullscreen) {
        flags |= SDL_WINDOW_FULLSCREEN;
    }

    m_window = SDL_CreateWindow(
            m_windowConfig.GetCString("title"),
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,
            m_windowConfig.GetInteger("windowed_width"),
            m_windowConfig.GetInteger("windowed_height"),
            flags);
    if (m_window == nullptr) {
        spdlog::error("SDL_CreateWindow error: {}", SDL_GetError());
    }

    m_glContext = SDL_GL_CreateContext(m_window);
    if (m_glContext == nullptr) {
        spdlog::error("SDL_GL_CreateContext error: {}", SDL_GetError());
    }

    m_vSync = m_windowConfig.GetBoolean("vsync");
    SDL_GL_SetSwapInterval(m_vSync ? 1 : 0);

    int display_w{};
    int display_h{};
    SDL_GL_GetDrawableSize(m_window, &display_w, &display_h);
    m_width = display_w;
    m_height = display_h;

    spdlog::info("Window initialize to: {} x {}, vsync={}", m_width, m_height, m_vSync);
}

void Window::update() {
    ZELO_PROFILE_FUNCTION();
    m_input.setMouseDelta(0, 0);

    SDL_Event event;

    bool mouseWheelEvent = false;

    while (SDL_PollEvent(&event)) {
        // TODO Forward to Imgui
//        ImGui_ImplSDL2_ProcessEvent(&event);
        switch (event.type) {
            case SDL_MOUSEMOTION:
                m_input.setMouseDelta(event.motion.xrel, event.motion.yrel);
                m_input.setMousePosition(event.motion.x, event.motion.y);
                break;
            case SDL_KEYDOWN:
            case SDL_KEYUP:
                m_input.handleKeyboardEvent(event.key);
                break;
            case SDL_MOUSEBUTTONDOWN:
            case SDL_MOUSEBUTTONUP:
                m_input.handleMouseEvent(event.button);
                break;
            case SDL_MOUSEWHEEL:
                m_input.handleMouseWheelEvent(event.wheel.x, event.wheel.y);
                mouseWheelEvent = true;
                break;
            case SDL_TEXTINPUT:
                m_input.handleTextEdit(event.text.text);
                break;
            case SDL_MULTIGESTURE:
                m_input.handleMultiGesture(event.mgesture);
                break;
            case SDL_QUIT:
                m_quit = true;
                break;
        }
    }

    if (!mouseWheelEvent) {
        m_input.handleMouseWheelEvent(0, 0);
    }
}

void Window::finalize() {
    SDL_GL_DeleteContext(m_glContext);
    SDL_DestroyWindow(m_window);
    SDL_Quit();
}

template<> Window *Singleton<Window>::msSingleton = nullptr;

Window *Window::getSingletonPtr() {
    return msSingleton;
}

void Window::swapBuffer() {
    SDL_GL_SwapWindow(m_window);
}

Input *Window::getInput() {
    return &m_input;
}

SDL_Window *Window::getSDLWindow() {
    return m_window;
}

int Window::getWidth() const {
    return this->m_width;
}

int Window::getHeight() const {
    return this->m_height;
}

glm::vec4 Window::getViewport() const {
    return glm::vec4(0.0f, 0.0f, this->m_width, this->m_height);
}

glm::vec2 Window::getDisplaySize() const {
    int w, h;
    SDL_GetWindowSize(m_window, &w, &h);
    return glm::vec2((float) w, (float) h);
}

glm::ivec2 Window::getDrawableSize() const {
    int display_w, display_h;
    SDL_GL_GetDrawableSize(m_window, &display_w, &display_h);
    return glm::ivec2(display_w, display_h);
}

const char *Window::getClipboardText() {
    return SDL_GetClipboardText();
}

void Window::setClipboardText(const char *text) {
    SDL_SetClipboardText(text);
}

void Window::makeCurrentContext() const {
    SDL_GL_MakeCurrent(m_window, m_glContext);
}

bool Window::shouldQuit() const {
    return m_quit;
}

void Window::drawCursor(bool enabled) {
    SDL_ShowCursor(enabled);
}

void Window::setFullscreen(uint32_t flag) {
    SDL_SetWindowFullscreen(m_window, flag);
}

void Window::toggleFullscreen() {
    m_fullscreen = !m_fullscreen;

    if (m_fullscreen) {
        setFullscreen(SDL_WINDOW_FULLSCREEN);
    } else {
        setFullscreen(0);
    }

}

void *Window::getHwnd() const {
    SDL_SysWMinfo wmInfo;
    SDL_VERSION(&wmInfo.version);
    SDL_GetWindowWMInfo(m_window, &wmInfo);
    return wmInfo.info.win.window;
}
