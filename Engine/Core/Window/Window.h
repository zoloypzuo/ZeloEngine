// Window.h
// created on 2021/3/28
// author @zoloypzuo
#ifndef ZELOENGINE_WINDOW_H
#define ZELOENGINE_WINDOW_H

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "ZeloSDL.h"

#include "Core/Parser/IniReader.h"
#include "Core/Input/Input.h"
#include "Core/EventSystem/Event.h"

// TODO move namespace
class Window :
        public Singleton<Window>,
        public IRuntimeModule {
public:
    explicit Window(const INIReader::Section &windowConfig);

    ~Window() override;

    void initialize() override;

    void update() override;

    void finalize() override;

    static Window *getSingletonPtr();

public:
    void swapBuffer();

    int getWidth() const;

    int getHeight() const;

    glm::vec4 getViewport() const;

    glm::vec2 getDisplaySize() const;

    glm::ivec2 getDrawableSize() const;

    static const char *getClipboardText();

    static void setClipboardText(const char *text);

    void makeCurrentContext() const;

    Input *getInput();

    SDL_Window *getSDLWindow();

    SDL_GLContext getGLContext() { return m_glContext; }

    bool shouldQuit() const;

    void drawCursor(bool enabled);

    void setFullscreen(uint32_t flag);

    void toggleFullscreen();

    void *getHwnd() const;

public:
    Zelo::Core::EventSystem::Event<SDL_Event *> WindowEvent;
    Zelo::Core::EventSystem::Event<void *> PreWindowEvent; // TODO Event with no args

private:
    const INIReader::Section m_windowConfig;

    SDL_Window *m_window{};
    SDL_GLContext m_glContext{};

    int m_width{};
    int m_height{};

    Input m_input;  // window hold input

    bool m_quit{};
    bool m_fullscreen{};

    bool m_vSync{};

    std::shared_ptr<spdlog::logger> m_logger{};
};

#endif //ZELOENGINE_WINDOW_H