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

public:
    static ImGuiManager *getSingletonPtr();

public:
    ImGui *getImGui() { return m_imgui.get(); }

private:
    std::unique_ptr<ImGui> m_imgui;
};


