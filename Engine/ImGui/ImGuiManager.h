// ImGuiManager.h
// created on 2021/5/28
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "ImGui.h"

class ImGuiManager : public Singleton<ImGuiManager>, public IRuntimeModule {
public:
    ImGuiManager();

    ~ImGuiManager() override;

    void initialize() override;

    void finalize() override;

    void update() override;

    void render();

public:
    static ImGuiManager *getSingletonPtr();

public:
//    void addInputCharactersUTF8(const char *text);
//
//    void setKeyEvent(int key, bool keydown);

private:
//    void createDeviceObjects(void);
//
//    void invalidateDeviceObjects(void);

//    static void renderDrawLists(ImDrawData *draw_data);

private:
    SDL_Window *m_sdlWindow;
};


