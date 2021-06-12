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
