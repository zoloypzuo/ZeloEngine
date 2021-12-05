// Font.h
// created on 2021/8/21
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

struct ImFont;  // imgui

namespace Zelo::Core::UI {
class Font {
public:
    Font(const std::string &fontFilename, float fontSize);

    ImFont *getFont() const;

private:
    ImFont *m_font{};
};
}
