// Window.h
// created on 2021/3/28
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Foundation/ZeloSingleton.h"
#include "Foundation/ZeloSDL.h"
#include "Foundation/ZeloEvent.h"

#include "Core/OS/Input.h"
#include "Core/Parser/IniReader.h"
#include "Core/Interface/IView.h"

namespace Zelo::Core::OS {
class Window :
        public Singleton<Zelo::Core::OS::Window>,
        public IRuntimeModule,
        public Zelo::Core::Interface::IView {
public:
    explicit Window(const INIReader::Section &windowConfig);

    ~Window() override;

    void initialize() override;

    void update() override;

    void finalize() override;

    static Zelo::Core::OS::Window *getSingletonPtr();

public:
    void swapBuffer();

    glm::vec4 getViewport() const;

    glm::vec2 getDisplaySize() const;

    glm::ivec2 getDrawableSize() const;

    static const char *getClipboardText();

    static void setClipboardText(const char *text);

    void makeCurrentContext() const;

    Zelo::Core::OS::Input *getInput();

    SDL_Window *getSDLWindow();

    SDL_GLContext getGLContext() { return m_glContext; }

    bool shouldQuit() const;

    void drawCursor(bool enabled);

    void setFullscreen(uint32_t flag);

    void toggleFullscreen();

    void *getHwnd() const;

public:
    Core::EventSystem::Event<SDL_Event *> WindowEvent;
    Core::EventSystem::Event<void *> PreWindowEvent; // TODO Event with no args

private:
    const INIReader::Section m_windowConfig;

    SDL_Window *m_window{};
    SDL_GLContext m_glContext{};


    Zelo::Core::OS::Input m_input;  // window hold input

    bool m_quit{};
    bool m_fullscreen{};

    bool m_vSync{};

    std::shared_ptr<spdlog::logger> m_logger{};
};
}
