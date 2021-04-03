// Window.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_WINDOW_H
#define ZELOENGINE_WINDOW_H

#include "ZeloPrerequisites.h"
#include <glm/glm.hpp>
#include <SDL.h>
#include "Input.h"
#include "GuiManager.h"

#if _WIN32
#undef main
#endif

class Window//: public IRuntimeModule
{
public:
    Window();

    ~Window();

    void initialize();

    void update();

    void swapBuffer();

    int getWidth() const;

    int getHeight() const;

    glm::vec4 getViewport() const;

    glm::vec2 getDisplaySize() const;

    glm::ivec2 getDrawableSize() const;

    GuiManager *getGuiManager() const;

    static const char *getClipboardText();

    static void setClipboardText(const char *text);

    void makeCurrentContext() const;

    Input *getInput();

    SDL_Window *getSDLWindow();

    bool shouldQuit() const;

    void drawCursor(bool enabled);

    void setFullscreen(uint32_t flag);

    void toggleFullscreen();

private:
    SDL_Window *m_window;
    SDL_GLContext m_glContext;
    std::unique_ptr<GuiManager> m_guiManager;

    int m_width{};
    int m_height{};

    Input m_input;

    bool m_quit{};
    bool m_fullscreen{};

    bool m_vSync{true};
};


#endif //ZELOENGINE_WINDOW_H