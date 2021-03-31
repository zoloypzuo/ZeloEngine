// Window.cpp
// created on 2021/3/28
// author @zoloypzuo

#include "ZeloPreCompiledHeader.h"
#include "Window.h"


Window::Window() {
    m_quit = false;

    if (SDL_Init(SDL_INIT_EVERYTHING & ~(SDL_INIT_TIMER | SDL_INIT_HAPTIC)) != 0) {
        spdlog::error("SDL_Init error: {}", SDL_GetError());
    }

    SDL_DisplayMode mode;
    SDL_GetCurrentDisplayMode(0, &mode);

    SDL_GL_SetAttribute(SDL_GL_RED_SIZE, BITS_PER_CHANNEL);
    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, BITS_PER_CHANNEL);
    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, BITS_PER_CHANNEL);
    SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, BITS_PER_CHANNEL);
    SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE, BITS_PER_CHANNEL * 4);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, BITS_PER_CHANNEL * 2);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

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
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
#endif

    m_fullscreen = false;

    uint32_t flags = SDL_WINDOW_OPENGL;

    if (m_fullscreen) {
        flags |= SDL_WINDOW_FULLSCREEN;
    }

    m_window = SDL_CreateWindow(
            "Engine!",
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,
//                mode.w, mode.h,
            800, 600, flags);
    if (m_window == nullptr) {
        spdlog::error("SDL_CreateWindow error: {}", SDL_GetError());
    }

    m_glContext = SDL_GL_CreateContext(m_window);
    if (m_glContext == nullptr) {
        spdlog::error("SDL_GL_CreateContext error: {}", SDL_GetError());
    }

    SDL_GL_SetSwapInterval(0);

    int display_w, display_h;
    SDL_GL_GetDrawableSize(m_window, &display_w, &display_h);
    this->m_width = display_w;
    this->m_height = display_h;

    spdlog::info("Window initialize to: {} x {}", this->m_width, this->m_height);
    initialize();
}

Window::~Window() {
    SDL_GL_DeleteContext(m_glContext);
    SDL_DestroyWindow(m_window);
    SDL_Quit();
}

void Window::initialize() {
    spdlog::info("Initializing GUI");
    // TODO gui
//    m_guiManager = std::make_unique<GuiManager>(getDrawableSize(), getDisplaySize(), getSDLWindow());
}

void Window::update() {
    m_input.setMouseDelta(0, 0);

    SDL_Event event;

    bool mouseWheelEvent = false;

    while (SDL_PollEvent(&event)) {
        switch (event.type) {
            case SDL_MOUSEMOTION:
                m_input.setMouseDelta(event.motion.xrel, event.motion.yrel);
                m_input.setMousePosition(event.motion.x, event.motion.y);
                break;
            case SDL_KEYDOWN:
            case SDL_KEYUP:
                //TODO
//                m_guiManager->setKeyEvent(event.key.keysym.sym & ~SDLK_SCANCODE_MASK, event.type == SDL_KEYDOWN);
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
                //TODO
//                m_guiManager->addInputCharactersUTF8(event.text.text);
                break;
            case SDL_MULTIGESTURE:
                m_input.handleMultigesture(event.mgesture);
                break;
            case SDL_QUIT:
                m_quit = true;
                break;
        }
    }

    if (mouseWheelEvent == false) {
        m_input.handleMouseWheelEvent(0, 0);
    }
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

GuiManager *Window::getGuiManager() const {
    return m_guiManager.get();
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