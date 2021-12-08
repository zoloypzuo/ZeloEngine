// IView.h
// created on 2021/12/8
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

namespace Zelo::Core::Interface {
class IView {
public:
    virtual ~IView() = default;

    int getWidth() const { return m_width; }

    int getHeight() const { return m_height; }

    void onResize(glm::ivec2 size) {
        m_width = size.x;
        m_height = size.y;
    }

protected:
    int m_width{};
    int m_height{};
};
}
