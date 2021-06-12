// ImGuiTextFilter.cpp.cc
// created on 2021/6/12
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImGuiTextFilter.h"
#include "Core/ImGui/ImUtil.h"
#include "Core/ImGui/ImGuiInternal.h"

ImGuiTextFilter::ImGuiTextFilter() {
    InputBuf[0] = 0;
    CountGrep = 0;
}

void ImGuiTextFilter::Draw(const char *label, float width) {
    ImGuiWindow *window = GetCurrentWindow();
    if (width < 0.0f) {
        ImVec2 label_size = ImGui::CalcTextSize(label, NULL);
        width = ImMax(window->Pos.x + ImGui::GetWindowContentRegionMax().x - window->DC.CursorPos.x -
                      (label_size.x + GImGui.Style.ItemSpacing.x * 4), 10.0f);
    }
    ImGui::PushItemWidth(width);
    ImGui::InputText(label, InputBuf, ARRAYSIZE(InputBuf));
    ImGui::PopItemWidth();
    Build();
}

void ImGuiTextFilter::TextRange::split(char separator, ImVector<TextRange> &out) const {
    out.resize(0);
    const char *wb = b;
    const char *we = wb;
    while (we < e) {
        if (*we == separator) {
            out.push_back(TextRange(wb, we));
            wb = we + 1;
        }
        we++;
    }
    if (wb != we)
        out.push_back(TextRange(wb, we));
}

void ImGuiTextFilter::TextRange::trim_blanks() {
    while (b < e && isblank(*b)) b++;
    while (e > b && isblank(*(e - 1))) e--;
}

ImGuiTextFilter::TextRange::TextRange(const char *_b, const char *_e) {
    b = _b;
    e = _e;
}

ImGuiTextFilter::TextRange::TextRange() { b = e = NULL; }

void ImGuiTextFilter::Build() {
    Filters.resize(0);
    TextRange input_range(InputBuf, InputBuf + strlen(InputBuf));
    input_range.split(',', Filters);

    CountGrep = 0;
    for (size_t i = 0; i != Filters.size(); i++) {
        Filters[i].trim_blanks();
        if (Filters[i].empty())
            continue;
        if (Filters[i].front() != '-')
            CountGrep += 1;
    }
}

bool ImGuiTextFilter::PassFilter(const char *val) const {
    if (Filters.empty())
        return true;

    if (val == NULL)
        val = "";

    for (size_t i = 0; i != Filters.size(); i++) {
        const TextRange &f = Filters[i];
        if (f.empty())
            continue;
        if (f.front() == '-') {
            // Subtract
            if (ImStristr(val, f.begin() + 1, f.end()) != NULL)
                return false;
        } else {
            // Grep
            if (ImStristr(val, f.begin(), f.end()) != NULL)
                return true;
        }
    }

    // Implicit * grep
    if (CountGrep == 0)
        return true;

    return false;
}
