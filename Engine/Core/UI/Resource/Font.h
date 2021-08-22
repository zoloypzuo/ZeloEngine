// Font.h
// created on 2021/8/21
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include <imgui.h>

namespace Zelo::Core::UI {
class Font {
public:
    Font(const std::string &fontFilename, float fontSize);

    ImFont *getFont() const;

private:
    ImFont *m_font{};
};
}
