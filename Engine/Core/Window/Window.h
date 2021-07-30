// Window.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_WINDOW_H
#define ZELOENGINE_WINDOW_H

#include "ZeloPrerequisites.h"
#include "Core/Parser/IniReader.h"
#include "Core/Input/Input.h"

#if _WIN32
#undef main
#endif

class Window : public IRuntimeModule {
public:
    explicit Window(const INIReader::Section &windowConfig);

    ~Window() override;

    void initialize() override;

    void update() override;

    void finalize() override;

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

    bool shouldQuit() const;

    void drawCursor(bool enabled);

    void setFullscreen(uint32_t flag);

    void toggleFullscreen();

private:
    SDL_Window *m_window;
    SDL_GLContext m_glContext;

    int m_width{};
    int m_height{};

    Input m_input;

    bool m_quit{};
    bool m_fullscreen{};

    bool m_vSync{};
};


#endif //ZELOENGINE_WINDOW_H