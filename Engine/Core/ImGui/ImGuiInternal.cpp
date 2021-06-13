// ImGuiInternal.cpp
// created on 2021/6/12
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImGuiInternal.h"
#include "ImUtil.h"

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
