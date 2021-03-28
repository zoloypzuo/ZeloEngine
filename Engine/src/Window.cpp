// Window.cpp
// created on 2021/3/28
// author @zoloypzuo

#include "ZeloPreCompiledHeader.h"
#include "Window.h"


class Window::Impl : public IRuntimeModule {
public:
    SDL_Window *m_window{};
    SDL_GLContext m_glContext{};

    int m_width{}, m_height{};

    bool m_quit{};
    bool m_fullscreen{};
public:
    void initialize() override {

        if (SDL_Init(SDL_INIT_EVERYTHING & ~(SDL_INIT_TIMER | SDL_INIT_HAPTIC)) != 0) {
            spdlog::error("SDL_Init error: %s", SDL_GetError());
        }

        SDL_DisplayMode mode;
        SDL_GetCurrentDisplayMode(0, &mode);

        int BITS_PER_CHANNEL = 8;
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
                SDL_WINDOWPOS_UNDEFINED,
                SDL_WINDOWPOS_UNDEFINED,
                mode.w, mode.h,
                flags);
        if (m_window == nullptr) {
            spdlog::error("SDL_CreateWindow error: %s", SDL_GetError());
        }

        m_glContext = SDL_GL_CreateContext(m_window);
        if (m_glContext == nullptr) {
            spdlog::error("SDL_GL_CreateContext error: %s", SDL_GetError());
        }

        SDL_GL_SetSwapInterval(0);

        int display_w, display_h;
        SDL_GL_GetDrawableSize(m_window, &display_w, &display_h);
        this->m_width = display_w;
        this->m_height = display_h;

        spdlog::info("Window init to: width={} x height={}", this->m_width, this->m_height);
    }

    void finalize() override {
        SDL_GL_DeleteContext(m_glContext);
        SDL_DestroyWindow(m_window);
        SDL_Quit();
    }

    void update() override {
//        m_input.setMouseDelta(0, 0);

        SDL_Event event;

        bool mouseWheelEvent = false;

        while (SDL_PollEvent(&event)) {
            switch (event.type) {
//                case SDL_MOUSEMOTION:
//                    m_input.setMouseDelta(event.motion.xrel, event.motion.yrel);
//                    m_input.setMousePosition(event.motion.x, event.motion.y);
//                    break;
//                case SDL_KEYDOWN:
//                case SDL_KEYUP:
//                    m_guiManager->setKeyEvent(event.key.keysym.sym & ~SDLK_SCANCODE_MASK, event.type == SDL_KEYDOWN);
//                    m_input.handleKeyboardEvent(event.key);
//                    break;
//                case SDL_MOUSEBUTTONDOWN:
//                case SDL_MOUSEBUTTONUP:
//                    m_input.handleMouseEvent(event.button);
//                    break;
                case SDL_MOUSEWHEEL:
//                    m_input.handleMouseWheelEvent(event.wheel.x, event.wheel.y);
                    mouseWheelEvent = true;
                    break;
//                case SDL_TEXTINPUT:
//                    m_guiManager->addInputCharactersUTF8(event.text.text);
//                    break;
//                case SDL_MULTIGESTURE:
//                    m_input.handleMultigesture(event.mgesture);
//                    break;
                case SDL_QUIT:
                    m_quit = true;
                    break;
            }
        }

        if (!mouseWheelEvent) {
//            m_input.handleMouseWheelEvent(0, 0);
        }
    }
};

Window::Window() :
        pImpl_(std::make_unique<Impl>()) {
    pImpl_->initialize();

}

Window::~Window() {
    pImpl_->finalize();
}


void Window::swap_buffer() {
    SDL_GL_SwapWindow(pImpl_->m_window);
}


void Window::make_current_context() {
    SDL_GL_MakeCurrent(pImpl_->m_window, pImpl_->m_glContext);
}

void Window::showCursor(bool enabled) {
    SDL_ShowCursor(enabled);
}

int Window::getWidth() const {
    return 0;
}

int Window::getHeight() const {
    return 0;
}

glm::vec4 Window::getViewport() const {
    return glm::vec4();
}

glm::vec2 Window::getDisplaySize() const {
    return glm::vec2();
}

glm::vec2 Window::getDrawableSize() const {
    return glm::vec2();
}

const char *Window::getClipboardText() const {
    return nullptr;
}

void Window::setClipboardText(const char *text) {

}

SDL_Window *Window::getSDLWindow() {
    return nullptr;
}

bool Window::shouldQuit() const {
    return pImpl_->m_quit;
}

void Window::setFullscreen(uint32_t flag) {

}

void Window::toggleFullscreen() {

}

void Window::update() {
    pImpl_->update();
}
