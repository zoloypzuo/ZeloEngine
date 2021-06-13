// ImGuiInternal.cpp
// created on 2021/6/12
// author @zoloypzuo
#include <cstdio>
#include "Core/Resource/Resource.h"
#include "Core/ImGui/ImGuiInternal.h"
#include "Core/ImGui/ImUtil.h"
#include "ZeloPreCompiledHeader.h"

ImGuiState GImGui;

// Pass in translated ASCII characters for text input.
// - with glfw you can get those from the callback set in glfwSetCharCallback()
// - on Windows you can get those using ToAscii+keyboard state, or via the VM_CHAR message
void ImGuiIO::AddInputCharacter(char c) {
    const int n = strlen(InputCharacters);
    if (n < sizeof(InputCharacters) / sizeof(InputCharacters[0])) {
        InputCharacters[n] = c;
        InputCharacters[n + 1] = 0;
    }
}

ImGuiIO::ImGuiIO() {
    memset(this, 0, sizeof(*this));
    DeltaTime = 1.0f / 60.0f;
    IniSavingRate = 5.0f;
    IniFilename = "imgui.ini";
    LogFilename = "imgui_log.txt";
    Font = NULL;
    FontAllowScaling = false;
    MousePos = ImVec2(-1, -1);
    MousePosPrev = ImVec2(-1, -1);
    MouseDoubleClickTime = 0.30f;
    MouseDoubleClickMaxDist = 6.0f;
}

// @formatter:off
ImGuiStyle::ImGuiStyle()
{
    WindowPadding			= ImVec2(8,8);		// Padding within a window
    WindowMinSize			= ImVec2(48,48);	// Minimum window size
    FramePadding			= ImVec2(5,4);		// Padding within a framed rectangle (used by most widgets)
    ItemSpacing				= ImVec2(10,5);		// Horizontal and vertical spacing between widgets
    ItemInnerSpacing		= ImVec2(5,5);		// Horizontal and vertical spacing between within elements of a composed widget (e.g. a slider and its label)
    TouchExtraPadding		= ImVec2(0,0);		// Expand bounding box for touch-based system where touch position is not accurate enough (unnecessary for mouse inputs). Unfortunately we don't sort widgets so priority on overlap will always be given to the first widget running. So dont grow this too much!
    AutoFitPadding			= ImVec2(8,8);		// Extra space after auto-fit (double-clicking on resize grip)
    WindowFillAlphaDefault	= 0.70f;
    WindowRounding			= 10.0f;
    TreeNodeSpacing			= 22.0f;
    ColumnsMinSpacing		= 6.0f;				// Minimum space between two columns
    ScrollBarWidth			= 16.0f;

    Colors[ImGuiCol_Text]					= ImVec4(0.90f, 0.90f, 0.90f, 1.00f);
    Colors[ImGuiCol_WindowBg]				= ImVec4(0.00f, 0.00f, 0.00f, 1.00f);
    Colors[ImGuiCol_Border]					= ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
    Colors[ImGuiCol_BorderShadow]			= ImVec4(0.00f, 0.00f, 0.00f, 0.60f);
    Colors[ImGuiCol_FrameBg]				= ImVec4(0.80f, 0.80f, 0.80f, 0.30f);	// Background of checkbox, radio button, plot, slider, text input
    Colors[ImGuiCol_TitleBg]				= ImVec4(0.50f, 0.50f, 1.00f, 0.45f);
    Colors[ImGuiCol_TitleBgCollapsed]		= ImVec4(0.40f, 0.40f, 0.80f, 0.20f);
    Colors[ImGuiCol_ScrollbarBg]			= ImVec4(0.40f, 0.40f, 0.80f, 0.15f);
    Colors[ImGuiCol_ScrollbarGrab]			= ImVec4(0.40f, 0.40f, 0.80f, 0.30f);
    Colors[ImGuiCol_ScrollbarGrabHovered]	= ImVec4(0.40f, 0.40f, 0.80f, 0.40f);
    Colors[ImGuiCol_ScrollbarGrabActive]	= ImVec4(0.80f, 0.50f, 0.50f, 0.40f);
    Colors[ImGuiCol_ComboBg]				= ImVec4(0.20f, 0.20f, 0.20f, 0.99f);
    Colors[ImGuiCol_CheckActive]			= ImVec4(0.90f, 0.90f, 0.90f, 0.50f);
    Colors[ImGuiCol_SliderGrab]				= ImVec4(1.00f, 1.00f, 1.00f, 0.30f);
    Colors[ImGuiCol_SliderGrabActive]		= ImVec4(0.80f, 0.50f, 0.50f, 1.00f);
    Colors[ImGuiCol_Button]					= ImVec4(0.67f, 0.40f, 0.40f, 0.60f);
    Colors[ImGuiCol_ButtonHovered]			= ImVec4(0.60f, 0.40f, 0.40f, 1.00f);
    Colors[ImGuiCol_ButtonActive]			= ImVec4(0.80f, 0.50f, 0.50f, 1.00f);
    Colors[ImGuiCol_Header]					= ImVec4(0.40f, 0.40f, 0.90f, 0.45f);
    Colors[ImGuiCol_HeaderHovered]			= ImVec4(0.45f, 0.45f, 0.90f, 0.80f);
    Colors[ImGuiCol_HeaderActive]			= ImVec4(0.60f, 0.60f, 0.80f, 1.00f);
    Colors[ImGuiCol_Column]					= ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
    Colors[ImGuiCol_ColumnHovered]			= ImVec4(0.60f, 0.40f, 0.40f, 1.00f);
    Colors[ImGuiCol_ColumnActive]			= ImVec4(0.80f, 0.50f, 0.50f, 1.00f);
    Colors[ImGuiCol_ResizeGrip]				= ImVec4(1.00f, 1.00f, 1.00f, 0.30f);
    Colors[ImGuiCol_ResizeGripHovered]		= ImVec4(1.00f, 1.00f, 1.00f, 0.60f);
    Colors[ImGuiCol_ResizeGripActive]		= ImVec4(1.00f, 1.00f, 1.00f, 0.90f);
    Colors[ImGuiCol_CloseButton]			= ImVec4(0.50f, 0.50f, 0.90f, 0.50f);
    Colors[ImGuiCol_CloseButtonHovered]		= ImVec4(0.70f, 0.70f, 0.90f, 0.60f);
    Colors[ImGuiCol_CloseButtonActive]		= ImVec4(0.70f, 0.70f, 0.70f, 1.00f);
    Colors[ImGuiCol_PlotLines]				= ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
    Colors[ImGuiCol_PlotLinesHovered]		= ImVec4(0.90f, 0.70f, 0.00f, 1.00f);
    Colors[ImGuiCol_PlotHistogram]			= ImVec4(0.90f, 0.70f, 0.00f, 1.00f);
    Colors[ImGuiCol_PlotHistogramHovered]	= ImVec4(1.00f, 0.60f, 0.00f, 1.00f);
    Colors[ImGuiCol_TextSelectedBg]			= ImVec4(0.00f, 0.00f, 1.00f, 0.35f);
    Colors[ImGuiCol_TooltipBg]				= ImVec4(0.05f, 0.05f, 0.10f, 0.90f);
}

// @formatter:on
ImGuiWindow::ImGuiWindow(const char *name, ImVec2 default_pos, ImVec2 default_size) {
    Name = strdup(name);
    ID = GetID(name);
    IDStack.push_back(ID);

    PosFloat = default_pos;
    Pos = ImVec2((float) (int) PosFloat.x, (float) (int) PosFloat.y);
    Size = SizeFull = default_size;
    SizeContentsFit = ImVec2(0.0f, 0.0f);
    ScrollY = 0.0f;
    NextScrollY = 0.0f;
    ScrollbarY = false;
    Visible = false;
    Collapsed = false;
    AutoFitFrames = -1;
    LastFrameDrawn = -1;
    ItemWidthDefault = 0.0f;
    FontScale = 1.0f;

    if (ImLength(Size) < 0.001f)
        AutoFitFrames = 3;

    FocusIdxCounter = -1;
    FocusIdxRequestCurrent = INT_MAX;
    FocusIdxRequestNext = INT_MAX;

    DrawList = new ImDrawList();
}

ImGuiWindow::~ImGuiWindow() {
    delete DrawList;
    DrawList = NULL;
    free(Name);
    Name = NULL;
}

ImGuiID ImGuiWindow::GetID(const char *str) {
    const ImGuiID seed = IDStack.empty() ? 0 : IDStack.back();
    const ImGuiID id = crc32(str, strlen(str), seed);
    RegisterAliveId(id);
    return id;
}

ImGuiID ImGuiWindow::GetID(const void *ptr) {
    const ImGuiID seed = IDStack.empty() ? 0 : IDStack.back();
    const ImGuiID id = crc32(&ptr, sizeof(void *), seed);
    RegisterAliveId(id);
    return id;
}

bool ImGuiWindow::FocusItemRegister(bool is_active, int *out_idx) {
    FocusIdxCounter++;
    if (out_idx)
        *out_idx = FocusIdxCounter;

    ImGuiState &g = GImGui;
    ImGuiWindow *window = GetCurrentWindow();
    if (!window->DC.AllowKeyboardFocus.back())
        return false;

    // Process input at this point: TAB, Shift-TAB switch focus
    if (FocusIdxRequestNext == INT_MAX && is_active && ImGui::IsKeyPressedMap(ImGuiKey_Tab)) {
        // Modulo on index will be applied at the end of frame once we've got the total counter of items.
        FocusIdxRequestNext = FocusIdxCounter + (g.IO.KeyShift ? -1 : +1);
    }

    const bool focus_requested = (FocusIdxCounter == FocusIdxRequestCurrent);
    return focus_requested;
}

void ImGuiWindow::FocusItemUnregister() {
    FocusIdxCounter--;
}

void ImGuiWindow::AddToRenderList() {
    ImGuiState &g = GImGui;

    if (!DrawList->commands.empty() && !DrawList->vtx_buffer.empty())
        g.RenderDrawLists.push_back(DrawList);
    for (size_t i = 0; i < DC.ChildWindows.size(); i++) {
        ImGuiWindow *child = DC.ChildWindows[i];
        ZELO_ASSERT(child->Visible);    // Shouldn't be in this list if we are not active this frame
        child->AddToRenderList();
    }
}

ImU32 ImGuiWindow::Color(ImGuiCol idx, float a) const {
    ImVec4 c = GImGui.Style.Colors[idx];
    c.w *= a;
    return ImConvertColorFloat4ToU32(c);
}

ImVec2 ImGuiWindow::WindowPadding() const {
    bool flagMatch = (Flags & ImGuiWindowFlags_ChildWindow) && !(Flags & ImGuiWindowFlags_ShowBorders);
    return flagMatch ? ImVec2(1, 1) : GImGui.Style.WindowPadding;
}

float ImGuiWindow::TitleBarHeight() const {
    return (Flags & ImGuiWindowFlags_NoTitleBar) ? 0 : FontSize() + GImGui.Style.FramePadding.y * 2.0f;
}

ImGuiAabb ImGuiWindow::TitleBarAabb() const { return ImGuiAabb(Pos, Pos + ImVec2(SizeFull.x, TitleBarHeight())); }


bool ImGui::IsKeyPressedMap(ImGuiKey key, bool repeat) {
    ImGuiState &g = GImGui;
    const int key_index = g.IO.KeyMap[key];
    return ImGui::IsKeyPressed(key_index, repeat);
}

ImGuiWindow *GetCurrentWindow() {
    GImGui.CurrentWindow->Accessed = true;
    return GImGui.CurrentWindow;
}

void RegisterAliveId(const ImGuiID &id) {
    if (GImGui.ActiveId == id)
        GImGui.ActiveIdIsAlive = true;
}

void LoadSettings() {
    ImGuiState &g = GImGui;
    const char *filename = g.IO.IniFilename;
    if (!filename)
        return;

    // Load file
    FILE * f{};
    if ((f = fopen(filename, "rt")) == NULL)
        return;
    if (fseek(f, 0, SEEK_END))
        return;
    long f_size = ftell(f);
    if (f_size == -1)
        return;
    if (fseek(f, 0, SEEK_SET))
        return;
    char *f_data = new char[f_size + 1];
    f_size = fread(f_data, 1, f_size, f);    // Text conversion alter read size so let's not be fussy about return value
    fclose(f);
    if (f_size == 0) {
        delete[] f_data;
        return;
    }
    f_data[f_size] = 0;

    ImGuiIniData *settings = NULL;
    const char *buf_end = f_data + f_size;
    for (const char *line_start = f_data; line_start < buf_end;) {
        const char *line_end = line_start;
        while (line_end < buf_end && *line_end != '\n' && *line_end != '\r')
            line_end++;

        if (line_start[0] == '[' && line_end > line_start && line_end[-1] == ']') {
            char name[64];
            ImFormatString(name, ARRAYSIZE(name), "%.*s", line_end - line_start - 2, line_start + 1);
            settings = FindWindowSettings(name);
        } else if (settings) {
            float x{}, y{};
            int i{};
            if (sscanf(line_start, "Pos=%f,%f", &x, &y) == 2)
                settings->Pos = ImVec2(x, y);
            else if (sscanf(line_start, "Size=%f,%f", &x, &y) == 2)
                settings->Size = ImMax(ImVec2(x, y), g.Style.WindowMinSize);
            else if (sscanf(line_start, "Collapsed=%d", &i) == 1)
                settings->Collapsed = (i != 0);
        }

        line_start = line_end + 1;
    }

    delete[] f_data;
}

void SaveSettings() {
    ImGuiState &g = GImGui;
    const char *filename = g.IO.IniFilename;
    if (!filename)
        return;

    // Gather data from windows that were active during this session
    for (size_t i = 0; i != g.Windows.size(); i++) {
        ImGuiWindow *window = g.Windows[i];
        if (window->Flags & (ImGuiWindowFlags_ChildWindow | ImGuiWindowFlags_Tooltip))
            continue;
        ImGuiIniData *settings = FindWindowSettings(window->Name);
        settings->Pos = window->Pos;
        settings->Size = window->SizeFull;
        settings->Collapsed = window->Collapsed;
    }

    // Write .ini file
    // If a window wasn't opened in this session we preserve its settings
    FILE * f = fopen(filename, "wt");
    if (!f)
        return;
    for (size_t i = 0; i != g.Settings.size(); i++) {
        const ImGuiIniData *ini = g.Settings[i];
        fprintf(f, "[%s]\n", ini->Name);
        fprintf(f, "Pos=%d,%d\n", (int) ini->Pos.x, (int) ini->Pos.y);
        fprintf(f, "Size=%d,%d\n", (int) ini->Size.x, (int) ini->Size.y);
        fprintf(f, "Collapsed=%d\n", ini->Collapsed);
        fprintf(f, "\n");
    }

    fclose(f);
}

void MarkSettingsDirty() {
    ImGuiState &g = GImGui;

    if (g.SettingsDirtyTimer <= 0.0f)
        g.SettingsDirtyTimer = g.IO.IniSavingRate;
}

ImGuiIniData *FindWindowSettings(const char *name) {
    ImGuiState &g = GImGui;

    for (size_t i = 0; i != g.Settings.size(); i++) {
        ImGuiIniData *ini = g.Settings[i];
        if (ImStricmp(ini->Name, name) == 0)
            return ini;
    }
    auto *ini = new ImGuiIniData();
    ini->Name = _strdup(name);
    ini->Collapsed = false;
    ini->Pos = ImVec2(FLT_MAX, FLT_MAX);
    ini->Size = ImVec2(0, 0);
    g.Settings.push_back(ini);
    return ini;
}

namespace ImGui {
bool ButtonBehaviour(const ImGuiAabb &bb, const ImGuiID &id, bool *out_hovered, bool *out_held, bool repeat) {
    ImGuiState &g = GImGui;
    ImGuiWindow *window = GetCurrentWindow();

    const bool hovered = (g.HoveredWindow == window) && (g.HoveredId == 0) && ImGui::IsMouseHoveringBox(bb);
    bool pressed = false;
    if (hovered) {
        g.HoveredId = id;
        if (g.IO.MouseClicked[0]) {
            g.ActiveId = id;
        } else if (repeat && g.ActiveId && ImGui::IsMouseClicked(0, true)) {
            pressed = true;
        }
    }

    bool held = false;
    if (g.ActiveId == id) {
        if (g.IO.MouseDown[0]) {
            held = true;
        } else {
            if (hovered)
                pressed = true;
            g.ActiveId = 0;
        }
    }

    if (out_hovered) *out_hovered = hovered;
    if (out_held) *out_held = held;

    return pressed;
}

// Find the optional ## from which we stop displaying text.
const char *FindTextDisplayEnd(const char *text, const char *text_end) {
    const char *text_display_end = text;
    while ((!text_end || text_display_end < text_end) && *text_display_end != '\0' &&
           (text_display_end[0] != '#' || text_display_end[1] != '#'))
        text_display_end++;
    return text_display_end;
}

void LogText(const ImVec2 &ref_pos, const char *text, const char *text_end) {
    ImGuiState &g = GImGui;
    ImGuiWindow *window = GetCurrentWindow();

    if (!text_end)
        text_end = FindTextDisplayEnd(text, text_end);

    const bool log_new_line = ref_pos.y > window->DC.LogLineHeight + 1;
    window->DC.LogLineHeight = ref_pos.y;

    const char *text_remaining = text;
    const int tree_depth = window->DC.TreeDepth;
    while (true) {
        const char *line_end = text_remaining;
        while (line_end < text_end)
            if (*line_end == '\n')
                break;
            else
                line_end++;
        if (line_end >= text_end)
            line_end = NULL;

        bool is_first_line = (text == text_remaining);
        bool is_last_line = false;
        if (line_end == NULL) {
            is_last_line = true;
            line_end = text_end;
        }
        if (line_end != NULL && !(is_last_line && (line_end - text_remaining) == 0)) {
            const int char_count = (int) (line_end - text_remaining);
            if (g.LogFile) {
                if (log_new_line || !is_first_line)
                    fprintf(g.LogFile, "\n%*s%.*s", tree_depth * 4, "", char_count, text_remaining);
                else
                    fprintf(g.LogFile, " %.*s", char_count, text_remaining);
            } else {
                if (log_new_line || !is_first_line)
                    g.LogClipboard.Append("\n%*s%.*s", tree_depth * 4, "", char_count, text_remaining);
                else
                    g.LogClipboard.Append(" %.*s", char_count, text_remaining);
            }
        }

        if (is_last_line)
            break;
        text_remaining = line_end + 1;
    }
}

void RenderText(ImVec2 pos, const char *text, const char *text_end, const bool hide_text_after_hash) {
    ImGuiState &g = GImGui;
    ImGuiWindow *window = GetCurrentWindow();

    // Hide anything after a '##' string
    const char *text_display_end{};
    if (hide_text_after_hash) {
        text_display_end = ImGui::FindTextDisplayEnd(text, text_end);
    } else {
        if (!text_end)
            text_end = text + strlen(text);
        text_display_end = text_end;
    }

    const int text_len = (int) (text_display_end - text);
    //ZELO_ASSERT(text_len >= 0 && text_len < 10000);	// Suspicious text length
    if (text_len > 0) {
        // Render
        window->DrawList->AddText(window->Font(), window->FontSize(), pos, window->Color(ImGuiCol_Text), text,
                                  text + text_len);

        // Log as text. We split text into individual lines to add the tree level padding
        if (g.LogEnabled)
            ImGui::LogText(pos, text, text_display_end);
    }
}

void RenderFrame(ImVec2 p_min, ImVec2 p_max, ImU32 fill_col, bool border, float rounding) {
    ImGuiState &g = GImGui;
    ImGuiWindow *window = GetCurrentWindow();

    window->DrawList->AddRectFilled(p_min, p_max, fill_col, rounding);
    if (border && (window->Flags & ImGuiWindowFlags_ShowBorders)) {
        window->DrawList->AddRect(p_min + ImVec2(1, 1), p_max + ImVec2(1, 1), window->Color(ImGuiCol_BorderShadow),
                                  rounding);
        window->DrawList->AddRect(p_min, p_max, window->Color(ImGuiCol_Border), rounding);
    }
}

ImVec2 CalcTextSize(const char *text, const char *text_end, const bool hide_text_after_hash) {
    ImGuiState &g = GImGui;
    ImGuiWindow *window = GetCurrentWindow();

    const char *text_display_end;
    if (hide_text_after_hash)
        text_display_end = ImGui::FindTextDisplayEnd(text, text_end);        // Hide anything after a '##' string
    else
        text_display_end = text_end;

    const ImVec2 size = window->Font()->CalcTextSize(window->FontSize(), 0, text, text_display_end, NULL);
    return size;
}

void ItemSize(ImVec2 size, ImVec2 *adjust_start_offset) {
    ImGuiState &g = GImGui;
    ImGuiWindow *window = GetCurrentWindow();
    if (window->Collapsed)
        return;

    const float line_height = ImMax(window->DC.CurrentLineHeight, size.y);
    if (adjust_start_offset)
        adjust_start_offset->y = adjust_start_offset->y + (line_height - size.y) * 0.5f;

    // Always align ourselves on pixel boundaries
    window->DC.CursorPosPrevLine = ImVec2(window->DC.CursorPos.x + size.x, window->DC.CursorPos.y);
    window->DC.CursorPos = ImVec2((float) (int) (window->Pos.x + window->DC.ColumnStartX),
                                  (float) (int) (window->DC.CursorPos.y + line_height + g.Style.ItemSpacing.y));

    window->SizeContentsFit = ImMax(window->SizeContentsFit,
                                    ImVec2(window->DC.CursorPosPrevLine.x, window->DC.CursorPos.y) - window->Pos +
                                    ImVec2(0.0f, window->ScrollY));

    window->DC.PrevLineHeight = line_height;
    window->DC.CurrentLineHeight = 0.0f;
}

void ItemSize(const ImGuiAabb &aabb, ImVec2 *adjust_start_offset) {
    ImGui::ItemSize(aabb.GetSize(), adjust_start_offset);
}

void PushColumnClipRect(int column_index) {
    ImGuiWindow *window = GetCurrentWindow();
    if (column_index < 0)
        column_index = window->DC.ColumnCurrent;

    const float x1 = window->Pos.x + ImGui::GetColumnOffset(column_index) - 1;
    const float x2 = window->Pos.x + ImGui::GetColumnOffset(column_index + 1) - 1;
    ImGui::PushClipRect(ImVec4(x1, -FLT_MAX, x2, +FLT_MAX));
}


bool IsClipped(const ImGuiAabb &bb) {
    ImGuiState &g = GImGui;
    ImGuiWindow *window = GetCurrentWindow();

    if (!bb.Overlaps(ImGuiAabb(window->ClipRectStack.back())) && !g.LogEnabled)
        return true;
    return false;
}

bool IsClipped(ImVec2 item_size) {
    ImGuiWindow *window = GetCurrentWindow();
    return IsClipped(ImGuiAabb(window->DC.CursorPos, window->DC.CursorPos + item_size));
}

bool ClipAdvance(const ImGuiAabb &bb, bool skip_columns) {
    ImGuiWindow *window = GetCurrentWindow();
    if (ImGui::IsClipped(bb)) {
        window->DC.LastItemHovered = false;
        return true;
    }
    window->DC.LastItemHovered = ImGui::IsMouseHoveringBox(
            bb);        // this is a sensible default but widgets are free to override it after calling ClipAdvance
    return false;
}

void PushClipRect(const ImVec4 &clip_rect, bool clipped) {
    ImGuiState &g = GImGui;
    ImGuiWindow *window = GetCurrentWindow();

    ImVec4 cr = clip_rect;
    if (clipped && !window->ClipRectStack.empty()) {
        // Clip to new clip rect
        const ImVec4 cur_cr = window->ClipRectStack.back();
        cr = ImVec4(ImMax(cr.x, cur_cr.x), ImMax(cr.y, cur_cr.y), ImMin(cr.z, cur_cr.z), ImMin(cr.w, cur_cr.w));
    }

    window->ClipRectStack.push_back(cr);
    window->DrawList->PushClipRect(cr);
}

void PopClipRect() {
    ImGuiState &g = GImGui;
    ImGuiWindow *window = GetCurrentWindow();
    window->ClipRectStack.pop_back();
    window->DrawList->PopClipRect();
}

// - Box is clipped by our current clip setting
// - Expand to be generous on unprecise inputs systems (touch)
bool IsMouseHoveringBox(const ImGuiAabb &box) {
    ImGuiState &g = GImGui;
    ImGuiWindow *window = GetCurrentWindow();

    // Clip
    ImGuiAabb box_clipped = box;
    if (!window->ClipRectStack.empty()) {
        const ImVec4 clip_rect = window->ClipRectStack.back();
        box_clipped.Clip(ImGuiAabb(ImVec2(clip_rect.x, clip_rect.y), ImVec2(clip_rect.z, clip_rect.w)));
    }

    // Expand for touch input
    ImGuiAabb box_for_touch(box_clipped.Min - g.Style.TouchExtraPadding, box_clipped.Max + g.Style.TouchExtraPadding);
    return box_for_touch.Contains(g.IO.MousePos);
}

bool CloseWindowButton(bool *open) {
    ImGuiState &g = GImGui;
    ImGuiWindow *window = GetCurrentWindow();

    const ImGuiID id = window->GetID("##CLOSE");

    const float title_bar_height = window->TitleBarHeight();
    const ImGuiAabb bb(window->Aabb().GetTR() + ImVec2(-title_bar_height + 3.0f, 2.0f),
                       window->Aabb().GetTR() + ImVec2(-2.0f, +title_bar_height - 2.0f));

    bool hovered, held;
    bool pressed = ButtonBehaviour(bb, id, &hovered, &held);

    // Render
    const ImU32 col = window->Color(
            (held && hovered) ? ImGuiCol_CloseButtonActive : hovered ? ImGuiCol_CloseButtonHovered
                                                                     : ImGuiCol_CloseButton);
    window->DrawList->AddCircleFilled(bb.GetCenter(), ImMax(2.0f, title_bar_height * 0.5f - 4), col, 16);
    //RenderFrame(bb.Min, bb.Max, col, false);

    const float cross_padding = 4;
    if (hovered && bb.GetWidth() >= (cross_padding + 1) * 2 && bb.GetHeight() >= (cross_padding + 1) * 2) {
        window->DrawList->AddLine(bb.GetTL() + ImVec2(+cross_padding, +cross_padding),
                                  bb.GetBR() + ImVec2(-cross_padding, -cross_padding), window->Color(ImGuiCol_Text));
        window->DrawList->AddLine(bb.GetBL() + ImVec2(+cross_padding, -cross_padding),
                                  bb.GetTR() + ImVec2(-cross_padding, +cross_padding), window->Color(ImGuiCol_Text));
    }

    if (open != NULL && pressed)
        *open = !*open;

    return pressed;
}

void FocusWindow(ImGuiWindow *window) {
    ImGuiState &g = GImGui;
    g.FocusedWindow = window;

    // Move to front
    for (size_t i = 0; i < g.Windows.size(); i++)
        if (g.Windows[i] == window) {
            g.Windows.erase(g.Windows.begin() + i);
            break;
        }
    g.Windows.push_back(window);
}

ImGuiWindow *FindHoveredWindow(ImVec2 pos, bool excluding_children) {
    ImGuiState &g = GImGui;
    for (int i = (int) g.Windows.size() - 1; i >= 0; i--) {
        ImGuiWindow *window = g.Windows[i];
        if (!window->Visible)
            continue;
        if (excluding_children && (window->Flags & ImGuiWindowFlags_ChildWindow) != 0)
            continue;
        ImGuiAabb bb(window->Pos - g.Style.TouchExtraPadding, window->Pos + window->Size + g.Style.TouchExtraPadding);
        if (bb.Contains(pos))
            return window;
    }
    return NULL;
}
}