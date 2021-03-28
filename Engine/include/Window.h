// Window.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_WINDOW_H
#define ZELOENGINE_WINDOW_H

#include "ZeloPrerequisites.h"
#include <glm/glm.hpp>
#include <SDL.h>

#if _WIN32
#undef main
#endif

class Window {
public:
    Window();

    ~Window();

    void update();

    void swap_buffer();

    void make_current_context();

    int getWidth() const;

    int getHeight() const;

    glm::vec4 getViewport() const;

    glm::vec2 getDisplaySize() const;

    glm::vec2 getDrawableSize() const;

    const char *getClipboardText() const;

    void setClipboardText(const char *text);

    SDL_Window *getSDLWindow();

    void showCursor(bool enabled);

    bool shouldQuit() const;

    void setFullscreen(uint32_t flag);

    void toggleFullscreen();

private:
    class Impl;

    std::unique_ptr<Impl> pImpl_;
};


#endif //ZELOENGINE_WINDOW_H