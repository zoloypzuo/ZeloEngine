// Font.cpp
// created on 2021/8/21
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Font.h"
#include <imgui.h>
#include "Core/Resource/Resource.h"

using namespace Zelo::Core::UI;

Font::Font(const std::string &fontFilename, float fontSize) {
    Resource res(fontFilename);
    void *fontData = res.readCopy();
    int fontDataSize = static_cast<int>(res.getFileSize());
    ImGui::GetIO().Fonts->AddFontFromMemoryTTF(fontData, fontDataSize, fontSize);
}
