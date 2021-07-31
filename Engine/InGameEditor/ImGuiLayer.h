#pragma once

#include "ZeloPrerequisites.h"

namespace Zelo {

class ImGuiLayer {
public:
    ImGuiLayer();

    ~ImGuiLayer() = default;

    virtual void OnAttach();

    virtual void OnDetach();

//    void OnEvent(Event &e) override;

    void Begin();

    void End();

    void BlockEvents(bool block) { m_BlockEvents = block; }

    void SetDarkThemeColors();

private:
    bool m_BlockEvents = true;
    float m_Time = 0.0f;
};

}
