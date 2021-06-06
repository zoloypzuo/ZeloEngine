// ImGuiManager.h
// created on 2021/5/28
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Core/ImGui/ImGui.h"
#include "Core/RHI/RenderCommand.h"

#include "Renderer/OpenGL/GLSLShaderProgram.h"
#include "Renderer/OpenGL/GLTexture.h"
#include "Renderer/OpenGL/GLVertexArray.h"

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

    void renderDrawLists(ImDrawList **const draw_lists, int count);

    const char *getClipboardText();

    void setClipboardText(const char *text, const char *text_end);

private:
//    void createDeviceObjects(void);
//
//    void invalidateDeviceObjects(void);

    void initGL();

    void initImGui();

private:
    SDL_Window *m_sdlWindow{};
    std::unique_ptr<GLSLShaderProgram> m_imguiShader{};
    std::unique_ptr<GLTexture> m_imguiTex{};
    Ref<Zelo::GLVertexArray> m_imguiVAO{};
    RenderCommand * m_renderCommand{};
};


