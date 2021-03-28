// Window.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_WINDOW_H
#define ZELOENGINE_WINDOW_H

#include "ZeloPrerequisites.h"

class Window : IRuntimeModule {
public:
    Window();

    ~Window() override;

    void initialize() override;

    void finalize() override;

    void update() override;

    void swap_buffer();

    void make_current_context();

    void drawCursor();

    int getWidth() const;
    int getHeight() const;
    glm::vec4 getViewport() const;
    glm::vec2 getDisplaySize() const;
    glm::vec2 getDrawableSize() const;
    const char* getClipboardText() const;
    void setClipboardText(const char* text);
    SDL_Window* getSDLWindow();
    bool shouldQuit() const;
    void setFullscreen(uint32_t flag);
    void toggleFullscreen();

};


#endif //ZELOENGINE_WINDOW_H