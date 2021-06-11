// ImGui.cpp
// created on 2021/5/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImGui.h"
#include "ImWidget.h"
#include "ImUtil.h"
#include "ImGuiAabb.h"
#include "Core/Resource/Resource.h"

// @formatter:off

//-------------------------------------------------------------------------
// Forward Declarations
//-------------------------------------------------------------------------

namespace ImGui
{

static bool			ButtonBehaviour(const ImGuiAabb& bb, const ImGuiID& id, bool* out_hovered = NULL, bool* out_held = NULL, bool repeat = false);
static void			RenderFrame(ImVec2 p_min, ImVec2 p_max, ImU32 fill_col, bool border = true, float rounding = 0.0f);
static void			RenderText(ImVec2 pos, const char* text, const char* text_end = NULL, bool hide_text_after_hash = true);
static ImVec2		CalcTextSize(const char* text, const char* text_end = NULL, bool hide_text_after_hash = true);
static void			LogText(const ImVec2& ref_pos, const char* text, const char* text_end = NULL);

static void			ItemSize(ImVec2 size, ImVec2* adjust_start_offset = NULL);
static void			ItemSize(const ImGuiAabb& aabb, ImVec2* adjust_start_offset = NULL);
static void			PushColumnClipRect(int column_index = -1);
static bool			IsClipped(const ImGuiAabb& aabb);
static bool			ClipAdvance(const ImGuiAabb& aabb, bool skip_columns = false);

static bool			IsMouseHoveringBox(const ImGuiAabb& box);
static bool			IsKeyPressedMap(ImGuiKey key, bool repeat = true);

static bool			CloseWindowButton(bool* open = NULL);
static void			FocusWindow(ImGuiWindow* window);
static ImGuiWindow* FindHoveredWindow(ImVec2 pos, bool excluding_childs);

}; // namespace ImGui

struct ImGuiColMod	// Color/style modifier, backup of modified data so we can restore it
{
    ImGuiCol	Col;
    ImVec4		PreviousValue;
};

// Temporary per-window data, reset at the beginning of the frame
struct ImGuiDrawContext
{
    ImVec2					CursorPos{};
    ImVec2					CursorPosPrevLine{};
    ImVec2					CursorStartPos{};
    float					CurrentLineHeight;
    float					PrevLineHeight;
    float					LogLineHeight;
    int						TreeDepth;
    bool					LastItemHovered;
    ImVector<ImGuiWindow*>	ChildWindows;
    ImVector<bool>			AllowKeyboardFocus;
    ImVector<float>			ItemWidth;
    ImVector<ImGuiColMod>	ColorModifiers;
    ImGuiColorEditMode		ColorEditMode{};
    ImGuiStorage*			StateStorage;
    int						OpenNextNode;

    float					ColumnStartX;
    int						ColumnCurrent;
    int						ColumnsCount;
    bool					ColumnsShowBorders;
    ImVec2					ColumnsStartCursorPos{};
    ImGuiID					ColumnsSetID{};

    ImGuiDrawContext()
    {
        CursorPos = CursorPosPrevLine = CursorStartPos = ImVec2(0.0f, 0.0f);
        CurrentLineHeight = PrevLineHeight = 0.0f;
        LogLineHeight = -1.0f;
        TreeDepth = 0;
        LastItemHovered = false;
        StateStorage = NULL;
        OpenNextNode = -1;

        ColumnStartX = 0.0f;
        ColumnCurrent = 0;
        ColumnsCount = 1;
        ColumnsShowBorders = true;
        ColumnsStartCursorPos = ImVec2(0,0);
    }
};

struct ImGuiTextEditState;
#define STB_TEXTEDIT_STRING	ImGuiTextEditState
#define STB_TEXTEDIT_CHARTYPE char
#include "stb_textedit.h"

// State of the currently focused/edited text input box
struct ImGuiTextEditState
{
    char				Text[1024]{};						// edit buffer, we need to persist but can't guarantee the persistence of the user-provided buffer. so own buffer.
    char				InitialText[1024]{};				// backup of end-user buffer at focusing time, to ESC key can do a revert. Also used for arithmetic operations (but could use a pre-parsed float there).
    int					MaxLength{};						// end-user buffer size <= 1024 (or increase above)
    float				Width{};							// widget width
    float				ScrollX{};
    STB_TexteditState	StbState{};
    float				CursorAnim{};
    bool				SelectedAllMouseLock{};
    ImFont				Font{};
    float				FontSize{};

    ImGuiTextEditState()								{ memset(this, 0, sizeof(*this)); }

    void				CursorAnimReset()				{ CursorAnim = -0.30f; }												// After a user-input the cursor stays on for a while without blinking
    bool				CursorIsVisible() const			{ return CursorAnim <= 0.0f || fmodf(CursorAnim, 1.20f) <= 0.80f; }		// Blinking
    bool				HasSelection() const			{ return StbState.select_start != StbState.select_end; }
    void				SelectAll()						{ StbState.select_start = 0; StbState.select_end = strlen(Text); StbState.cursor = StbState.select_end; StbState.has_preferred_x = false; }

    void				OnKeyboardPressed(int key);
    void 				UpdateScrollOffset();
    ImVec2				CalcDisplayOffsetFromCharIdx(int i) const;

    // Static functions because they are used to render non-focused instances of a text input box
    static const char*	GetTextPointerClipped(ImFont font, float font_size, const char* text, float width, ImVec2* out_text_size = NULL);
    static void			RenderTextScrolledClipped(ImFont font, float font_size, const char* buf, ImVec2 pos_base, float width, float scroll_x);
};

struct ImGuiIniData
{
    char*	Name{};
    ImVec2	Pos{};
    ImVec2	Size{};
    bool	Collapsed{};

    ImGuiIniData() { memset(this, 0, sizeof(*this)); }
    ~ImGuiIniData() { if (Name) { free(Name); Name = NULL; } }
};

struct ImGuiState
{
    bool					Initialized;
    ImGuiIO					IO;
    ImGuiStyle				Style;
    float					Time;
    int						FrameCount;
    int						FrameCountRendered;
    ImVector<ImGuiWindow*>	Windows;
    ImGuiWindow*			CurrentWindow;						// Being drawn into
    ImVector<ImGuiWindow*>	CurrentWindowStack;
    ImGuiWindow*			FocusedWindow;						// Will catch keyboard inputs
    ImGuiWindow*			HoveredWindow;						// Will catch mouse inputs
    ImGuiWindow*			HoveredWindowExcludingChilds;		// Will catch mouse inputs (for focus/move only)
    ImGuiID					HoveredId{};
    ImGuiID					ActiveId{};
    ImGuiID					ActiveIdPreviousFrame{};
    bool					ActiveIdIsAlive;
    float					SettingsDirtyTimer;
    ImVector<ImGuiIniData*>	Settings;
    ImVec2					NewWindowDefaultPos{};

    // Render
    ImVector<ImDrawList*>	RenderDrawLists;

    // Widget state
    ImGuiTextEditState		InputTextState;
    ImGuiID					SliderAsInputTextId;
    ImGuiStorage			ColorEditModeStorage;				// for user selection
    ImGuiID					ActiveComboID;
    char					Tooltip[1024]{};

    // Logging
    bool					LogEnabled;
    FILE*					LogFile;
    ImGuiTextBuffer			LogClipboard;
    int						LogAutoExpandMaxDepth;

    ImGuiState()
    {
        Initialized = false;
        Time = 0.0f;
        FrameCount = 0;
        FrameCountRendered = -1;
        CurrentWindow = NULL;
        FocusedWindow = NULL;
        HoveredWindow = NULL;
        HoveredWindowExcludingChilds = NULL;
        ActiveIdIsAlive = false;
        SettingsDirtyTimer = 0.0f;
        NewWindowDefaultPos = ImVec2(60, 60);
        SliderAsInputTextId = 0;
        ActiveComboID = 0;
        memset(Tooltip, 0, sizeof(Tooltip));
        LogEnabled = false;
        LogFile = NULL;
        LogAutoExpandMaxDepth = 2;
    }
};

static ImGuiState	GImGui;

struct ImGuiWindow
{
    char*					Name;
    ImGuiID					ID;
    ImGuiWindowFlags		Flags{};
    ImVec2					PosFloat{};
    ImVec2					Pos{};								// Position rounded-up to nearest pixel
    ImVec2					Size{};								// Current size (==SizeFull or collapsed title bar size)
    ImVec2					SizeFull{};							// Size when non collapsed
    ImVec2					SizeContentsFit{};					// Size of contents (extents reach by the drawing cursor) - may not fit within Size.
    float					ScrollY;
    float					NextScrollY;
    bool					ScrollbarY;
    bool					Visible;
    bool					Collapsed;
    bool					Accessed{};
    int						AutoFitFrames;

    ImGuiDrawContext		DC;
    ImVector<ImGuiID>		IDStack;
    ImVector<ImVec4>		ClipRectStack;
    int						LastFrameDrawn;
    float					ItemWidthDefault;
    ImGuiStorage			StateStorage;
    float					FontScale;

    int						FocusIdxCounter;					// Start at -1 and increase as assigned via FocusItemRegister()
    int						FocusIdxRequestCurrent;				// Item being requested for focus, rely on layout to be stable between the frame pressing TAB and the next frame
    int						FocusIdxRequestNext;				// Item being requested for focus, for next update

    ImDrawList*				DrawList;

public:
    ImGuiWindow(const char* name, ImVec2 default_pos, ImVec2 default_size);
    ~ImGuiWindow();

    ImGuiID		GetID(const char* str);
    ImGuiID		GetID(const void* ptr);

    void		AddToRenderList();
    bool		FocusItemRegister(bool is_active, int* out_idx = NULL);	// Return TRUE if focus is requested
    void		FocusItemUnregister();

    ImGuiAabb	Aabb() const							{ return ImGuiAabb(Pos, Pos+Size); }
    ImFont		Font() const							{ return GImGui.IO.Font; }
    float		FontSize() const						{ return GImGui.IO.FontHeight * FontScale; }
    ImVec2		CursorPos() const						{ return DC.CursorPos; }
    float		TitleBarHeight() const					{ return (Flags & ImGuiWindowFlags_NoTitleBar) ? 0 : FontSize() + GImGui.Style.FramePadding.y * 2.0f; }
    ImGuiAabb	TitleBarAabb() const					{ return ImGuiAabb(Pos, Pos + ImVec2(SizeFull.x, TitleBarHeight())); }
    ImVec2		WindowPadding() const					{ return ((Flags & ImGuiWindowFlags_ChildWindow) && !(Flags & ImGuiWindowFlags_ShowBorders)) ? ImVec2(1,1) : GImGui.Style.WindowPadding; }
    ImU32		Color(ImGuiCol idx, float a=1.f) const	{ ImVec4 c = GImGui.Style.Colors[idx]; c.w *= a; return ImConvertColorFloat4ToU32(c); }
};

static ImGuiWindow*	GetCurrentWindow()
{
    GImGui.CurrentWindow->Accessed = true;
    return GImGui.CurrentWindow;
}

static void RegisterAliveId(const ImGuiID& id)
{
    if (GImGui.ActiveId == id)
        GImGui.ActiveIdIsAlive = true;
}

//-----------------------------------------------------------------------------
// User facing structures
//-----------------------------------------------------------------------------

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

ImGuiIO::ImGuiIO()
{
    memset(this, 0, sizeof(*this));
    DeltaTime = 1.0f/60.0f;
    IniSavingRate = 5.0f;
    IniFilename = "imgui.ini";
    LogFilename = "imgui_log.txt";
    Font = NULL;
    FontAllowScaling = false;
    MousePos = ImVec2(-1,-1);
    MousePosPrev = ImVec2(-1,-1);
    MouseDoubleClickTime = 0.30f;
    MouseDoubleClickMaxDist = 6.0f;
}

// Pass in translated ASCII characters for text input.
// - with glfw you can get those from the callback set in glfwSetCharCallback()
// - on Windows you can get those using ToAscii+keyboard state, or via the VM_CHAR message
void ImGuiIO::AddInputCharacter(char c)
{
    const int n = strlen(InputCharacters);
    if (n < sizeof(InputCharacters) / sizeof(InputCharacters[0]))
    {
        InputCharacters[n] = c;
        InputCharacters[n+1] = 0;
    }
}

//-----------------------------------------------------------------------------

void ImGuiStorage::Clear()
{
    Data.clear();
}

// std::lower_bound but without the bullshit
static ImVector<ImGuiStorage::Pair>::iterator LowerBound(ImVector<ImGuiStorage::Pair>& data, ImU32 key)
{
    ImVector<ImGuiStorage::Pair>::iterator first = data.begin();
    ImVector<ImGuiStorage::Pair>::iterator last = data.end();
    int count = last - first;
    while (count > 0)
    {
        int count2 = count / 2;
        ImVector<ImGuiStorage::Pair>::iterator mid = first + count2;
        if (mid->key < key)
        {
            first = ++mid;
            count -= count2 + 1;
        }
        else
        {
            count = count2;
        }
    }
    return first;
}

int* ImGuiStorage::Find(ImU32 key)
{
    ImVector<Pair>::iterator it = LowerBound(Data, key);
    if (it == Data.end())
        return NULL;
    if (it->key != key)
        return NULL;
    return &it->val;
}

int ImGuiStorage::GetInt(ImU32 key, int default_val)
{
    int* pval = Find(key);
    if (!pval)
        return default_val;
    return *pval;
}

// FIXME-OPT: We are wasting time because all SetInt() are preceeded by GetInt() calls so we should have the result from lower_bound already in place.
// However we only use SetInt() on explicit user action (so that's maximum once a frame) so the optimisation isn't much needed.
void ImGuiStorage::SetInt(ImU32 key, int val)
{
    ImVector<Pair>::iterator it = LowerBound(Data, key);
    if (it != Data.end() && it->key == key)
    {
        it->val = val;
    }
    else
    {
        Pair pair_key{};
        pair_key.key = key;
        pair_key.val = val;
        Data.insert(it, pair_key);
    }
}

void ImGuiStorage::SetAllInt(int v)
{
    for (size_t i = 0; i < Data.size(); i++)
        Data[i].val = v;
}

//-----------------------------------------------------------------------------

ImGuiTextFilter::ImGuiTextFilter()
{
    InputBuf[0] = 0;
    CountGrep = 0;
}

void ImGuiTextFilter::Draw(const char* label, float width)
{
    ImGuiWindow* window = GetCurrentWindow();
    if (width < 0.0f)
    {
        ImVec2 label_size = ImGui::CalcTextSize(label, NULL);
        width = ImMax(window->Pos.x + ImGui::GetWindowContentRegionMax().x - window->DC.CursorPos.x - (label_size.x + GImGui.Style.ItemSpacing.x*4), 10.0f);
    }
    ImGui::PushItemWidth(width);
    ImGui::InputText(label, InputBuf, ARRAYSIZE(InputBuf));
    ImGui::PopItemWidth();
    Build();
}

void ImGuiTextFilter::TextRange::split(char separator, ImVector<TextRange>& out)
{
    out.resize(0);
    const char* wb = b;
    const char* we = wb;
    while (we < e)
    {
        if (*we == separator)
        {
            out.push_back(TextRange(wb, we));
            wb = we + 1;
        }
        we++;
    }
    if (wb != we)
        out.push_back(TextRange(wb, we));
}

void ImGuiTextFilter::Build()
{
    Filters.resize(0);
    TextRange input_range(InputBuf, InputBuf+strlen(InputBuf));
    input_range.split(',', Filters);

    CountGrep = 0;
    for (size_t i = 0; i != Filters.size(); i++)
    {
        Filters[i].trim_blanks();
        if (Filters[i].empty())
            continue;
        if (Filters[i].front() != '-')
            CountGrep += 1;
    }
}

bool ImGuiTextFilter::PassFilter(const char* val) const
{
    if (Filters.empty())
        return true;

    if (val == NULL)
        val = "";

    for (size_t i = 0; i != Filters.size(); i++)
    {
        const TextRange& f = Filters[i];
        if (f.empty())
            continue;
        if (f.front() == '-')
        {
            // Subtract
            if (ImStristr(val, f.begin()+1, f.end()) != NULL)
                return false;
        }
        else
        {
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

//-----------------------------------------------------------------------------

void ImGuiTextBuffer::Append(const char* fmt, ...)
{
    va_list args;
            va_start(args, fmt);
    int len = vsnprintf(NULL, 0, fmt, args);
            va_end(args);

    const size_t write_off = Buf.size();
    if (write_off + len >= Buf.capacity())
        Buf.reserve(Buf.capacity() * 2);

    Buf.resize(write_off + len);

            va_start(args, fmt);
    ImFormatStringV(&Buf[write_off] - 1, len+1, fmt, args);
            va_end(args);
}

//-----------------------------------------------------------------------------

ImGuiWindow::ImGuiWindow(const char* name, ImVec2 default_pos, ImVec2 default_size)
{
    Name = strdup(name);
    ID = GetID(name);
    IDStack.push_back(ID);

    PosFloat = default_pos;
    Pos = ImVec2((float)(int)PosFloat.x, (float)(int)PosFloat.y);
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

ImGuiWindow::~ImGuiWindow()
{
    delete DrawList;
    DrawList = NULL;
    free(Name);
    Name = NULL;
}

ImGuiID ImGuiWindow::GetID(const char* str)
{
    const ImGuiID seed = IDStack.empty() ? 0 : IDStack.back();
    const ImGuiID id = crc32(str, strlen(str), seed);
    RegisterAliveId(id);
    return id;
}

ImGuiID ImGuiWindow::GetID(const void* ptr)
{
    const ImGuiID seed = IDStack.empty() ? 0 : IDStack.back();
    const ImGuiID id = crc32(&ptr, sizeof(void*), seed);
    RegisterAliveId(id);
    return id;
}

bool ImGuiWindow::FocusItemRegister(bool is_active, int* out_idx)
{
    FocusIdxCounter++;
    if (out_idx)
        *out_idx = FocusIdxCounter;

    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (!window->DC.AllowKeyboardFocus.back())
        return false;

    // Process input at this point: TAB, Shift-TAB switch focus
    if (FocusIdxRequestNext == INT_MAX && is_active && ImGui::IsKeyPressedMap(ImGuiKey_Tab))
    {
        // Modulo on index will be applied at the end of frame once we've got the total counter of items.
        FocusIdxRequestNext = FocusIdxCounter + (g.IO.KeyShift ? -1 : +1);
    }

    const bool focus_requested = (FocusIdxCounter == FocusIdxRequestCurrent);
    return focus_requested;
}

void ImGuiWindow::FocusItemUnregister()
{
    FocusIdxCounter--;
}

void ImGuiWindow::AddToRenderList()
{
    ImGuiState& g = GImGui;

    if (!DrawList->commands.empty() && !DrawList->vtx_buffer.empty())
        g.RenderDrawLists.push_back(DrawList);
    for (size_t i = 0; i < DC.ChildWindows.size(); i++)
    {
        ImGuiWindow* child = DC.ChildWindows[i];
        ZELO_ASSERT(child->Visible);	// Shouldn't be in this list if we are not active this frame
        child->AddToRenderList();
    }
}

//-----------------------------------------------------------------------------

namespace ImGui
{

static ImGuiIniData* FindWindowSettings(const char* name)
{
    ImGuiState& g = GImGui;

    for (size_t i = 0; i != g.Settings.size(); i++)
    {
        ImGuiIniData* ini = g.Settings[i];
        if (ImStricmp(ini->Name, name) == 0)
            return ini;
    }
    ImGuiIniData* ini = new ImGuiIniData();
    ini->Name = strdup(name);
    ini->Collapsed = false;
    ini->Pos = ImVec2(FLT_MAX,FLT_MAX);
    ini->Size = ImVec2(0,0);
    g.Settings.push_back(ini);
    return ini;
}

// Zero-tolerance, poor-man .ini parsing
// FIXME: Write something less rubbish
static void LoadSettings()
{
    ImGuiState& g = GImGui;
    const char* filename = g.IO.IniFilename;
    if (!filename)
        return;

    // Load file
    FILE* f;
    if ((f = fopen(filename, "rt")) == NULL)
        return;
    if (fseek(f, 0, SEEK_END))
        return;
    long f_size = ftell(f);
    if (f_size == -1)
        return;
    if (fseek(f, 0, SEEK_SET))
        return;
    char* f_data = new char[f_size+1];
    f_size = fread(f_data, 1, f_size, f);	// Text conversion alter read size so let's not be fussy about return value
    fclose(f);
    if (f_size == 0)
    {
        delete[] f_data;
        return;
    }
    f_data[f_size] = 0;

    ImGuiIniData* settings = NULL;
    const char* buf_end = f_data + f_size;
    for (const char* line_start = f_data; line_start < buf_end; )
    {
        const char* line_end = line_start;
        while (line_end < buf_end && *line_end != '\n' && *line_end != '\r')
            line_end++;

        if (line_start[0] == '[' && line_end > line_start && line_end[-1] == ']')
        {
            char name[64];
            ImFormatString(name, ARRAYSIZE(name), "%.*s", line_end-line_start-2, line_start+1);
            settings = FindWindowSettings(name);
        }
        else if (settings)
        {
            float x, y;
            int i;
            if (sscanf(line_start, "Pos=%f,%f", &x, &y) == 2)
                settings->Pos = ImVec2(x, y);
            else if (sscanf(line_start, "Size=%f,%f", &x, &y) == 2)
                settings->Size = ImMax(ImVec2(x, y), g.Style.WindowMinSize);
            else if (sscanf(line_start, "Collapsed=%d", &i) == 1)
                settings->Collapsed = (i != 0);
        }

        line_start = line_end+1;
    }

    delete[] f_data;
}

static void SaveSettings()
{
    ImGuiState& g = GImGui;
    const char* filename = g.IO.IniFilename;
    if (!filename)
        return;

    // Gather data from windows that were active during this session
    for (size_t i = 0; i != g.Windows.size(); i++)
    {
        ImGuiWindow* window = g.Windows[i];
        if (window->Flags & (ImGuiWindowFlags_ChildWindow | ImGuiWindowFlags_Tooltip))
            continue;
        ImGuiIniData* settings = FindWindowSettings(window->Name);
        settings->Pos = window->Pos;
        settings->Size = window->SizeFull;
        settings->Collapsed = window->Collapsed;
    }

    // Write .ini file
    // If a window wasn't opened in this session we preserve its settings
    FILE* f = fopen(filename, "wt");
    if (!f)
        return;
    for (size_t i = 0; i != g.Settings.size(); i++)
    {
        const ImGuiIniData* ini = g.Settings[i];
        fprintf(f, "[%s]\n", ini->Name);
        fprintf(f, "Pos=%d,%d\n", (int)ini->Pos.x, (int)ini->Pos.y);
        fprintf(f, "Size=%d,%d\n", (int)ini->Size.x, (int)ini->Size.y);
        fprintf(f, "Collapsed=%d\n", ini->Collapsed);
        fprintf(f, "\n");
    }

    fclose(f);
}

static void MarkSettingsDirty()
{
    ImGuiState& g = GImGui;

    if (g.SettingsDirtyTimer <= 0.0f)
        g.SettingsDirtyTimer = g.IO.IniSavingRate;
}

ImGuiIO& GetIO()
{
    return GImGui.IO;
}

ImGuiStyle& GetStyle()
{
    return GImGui.Style;
}

void NewFrame()
{
    ImGuiState& g = GImGui;

    // Check user inputs
    ZELO_ASSERT(g.IO.DeltaTime > 0.0f);
    ZELO_ASSERT(g.IO.DisplaySize.x > 0.0f && g.IO.DisplaySize.y > 0.0f);
    ZELO_ASSERT(g.IO.RenderDrawListsFn != NULL);	// Must be implemented

    if (!g.Initialized)
    {
        // Initialize on first frame
        ZELO_ASSERT(g.Settings.empty());
        LoadSettings();
        if (!g.IO.Font)
        {
            // Default font
            const void* fnt_data;
            unsigned int fnt_size;
            ImGui::GetDefaultFontData(&fnt_data, &fnt_size, NULL, NULL);
            g.IO.Font = new ImBitmapFont();
            g.IO.Font->LoadFromMemory(fnt_data, fnt_size);
            g.IO.FontHeight = g.IO.Font->GetFontSize();
        }
        g.Initialized = true;
    }

    g.Time += g.IO.DeltaTime;
    g.FrameCount += 1;
    g.Tooltip[0] = '\0';

    // Update inputs state
    if (g.IO.MousePos.x < 0 && g.IO.MousePos.y < 0)
        g.IO.MousePos = ImVec2(-9999.0f, -9999.0f);
    if ((g.IO.MousePos.x < 0 && g.IO.MousePos.y < 0) || (g.IO.MousePosPrev.x < 0 && g.IO.MousePosPrev.y < 0))	// if mouse just appeared or disappeared (negative coordinate) we cancel out movement in MouseDelta
        g.IO.MouseDelta = ImVec2(0.0f, 0.0f);
    else
        g.IO.MouseDelta = g.IO.MousePos - g.IO.MousePosPrev;
    g.IO.MousePosPrev = g.IO.MousePos;
    for (int i = 0; i < ARRAYSIZE(g.IO.MouseDown); i++)
    {
        g.IO.MouseDownTime[i] = g.IO.MouseDown[i] ? (g.IO.MouseDownTime[i] < 0.0f ? 0.0f : g.IO.MouseDownTime[i] + g.IO.DeltaTime) : -1.0f;
        g.IO.MouseClicked[i] = (g.IO.MouseDownTime[i] == 0.0f);
        g.IO.MouseDoubleClicked[i] = false;
        if (g.IO.MouseClicked[i])
        {
            if (g.Time - g.IO.MouseClickedTime[i] < g.IO.MouseDoubleClickTime)
            {
                if (ImLength(g.IO.MousePos - g.IO.MouseClickedPos[i]) < g.IO.MouseDoubleClickMaxDist)
                    g.IO.MouseDoubleClicked[i] = true;
                g.IO.MouseClickedTime[i] = -FLT_MAX;	// so the third click isn't turned into a double-click
            }
            else
            {
                g.IO.MouseClickedTime[i] = g.Time;
                g.IO.MouseClickedPos[i] = g.IO.MousePos;
            }
        }
    }
    for (int i = 0; i < ARRAYSIZE(g.IO.KeysDown); i++)
        g.IO.KeysDownTime[i] = g.IO.KeysDown[i] ? (g.IO.KeysDownTime[i] < 0.0f ? 0.0f : g.IO.KeysDownTime[i] + g.IO.DeltaTime) : -1.0f;

    // Clear reference to active widget if the widget isn't alive anymore
    g.HoveredId = 0;
    if (!g.ActiveIdIsAlive && g.ActiveIdPreviousFrame == g.ActiveId && g.ActiveId != 0)
        g.ActiveId = 0;
    g.ActiveIdPreviousFrame = g.ActiveId;
    g.ActiveIdIsAlive = false;

    // Delay saving settings so we don't spam disk too much
    if (g.SettingsDirtyTimer > 0.0f)
    {
        g.SettingsDirtyTimer -= g.IO.DeltaTime;
        if (g.SettingsDirtyTimer <= 0.0f)
            SaveSettings();
    }

    g.HoveredWindow = ImGui::FindHoveredWindow(g.IO.MousePos, false);
    g.HoveredWindowExcludingChilds = ImGui::FindHoveredWindow(g.IO.MousePos, true);

    // Are we snooping input?
    g.IO.WantCaptureMouse = (g.HoveredWindow != NULL) || (g.ActiveId != 0);
    g.IO.WantCaptureKeyboard = (g.ActiveId != 0);

    // Scale & Scrolling
    if (g.HoveredWindow && g.IO.MouseWheel != 0)
    {
        ImGuiWindow* window = g.HoveredWindow;
        if (g.IO.KeyCtrl)
        {
            if (g.IO.FontAllowScaling)
            {
                // Zoom / Scale window
                float new_font_scale = ImClamp(window->FontScale + g.IO.MouseWheel * 0.10f, 0.50f, 2.50f);
                float scale = new_font_scale / window->FontScale;
                window->FontScale = new_font_scale;

                ImVec2 offset = window->Size * (1.0f - scale) * (g.IO.MousePos - window->Pos) / window->Size;
                window->Pos += offset;
                window->PosFloat += offset;
                window->Size *= scale;
                window->SizeFull *= scale;
            }
        }
        else
        {
            // Scroll
            window->NextScrollY -= g.IO.MouseWheel * window->FontSize() * 5.0f;
        }
    }

    // Pressing TAB activate widget focus
    // NB: Don't discard FocusedWindow if it isn't active, so that a window that go on/off programatically won't lose its keyboard focus.
    if (g.ActiveId == 0 && g.FocusedWindow != NULL && g.FocusedWindow->Visible && IsKeyPressedMap(ImGuiKey_Tab, false))
    {
        g.FocusedWindow->FocusIdxRequestNext = 0;
    }

    // Mark all windows as not visible
    for (size_t i = 0; i != g.Windows.size(); i++)
        g.Windows[i]->Visible = false;

    // Create implicit window
    // We will only render it if the user has added something to it.
    ZELO_ASSERT(g.CurrentWindowStack.empty());	// No window should be open at the beginning of the frame!
    ImGui::Begin("Debug", NULL, ImVec2(400,400));
}

// NB: behaviour of ImGui after Shutdown() is not tested/guaranteed at the moment. This function is merely here to free heap allocations.
void Shutdown()
{
    ImGuiState& g = GImGui;
    if (!g.Initialized)
        return;

    SaveSettings();

    for (size_t i = 0; i < g.Windows.size(); i++)
        delete g.Windows[i];
    g.Windows.clear();
    g.CurrentWindowStack.clear();
    g.FocusedWindow = NULL;
    g.HoveredWindow = NULL;
    g.HoveredWindowExcludingChilds = NULL;
    for (size_t i = 0; i < g.Settings.size(); i++)
        delete g.Settings[i];
    g.Settings.clear();
    g.ColorEditModeStorage.Clear();
    if (g.LogFile && g.LogFile != stdout)
    {
        fclose(g.LogFile);
        g.LogFile = NULL;
    }
    if (g.IO.Font)
    {
        delete g.IO.Font;
        g.IO.Font = NULL;
    }

    g.Initialized = false;
}

static void AddWindowToSortedBuffer(ImGuiWindow* window, ImVector<ImGuiWindow*>& sorted_windows)
{
    sorted_windows.push_back(window);
    if (window->Visible)
    {
        for (size_t i = 0; i < window->DC.ChildWindows.size(); i++)
        {
            ImGuiWindow* child = window->DC.ChildWindows[i];
            AddWindowToSortedBuffer(child, sorted_windows);
        }
    }
}

static void PushClipRect(const ImVec4& clip_rect, bool clipped = true)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    ImVec4 cr = clip_rect;
    if (clipped && !window->ClipRectStack.empty())
    {
        // Clip to new clip rect
        const ImVec4 cur_cr = window->ClipRectStack.back();
        cr = ImVec4(ImMax(cr.x, cur_cr.x), ImMax(cr.y, cur_cr.y), ImMin(cr.z, cur_cr.z), ImMin(cr.w, cur_cr.w));
    }

    window->ClipRectStack.push_back(cr);
    window->DrawList->PushClipRect(cr);
}

static void PopClipRect()
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    window->ClipRectStack.pop_back();
    window->DrawList->PopClipRect();
}

void Render()
{
    ImGuiState& g = GImGui;
    ZELO_ASSERT(g.Initialized);						// Forgot to call ImGui::NewFrame()

    const bool first_render_of_the_frame = (g.FrameCountRendered != g.FrameCount);
    g.FrameCountRendered = g.FrameCount;

    if (first_render_of_the_frame)
    {
        // Hide implicit window if it hasn't been used
        ZELO_ASSERT(g.CurrentWindowStack.size() == 1);	// Mismatched Begin/End
        if (g.CurrentWindow && !g.CurrentWindow->Accessed)
            g.CurrentWindow->Visible = false;
        ImGui::End();

        // Sort the window list so that all child windows are after their parent
        // When cannot do that on FocusWindow() because childs may not exist yet
        ImVector<ImGuiWindow*> sorted_windows;
        sorted_windows.reserve(g.Windows.size());
        for (size_t i = 0; i != g.Windows.size(); i++)
        {
            ImGuiWindow* window = g.Windows[i];
            if (window->Flags & ImGuiWindowFlags_ChildWindow)			// if a child is visible its parent will add it
                if (window->Visible)
                    continue;
            AddWindowToSortedBuffer(window, sorted_windows);
        }
        ZELO_ASSERT(g.Windows.size() == sorted_windows.size());			// We done something wrong
        g.Windows.swap(sorted_windows);

        // Clear data for next frame
        g.IO.MouseWheel = 0;
        memset(g.IO.InputCharacters, 0, sizeof(g.IO.InputCharacters));
    }

    // Gather windows to render
    g.RenderDrawLists.resize(0);
    for (size_t i = 0; i != g.Windows.size(); i++)
    {
        ImGuiWindow* window = g.Windows[i];
        if (!window->Visible)
            continue;
        if (window->Flags & ImGuiWindowFlags_ChildWindow)
            continue;
        window->AddToRenderList();
    }

    // Render tooltip
    if (g.Tooltip[0])
    {
        // Use a dummy window to render the tooltip
        ImGui::Begin("##Tooltip", NULL, ImVec2(0,0), 0.0f, ImGuiWindowFlags_NoTitleBar|ImGuiWindowFlags_NoResize|ImGuiWindowFlags_Tooltip);
        ImGuiWindow* window = GetCurrentWindow();
        //window->DrawList->Clear();
        ImGui::PushClipRect(ImVec4(-9999,-9999,+9999,+9999), false);
        const ImVec2 text_size = CalcTextSize(g.Tooltip, NULL, false);
        const ImVec2 pos = g.IO.MousePos + ImVec2(32,16);
        const ImGuiAabb bb(pos - g.Style.FramePadding*2, pos + text_size + g.Style.FramePadding*2);
        ImGui::RenderFrame(bb.Min, bb.Max, window->Color(ImGuiCol_TooltipBg), false, g.Style.WindowRounding);
        ImGui::RenderText(pos, g.Tooltip, NULL, false);
        ImGui::PopClipRect();
        ImGui::End();
        window->AddToRenderList();
    }

    // Render
    if (!g.RenderDrawLists.empty())
        g.IO.RenderDrawListsFn(&g.RenderDrawLists[0], (int)g.RenderDrawLists.size());
    g.RenderDrawLists.resize(0);
}

// Find the optional ## from which we stop displaying text.
static const char*	FindTextDisplayEnd(const char* text, const char* text_end = NULL)
{
    const char* text_display_end = text;
    while ((!text_end || text_display_end < text_end) && *text_display_end != '\0' && (text_display_end[0] != '#' || text_display_end[1] != '#'))
        text_display_end++;
    return text_display_end;
}

static void LogText(const ImVec2& ref_pos, const char* text, const char* text_end)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    if (!text_end)
        text_end = FindTextDisplayEnd(text, text_end);

    const bool log_new_line = ref_pos.y > window->DC.LogLineHeight+1;
    window->DC.LogLineHeight = ref_pos.y;

    const char* text_remaining = text;
    const int tree_depth = window->DC.TreeDepth;
    while (true)
    {
        const char* line_end = text_remaining;
        while (line_end < text_end)
            if (*line_end == '\n')
                break;
            else
                line_end++;
        if (line_end >= text_end)
            line_end = NULL;

        bool is_first_line = (text == text_remaining);
        bool is_last_line = false;
        if (line_end == NULL)
        {
            is_last_line = true;
            line_end = text_end;
        }
        if (line_end != NULL && !(is_last_line && (line_end - text_remaining)==0))
        {
            const int char_count = (int)(line_end - text_remaining);
            if (g.LogFile)
            {
                if (log_new_line || !is_first_line)
                    fprintf(g.LogFile, "\n%*s%.*s", tree_depth*4, "", char_count, text_remaining);
                else
                    fprintf(g.LogFile, " %.*s", char_count, text_remaining);
            }
            else
            {
                if (log_new_line || !is_first_line)
                    g.LogClipboard.Append("\n%*s%.*s", tree_depth*4, "", char_count, text_remaining);
                else
                    g.LogClipboard.Append(" %.*s", char_count, text_remaining);
            }
        }

        if (is_last_line)
            break;
        text_remaining = line_end + 1;
    }
}

static void RenderText(ImVec2 pos, const char* text, const char* text_end, const bool hide_text_after_hash)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    // Hide anything after a '##' string
    const char* text_display_end;
    if (hide_text_after_hash)
    {
        text_display_end = FindTextDisplayEnd(text, text_end);
    }
    else
    {
        if (!text_end)
            text_end = text + strlen(text);
        text_display_end = text_end;
    }

    const int text_len = (int)(text_display_end - text);
    //ZELO_ASSERT(text_len >= 0 && text_len < 10000);	// Suspicious text length
    if (text_len > 0)
    {
        // Render
        window->DrawList->AddText(window->Font(), window->FontSize(), pos, window->Color(ImGuiCol_Text), text, text + text_len);

        // Log as text. We split text into individual lines to add the tree level padding
        if (g.LogEnabled)
            LogText(pos, text, text_display_end);
    }
}

static void RenderFrame(ImVec2 p_min, ImVec2 p_max, ImU32 fill_col, bool border, float rounding)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    window->DrawList->AddRectFilled(p_min, p_max, fill_col, rounding);
    if (border && (window->Flags & ImGuiWindowFlags_ShowBorders))
    {
        window->DrawList->AddRect(p_min+ImVec2(1,1), p_max+ImVec2(1,1), window->Color(ImGuiCol_BorderShadow), rounding);
        window->DrawList->AddRect(p_min, p_max, window->Color(ImGuiCol_Border), rounding);
    }
}

static void RenderCollapseTriangle(ImVec2 p_min, bool open, float scale = 1.0f, bool shadow = false)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    const float h = window->FontSize() * 1.00f;
    const float r = h * 0.40f * scale;
    ImVec2 center = p_min + ImVec2(h*0.50f, h*0.50f*scale);

    ImVec2 a, b, c;
    if (open)
    {
        center.y -= r*0.25f;
        a = center + ImVec2(0,1)*r;
        b = center + ImVec2(-0.866f,-0.5f)*r;
        c = center + ImVec2(0.866f,-0.5f)*r;
    }
    else
    {
        a = center + ImVec2(1,0)*r;
        b = center + ImVec2(-0.500f,0.866f)*r;
        c = center + ImVec2(-0.500f,-0.866f)*r;
    }

    if (shadow)
        window->DrawList->AddTriangleFilled(a+ImVec2(2,2), b+ImVec2(2,2), c+ImVec2(2,2), window->Color(ImGuiCol_BorderShadow));
    window->DrawList->AddTriangleFilled(a, b, c, window->Color(ImGuiCol_Border));
}

static ImVec2 CalcTextSize(const char* text, const char* text_end, const bool hide_text_after_hash)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    const char* text_display_end;
    if (hide_text_after_hash)
        text_display_end = FindTextDisplayEnd(text, text_end);		// Hide anything after a '##' string
    else
        text_display_end = text_end;

    const ImVec2 size = window->Font()->CalcTextSize(window->FontSize(), 0, text, text_display_end, NULL);
    return size;
}

static ImGuiWindow* FindHoveredWindow(ImVec2 pos, bool excluding_childs)
{
    ImGuiState& g = GImGui;
    for (int i = (int)g.Windows.size()-1; i >= 0; i--)
    {
        ImGuiWindow* window = g.Windows[i];
        if (!window->Visible)
            continue;
        if (excluding_childs && (window->Flags & ImGuiWindowFlags_ChildWindow) != 0)
            continue;
        ImGuiAabb bb(window->Pos - g.Style.TouchExtraPadding, window->Pos+window->Size + g.Style.TouchExtraPadding);
        if (bb.Contains(pos))
            return window;
    }
    return NULL;
}

// - Box is clipped by our current clip setting
// - Expand to be generous on unprecise inputs systems (touch)
static bool IsMouseHoveringBox(const ImGuiAabb& box)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    // Clip
    ImGuiAabb box_clipped = box;
    if (!window->ClipRectStack.empty())
    {
        const ImVec4 clip_rect = window->ClipRectStack.back();
        box_clipped.Clip(ImGuiAabb(ImVec2(clip_rect.x, clip_rect.y), ImVec2(clip_rect.z, clip_rect.w)));
    }

    // Expand for touch input
    ImGuiAabb box_for_touch(box_clipped.Min - g.Style.TouchExtraPadding, box_clipped.Max + g.Style.TouchExtraPadding);
    return box_for_touch.Contains(g.IO.MousePos);
}

static bool IsKeyPressedMap(ImGuiKey key, bool repeat)
{
    ImGuiState& g = GImGui;
    const int key_index = g.IO.KeyMap[key];
    return IsKeyPressed(key_index, repeat);
}

bool IsKeyPressed(int key_index, bool repeat)
{
    ImGuiState& g = GImGui;
    ZELO_ASSERT(key_index >= 0 && key_index < ARRAYSIZE(g.IO.KeysDown));
    const float t = g.IO.KeysDownTime[key_index];
    if (t == 0.0f)
        return true;

    // FIXME: Repeat rate should be provided elsewhere?
    const float KEY_REPEAT_DELAY = 0.250f;
    const float KEY_REPEAT_RATE = 0.020f;
    if (repeat && t > KEY_REPEAT_DELAY)
        if ((fmodf(t - KEY_REPEAT_DELAY, KEY_REPEAT_RATE) > KEY_REPEAT_RATE*0.5f) != (fmodf(t - KEY_REPEAT_DELAY - g.IO.DeltaTime, KEY_REPEAT_RATE) > KEY_REPEAT_RATE*0.5f))
            return true;

    return false;
}

bool IsMouseClicked(int button, bool repeat)
{
    ImGuiState& g = GImGui;
    ZELO_ASSERT(button >= 0 && button < ARRAYSIZE(g.IO.MouseDown));
    const float t = g.IO.MouseDownTime[button];
    if (t == 0.0f)
        return true;

    // FIXME: Repeat rate should be provided elsewhere?
    const float MOUSE_REPEAT_DELAY = 0.250f;
    const float MOUSE_REPEAT_RATE = 0.020f;
    if (repeat && t > MOUSE_REPEAT_DELAY)
        if ((fmodf(t - MOUSE_REPEAT_DELAY, MOUSE_REPEAT_RATE) > MOUSE_REPEAT_RATE*0.5f) != (fmodf(t - MOUSE_REPEAT_DELAY - g.IO.DeltaTime, MOUSE_REPEAT_RATE) > MOUSE_REPEAT_RATE*0.5f))
            return true;

    return false;
}

ImVec2 GetMousePos()
{
    return GImGui.IO.MousePos;
}

bool IsHovered()
{
    ImGuiWindow* window = GetCurrentWindow();
    return window->DC.LastItemHovered;
}

void SetTooltip(const char* fmt, ...)
{
    ImGuiState& g = GImGui;
    va_list args;
            va_start(args, fmt);
    ImFormatStringV(g.Tooltip, ARRAYSIZE(g.Tooltip), fmt, args);
            va_end(args);
}

void SetNewWindowDefaultPos(ImVec2 pos)
{
    ImGuiState& g = GImGui;
    g.NewWindowDefaultPos = pos;
}

float GetTime()
{
    return GImGui.Time;
}

int GetFrameCount()
{
    return GImGui.FrameCount;
}

static ImGuiWindow* FindWindow(const char* name)
{
    ImGuiState& g = GImGui;
    for (size_t i = 0; i != g.Windows.size(); i++)
        if (strcmp(g.Windows[i]->Name, name) == 0)
            return g.Windows[i];
    return NULL;
}

void BeginChild(const char* str_id, ImVec2 size, bool border, ImGuiWindowFlags extra_flags)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    ImU32 flags = ImGuiWindowFlags_NoTitleBar|ImGuiWindowFlags_NoMove|ImGuiWindowFlags_NoResize|ImGuiWindowFlags_ChildWindow;

    const ImVec2 content_max = window->Pos + ImGui::GetWindowContentRegionMax();
    const ImVec2 cursor_pos = window->Pos + ImGui::GetCursorPos();
    if (size.x <= 0.0f)
    {
        size.x = ImMax(content_max.x - cursor_pos.x, g.Style.WindowMinSize.x);
        flags |= ImGuiWindowFlags_ChildWindowAutoFitX;
    }
    if (size.y <= 0.0f)
    {
        size.y = ImMax(content_max.y - cursor_pos.y, g.Style.WindowMinSize.y);
        flags |= ImGuiWindowFlags_ChildWindowAutoFitY;
    }
    if (border)
        flags |= ImGuiWindowFlags_ShowBorders;
    flags |= extra_flags;

    char title[256];
    ImFormatString(title, ARRAYSIZE(title), "%s.%s", window->Name, str_id);

    const float alpha = (flags & ImGuiWindowFlags_ComboBox) ? 1.0f : 0.0f;
    ImGui::Begin(title, NULL, size, alpha, flags);

    if (!(window->Flags & ImGuiWindowFlags_ShowBorders))
        g.CurrentWindow->Flags &= ~ImGuiWindowFlags_ShowBorders;
}

void EndChild()
{
    ImGuiWindow* window = GetCurrentWindow();

    if (window->Flags & ImGuiWindowFlags_ComboBox)
    {
        ImGui::End();
    }
    else
    {
        // When using filling child window, we don't provide the width/height to ItemSize so that it doesn't feed back into automatic fitting
        ImVec2 sz = ImGui::GetWindowSize();
        if (window->Flags & ImGuiWindowFlags_ChildWindowAutoFitX)
            sz.x = 0;
        if (window->Flags & ImGuiWindowFlags_ChildWindowAutoFitY)
            sz.y = 0;

        ImGui::End();
        ImGui::ItemSize(sz);
    }
}

bool Begin(const char* name, bool* open, ImVec2 size, float fill_alpha, ImGuiWindowFlags flags)
{
    ImGuiState& g = GImGui;
    const ImGuiStyle& style = g.Style;

    ImGuiWindow* window = FindWindow(name);
    if (!window)
    {
        if (flags & ImGuiWindowFlags_ChildWindow)
        {
            window = new ImGuiWindow(name, ImVec2(0,0), size);
        }
        else
        {
            ImGuiIniData* settings = FindWindowSettings(name);
            if (settings && ImLength(settings->Size) > 0.0f && !(flags & ImGuiWindowFlags_NoResize))// && ImLengthsize) == 0.0f)
                size = settings->Size;

            window = new ImGuiWindow(name, g.NewWindowDefaultPos, size);

            if (settings->Pos.x != FLT_MAX)
            {
                window->PosFloat = settings->Pos;
                window->Pos = ImVec2((float)(int)window->PosFloat.x, (float)(int)window->PosFloat.y);
                window->Collapsed = settings->Collapsed;
            }
        }
        g.Windows.push_back(window);
    }
    window->Flags = (ImGuiWindowFlags)flags;

    g.CurrentWindowStack.push_back(window);
    g.CurrentWindow = window;

    // Default alpha
    if (fill_alpha < 0.0f)
        fill_alpha = style.WindowFillAlphaDefault;

    // When reusing window again multiple times a frame, just append content (don't need to setup again)
    const int current_frame = ImGui::GetFrameCount();
    const bool first_begin_of_the_frame = (window->LastFrameDrawn != current_frame);
    if (first_begin_of_the_frame)
    {
        // New windows appears in front
        if (window->LastFrameDrawn < current_frame - 1)
            ImGui::FocusWindow(window);

        window->DrawList->Clear();
        window->Visible = true;
        window->LastFrameDrawn = current_frame;
        window->ClipRectStack.resize(0);

        if (flags & ImGuiWindowFlags_ChildWindow)
        {
            ImGuiWindow* parent_window = g.CurrentWindowStack[g.CurrentWindowStack.size()-2];
            parent_window->DC.ChildWindows.push_back(window);
            window->Pos = window->PosFloat = parent_window->DC.CursorPos;
            window->SizeFull = size;
            if (!(flags & ImGuiWindowFlags_ComboBox))
                ImGui::PushClipRect(parent_window->ClipRectStack.back());
        }

        // ID stack
        window->IDStack.resize(0);
        ImGui::PushID(window);

        // Move window (at the beginning of the frame)
        const ImGuiID move_id = window->GetID("#MOVE");
        RegisterAliveId(move_id);
        if (g.ActiveId == move_id)
        {
            if (g.IO.MouseDown[0])
            {
                if (!(window->Flags & ImGuiWindowFlags_NoMove))
                {
                    window->PosFloat += g.IO.MouseDelta;
                    MarkSettingsDirty();
                }
                ImGui::FocusWindow(window);
            }
            else
            {
                g.ActiveId = 0;
            }
        }

        // Clamp into view
        if (!(window->Flags & ImGuiWindowFlags_ChildWindow))
        {
            const ImVec2 pad = ImVec2(window->FontSize()*2.0f, window->FontSize()*2.0f);
            window->PosFloat = ImMax(window->PosFloat + window->Size, pad) - window->Size;
            window->PosFloat = ImMin(window->PosFloat, ImVec2(g.IO.DisplaySize.x, g.IO.DisplaySize.y) - pad);
            window->Pos = ImVec2((float)(int)window->PosFloat.x, (float)(int)window->PosFloat.y);
            window->SizeFull = ImMax(window->SizeFull, pad);
        }
        else
        {
            window->Pos = ImVec2((float)(int)window->PosFloat.x, (float)(int)window->PosFloat.y);
        }
        window->ItemWidthDefault = (float)(int)(window->Size.x > 0.0f ? window->Size.x * 0.65f : 250.0f);

        // Prepare for focus requests
        if (window->FocusIdxRequestNext == INT_MAX || window->FocusIdxCounter == -1)
        {
            window->FocusIdxRequestCurrent = INT_MAX;
        }
        else
        {
            const int mod = window->FocusIdxCounter+1;
            window->FocusIdxRequestCurrent = (window->FocusIdxRequestNext + mod) % mod;
        }
        window->FocusIdxCounter = -1;
        window->FocusIdxRequestNext = INT_MAX;

        ImGuiAabb title_bar_aabb = window->TitleBarAabb();

        // Apply and ImClamp scrolling
        window->ScrollY = window->NextScrollY;
        window->ScrollY = ImMax(window->ScrollY, 0.0f);
        if (!window->Collapsed)
            window->ScrollY = ImMin(window->ScrollY, ImMax(0.0f, (float)window->SizeContentsFit.y - window->SizeFull.y));
        window->NextScrollY = window->ScrollY;

        // NB- at this point we don't have a clipping rectangle setup yet!
        // Collapse window by double-clicking on title bar
        if (!(window->Flags & ImGuiWindowFlags_NoTitleBar))
        {
            if (g.HoveredWindow == window && IsMouseHoveringBox(title_bar_aabb) && g.IO.MouseDoubleClicked[0])
            {
                window->Collapsed = !window->Collapsed;
                MarkSettingsDirty();
                ImGui::FocusWindow(window);
            }
        }
        else
        {
            window->Collapsed = false;
        }

        if (window->Collapsed)
        {
            // Title bar only
            window->Size = title_bar_aabb.GetSize();
            window->DrawList->AddRectFilled(title_bar_aabb.GetTL(), title_bar_aabb.GetBR(), window->Color(ImGuiCol_TitleBgCollapsed), g.Style.WindowRounding);
            if (window->Flags & ImGuiWindowFlags_ShowBorders)
            {
                window->DrawList->AddRect(title_bar_aabb.GetTL()+ImVec2(1,1), title_bar_aabb.GetBR()+ImVec2(1,1), window->Color(ImGuiCol_BorderShadow), g.Style.WindowRounding);
                window->DrawList->AddRect(title_bar_aabb.GetTL(), title_bar_aabb.GetBR(), window->Color(ImGuiCol_Border), g.Style.WindowRounding);
            }
        }
        else
        {
            window->Size = window->SizeFull;

            // Draw resize grip
            ImU32 resize_col = 0;
            if (!(window->Flags & ImGuiWindowFlags_NoResize))
            {
                const ImGuiAabb resize_aabb(window->Aabb().GetBR()-ImVec2(18,18), window->Aabb().GetBR());
                const ImGuiID resize_id = window->GetID("#RESIZE");
                bool hovered, held;
                ButtonBehaviour(resize_aabb, resize_id, &hovered, &held);
                resize_col = window->Color(held ? ImGuiCol_ResizeGripActive : hovered ? ImGuiCol_ResizeGripHovered : ImGuiCol_ResizeGrip);

                const ImVec2 size_auto_fit = ImClamp(window->SizeContentsFit + style.AutoFitPadding, style.WindowMinSize, g.IO.DisplaySize - style.AutoFitPadding);
                if (window->AutoFitFrames > 0)
                {
                    // Auto-fit only grows during the first few frames
                    window->SizeFull = ImMax(window->SizeFull, size_auto_fit);
                    MarkSettingsDirty();
                }
                else if (g.HoveredWindow == window && held && g.IO.MouseDoubleClicked[0])
                {
                    // Manual auto-fit
                    window->SizeFull = size_auto_fit;
                    window->Size = window->SizeFull;
                    MarkSettingsDirty();
                }
                else if (held)
                {
                    // Resize
                    window->SizeFull = ImMax(window->SizeFull + g.IO.MouseDelta, style.WindowMinSize);
                    window->Size = window->SizeFull;
                    MarkSettingsDirty();
                }

                // Update aabb immediately so that the rendering below isn't one frame late
                title_bar_aabb = window->TitleBarAabb();
            }

            // Title bar + Window box
            if (fill_alpha > 0.0f)
            {
                if ((window->Flags & ImGuiWindowFlags_ComboBox) != 0)
                    window->DrawList->AddRectFilled(window->Pos, window->Pos+window->Size, window->Color(ImGuiCol_ComboBg, fill_alpha), 0);
                else
                    window->DrawList->AddRectFilled(window->Pos, window->Pos+window->Size, window->Color(ImGuiCol_WindowBg, fill_alpha), g.Style.WindowRounding);
            }

            if (!(window->Flags & ImGuiWindowFlags_NoTitleBar))
                window->DrawList->AddRectFilled(title_bar_aabb.GetTL(), title_bar_aabb.GetBR(), window->Color(ImGuiCol_TitleBg), g.Style.WindowRounding, 1|2);

            if (window->Flags & ImGuiWindowFlags_ShowBorders)
            {
                const float rounding = (window->Flags & ImGuiWindowFlags_ComboBox) ? 0.0f : g.Style.WindowRounding;
                window->DrawList->AddRect(window->Pos+ImVec2(1,1), window->Pos+window->Size+ImVec2(1,1), window->Color(ImGuiCol_BorderShadow), rounding);
                window->DrawList->AddRect(window->Pos, window->Pos+window->Size, window->Color(ImGuiCol_Border), rounding);
                if (!(window->Flags & ImGuiWindowFlags_NoTitleBar))
                    window->DrawList->AddLine(title_bar_aabb.GetBL(), title_bar_aabb.GetBR(), window->Color(ImGuiCol_Border));
            }

            // Scrollbar
            window->ScrollbarY = (window->SizeContentsFit.y > window->Size.y) && !(window->Flags & ImGuiWindowFlags_NoScrollbar);
            if (window->ScrollbarY)
            {
                ImGuiAabb scrollbar_bb(window->Aabb().Max.x - style.ScrollBarWidth, title_bar_aabb.Max.y+1, window->Aabb().Max.x, window->Aabb().Max.y-1);
                //window->DrawList->AddLine(scrollbar_bb.GetTL(), scrollbar_bb.GetBL(), g.Colors[ImGuiCol_Border]);
                window->DrawList->AddRectFilled(scrollbar_bb.Min, scrollbar_bb.Max, window->Color(ImGuiCol_ScrollbarBg));
                scrollbar_bb.Expand(ImVec2(-3,-3));

                const float grab_size_y_norm = ImSaturate(window->Size.y / ImMax(window->SizeContentsFit.y, window->Size.y));
                const float grab_size_y = scrollbar_bb.GetHeight() * grab_size_y_norm;

                // Handle input right away (none of the code above is relying on scrolling)
                bool held = false;
                bool hovered = false;
                if (grab_size_y_norm < 1.0f)
                {
                    const ImGuiID scrollbar_id = window->GetID("#SCROLLY");
                    ButtonBehaviour(scrollbar_bb, scrollbar_id, &hovered, &held);
                    if (held)
                    {
                        g.HoveredId = scrollbar_id;
                        const float pos_y_norm = ImSaturate((g.IO.MousePos.y - (scrollbar_bb.Min.y + grab_size_y*0.5f)) / (scrollbar_bb.GetHeight() - grab_size_y)) * (1.0f - grab_size_y_norm);
                        window->ScrollY = pos_y_norm * window->SizeContentsFit.y;
                        window->NextScrollY = window->ScrollY;
                    }
                }

                // Normalized height of the grab
                const float pos_y_norm = ImSaturate(window->ScrollY / ImMax(0.0f, window->SizeContentsFit.y));
                const ImU32 grab_col = window->Color(held ? ImGuiCol_ScrollbarGrabActive : hovered ? ImGuiCol_ScrollbarGrabHovered : ImGuiCol_ScrollbarGrab);
                window->DrawList->AddRectFilled(
                        ImVec2(scrollbar_bb.Min.x, ImLerp(scrollbar_bb.Min.y, scrollbar_bb.Max.y, pos_y_norm)),
                        ImVec2(scrollbar_bb.Max.x, ImLerp(scrollbar_bb.Min.y, scrollbar_bb.Max.y, pos_y_norm + grab_size_y_norm)), grab_col);
            }

            // Render resize grip
            // (after the input handling so we don't have a frame of latency)
            if (!(window->Flags & ImGuiWindowFlags_NoResize))
            {
                const float r = style.WindowRounding;
                const ImVec2 br = window->Aabb().GetBR();
                if (r == 0.0f)
                {
                    window->DrawList->AddTriangleFilled(br, br-ImVec2(0,14), br-ImVec2(14,0), resize_col);
                }
                else
                {
                    // FIXME: We should draw 4 triangles and decide on a size that's not dependant on the rounding size (previously used 18)
                    window->DrawList->AddArc(br - ImVec2(r,r), r, resize_col, 6, 9, true);
                    window->DrawList->AddTriangleFilled(br+ImVec2(0,-2*r),br+ImVec2(0,-r),br+ImVec2(-r,-r), resize_col);
                    window->DrawList->AddTriangleFilled(br+ImVec2(-r,-r), br+ImVec2(-r,0),br+ImVec2(-2*r,0), resize_col);
                }
            }
        }

        // Setup drawing context
        window->DC.ColumnStartX = window->WindowPadding().x;
        window->DC.CursorStartPos = window->Pos + ImVec2(window->DC.ColumnStartX, window->TitleBarHeight() + window->WindowPadding().y) - ImVec2(0.0f, window->ScrollY);
        window->DC.CursorPos = window->DC.CursorStartPos;
        window->DC.CursorPosPrevLine = window->DC.CursorPos;
        window->DC.CurrentLineHeight = window->DC.PrevLineHeight = 0.0f;
        window->DC.LogLineHeight = window->DC.CursorPos.y - 9999.0f;
        window->DC.ChildWindows.resize(0);
        window->DC.ItemWidth.resize(0);
        window->DC.ItemWidth.push_back(window->ItemWidthDefault);
        window->DC.AllowKeyboardFocus.resize(0);
        window->DC.AllowKeyboardFocus.push_back(true);
        window->DC.ColorModifiers.resize(0);
        window->DC.ColorEditMode = ImGuiColorEditMode_UserSelect;
        window->DC.ColumnCurrent = 0;
        window->DC.ColumnsCount = 1;
        window->DC.TreeDepth = 0;
        window->DC.StateStorage = &window->StateStorage;
        window->DC.OpenNextNode = -1;

        // Reset contents size for auto-fitting
        window->SizeContentsFit = ImVec2(0.0f, 0.0f);
        if (window->AutoFitFrames > 0)
            window->AutoFitFrames--;

        // Title bar
        if (!(window->Flags & ImGuiWindowFlags_NoTitleBar))
        {
            ImGui::PushClipRect(ImVec4(window->Pos.x-0.5f, window->Pos.y-0.5f, window->Pos.x+window->Size.x-1.5f, window->Pos.y+window->Size.y-1.5f), false);
            RenderCollapseTriangle(window->Pos + style.FramePadding, !window->Collapsed, 1.0f, true);
            RenderText(window->Pos + style.FramePadding + ImVec2(window->FontSize() + style.ItemInnerSpacing.x, 0), name);
            if (open)
                ImGui::CloseWindowButton(open);
            ImGui::PopClipRect();
        }
    }

    // Clip rectangle
    // We set this up after processing the resize grip so that our clip rectangle doesn't lag by a frame
    const ImGuiAabb title_bar_aabb = window->TitleBarAabb();
    ImVec4 clip_rect(title_bar_aabb.Min.x+0.5f, title_bar_aabb.Max.y+0.5f, window->Aabb().Max.x-1.5f, window->Aabb().Max.y-1.5f);
    if (window->ScrollbarY)
        clip_rect.z -= g.Style.ScrollBarWidth;
    ImGui::PushClipRect(clip_rect);

    if (first_begin_of_the_frame)
    {
        // Clear 'accessed' flag last thing
        window->Accessed = false;
    }

    // Return collapsed so that user can perform an early out optimisation
    return !window->Collapsed;
}

void End()
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = g.CurrentWindow;

    ImGui::Columns(1, "#CloseColumns");
    ImGui::PopClipRect();
    if (window->Flags & ImGuiWindowFlags_ChildWindow)
        if (!(window->Flags & ImGuiWindowFlags_ComboBox))
            ImGui::PopClipRect();

    // Select window for move/focus when we're done with all our widgets
    ImGuiAabb bb(window->Pos, window->Pos+window->Size);
    if (g.ActiveId == 0 && g.HoveredId == 0 && g.HoveredWindowExcludingChilds == window && IsMouseHoveringBox(bb) && g.IO.MouseClicked[0])
        g.ActiveId = window->GetID("#MOVE");

    // Stop logging
    if (!(window->Flags & ImGuiWindowFlags_ChildWindow))	// FIXME: more options for scope of logging
    {
        g.LogEnabled = false;
        if (g.LogFile != NULL)
        {
            fprintf(g.LogFile, "\n");
            if (g.LogFile == stdout)
                fflush(g.LogFile);
            else
                fclose(g.LogFile);
            g.LogFile = NULL;
        }
        if (g.LogClipboard.size() > 1)
        {
            g.LogClipboard.Append("\n");
            if (g.IO.SetClipboardTextFn)
                g.IO.SetClipboardTextFn(g.LogClipboard.begin(), g.LogClipboard.end());
            g.LogClipboard.clear();
        }
    }

    // Pop
    g.CurrentWindowStack.pop_back();
    g.CurrentWindow = g.CurrentWindowStack.empty() ? NULL : g.CurrentWindowStack.back();
}

static void FocusWindow(ImGuiWindow* window)
{
    ImGuiState& g = GImGui;
    g.FocusedWindow = window;

    // Move to front
    for (size_t i = 0; i < g.Windows.size(); i++)
        if (g.Windows[i] == window)
        {
            g.Windows.erase(g.Windows.begin() + i);
            break;
        }
    g.Windows.push_back(window);
}

void PushItemWidth(float item_width)
{
    ImGuiWindow* window = GetCurrentWindow();
    item_width = (float)(int)item_width;
    window->DC.ItemWidth.push_back(item_width > 0.0f ? item_width : window->ItemWidthDefault);
}

void PopItemWidth()
{
    ImGuiWindow* window = GetCurrentWindow();
    window->DC.ItemWidth.pop_back();
}

void PushAllowKeyboardFocus(bool allow_keyboard_focus)
{
    ImGuiWindow* window = GetCurrentWindow();
    window->DC.AllowKeyboardFocus.push_back(allow_keyboard_focus);
}

void PopAllowKeyboardFocus()
{
    ImGuiWindow* window = GetCurrentWindow();
    window->DC.AllowKeyboardFocus.pop_back();
}

void PushStyleColor(ImGuiCol idx, ImVec4 col)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    ImGuiColMod backup;
    backup.Col = idx;
    backup.PreviousValue = g.Style.Colors[idx];
    window->DC.ColorModifiers.push_back(backup);
    g.Style.Colors[idx] = col;
}

void PopStyleColor()
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    ImGuiColMod& backup = window->DC.ColorModifiers.back();
    g.Style.Colors[backup.Col] = backup.PreviousValue;
    window->DC.ColorModifiers.pop_back();
}

const char* GetStyleColorName(ImGuiCol idx)
{
    // Create with regexp: ImGuiCol_{.*}, --> case ImGuiCol_\1: return "\1";
    switch (idx)
    {
        case ImGuiCol_Text: return "Text";
        case ImGuiCol_WindowBg: return "WindowBg";
        case ImGuiCol_Border: return "Border";
        case ImGuiCol_BorderShadow: return "BorderShadow";
        case ImGuiCol_FrameBg: return "FrameBg";
        case ImGuiCol_TitleBg: return "TitleBg";
        case ImGuiCol_TitleBgCollapsed: return "TitleBgCollapsed";
        case ImGuiCol_ScrollbarBg: return "ScrollbarBg";
        case ImGuiCol_ScrollbarGrab: return "ScrollbarGrab";
        case ImGuiCol_ScrollbarGrabHovered: return "ScrollbarGrabHovered";
        case ImGuiCol_ScrollbarGrabActive: return "ScrollbarGrabActive";
        case ImGuiCol_ComboBg: return "ComboBg";
        case ImGuiCol_CheckActive: return "CheckActive";
        case ImGuiCol_SliderGrab: return "SliderGrab";
        case ImGuiCol_SliderGrabActive: return "SliderGrabActive";
        case ImGuiCol_Button: return "Button";
        case ImGuiCol_ButtonHovered: return "ButtonHovered";
        case ImGuiCol_ButtonActive: return "ButtonActive";
        case ImGuiCol_Header: return "Header";
        case ImGuiCol_HeaderHovered: return "HeaderHovered";
        case ImGuiCol_HeaderActive: return "HeaderActive";
        case ImGuiCol_Column: return "Column";
        case ImGuiCol_ColumnHovered: return "ColumnHovered";
        case ImGuiCol_ColumnActive: return "ColumnActive";
        case ImGuiCol_ResizeGrip: return "ResizeGrip";
        case ImGuiCol_ResizeGripHovered: return "ResizeGripHovered";
        case ImGuiCol_ResizeGripActive: return "ResizeGripActive";
        case ImGuiCol_CloseButton: return "CloseButton";
        case ImGuiCol_CloseButtonHovered: return "CloseButtonHovered";
        case ImGuiCol_CloseButtonActive: return "CloseButtonActive";
        case ImGuiCol_PlotLines: return "PlotLines";
        case ImGuiCol_PlotLinesHovered: return "PlotLinesHovered";
        case ImGuiCol_PlotHistogram: return "PlotHistogram";
        case ImGuiCol_PlotHistogramHovered: return "ImGuiCol_PlotHistogramHovered";
        case ImGuiCol_TextSelectedBg: return "TextSelectedBg";
        case ImGuiCol_TooltipBg: return "TooltipBg";
    }
    ZELO_ASSERT(0);
    return "Unknown";
}

bool GetWindowIsFocused()
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    return g.FocusedWindow == window;
}

float GetWindowWidth()
{
    ImGuiWindow* window = GetCurrentWindow();
    return window->Size.x;
}

ImVec2 GetWindowPos()
{
    ImGuiWindow* window = GetCurrentWindow();
    return window->Pos;
}

void SetWindowPos(ImVec2 pos)
{
    ImGuiWindow* window = GetCurrentWindow();
    window->Pos = pos;
}

ImVec2 GetWindowSize()
{
    ImGuiWindow* window = GetCurrentWindow();
    return window->Size;
}

ImVec2 GetWindowContentRegionMin()
{
    ImGuiWindow* window = GetCurrentWindow();
    return ImVec2(0, window->TitleBarHeight()) + window->WindowPadding();
}

ImVec2 GetWindowContentRegionMax()
{
    ImGuiWindow* window = GetCurrentWindow();
    ImVec2 m = window->Size - window->WindowPadding();
    if (window->ScrollbarY)
        m.x -= GImGui.Style.ScrollBarWidth;
    return m;
}

float GetTextLineHeight()
{
    ImGuiWindow* window = GetCurrentWindow();
    return window->FontSize();
}

float GetTextLineSpacing()
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    return window->FontSize() + g.Style.ItemSpacing.y;
}

ImDrawList*	GetWindowDrawList()
{
    ImGuiWindow* window = GetCurrentWindow();
    return window->DrawList;
}

void SetFontScale(float scale)
{
    ImGuiWindow* window = GetCurrentWindow();
    window->FontScale = scale;
}

ImVec2 GetCursorPos()
{
    ImGuiWindow* window = GetCurrentWindow();
    return window->DC.CursorPos - window->Pos;
}

void SetCursorPos(ImVec2 p)
{
    ImGuiWindow* window = GetCurrentWindow();
    window->DC.CursorPos = window->Pos + p;
}

void SetScrollPosHere()
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    window->NextScrollY = (window->DC.CursorPos.y + window->ScrollY) - (window->Pos.y + window->SizeFull.y * 0.5f) - (window->TitleBarHeight() + window->WindowPadding().y);
}

void SetTreeStateStorage(ImGuiStorage* tree)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    window->DC.StateStorage = tree ? tree : &window->StateStorage;
}

void TextV(const char* fmt, va_list args)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return;

    static char buf[1024];
    const char* text_end = buf + ImFormatStringV(buf, ARRAYSIZE(buf), fmt, args);
    TextUnformatted(buf, text_end);
}

void Text(const char* fmt, ...)
{
    va_list args;
            va_start(args, fmt);
    TextV(fmt, args);
            va_end(args);
}

void TextUnformatted(const char* text, const char* text_end)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return;

    const char* text_begin = text;
    if (text_end == NULL)
        text_end = text + strlen(text);

    if (text_end - text > 2000)
    {
        // Long text!
        // Perform manual coarse clipping to optimize for long multi-line text
        // From this point we will only compute the width of lines that are visible.
        const char* line = text;
        const float line_height = ImGui::GetTextLineHeight();
        const ImVec2 start_pos = window->DC.CursorPos;
        const ImVec4 clip_rect = window->ClipRectStack.back();
        ImVec2 text_size(0,0);

        if (start_pos.y <= clip_rect.w)
        {
            ImVec2 pos = start_pos;

            // lines to skip (can't skip when logging text)
            if (!g.LogEnabled)
            {
                int lines_skippable = (int)((clip_rect.y - start_pos.y) / line_height) - 1;
                if (lines_skippable > 0)
                {
                    int lines_skipped = 0;
                    while (line < text_end && lines_skipped <= lines_skippable)
                    {
                        const char* line_end = strchr(line, '\n');
                        line = line_end + 1;
                        lines_skipped++;
                    }
                    pos.y += lines_skipped * line_height;
                }
            }
            else
            {
                printf("");
            }

            // lines to render?
            if (line < text_end)
            {
                ImGuiAabb line_box(pos, pos + ImVec2(ImGui::GetWindowWidth(), line_height));
                while (line < text_end)
                {
                    const char* line_end = strchr(line, '\n');
                    if (ImGui::IsClipped(line_box))
                        break;

                    const ImVec2 line_size = CalcTextSize(line, line_end, false);
                    text_size.x = ImMax(text_size.x, line_size.x);
                    RenderText(pos, line, line_end, false);
                    if (!line_end)
                        line_end = text_end;
                    line = line_end + 1;
                    line_box.Min.y += line_height;
                    line_box.Max.y += line_height;
                    pos.y += line_height;
                }

                // count remaining lines
                int lines_skipped = 0;
                while (line < text_end)
                {
                    const char* line_end = strchr(line, '\n');
                    if (!line_end)
                        line_end = text_end;
                    line = line_end + 1;
                    lines_skipped++;
                }
                pos.y += lines_skipped * line_height;
            }

            text_size.y += (pos - start_pos).y;
        }
        const ImGuiAabb bb(window->DC.CursorPos, window->DC.CursorPos + text_size);
        ItemSize(bb);
        ClipAdvance(bb);
    }
    else
    {
        const ImVec2 text_size = CalcTextSize(text_begin, text_end, false);
        ImGuiAabb bb(window->DC.CursorPos, window->DC.CursorPos + text_size);
        ItemSize(bb.GetSize(), &bb.Min);

        if (ClipAdvance(bb))
            return;

        // Render
        // We don't hide text after # in this end-user function.
        RenderText(bb.Min, text_begin, text_end, false);
    }
}

void AlignFirstTextHeightToWidgets()
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return;

    // Declare a dummy item size to that upcoming items that are smaller will center-align on the newly expanded line height.
    ImGui::ItemSize(ImVec2(0, window->FontSize() + g.Style.FramePadding.y*2));
    ImGui::SameLine(0, 0);
}

void LabelText(const char* label, const char* fmt, ...)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return;
    const ImGuiStyle& style = g.Style;
    const float w = window->DC.ItemWidth.back();

    static char buf[1024];
    va_list args;
            va_start(args, fmt);
    const char* text_begin = &buf[0];
    const char* text_end = text_begin + ImFormatStringV(buf, ARRAYSIZE(buf), fmt, args);
            va_end(args);

    const ImVec2 text_size = CalcTextSize(label);
    const ImGuiAabb value_bb(window->DC.CursorPos, window->DC.CursorPos + ImVec2(w + style.FramePadding.x*2, text_size.y));
    const ImGuiAabb bb(window->DC.CursorPos, window->DC.CursorPos + ImVec2(w + style.FramePadding.x*2 + style.ItemInnerSpacing.x, 0.0f) + text_size);
    ItemSize(bb);

    if (ClipAdvance(value_bb))
        return;

    // Render
    RenderText(value_bb.Min, text_begin, text_end);
    RenderText(ImVec2(value_bb.Max.x + style.ItemInnerSpacing.x, value_bb.Min.y), label);
}

static bool ButtonBehaviour(const ImGuiAabb& bb, const ImGuiID& id, bool* out_hovered, bool* out_held, bool repeat)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    const bool hovered = (g.HoveredWindow == window) && (g.HoveredId == 0) && IsMouseHoveringBox(bb);
    bool pressed = false;
    if (hovered)
    {
        g.HoveredId = id;
        if (g.IO.MouseClicked[0])
        {
            g.ActiveId = id;
        }
        else if (repeat && g.ActiveId && ImGui::IsMouseClicked(0, true))
        {
            pressed = true;
        }
    }

    bool held = false;
    if (g.ActiveId == id)
    {
        if (g.IO.MouseDown[0])
        {
            held = true;
        }
        else
        {
            if (hovered)
                pressed = true;
            g.ActiveId = 0;
        }
    }

    if (out_hovered) *out_hovered = hovered;
    if (out_held) *out_held = held;

    return pressed;
}

bool Button(const char* label, ImVec2 size, bool repeat_when_held)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return false;

    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);

    const ImVec2 text_size = CalcTextSize(label);
    if (size.x == 0.0f)
        size.x = text_size.x;
    if (size.y == 0.0f)
        size.y = text_size.y;

    const ImGuiAabb bb(window->DC.CursorPos, window->DC.CursorPos+size + style.FramePadding*2.0f);
    ItemSize(bb);

    if (ClipAdvance(bb))
        return false;

    bool hovered, held;
    bool pressed = ButtonBehaviour(bb, id, &hovered, &held, repeat_when_held);

    // Render
    const ImU32 col = window->Color((hovered && held) ? ImGuiCol_ButtonActive : hovered ? ImGuiCol_ButtonHovered : ImGuiCol_Button);
    RenderFrame(bb.Min, bb.Max, col);

    if (size.x < text_size.x || size.y < text_size.y)
        PushClipRect(ImVec4(bb.Min.x+style.FramePadding.x, bb.Min.y+style.FramePadding.y, bb.Max.x, bb.Max.y-style.FramePadding.y));		// Allow extra to draw over the horizontal padding to make it visible that text doesn't fit
    const ImVec2 off = ImVec2(ImMax(0.0f, size.x - text_size.x) * 0.5f, ImMax(0.0f, size.y - text_size.y) * 0.5f);
    RenderText(bb.Min + style.FramePadding + off, label);
    if (size.x < text_size.x || size.y < text_size.y)
        PopClipRect();

    return pressed;
}

// Fits within text without additional spacing.
bool SmallButton(const char* label)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return false;

    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);

    const ImGuiAabb bb(window->DC.CursorPos, window->DC.CursorPos+CalcTextSize(label) + ImVec2(style.FramePadding.x*2,0));
    ItemSize(bb);

    if (ClipAdvance(bb))
        return false;

    bool hovered, held;
    bool pressed = ButtonBehaviour(bb, id, &hovered, &held);

    // Render
    const ImU32 col = window->Color((hovered && held) ? ImGuiCol_ButtonActive : hovered ? ImGuiCol_ButtonHovered : ImGuiCol_Button);
    RenderFrame(bb.Min, bb.Max, col);
    RenderText(bb.Min + ImVec2(style.FramePadding.x,0), label);

    return pressed;
}

static bool CloseWindowButton(bool* open)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    const ImGuiID id = window->GetID("##CLOSE");

    const float title_bar_height = window->TitleBarHeight();
    const ImGuiAabb bb(window->Aabb().GetTR() + ImVec2(-title_bar_height+3.0f,2.0f), window->Aabb().GetTR() + ImVec2(-2.0f,+title_bar_height-2.0f));

    bool hovered, held;
    bool pressed = ButtonBehaviour(bb, id, &hovered, &held);

    // Render
    const ImU32 col = window->Color((held && hovered) ? ImGuiCol_CloseButtonActive : hovered ? ImGuiCol_CloseButtonHovered : ImGuiCol_CloseButton);
    window->DrawList->AddCircleFilled(bb.GetCenter(), ImMax(2.0f,title_bar_height*0.5f-4), col, 16);
    //RenderFrame(bb.Min, bb.Max, col, false);

    const float cross_padding = 4;
    if (hovered && bb.GetWidth() >= (cross_padding+1)*2 && bb.GetHeight() >= (cross_padding+1)*2)
    {
        window->DrawList->AddLine(bb.GetTL()+ImVec2(+cross_padding,+cross_padding), bb.GetBR()+ImVec2(-cross_padding,-cross_padding), window->Color(ImGuiCol_Text));
        window->DrawList->AddLine(bb.GetBL()+ImVec2(+cross_padding,-cross_padding), bb.GetTR()+ImVec2(-cross_padding,+cross_padding), window->Color(ImGuiCol_Text));
    }

    if (open != NULL && pressed)
        *open = !*open;

    return pressed;
}

void LogToTTY(int max_depth)
{
    ImGuiState& g = GImGui;
    if (g.LogEnabled)
        return;
    g.LogEnabled = true;
    g.LogFile = stdout;
    g.LogAutoExpandMaxDepth = max_depth;
}

void LogToFile(int max_depth, const char* filename)
{
    ImGuiState& g = GImGui;
    if (g.LogEnabled)
        return;
    ZELO_ASSERT(filename);
    g.LogEnabled = true;
    g.LogFile = fopen(filename, "at");
    g.LogAutoExpandMaxDepth = max_depth;
}

void LogToClipboard(int max_depth)
{
    ImGuiState& g = GImGui;
    if (g.LogEnabled)
        return;
    g.LogEnabled = true;
    g.LogFile = NULL;
    g.LogAutoExpandMaxDepth = max_depth;
}

void LogButtons()
{
    ImGuiState& g = GImGui;

    ImGui::PushID("LogButtons");
    const bool log_to_tty = ImGui::Button("Log To TTY");
    ImGui::SameLine();
    const bool log_to_file = ImGui::Button("Log To File");
    ImGui::SameLine();
    const bool log_to_clipboard = ImGui::Button("Log To Clipboard");
    ImGui::SameLine();

    ImGui::PushItemWidth(80.0f);
    ImGui::PushAllowKeyboardFocus(false);
    ImGui::SliderInt("Depth", &g.LogAutoExpandMaxDepth, 0, 9, NULL);
    ImGui::PopAllowKeyboardFocus();
    ImGui::PopItemWidth();
    ImGui::PopID();

    // Start logging at the end of the function so that the buttons don't appear in the log
    if (log_to_tty)
        LogToTTY(g.LogAutoExpandMaxDepth);
    if (log_to_file)
        LogToFile(g.LogAutoExpandMaxDepth, g.IO.LogFilename);
    if (log_to_clipboard)
        LogToClipboard(g.LogAutoExpandMaxDepth);
}

bool CollapsingHeader(const char* label, const char* str_id, const bool display_frame, const bool default_open)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return false;

    const ImGuiStyle& style = g.Style;

    ZELO_ASSERT(str_id != NULL || label != NULL);
    if (str_id == NULL)
        str_id = label;
    if (label == NULL)
        label = str_id;
    const ImGuiID id = window->GetID(str_id);

    ImGuiStorage* tree = window->DC.StateStorage;
    bool opened;
    if (window->DC.OpenNextNode != -1)
    {
        opened = window->DC.OpenNextNode > 0;
        tree->SetInt(id, opened);
        window->DC.OpenNextNode = -1;
    }
    else
    {
        opened = tree->GetInt(id, default_open) != 0;
    }

    const ImVec2 window_padding = window->WindowPadding();
    const ImVec2 text_size = CalcTextSize(label);
    const ImVec2 pos_min = window->DC.CursorPos;
    const ImVec2 pos_max = window->Pos + GetWindowContentRegionMax();
    ImGuiAabb bb = ImGuiAabb(pos_min, ImVec2(pos_max.x, pos_min.y + text_size.y));
    if (display_frame)
    {
        bb.Min.x -= window_padding.x*0.5f;
        bb.Max.x += window_padding.x*0.5f;
        bb.Max.y += style.FramePadding.y * 2;
    }

    const ImGuiAabb text_bb(bb.Min, bb.Min + ImVec2(window->FontSize() + style.FramePadding.x*2*2,0) + text_size);
    ItemSize(ImVec2(text_bb.GetSize().x, bb.GetSize().y));	// NB: we don't provide our width so that it doesn't get feed back into AutoFit

    // Logging auto expand tree nodes (but not collapsing headers.. seems like sensible behaviour)
    // NB- If we are above max depth we still allow manually opened nodes to be logged
    if (!display_frame)
        if (g.LogEnabled && window->DC.TreeDepth < g.LogAutoExpandMaxDepth)
            opened = true;

    if (ClipAdvance(bb))
        return opened;

    bool hovered, held;
    bool pressed = ButtonBehaviour(display_frame ? bb : text_bb, id, &hovered, &held);
    if (pressed)
    {
        opened = !opened;
        tree->SetInt(id, opened);
    }

    // Render
    const ImU32 col = window->Color((held && hovered) ? ImGuiCol_HeaderActive : hovered ? ImGuiCol_HeaderHovered : ImGuiCol_Header);
    if (display_frame)
    {
        RenderFrame(bb.Min, bb.Max, col, true);
        RenderCollapseTriangle(bb.Min + style.FramePadding, opened, 1.0f, true);
        RenderText(bb.Min + style.FramePadding + ImVec2(window->FontSize() + style.FramePadding.x*2,0), label);
    }
    else
    {
        if ((held && hovered) || hovered)
            RenderFrame(bb.Min, bb.Max, col, false);
        RenderCollapseTriangle(bb.Min + ImVec2(style.FramePadding.x, window->FontSize()*0.15f), opened, 0.70f);
        RenderText(bb.Min + ImVec2(window->FontSize() + style.FramePadding.x*2,0), label);
    }

    return opened;
}

void BulletText(const char* fmt, ...)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return;

    static char buf[1024];
    va_list args;
            va_start(args, fmt);
    const char* text_begin = buf;
    const char* text_end = text_begin + ImFormatStringV(buf, ARRAYSIZE(buf), fmt, args);
            va_end(args);

    const float line_height = window->FontSize();
    const ImVec2 text_size = CalcTextSize(text_begin, text_end);
    const ImGuiAabb bb(window->DC.CursorPos, window->DC.CursorPos + ImVec2(line_height + (text_size.x ? (g.Style.FramePadding.x*2) : 0.0f),0) + text_size);	// Empty text doesn't add padding
    ItemSize(bb);

    if (ClipAdvance(bb))
        return;

    // Render
    const float bullet_size = line_height*0.15f;
    window->DrawList->AddCircleFilled(bb.Min + ImVec2(g.Style.FramePadding.x + line_height*0.5f, line_height*0.5f), bullet_size, window->Color(ImGuiCol_Text));
    RenderText(bb.Min+ImVec2(window->FontSize()+g.Style.FramePadding.x*2,0), text_begin, text_end);
}

bool TreeNode(const char* str_id, const char* fmt, ...)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    ImGuiStorage* tree = window->DC.StateStorage;

    static char buf[1024];
    va_list args;
            va_start(args, fmt);
    ImFormatStringV(buf, ARRAYSIZE(buf), fmt, args);
            va_end(args);

    if (!str_id || !str_id[0])
        str_id = fmt;

    ImGui::PushID(str_id);
    const bool opened = ImGui::CollapsingHeader(buf, "", false);		// do not add to the ID so that TreeNodeSetOpen can access
    ImGui::PopID();

    if (opened)
        ImGui::TreePush(str_id);

    return opened;
}

bool TreeNode(const void* ptr_id, const char* fmt, ...)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    ImGuiStorage* tree = window->DC.StateStorage;

    static char buf[1024];
    va_list args;
            va_start(args, fmt);
    ImFormatStringV(buf, ARRAYSIZE(buf), fmt, args);
            va_end(args);

    if (!ptr_id)
        ptr_id = fmt;

    ImGui::PushID(ptr_id);
    const bool opened = ImGui::CollapsingHeader(buf, "", false);
    ImGui::PopID();

    if (opened)
        ImGui::TreePush(ptr_id);

    return opened;
}

bool TreeNode(const char* str_label_id)
{
    return TreeNode(str_label_id, "%s", str_label_id);
}

void OpenNextNode(bool open)
{
    ImGuiWindow* window = GetCurrentWindow();
    window->DC.OpenNextNode = open ? 1 : 0;
}

void PushID(const char* str_id)
{
    ImGuiWindow* window = GetCurrentWindow();
    window->IDStack.push_back(window->GetID(str_id));
}

void PushID(const void* ptr_id)
{
    ImGuiWindow* window = GetCurrentWindow();
    window->IDStack.push_back(window->GetID(ptr_id));
}

void PushID(int int_id)
{
    const void* ptr_id = (void*)(intptr_t)int_id;
    ImGuiWindow* window = GetCurrentWindow();
    window->IDStack.push_back(window->GetID(ptr_id));
}

void PopID()
{
    ImGuiWindow* window = GetCurrentWindow();
    window->IDStack.pop_back();
}

// NB: only call right after InputText because we are using its InitialValue storage
static void ApplyNumericalTextInput(const char* buf, float *v)
{
    while (*buf == ' ' || *buf == '\t')
        buf++;

    // We don't support '-' op because it would conflict with inputing negative value.
    // Instead you can use +-100 to subtract from an existing value
    char op = buf[0];
    if (op == '+' || op == '*' || op == '/')
    {
        buf++;
        while (*buf == ' ' || *buf == '\t')
            buf++;
    }
    else
    {
        op = 0;
    }
    if (!buf[0])
        return;

    float ref_v = *v;
    if (op)
        if (sscanf(GImGui.InputTextState.InitialText, "%f", &ref_v) < 1)
            return;

    float op_v = 0.0f;
    if (sscanf(buf, "%f", &op_v) < 1)
        return;

    if (op == '+')
        *v = ref_v + op_v;
    else if (op == '*')
        *v = ref_v * op_v;
    else if (op == '/')
    {
        if (op_v == 0.0f)
            return;
        *v = ref_v / op_v;
    }
    else
        *v = op_v;
}

// use power!=1.0 for logarithmic sliders
bool SliderFloat(const char* label, float* v, float v_min, float v_max, const char* display_format, float power)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return false;

    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);
    const float w = window->DC.ItemWidth.back();

    if (!display_format)
        display_format = "%.3f";

    // Dodgily parse display precision back from the display format
    int decimal_precision = 3;
    if (const char* p = strchr(display_format, '%'))
    {
        p++;
        while (*p >= '0' && *p <= '9')
            p++;
        if (*p == '.')
        {
            decimal_precision = atoi(p+1);
            if (decimal_precision < 0 || decimal_precision > 10)
                decimal_precision = 3;
        }
    }

    const bool tab_focus_requested = window->FocusItemRegister(g.ActiveId == id);

    const ImVec2 text_size = CalcTextSize(label);
    const ImGuiAabb frame_bb(window->DC.CursorPos, window->DC.CursorPos + ImVec2(w, text_size.y) + style.FramePadding*2.0f);
    const ImGuiAabb slider_bb(frame_bb.Min+g.Style.FramePadding, frame_bb.Max-g.Style.FramePadding);
    const ImGuiAabb bb(frame_bb.Min, frame_bb.Max + ImVec2(style.ItemInnerSpacing.x + text_size.x, 0.0f));

    if (IsClipped(slider_bb))
    {
        // NB- we don't use ClipAdvance() because we don't want to submit ItemSize() because we may change into a text edit later which may submit an ItemSize itself
        ItemSize(bb);
        return false;
    }

    const bool is_unbound = v_min == -FLT_MAX || v_min == FLT_MAX || v_max == -FLT_MAX || v_max == FLT_MAX;

    const float grab_size_in_units = 1.0f;															// In 'v' units. Probably needs to be parametrized, based on a 'v_step' value? decimal precision?
    float grab_size_in_pixels;
    if (decimal_precision > 0 || is_unbound)
        grab_size_in_pixels = 10.0f;
    else
        grab_size_in_pixels = ImMax(grab_size_in_units * (w / (v_max-v_min+1.0f)), 8.0f);				// Integer sliders
    const float slider_effective_w = slider_bb.GetWidth() - grab_size_in_pixels;
    const float slider_effective_x1 = slider_bb.Min.x + grab_size_in_pixels*0.5f;
    const float slider_effective_x2 = slider_bb.Max.x - grab_size_in_pixels*0.5f;

    // For logarithmic sliders that cross over sign boundary we want the exponential increase to be symetric around 0.0
    float linear_zero_pos = 0.0f;	// 0.0->1.0f
    if (!is_unbound)
    {
        if (v_min * v_max < 0.0f)
        {
            // Different sign
            const float linear_dist_min_to_0 = powf(abs(0.0f - v_min), 1.0f/power);
            const float linear_dist_max_to_0 = powf(abs(v_max - 0.0f), 1.0f/power);
            linear_zero_pos = linear_dist_min_to_0 / (linear_dist_min_to_0+linear_dist_max_to_0);
        }
        else
        {
            // Same sign
            linear_zero_pos = v_min < 0.0f ? 1.0f : 0.0f;
        }
    }

    const bool hovered = (g.HoveredWindow == window) && (g.HoveredId == 0) && IsMouseHoveringBox(slider_bb);
    if (hovered)
        g.HoveredId = id;

    bool start_text_input = false;
    if (tab_focus_requested || (hovered && g.IO.MouseClicked[0]))
    {
        g.ActiveId = id;

        const bool is_ctrl_down = g.IO.KeyCtrl;
        if (tab_focus_requested || is_ctrl_down || is_unbound)
        {
            start_text_input = true;
            g.SliderAsInputTextId = 0;
        }
    }

    // Tabbing thru or CTRL-clicking through slider turns into an input box
    bool value_changed = false;
    if (start_text_input || (g.ActiveId == id && id == g.SliderAsInputTextId))
    {
        char text_buf[64];
        ImFormatString(text_buf, ARRAYSIZE(text_buf), "%.*f", decimal_precision, *v);

        g.ActiveId = g.SliderAsInputTextId;
        g.HoveredId = 0;
        window->FocusItemUnregister();	// Our replacement slider will override the focus ID (that we needed to declare previously to allow for a TAB focus to happen before we got selected)
        value_changed = ImGui::InputText(label, text_buf, ARRAYSIZE(text_buf), ImGuiInputTextFlags_CharsDecimal | ImGuiInputTextFlags_AutoSelectAll | ImGuiInputTextFlags_AlignCenter);
        if (g.SliderAsInputTextId == 0)
        {
            // First frame
            ZELO_ASSERT(g.ActiveId == id);	// InputText ID should match the Slider ID (else we'd need to store them both)
            g.SliderAsInputTextId = g.ActiveId;
            g.ActiveId = id;
            g.HoveredId = id;
        }
        else
        {
            if (g.ActiveId == g.SliderAsInputTextId)
                g.ActiveId = id;
            else
                g.ActiveId = g.SliderAsInputTextId = 0;
        }
        if (value_changed)
        {
            ApplyNumericalTextInput(text_buf, v);
        }
        return value_changed;
    }

    ItemSize(bb);
    RenderFrame(frame_bb.Min, frame_bb.Max, window->Color(ImGuiCol_FrameBg));

    if (g.ActiveId == id)
    {
        if (g.IO.MouseDown[0])
        {
            if (!is_unbound)
            {
                const float normalized_pos = ImClamp((g.IO.MousePos.x - slider_effective_x1) / slider_effective_w, 0.0f, 1.0f);

                // Linear slider
                //float new_value = ImLerp(v_min, v_max, normalized_pos);

                // Account for logarithmic scale on both sides of the zero
                float new_value;
                if (normalized_pos < linear_zero_pos)
                {
                    // Negative: rescale to the negative range before powering
                    float a = 1.0f - (normalized_pos / linear_zero_pos);
                    a = powf(a, power);
                    new_value = ImLerp(ImMin(v_max,0.f), v_min, a);
                }
                else
                {
                    // Positive: rescale to the positive range before powering
                    float a = normalized_pos;
                    if (abs(linear_zero_pos - 1.0f) > 1.e-6)
                        a = (a - linear_zero_pos) / (1.0f - linear_zero_pos);
                    a = powf(a, power);
                    new_value = ImLerp(ImMax(v_min,0.0f), v_max, a);
                }

                // Round past decimal precision
                //  0: 1
                //  1: 0.1
                //  2: 0.01
                //  etc..
                // So when our value is 1.99999 with a precision of 0.001 we'll end up rounding to 2.0
                const float min_step = 1.0f / powf(10.0f, (float)decimal_precision);
                const float remainder = fmodf(new_value, min_step);
                if (remainder <= min_step*0.5f)
                    new_value -= remainder;
                else
                    new_value += (min_step - remainder);

                if (*v != new_value)
                {
                    *v = new_value;
                    value_changed = true;
                }
            }
        }
        else
        {
            g.ActiveId = 0;
        }
    }

    if (!is_unbound)
    {
        // Linear slider
        // const float grab_t = (ImClamp(*v, v_min, v_max) - v_min) / (v_max - v_min);

        // Calculate slider grab positioning
        float grab_t;
        float v_clamped = ImClamp(*v, v_min, v_max);
        if (v_clamped < 0.0f)
        {
            float f = 1.0f - (v_clamped - v_min) / (ImMin(0.0f,v_max) - v_min);
            grab_t = (1.0f - powf(f, 1.0f/power)) * linear_zero_pos;
        }
        else
        {
            float f = (v_clamped - ImMax(0.0f,v_min)) / (v_max - ImMax(0.0f,v_min));
            grab_t = linear_zero_pos + powf(f, 1.0f/power) * (1.0f - linear_zero_pos);
        }

        // Draw
        const float grab_x = ImLerp(slider_effective_x1, slider_effective_x2, grab_t);
        const ImGuiAabb grab_bb(ImVec2(grab_x-grab_size_in_pixels*0.5f,frame_bb.Min.y+2.0f), ImVec2(grab_x+grab_size_in_pixels*0.5f,frame_bb.Max.y-1.0f));
        window->DrawList->AddRectFilled(grab_bb.Min, grab_bb.Max, window->Color(g.ActiveId == id ? ImGuiCol_SliderGrabActive : ImGuiCol_SliderGrab));
    }

    char value_buf[64];
    ImFormatString(value_buf, ARRAYSIZE(value_buf), display_format, *v);
    RenderText(ImVec2(slider_bb.GetCenter().x-CalcTextSize(value_buf).x*0.5f, frame_bb.Min.y + style.FramePadding.y), value_buf);

    RenderText(ImVec2(frame_bb.Max.x + style.ItemInnerSpacing.x, slider_bb.Min.y), label);

    return value_changed;
}

bool SliderAngle(const char* label, float* v, float v_degrees_min, float v_degrees_max)
{
    float v_deg = *v * 360.0f / (2*PI);
    bool changed = ImGui::SliderFloat(label, &v_deg, v_degrees_min, v_degrees_max, "%.0f deg", 1.0f);
    *v = v_deg * (2*PI) / 360.0f;
    return changed;
}

bool SliderInt(const char* label, int* v, int v_min, int v_max, const char* display_format)
{
    if (!display_format)
        display_format = "%.0f";
    float v_f = (float)*v;
    bool changed = ImGui::SliderFloat(label, &v_f, (float)v_min, (float)v_max, display_format, 1.0f);
    *v = (int)v_f;
    return changed;
}

bool SliderFloat3(const char* label, float v[3], float v_min, float v_max, const char* display_format, float power)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return false;

    const ImGuiStyle& style = g.Style;
    const ImVec2 text_size = CalcTextSize(label);

    bool value_changed = false;

    ImGui::PushID(label);

    const int components = 3;
    const float w_full = window->DC.ItemWidth.back();
    const float w_item_one  = ImMax(1.0f, (float)(int)((w_full - (style.FramePadding.x*2.0f+style.ItemInnerSpacing.x)*(components-1)) / (float)components));
    const float w_item_last = ImMax(1.0f, (float)(int)(w_full - (w_item_one+style.FramePadding.x*2.0f+style.ItemInnerSpacing.x)*(components-1)));

    ImGui::PushItemWidth(w_item_one);
    value_changed |= ImGui::SliderFloat("##X", &v[0], v_min, v_max, display_format, power);
    ImGui::SameLine(0, 0);
    value_changed |= ImGui::SliderFloat("##Y", &v[1], v_min, v_max, display_format, power);
    ImGui::SameLine(0, 0);
    ImGui::PopItemWidth();

    ImGui::PushItemWidth(w_item_last);
    value_changed |= ImGui::SliderFloat("##Z", &v[2], v_min, v_max, display_format, power);
    ImGui::SameLine(0, 0);
    ImGui::PopItemWidth();

    ImGui::TextUnformatted(label, FindTextDisplayEnd(label));

    ImGui::PopID();

    return value_changed;
}

// Enum for ImGui::Plot()
enum ImGuiPlotType
{
    ImGuiPlotType_Lines,
    ImGuiPlotType_Histogram,
};

static void Plot(ImGuiPlotType plot_type, const char* label, const float* values, int values_count, int values_offset, const char* overlay_text, float scale_min, float scale_max, ImVec2 graph_size)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return;

    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);

    const ImVec2 text_size = CalcTextSize(label);
    if (graph_size.x == 0)
        graph_size.x = window->DC.ItemWidth.back();
    if (graph_size.y == 0)
        graph_size.y = text_size.y;

    const ImGuiAabb frame_bb(window->DC.CursorPos, window->DC.CursorPos + ImVec2(graph_size.x, graph_size.y) + style.FramePadding*2.0f);
    const ImGuiAabb graph_bb(frame_bb.Min + style.FramePadding, frame_bb.Max - style.FramePadding);
    const ImGuiAabb bb(frame_bb.Min, frame_bb.Max + ImVec2(style.ItemInnerSpacing.x + text_size.x,0));
    ItemSize(bb);

    if (ClipAdvance(bb))
        return;

    // Determine scale if not specified
    if (scale_min == FLT_MAX || scale_max == FLT_MAX)
    {
        float v_min = FLT_MAX;
        float v_max = -FLT_MAX;
        for (int i = 0; i < values_count; i++)
        {
            v_min = ImMin(v_min, values[i]);
            v_max = ImMax(v_max, values[i]);
        }
        if (scale_min == FLT_MAX)
            scale_min = v_min;
        if (scale_max == FLT_MAX)
            scale_max = v_max;
    }

    RenderFrame(frame_bb.Min, frame_bb.Max, window->Color(ImGuiCol_FrameBg));

    int res_w = ImMin((int)graph_size.x, values_count);
    if (plot_type == ImGuiPlotType_Lines)
        res_w -= 1;

    // Tooltip on hover
    int v_hovered = -1;
    if (IsMouseHoveringBox(graph_bb))
    {
        const float t = ImClamp((g.IO.MousePos.x - graph_bb.Min.x) / (graph_bb.Max.x - graph_bb.Min.x), 0.0f, 0.9999f);
        const int v_idx = (int)(t * (values_count + ((plot_type == ImGuiPlotType_Lines) ? -1 : 0)));
        ZELO_ASSERT(v_idx >= 0 && v_idx < values_count);

        const float v0 = values[(v_idx + values_offset) % values_count];
        const float v1 = values[(v_idx + 1 + values_offset) % values_count];
        if (plot_type == ImGuiPlotType_Lines)
            ImGui::SetTooltip("%d: %8.4g\n%d: %8.4g", v_idx, v0, v_idx+1, v1);
        else if (plot_type == ImGuiPlotType_Histogram)
            ImGui::SetTooltip("%d: %8.4g", v_idx, v0);
        v_hovered = v_idx;
    }

    const float t_step = 1.0f / (float)res_w;

    float v0 = values[(0 + values_offset) % values_count];
    float t0 = 0.0f;
    ImVec2 p0 = ImVec2( t0, 1.0f - ImSaturate((v0 - scale_min) / (scale_max - scale_min)) );

    const ImU32 col_base = window->Color((plot_type == ImGuiPlotType_Lines) ? ImGuiCol_PlotLines : ImGuiCol_PlotHistogram);
    const ImU32 col_hovered = window->Color((plot_type == ImGuiPlotType_Lines) ? ImGuiCol_PlotLinesHovered : ImGuiCol_PlotHistogramHovered);

    while (t0 < 1.0f)
    {
        const float t1 = t0 + t_step;
        const int v_idx = (int)(t0 * values_count);
        ZELO_ASSERT(v_idx >= 0 && v_idx < values_count);
        const float v1 = values[(v_idx + values_offset + 1) % values_count];
        const ImVec2 p1 = ImVec2( t1, 1.0f - ImSaturate((v1 - scale_min) / (scale_max - scale_min)) );

        // NB: draw calls are merged into ones
        if (plot_type == ImGuiPlotType_Lines)
            window->DrawList->AddLine(ImLerp(graph_bb.Min, graph_bb.Max, p0), ImLerp(graph_bb.Min, graph_bb.Max, p1), v_hovered == v_idx ? col_hovered : col_base);
        else if (plot_type == ImGuiPlotType_Histogram)
            window->DrawList->AddRectFilled(ImLerp(graph_bb.Min, graph_bb.Max, p0), ImLerp(graph_bb.Min, graph_bb.Max, ImVec2(p1.x, 1.0f))+ImVec2(-1,0), v_hovered == v_idx ? col_hovered : col_base);

        v0 = v1;
        t0 = t1;
        p0 = p1;
    }

    // Overlay last value
    if (overlay_text)
        RenderText(ImVec2(graph_bb.GetCenter().x-CalcTextSize(overlay_text).x*0.5f, frame_bb.Min.y + style.FramePadding.y), overlay_text);

    RenderText(ImVec2(frame_bb.Max.x + style.ItemInnerSpacing.x, graph_bb.Min.y), label);
}

void PlotLines(const char* label, const float* values, int values_count, int values_offset, const char* overlay_text, float scale_min, float scale_max, ImVec2 graph_size)
{
    ImGui::Plot(ImGuiPlotType_Lines, label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size);
}

void PlotHistogram(const char* label, const float* values, int values_count, int values_offset, const char* overlay_text, float scale_min, float scale_max, ImVec2 graph_size)
{
    ImGui::Plot(ImGuiPlotType_Histogram, label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size);
}

void Checkbox(const char* label, bool* v)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return;

    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);

    const ImVec2 text_size = CalcTextSize(label);

    const ImGuiAabb check_bb(window->DC.CursorPos, window->DC.CursorPos + ImVec2(text_size.y + style.FramePadding.y*2, text_size.y + style.FramePadding.y*2));
    ItemSize(check_bb);
    SameLine(0, (int)g.Style.ItemInnerSpacing.x);

    const ImGuiAabb text_bb(window->DC.CursorPos + ImVec2(0,style.FramePadding.y), window->DC.CursorPos + ImVec2(0,style.FramePadding.y) + text_size);
    ItemSize(ImVec2(text_bb.GetWidth(), check_bb.GetHeight()));

    if (ClipAdvance(check_bb))
        return;

    RenderFrame(check_bb.Min, check_bb.Max, window->Color(ImGuiCol_FrameBg));

    const bool hovered = (g.HoveredWindow == window) && (g.HoveredId == 0) && IsMouseHoveringBox(check_bb);
    const bool pressed = hovered && g.IO.MouseClicked[0];
    if (hovered)
        g.HoveredId = id;
    if (pressed)
    {
        *v = !(*v);
        g.ActiveId = 0;	// Clear focus
    }

    if (*v)
    {
        window->DrawList->AddRectFilled(check_bb.Min+ImVec2(4,4), check_bb.Max-ImVec2(4,4), window->Color(ImGuiCol_CheckActive));
    }

    if (g.LogEnabled)
        LogText(text_bb.GetTL(), *v ? "[x]" : "[ ]");
    RenderText(text_bb.GetTL(), label);
}

void CheckboxFlags(const char* label, unsigned int* flags, unsigned int flags_value)
{
    bool v = (*flags & flags_value) ? true : false;
    ImGui::Checkbox(label, &v);
    if (v)
        *flags |= flags_value;
    else
        *flags &= ~flags_value;
}

bool RadioButton(const char* label, bool active)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return false;

    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);

    const ImVec2 text_size = CalcTextSize(label);

    const ImGuiAabb check_bb(window->DC.CursorPos, window->DC.CursorPos + ImVec2(text_size.y + style.FramePadding.y*2-1, text_size.y + style.FramePadding.y*2-1));
    ItemSize(check_bb);
    SameLine(0, (int)style.ItemInnerSpacing.x);

    const ImGuiAabb text_bb(window->DC.CursorPos + ImVec2(0, style.FramePadding.y), window->DC.CursorPos + ImVec2(0, style.FramePadding.y) + text_size);
    ItemSize(ImVec2(text_bb.GetWidth(), check_bb.GetHeight()));

    if (ClipAdvance(check_bb))
        return false;

    ImVec2 center = check_bb.GetCenter();
    center.x = (float)(int)center.x + 0.5f;
    center.y = (float)(int)center.y + 0.5f;
    const float radius = check_bb.GetHeight() * 0.5f;

    const bool hovered = (g.HoveredWindow == window) && (g.HoveredId == 0) && IsMouseHoveringBox(check_bb);
    const bool pressed = hovered && g.IO.MouseClicked[0];
    if (hovered)
        g.HoveredId = id;

    window->DrawList->AddCircleFilled(center, radius, window->Color(ImGuiCol_FrameBg), 16);
    if (active)
        window->DrawList->AddCircleFilled(center, radius-2, window->Color(ImGuiCol_CheckActive), 16);

    if (window->Flags & ImGuiWindowFlags_ShowBorders)
    {
        window->DrawList->AddCircle(center+ImVec2(1,1), radius, window->Color(ImGuiCol_BorderShadow), 16);
        window->DrawList->AddCircle(center, radius, window->Color(ImGuiCol_Border), 16);
    }

    RenderText(text_bb.GetTL(), label);

    return pressed;
}

bool RadioButton(const char* label, int* v, int v_button)
{
    const bool pressed = ImGui::RadioButton(label, *v == v_button);
    if (pressed)
    {
        *v = v_button;
    }
    return pressed;
}

}; // namespace ImGui

// Wrapper for stb_textedit.h to edit text (our wrapper is for: statically sized buffer, single-line, ASCII, fixed-width font)
int		STB_TEXTEDIT_STRINGLEN(const STB_TEXTEDIT_STRING* obj)									{ return (int)strlen(obj->Text); }
char	STB_TEXTEDIT_GETCHAR(const STB_TEXTEDIT_STRING* obj, int idx)							{ return (char)obj->Text[idx]; }
float	STB_TEXTEDIT_GETWIDTH(STB_TEXTEDIT_STRING* obj, int line_start_idx, int char_idx)		{ return obj->Font->CalcTextSize(obj->FontSize, 0, &obj->Text[char_idx], &obj->Text[char_idx]+1, NULL).x; }
char	STB_TEXTEDIT_KEYTOTEXT(int key)															{ return key >= 0x10000 ? 0 : (char)key; }
char	STB_TEXTEDIT_NEWLINE = '\n';
void	STB_TEXTEDIT_LAYOUTROW(StbTexteditRow* r, STB_TEXTEDIT_STRING* obj, int line_start_idx)
{
    const char* text_remaining = NULL;
    const ImVec2 size = obj->Font->CalcTextSize(obj->FontSize, FLT_MAX, obj->Text + line_start_idx, NULL, &text_remaining);
    r->x0 = 0.0f;
    r->x1 = size.x;
    r->baseline_y_delta = size.y;
    r->ymin = 0.0f;
    r->ymax = size.y;
    r->num_chars = (int)(text_remaining - (obj->Text + line_start_idx));
}

static bool is_white(char c)		{ return c==0 || c==' ' || c=='\t' || c=='\r' || c=='\n'; }
static bool is_separator(char c)	{ return c==',' || c==';' || c=='(' || c==')' || c=='{' || c=='}' || c=='[' || c==']' || c=='|'; }

#define	STB_TEXTEDIT_IS_SPACE(c)																(is_white(c) || is_separator(c))
void	STB_TEXTEDIT_DELETECHARS(STB_TEXTEDIT_STRING* obj, int idx, int n)						{ char* dst = obj->Text+idx; const char* src = obj->Text+idx+n; while (char c = *src++) *dst++ = c; *dst = '\0'; }

bool	STB_TEXTEDIT_INSERTCHARS(STB_TEXTEDIT_STRING* obj, int idx, const char* new_text, int new_text_size)
{
    char* buf_end = obj->Text + obj->MaxLength;
    int text_size = strlen(obj->Text);

    if (new_text_size > buf_end - (obj->Text + text_size + 1))
        return false;

    memmove(obj->Text + idx + new_text_size, obj->Text + idx, text_size - idx);
    memcpy(obj->Text + idx, new_text, new_text_size);
    obj->Text[text_size + new_text_size] = 0;

    return true;
}

enum
{
    STB_TEXTEDIT_K_LEFT = 1 << 16,	// keyboard input to move cursor left
    STB_TEXTEDIT_K_RIGHT,			// keyboard input to move cursor right
    STB_TEXTEDIT_K_UP,				// keyboard input to move cursor up
    STB_TEXTEDIT_K_DOWN,			// keyboard input to move cursor down
    STB_TEXTEDIT_K_LINESTART,		// keyboard input to move cursor to start of line
    STB_TEXTEDIT_K_LINEEND,			// keyboard input to move cursor to end of line
    STB_TEXTEDIT_K_TEXTSTART,		// keyboard input to move cursor to start of text
    STB_TEXTEDIT_K_TEXTEND,			// keyboard input to move cursor to end of text
    STB_TEXTEDIT_K_DELETE,			// keyboard input to delete selection or character under cursor
    STB_TEXTEDIT_K_BACKSPACE,		// keyboard input to delete selection or character left of cursor
    STB_TEXTEDIT_K_UNDO,			// keyboard input to perform undo
    STB_TEXTEDIT_K_REDO,			// keyboard input to perform redo
    STB_TEXTEDIT_K_WORDLEFT,		// keyboard input to move cursor left one word
    STB_TEXTEDIT_K_WORDRIGHT,		// keyboard input to move cursor right one word
    STB_TEXTEDIT_K_SHIFT = 1 << 17,
};

#define STB_TEXTEDIT_IMPLEMENTATION
#include "stb_textedit.h"

void ImGuiTextEditState::OnKeyboardPressed(int key)
{
    stb_textedit_key(this, &StbState, key);
    CursorAnimReset();
}

void ImGuiTextEditState::UpdateScrollOffset()
{
    // Scroll in chunks of quarter width
    const float scroll_x_increment = Width * 0.25f;
    const float cursor_offset_x = Font->CalcTextSize(FontSize, 0, Text, Text+StbState.cursor, NULL).x;
    if (ScrollX > cursor_offset_x)
        ScrollX = ImMax(0.0f, cursor_offset_x - scroll_x_increment);
    else if (ScrollX < cursor_offset_x - Width)
        ScrollX = cursor_offset_x - Width + scroll_x_increment;
}

ImVec2 ImGuiTextEditState::CalcDisplayOffsetFromCharIdx(int i) const
{
    const char* text_start = GetTextPointerClipped(Font, FontSize, Text, ScrollX, NULL);
    const char* text_end = (Text+i >= text_start) ? Text+i : text_start;					// Clip if requested character is outside of display
    ZELO_ASSERT(text_end >= text_start);

    const ImVec2 offset = Font->CalcTextSize(FontSize, Width, text_start, text_end, NULL);
    return offset;
}

// [Static]
const char*	ImGuiTextEditState::GetTextPointerClipped(ImFont font, float font_size, const char* text, float width, ImVec2* out_text_size)
{
    if (width <= 0.0f)
        return text;

    const char* text_clipped_end = NULL;
    const ImVec2 text_size = font->CalcTextSize(font_size, width, text, NULL, &text_clipped_end);
    if (out_text_size)
        *out_text_size = text_size;
    return text_clipped_end;
}

// [Static]
void ImGuiTextEditState::RenderTextScrolledClipped(ImFont font, float font_size, const char* buf, ImVec2 pos, float width, float scroll_x)
{
    // NB- We start drawing at character boundary
    ImVec2 text_size;
    const char* text_start = GetTextPointerClipped(font, font_size, buf, scroll_x, NULL);
    const char* text_end = GetTextPointerClipped(font, font_size, text_start, width, &text_size);

    // Draw a little clip symbol if we've got text on either left or right of the box
    const char symbol_c = '~';
    const float symbol_w = font_size*0.40f;		// FIXME: compute correct width
    const float clip_begin = (text_start > buf && text_start < text_end) ? symbol_w : 0.0f;
    const float clip_end = (text_end[0] != '\0' && text_end > text_start) ? symbol_w : 0.0f;

    // Draw text
    ImGui::RenderText(pos+ImVec2(clip_begin,0), text_start+(clip_begin?1:0), text_end-(clip_end?1:0), false);//, &text_params_with_clipping);

    // Draw the clip symbol
    const char s[2] = {symbol_c,'\0'};
    if (clip_begin > 0.0f)
        ImGui::RenderText(pos, s);
    if (clip_end > 0.0f)
        ImGui::RenderText(pos+ImVec2(width-clip_end,0.0f), s);
}

namespace ImGui
{

bool InputFloat(const char* label, float *v, float step, float step_fast, int decimal_precision)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return false;

    const ImGuiStyle& style = g.Style;
    const float w = window->DC.ItemWidth.back();
    const ImVec2 text_size = CalcTextSize(label);
    const ImGuiAabb frame_bb(window->DC.CursorPos, window->DC.CursorPos + ImVec2(w, text_size.y) + style.FramePadding*2.0f);

    ImGui::PushID(label);
    const float button_sz = window->FontSize();
    if (step)
        ImGui::PushItemWidth(ImMax(1.0f, window->DC.ItemWidth.back() - (button_sz+g.Style.FramePadding.x*2.0f+g.Style.ItemInnerSpacing.x)*2));

    char buf[64];
    if (decimal_precision < 0)
        ImFormatString(buf, ARRAYSIZE(buf), "%f", *v);		// Ideally we'd have a minimum decimal precision of 1 to visually denote that it is a float, while hiding non-significant digits?
    else
        ImFormatString(buf, ARRAYSIZE(buf), "%.*f", decimal_precision, *v);
    bool value_changed = false;
    if (ImGui::InputText("", buf, ARRAYSIZE(buf), ImGuiInputTextFlags_CharsDecimal|ImGuiInputTextFlags_AlignCenter|ImGuiInputTextFlags_AutoSelectAll))
    {
        ApplyNumericalTextInput(buf, v);
        value_changed = true;
    }
    if (step)
        ImGui::PopItemWidth();

    if (step)
    {
        ImGui::SameLine(0, 0);
        if (ImGui::Button("-", ImVec2(button_sz,button_sz), true))
        {
            *v -= g.IO.KeyCtrl && step_fast ? step_fast : step;
            value_changed = true;
        }
        ImGui::SameLine(0, (int)g.Style.ItemInnerSpacing.x);
        if (ImGui::Button("+", ImVec2(button_sz,button_sz), true))
        {
            *v += g.IO.KeyCtrl && step_fast  ? step_fast : step;
            value_changed = true;
        }
    }

    ImGui::PopID();

    RenderText(ImVec2(frame_bb.Max.x + style.ItemInnerSpacing.x, frame_bb.Min.y + g.Style.FramePadding.y), label);

    //ImGui::SameLine(0, (int)g.Style.ItemInnerSpacing.x);
    //ImGui::TextUnformatted(label, FindTextDisplayEnd(label));

    return value_changed;
}

bool InputInt(const char* label, int *v, int step, int step_fast)
{
    float f = (float)*v;
    const bool value_changed = ImGui::InputFloat(label, &f, (float)step, (float)step_fast, 0);
    *v = (int)f;
    return value_changed;
}

bool InputText(const char* label, char* buf, size_t buf_size, ImGuiInputTextFlags flags)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return false;

    const ImGuiIO& io = g.IO;
    const ImGuiStyle& style = g.Style;

    const ImGuiID id = window->GetID(label);
    const float w = window->DC.ItemWidth.back();

    const ImVec2 text_size = CalcTextSize(label);
    const ImGuiAabb frame_bb(window->DC.CursorPos, window->DC.CursorPos + ImVec2(w, text_size.y) + style.FramePadding*2.0f);
    const ImGuiAabb bb(frame_bb.Min, frame_bb.Max + ImVec2(style.ItemInnerSpacing.x + text_size.x, 0.0f));
    ItemSize(bb);

    if (ClipAdvance(frame_bb))
        return false;

    // NB: we can only read/write if we are the active widget!
    ImGuiTextEditState& edit_state = g.InputTextState;

    const bool is_ctrl_down = io.KeyCtrl;
    const bool is_shift_down = io.KeyShift;
    const bool tab_focus_requested = window->FocusItemRegister(g.ActiveId == id);
    //const bool align_center = (bool)(flags & ImGuiInputTextFlags_AlignCenter);	// FIXME: Unsupported

    const bool hovered = (g.HoveredWindow == window) && (g.HoveredId == 0) && IsMouseHoveringBox(frame_bb);
    if (hovered)
        g.HoveredId = id;

    bool select_all = (g.ActiveId != id) && (flags & ImGuiInputTextFlags_AutoSelectAll) != 0;
    if (tab_focus_requested || (hovered && io.MouseClicked[0]))
    {
        if (g.ActiveId != id)
        {
            // Start edition
            strcpy(edit_state.Text, buf);
            strcpy(edit_state.InitialText, buf);
            edit_state.ScrollX = 0.0f;
            edit_state.Width = w;
            stb_textedit_initialize_state(&edit_state.StbState, true);
            edit_state.CursorAnimReset();

            if (tab_focus_requested || is_ctrl_down)
                select_all = true;
        }
        g.ActiveId = id;
    }
    else if (io.MouseClicked[0])
    {
        // Release focus when we click outside
        if (g.ActiveId == id)
        {
            g.ActiveId = 0;
        }
    }

    bool value_changed = false;
    bool cancel_edit = false;
    if (g.ActiveId == id)
    {
        edit_state.MaxLength = buf_size < ARRAYSIZE(edit_state.Text) ? buf_size : ARRAYSIZE(edit_state.Text);
        edit_state.Font = window->Font();
        edit_state.FontSize = window->FontSize();

        const float mx = g.IO.MousePos.x - frame_bb.Min.x - style.FramePadding.x;
        const float my = window->FontSize()*0.5f;	// Better for single line

        edit_state.UpdateScrollOffset();
        if (select_all || (hovered && io.MouseDoubleClicked[0]))
        {
            edit_state.SelectAll();
            edit_state.SelectedAllMouseLock = true;
        }
        else if (io.MouseClicked[0] && !edit_state.SelectedAllMouseLock)
        {
            stb_textedit_click(&edit_state, &edit_state.StbState, mx + edit_state.ScrollX, my);
            edit_state.CursorAnimReset();

        }
        else if (io.MouseDown[0] && !edit_state.SelectedAllMouseLock)
        {
            stb_textedit_drag(&edit_state, &edit_state.StbState, mx + edit_state.ScrollX, my);
            edit_state.CursorAnimReset();
        }
        if (edit_state.SelectedAllMouseLock && !io.MouseDown[0])
            edit_state.SelectedAllMouseLock = false;

        const int k_mask = (is_shift_down ? STB_TEXTEDIT_K_SHIFT : 0);
        if (IsKeyPressedMap(ImGuiKey_LeftArrow))			edit_state.OnKeyboardPressed(is_ctrl_down ? STB_TEXTEDIT_K_WORDLEFT | k_mask : STB_TEXTEDIT_K_LEFT | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_RightArrow))			edit_state.OnKeyboardPressed(is_ctrl_down ? STB_TEXTEDIT_K_WORDRIGHT | k_mask  : STB_TEXTEDIT_K_RIGHT | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_UpArrow))				edit_state.OnKeyboardPressed(STB_TEXTEDIT_K_UP | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_DownArrow))			edit_state.OnKeyboardPressed(STB_TEXTEDIT_K_DOWN | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_Home))				edit_state.OnKeyboardPressed(is_ctrl_down ? STB_TEXTEDIT_K_TEXTSTART | k_mask : STB_TEXTEDIT_K_LINESTART | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_End))					edit_state.OnKeyboardPressed(is_ctrl_down ? STB_TEXTEDIT_K_TEXTEND | k_mask : STB_TEXTEDIT_K_LINEEND | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_Delete))				edit_state.OnKeyboardPressed(STB_TEXTEDIT_K_DELETE | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_Backspace))			edit_state.OnKeyboardPressed(STB_TEXTEDIT_K_BACKSPACE | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_Enter))				{ g.ActiveId = 0; }
        else if (IsKeyPressedMap(ImGuiKey_Escape))				{ g.ActiveId = 0; cancel_edit = true; }
        else if (is_ctrl_down && IsKeyPressedMap(ImGuiKey_Z))	edit_state.OnKeyboardPressed(STB_TEXTEDIT_K_UNDO);		// I don't want to use shortcuts but we should probably have an Input-catch stack
        else if (is_ctrl_down && IsKeyPressedMap(ImGuiKey_Y))	edit_state.OnKeyboardPressed(STB_TEXTEDIT_K_REDO);
        else if (is_ctrl_down && IsKeyPressedMap(ImGuiKey_A))	edit_state.SelectAll();
        else if (is_ctrl_down && IsKeyPressedMap(ImGuiKey_X))
        {
            if (!edit_state.HasSelection())
                edit_state.SelectAll();

            const int ib = ImMin(edit_state.StbState.select_start, edit_state.StbState.select_end);
            const int ie = ImMax(edit_state.StbState.select_start, edit_state.StbState.select_end);
            if (g.IO.SetClipboardTextFn)
                g.IO.SetClipboardTextFn(edit_state.Text+ib, edit_state.Text+ie);
            stb_textedit_cut(&edit_state, &edit_state.StbState);
        }
        else if (is_ctrl_down && IsKeyPressedMap(ImGuiKey_C))
        {
            const int ib = edit_state.HasSelection() ? ImMin(edit_state.StbState.select_start, edit_state.StbState.select_end) : 0;
            const int ie = edit_state.HasSelection() ? ImMax(edit_state.StbState.select_start, edit_state.StbState.select_end) : (int)strlen(edit_state.Text);
            if (g.IO.SetClipboardTextFn)
                g.IO.SetClipboardTextFn(edit_state.Text+ib, edit_state.Text+ie);
        }
        else if (is_ctrl_down && IsKeyPressedMap(ImGuiKey_V))
        {
            if (g.IO.GetClipboardTextFn)
                if (const char* clipboard = g.IO.GetClipboardTextFn())
                {
                    // Remove new-line from pasted buffer
                    int clipboard_len = strlen(clipboard);
                    char* clipboard_filtered = (char*)malloc(clipboard_len+1);
                    int clipboard_filtered_len = 0;
                    for (int i = 0; clipboard[i]; i++)
                    {
                        const char c = clipboard[i];
                        if (c == '\n' || c == '\r')
                            continue;
                        clipboard_filtered[clipboard_filtered_len++] = clipboard[i];
                    }
                    clipboard_filtered[clipboard_filtered_len] = 0;
                    stb_textedit_paste(&edit_state, &edit_state.StbState, clipboard_filtered, clipboard_filtered_len);
                    free(clipboard_filtered);
                }
        }
        else if (g.IO.InputCharacters[0])
        {
            // Text input
            for (int n = 0; n < ARRAYSIZE(g.IO.InputCharacters) && g.IO.InputCharacters[n]; n++)
            {
                const char c = g.IO.InputCharacters[n];
                if (c)
                {
                    // Filter
                    if (!isprint(c) && c != ' ')
                        continue;
                    if (flags & ImGuiInputTextFlags_CharsDecimal)
                        if (!(c >= '0' && c <= '9') && (c != '.') && (c != '-') && (c != '+') && (c != '*') && (c != '/'))
                            continue;
                    if (flags & ImGuiInputTextFlags_CharsHexadecimal)
                        if (!(c >= '0' && c <= '9') && !(c >= 'a' && c <= 'f') && !(c >= 'A' && c <= 'F'))
                            continue;

                    // Insert character!
                    edit_state.OnKeyboardPressed(c);
                }
            }
        }

        edit_state.CursorAnim += g.IO.DeltaTime;
        edit_state.UpdateScrollOffset();

        if (cancel_edit)
        {
            // Restore initial value
            ImFormatString(buf, buf_size, "%s", edit_state.InitialText);
            value_changed = true;
        }
        else
        {
            // Apply new value immediately - copy modified buffer back
            if (strcmp(edit_state.Text, buf) != 0)
            {
                ImFormatString(buf, buf_size, "%s", edit_state.Text);
                value_changed = true;
            }
        }
    }

    RenderFrame(frame_bb.Min, frame_bb.Max, window->Color(ImGuiCol_FrameBg), true);//, style.Rounding);

    const ImVec2 font_off_up = ImVec2(0.0f,window->FontSize()+1.0f);	// FIXME: this should be part of the font API
    const ImVec2 font_off_dn = ImVec2(0.0f,2.0f);

    if (g.ActiveId == id)
    {
        // Draw selection
        const int select_begin_idx = edit_state.StbState.select_start;
        const int select_end_idx = edit_state.StbState.select_end;
        if (select_begin_idx != select_end_idx)
        {
            const ImVec2 select_begin_pos = frame_bb.Min + style.FramePadding + edit_state.CalcDisplayOffsetFromCharIdx(ImMin(select_begin_idx,select_end_idx));
            const ImVec2 select_end_pos = frame_bb.Min + style.FramePadding + edit_state.CalcDisplayOffsetFromCharIdx(ImMax(select_begin_idx,select_end_idx));
            window->DrawList->AddRectFilled(select_begin_pos - font_off_up, select_end_pos + font_off_dn, window->Color(ImGuiCol_TextSelectedBg));
        }
    }

    // FIXME: 'align_center' unsupported
    ImGuiTextEditState::RenderTextScrolledClipped(window->Font(), window->FontSize(), buf, frame_bb.Min + style.FramePadding, w, (g.ActiveId == id) ? edit_state.ScrollX : 0.0f);

    if (g.ActiveId == id)
    {
        // Draw blinking cursor
        if (g.InputTextState.CursorIsVisible())
        {
            const ImVec2 cursor_pos = frame_bb.Min + style.FramePadding + edit_state.CalcDisplayOffsetFromCharIdx(edit_state.StbState.cursor);
            window->DrawList->AddRect(cursor_pos - font_off_up + ImVec2(0,2), cursor_pos + font_off_dn - ImVec2(0,3), window->Color(ImGuiCol_Text));
        }
    }

    RenderText(ImVec2(frame_bb.Max.x + style.ItemInnerSpacing.x, frame_bb.Min.y + style.FramePadding.y), label);

    return value_changed;
}

bool InputFloat3(const char* label, float v[3], int decimal_precision)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return false;

    const ImGuiStyle& style = g.Style;
    const ImVec2 text_size = CalcTextSize(label);

    bool value_changed = false;

    ImGui::PushID(label);

    const int components = 3;
    const float w_full = window->DC.ItemWidth.back();
    const float w_item_one  = ImMax(1.0f, (float)(int)((w_full - (style.FramePadding.x*2.0f+style.ItemInnerSpacing.x) * (components-1)) / (float)components));
    const float w_item_last = ImMax(1.0f, (float)(int)(w_full - (w_item_one+style.FramePadding.x*2.0f+style.ItemInnerSpacing.x) * (components-1)));

    ImGui::PushItemWidth(w_item_one);
    value_changed |= ImGui::InputFloat("##X", &v[0], 0, 0, decimal_precision);
    ImGui::SameLine(0, 0);
    value_changed |= ImGui::InputFloat("##Y", &v[1], 0, 0, decimal_precision);
    ImGui::SameLine(0, 0);
    ImGui::PopItemWidth();

    ImGui::PushItemWidth(w_item_last);
    value_changed |= ImGui::InputFloat("##Z", &v[2], 0, 0, decimal_precision);
    ImGui::SameLine(0, 0);
    ImGui::PopItemWidth();

    ImGui::TextUnformatted(label, FindTextDisplayEnd(label));

    ImGui::PopID();

    return value_changed;
}

static bool Combo_ArrayGetter(void* data, int idx, const char** out_text)
{
    const char** items = (const char**)data;
    if (out_text)
        *out_text = items[idx];
    return true;
}

bool Combo(const char* label, int* current_item, const char** items, int items_count, int popup_height_items)
{
    bool value_changed = Combo(label, current_item, Combo_ArrayGetter, (void*)items, items_count, popup_height_items);
    return value_changed;
}

static bool Combo_StringListGetter(void* data, int idx, const char** out_text)
{
    // FIXME-OPT: we could precompute the indices but let's not bother now.
    const char* items_separated_by_zeros = (const char*)data;
    int items_count = 0;
    const char* p = items_separated_by_zeros;
    while (*p)
    {
        if (idx == items_count)
            break;
        p += strlen(p) + 1;
        items_count++;
    }
    if (!*p)
        return false;
    if (out_text)
        *out_text = p;
    return true;
}

bool Combo(const char* label, int* current_item, const char* items_separated_by_zeros, int popup_height_items)
{
    int items_count = 0;
    const char* p = items_separated_by_zeros;
    while (*p)
    {
        p += strlen(p) + 1;
        items_count++;
    }
    bool value_changed = Combo(label, current_item, Combo_StringListGetter, (void*)items_separated_by_zeros, items_count, popup_height_items);
    return value_changed;
}

bool Combo(const char* label, int* current_item, bool (*items_getter)(void*, int, const char**), void* data, int items_count, int popup_height_items)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return false;

    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);

    const ImVec2 text_size = CalcTextSize(label);
    const float arrow_size = (window->FontSize() + style.FramePadding.x * 2.0f);
    const ImGuiAabb frame_bb(window->DC.CursorPos, window->DC.CursorPos + ImVec2(window->DC.ItemWidth.back(), text_size.y) + style.FramePadding*2.0f);
    const ImGuiAabb bb(frame_bb.Min, frame_bb.Max + ImVec2(style.ItemInnerSpacing.x + text_size.x,0));

    if (ClipAdvance(frame_bb))
        return false;

    bool value_changed = false;
    ItemSize(frame_bb);
    RenderFrame(frame_bb.Min, frame_bb.Max, window->Color(ImGuiCol_FrameBg));
    RenderFrame(ImVec2(frame_bb.Max.x-arrow_size, frame_bb.Min.y), frame_bb.Max, window->Color(ImGuiCol_Button));
    RenderCollapseTriangle(ImVec2(frame_bb.Max.x-arrow_size, frame_bb.Min.y) + style.FramePadding, true);

    if (*current_item >= 0 && *current_item < items_count)
    {
        const char* item_text;
        if (items_getter(data, *current_item, &item_text))
            RenderText(frame_bb.Min + style.FramePadding, item_text, NULL, false);
    }

    ImGui::SameLine(0, (int)g.Style.ItemInnerSpacing.x);
    ImGui::TextUnformatted(label, FindTextDisplayEnd(label));

    ImGui::PushID(id);
    const bool hovered = (g.HoveredWindow == window) && (g.HoveredId == 0) && IsMouseHoveringBox(bb);
    bool menu_toggled = false;
    if (hovered)
    {
        g.HoveredId = id;
        if (g.IO.MouseClicked[0])
        {
            menu_toggled = true;
            g.ActiveComboID = (g.ActiveComboID == id) ? 0 : id;
        }
    }

    if (g.ActiveComboID == id)
    {
        const ImVec2 backup_pos = ImGui::GetCursorPos();
        const float popup_off_x = 0.0f;//g.Style.ItemInnerSpacing.x;
        const float popup_height = (text_size.y + g.Style.ItemSpacing.y) * ImMin(items_count, popup_height_items) + g.Style.WindowPadding.y;
        const ImGuiAabb popup_aabb(ImVec2(frame_bb.Min.x+popup_off_x, frame_bb.Max.y), ImVec2(frame_bb.Max.x+popup_off_x, frame_bb.Max.y + popup_height));
        ImGui::SetCursorPos(popup_aabb.Min - window->Pos);

        ImGuiWindowFlags flags = ImGuiWindowFlags_ComboBox | ((window->Flags & ImGuiWindowFlags_ShowBorders) ? ImGuiWindowFlags_ShowBorders : 0);
        ImGui::BeginChild("#ComboBox", popup_aabb.GetSize(), false, flags);
        ImGuiWindow* child_window = GetCurrentWindow();

        bool combo_item_active = false;
        combo_item_active |= (g.ActiveId == child_window->GetID("#SCROLLY"));

        for (int item_idx = 0; item_idx < items_count; item_idx++)
        {
            const float item_h = child_window->FontSize();
            const float spacing_up = (float)(int)(g.Style.ItemSpacing.y/2);
            const float spacing_dn = g.Style.ItemSpacing.y - spacing_up;
            const ImGuiAabb item_aabb(ImVec2(popup_aabb.Min.x, child_window->DC.CursorPos.y - spacing_up), ImVec2(popup_aabb.Max.x, child_window->DC.CursorPos.y + item_h + spacing_dn));
            const ImGuiID item_id = child_window->GetID((void*)(intptr_t)item_idx);

            bool item_hovered, item_held;
            bool item_pressed = ButtonBehaviour(item_aabb, item_id, &item_hovered, &item_held);
            bool item_selected = item_idx == *current_item;

            if (item_hovered || item_selected)
            {
                const ImU32 col = window->Color((item_held && item_hovered) ? ImGuiCol_HeaderActive : item_hovered ? ImGuiCol_HeaderHovered : ImGuiCol_Header);
                RenderFrame(item_aabb.Min, item_aabb.Max, col, false);
            }

            const char* item_text;
            if (!items_getter(data, item_idx, &item_text))
                item_text = "*Unknown item*";
            ImGui::Text("%s", item_text);

            if (item_selected)
            {
                if (menu_toggled)
                    ImGui::SetScrollPosHere();
            }
            if (item_pressed)
            {
                g.ActiveId = 0;
                g.ActiveComboID = 0;
                value_changed = true;
                *current_item = item_idx;
            }

            combo_item_active |= (g.ActiveId == item_id);
        }
        ImGui::EndChild();
        ImGui::SetCursorPos(backup_pos);

        if (!combo_item_active && g.ActiveId != 0)
            g.ActiveComboID = 0;
    }

    ImGui::PopID();

    return value_changed;
}

// A little colored square. Return true when clicked.
bool ColorButton(const ImVec4& col, bool small_height, bool outline_border)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return false;

    const ImGuiStyle& style = g.Style;
    const float square_size = window->FontSize();
    const ImGuiAabb bb(window->DC.CursorPos, window->DC.CursorPos + ImVec2(square_size + style.FramePadding.x*2, square_size + (small_height ? 0 : style.FramePadding.y*2)));
    ItemSize(bb);

    if (ClipAdvance(bb))
        return false;

    const bool hovered = (g.HoveredWindow == window) && (g.HoveredId == 0) && IsMouseHoveringBox(bb);
    const bool pressed = hovered && g.IO.MouseClicked[0];

    const ImU32 col32 = ImConvertColorFloat4ToU32(col);
    RenderFrame(bb.Min, bb.Max, col32, outline_border);

    if (hovered)
    {
        int ix = (int)(col.x * 255.0f + 0.5f);
        int iy = (int)(col.y * 255.0f + 0.5f);
        int iz = (int)(col.z * 255.0f + 0.5f);
        int iw = (int)(col.w * 255.0f + 0.5f);
        ImGui::SetTooltip("Color:\n(%.2f,%.2f,%.2f,%.2f)\n#%02X%02X%02X%02X", col.x, col.y, col.z, col.w, ix, iy, iz, iw);
    }

    return pressed;
}

bool ColorEdit3(const char* label, float col[3])
{
    float col4[4];
    col4[0] = col[0];
    col4[1] = col[1];
    col4[2] = col[2];
    col4[3] = 1.0f;
    bool value_changed = ImGui::ColorEdit4(label, col4, false);
    col[0] = col4[0];
    col[1] = col4[1];
    col[2] = col4[2];
    return value_changed;
}

// Edit colours components color in 0..1 range
// Use CTRL-Click to input value and TAB to go to next item.
bool ColorEdit4(const char* label, float col[4], bool alpha)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return false;

    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);
    const float w_full = window->DC.ItemWidth.back();
    const float square_sz = (window->FontSize() + style.FramePadding.x * 2.0f);

    const ImVec2 text_size = CalcTextSize(label);

    ImGuiColorEditMode edit_mode = window->DC.ColorEditMode;
    if (edit_mode == ImGuiColorEditMode_UserSelect)
        edit_mode = g.ColorEditModeStorage.GetInt(id, 0) % 3;

    float fx = col[0];
    float fy = col[1];
    float fz = col[2];
    float fw = col[3];
    const ImVec4 col_display(fx, fy, fz, 1.0f);

    if (edit_mode == ImGuiColorEditMode_HSV)
        ImConvertColorRGBtoHSV(fx, fy, fz, fx, fy, fz);

    int ix = (int)(fx * 255.0f + 0.5f);
    int iy = (int)(fy * 255.0f + 0.5f);
    int iz = (int)(fz * 255.0f + 0.5f);
    int iw = (int)(fw * 255.0f + 0.5f);

    int components = alpha ? 4 : 3;
    bool value_changed = false;

    ImGui::PushID(label);

    bool hsv = (edit_mode == 1);
    switch (edit_mode)
    {
        case ImGuiColorEditMode_RGB:
        case ImGuiColorEditMode_HSV:
        {
            // 0: RGB 0..255
            // 1: HSV 0.255 Sliders
            const float w_items_all = w_full - (square_sz + style.ItemInnerSpacing.x);
            const float w_item_one  = ImMax(1.0f, (float)(int)((w_items_all - (style.FramePadding.x*2.0f+style.ItemInnerSpacing.x) * (components-1)) / (float)components));
            const float w_item_last = ImMax(1.0f, (float)(int)(w_items_all - (w_item_one+style.FramePadding.x*2.0f+style.ItemInnerSpacing.x) * (components-1)));

            ImGui::PushItemWidth(w_item_one);
            value_changed |= ImGui::SliderInt("##X", &ix, 0, 255, hsv ? "H:%3.0f" : "R:%3.0f");
            ImGui::SameLine(0, 0);
            value_changed |= ImGui::SliderInt("##Y", &iy, 0, 255, hsv ? "S:%3.0f" : "G:%3.0f");
            ImGui::SameLine(0, 0);
            if (alpha)
            {
                value_changed |= ImGui::SliderInt("##Z", &iz, 0, 255, hsv ? "V:%3.0f" : "B:%3.0f");
                ImGui::SameLine(0, 0);
                ImGui::PushItemWidth(w_item_last);
                value_changed |= ImGui::SliderInt("##W", &iw, 0, 255, "A:%3.0f");
            }
            else
            {
                ImGui::PushItemWidth(w_item_last);
                value_changed |= ImGui::SliderInt("##Z", &iz, 0, 255, hsv ? "V:%3.0f" : "B:%3.0f");
            }
            ImGui::PopItemWidth();
            ImGui::PopItemWidth();
        }
            break;
        case ImGuiColorEditMode_HEX:
        {
            // 2: RGB Hexadecimal
            const float w_slider_all = w_full - square_sz;
            char buf[64];
            if (alpha)
                sprintf(buf, "#%02X%02X%02X%02X", ix, iy, iz, iw);
            else
                sprintf(buf, "#%02X%02X%02X", ix, iy, iz);
            ImGui::PushItemWidth(w_slider_all - g.Style.ItemInnerSpacing.x);
            value_changed |= ImGui::InputText("##Text", buf, ARRAYSIZE(buf), ImGuiInputTextFlags_CharsHexadecimal);
            ImGui::PopItemWidth();
            char* p = buf;
            while (*p == '#' || *p == ' ' || *p == '\t')
                p++;
            ix = iy = iz = iw = 0;
            if (alpha)
                sscanf(p, "%02X%02X%02X%02X", &ix, &iy, &iz, &iw);
            else
                sscanf(p, "%02X%02X%02X", &ix, &iy, &iz);
        }
            break;
    }

    ImGui::SameLine(0, 0);
    ImGui::ColorButton(col_display);

    if (window->DC.ColorEditMode == ImGuiColorEditMode_UserSelect)
    {
        ImGui::SameLine(0, (int)style.ItemInnerSpacing.x);
        const char* button_titles[3] = { "RGB", "HSV", "HEX" };
        if (ImGui::Button(button_titles[edit_mode]))
        {
            // Don't set 'edit_mode' right away!
            g.ColorEditModeStorage.SetInt(id, (edit_mode + 1) % 3);
        }
    }

    ImGui::SameLine();
    ImGui::TextUnformatted(label, FindTextDisplayEnd(label));

    // Convert back
    fx = ix / 255.0f;
    fy = iy / 255.0f;
    fz = iz / 255.0f;
    fw = iw / 255.0f;
    if (edit_mode == 1)
        ImConvertColorHSVtoRGB(fx, fy, fz, fx, fy, fz);

    if (value_changed)
    {
        col[0] = fx;
        col[1] = fy;
        col[2] = fz;
        if (alpha)
            col[3] = fw;
    }

    ImGui::PopID();

    return value_changed;
}

void ColorEditMode(ImGuiColorEditMode mode)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    window->DC.ColorEditMode = mode;
}

void Separator()
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return;

    if (window->DC.ColumnsCount > 1)
        ImGui::PopClipRect();

    const ImGuiAabb bb(ImVec2(window->Pos.x, window->DC.CursorPos.y), ImVec2(window->Pos.x + window->Size.x, window->DC.CursorPos.y));
    ItemSize(ImVec2(0.0f, bb.GetSize().y));	// NB: we don't provide our width so that it doesn't get feed back into AutoFit

    if (ClipAdvance(bb, true))
    {
        if (window->DC.ColumnsCount > 1)
            ImGui::PushColumnClipRect();
        return;
    }

    window->DrawList->AddLine(bb.Min, bb.Max, window->Color(ImGuiCol_Border));

    if (window->DC.ColumnsCount > 1)
        ImGui::PushColumnClipRect();
}

void Spacing()
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return;

    ItemSize(ImVec2(0,0));
}

static void ItemSize(ImVec2 size, ImVec2* adjust_start_offset)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return;

    const float line_height = ImMax(window->DC.CurrentLineHeight, size.y);
    if (adjust_start_offset)
        adjust_start_offset->y = adjust_start_offset->y + (line_height - size.y) * 0.5f;

    // Always align ourselves on pixel boundaries
    window->DC.CursorPosPrevLine = ImVec2(window->DC.CursorPos.x + size.x, window->DC.CursorPos.y);
    window->DC.CursorPos = ImVec2((float)(int)(window->Pos.x + window->DC.ColumnStartX), (float)(int)(window->DC.CursorPos.y + line_height + g.Style.ItemSpacing.y));

    window->SizeContentsFit = ImMax(window->SizeContentsFit, ImVec2(window->DC.CursorPosPrevLine.x, window->DC.CursorPos.y) - window->Pos + ImVec2(0.0f, window->ScrollY));

    window->DC.PrevLineHeight = line_height;
    window->DC.CurrentLineHeight = 0.0f;
}

static void ItemSize(const ImGuiAabb& aabb, ImVec2* adjust_start_offset)
{
    ItemSize(aabb.GetSize(), adjust_start_offset);
}

void NextColumn()
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return;

    if (window->DC.ColumnsCount > 1)
    {
        ImGui::PopItemWidth();
        ImGui::PopClipRect();
        if (++window->DC.ColumnCurrent < window->DC.ColumnsCount)
            SameLine((int)(ImGui::GetColumnOffset(window->DC.ColumnCurrent) + g.Style.ItemSpacing.x));
        else
            window->DC.ColumnCurrent = 0;
        ImGui::PushColumnClipRect();
        ImGui::PushItemWidth(ImGui::GetColumnWidth() * 0.65f);
    }
}

bool IsClipped(const ImGuiAabb& bb)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    if (!bb.Overlaps(ImGuiAabb(window->ClipRectStack.back())) && !g.LogEnabled)
        return true;
    return false;
}

bool IsClipped(ImVec2 item_size)
{
    ImGuiWindow* window = GetCurrentWindow();
    return IsClipped(ImGuiAabb(window->DC.CursorPos, window->DC.CursorPos + item_size));
}

static bool ClipAdvance(const ImGuiAabb& bb, bool skip_columns)
{
    ImGuiWindow* window = GetCurrentWindow();
    if (ImGui::IsClipped(bb))
    {
        window->DC.LastItemHovered = false;
        return true;
    }
    window->DC.LastItemHovered = ImGui::IsMouseHoveringBox(bb);		// this is a sensible default but widgets are free to override it after calling ClipAdvance
    return false;
}

// Gets back to previous line and continue with horizontal layout
//		column_x == 0	: follow on previous item
//		columm_x != 0	: align to specified column
//		spacing_w < 0	: use default spacing if column_x==0, no spacing if column_x!=0
//		spacing_w >= 0	: enforce spacing
void SameLine(int column_x, int spacing_w)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (window->Collapsed)
        return;

    float x, y;
    if (column_x != 0)
    {
        if (spacing_w < 0) spacing_w = 0;
        x = window->Pos.x + (float)column_x + (float)spacing_w;
        y = window->DC.CursorPosPrevLine.y;
    }
    else
    {
        if (spacing_w < 0) spacing_w = (int)g.Style.ItemSpacing.x;
        x = window->DC.CursorPosPrevLine.x + (float)spacing_w;
        y = window->DC.CursorPosPrevLine.y;
    }
    window->DC.CurrentLineHeight = window->DC.PrevLineHeight;
    window->DC.CursorPos = ImVec2(x, y);
}

float GetColumnOffset(int column_index)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (column_index < 0)
        column_index = window->DC.ColumnCurrent;

    const ImGuiID column_id = ImGuiID(window->DC.ColumnsSetID + column_index);
    RegisterAliveId(column_id);
    const float default_t = column_index / (float)window->DC.ColumnsCount;
    const float t = (float)window->StateStorage.GetInt(column_id, (int)(default_t * 8096)) / 8096;		// Cheaply store our floating point value inside the integer (could store an union into the map?)

    const float offset = window->DC.ColumnStartX + t * (window->Size.x - g.Style.ScrollBarWidth - window->DC.ColumnStartX);
    return offset;
}

void SetColumnOffset(int column_index, float offset)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    if (column_index < 0)
        column_index = window->DC.ColumnCurrent;

    const ImGuiID column_id = ImGuiID(window->DC.ColumnsSetID + column_index);
    const float t = (offset - window->DC.ColumnStartX) / (window->Size.x - g.Style.ScrollBarWidth - window->DC.ColumnStartX);
    window->StateStorage.SetInt(column_id, (int)(t*8096));
}

float GetColumnWidth(int column_index)
{
    ImGuiWindow* window = GetCurrentWindow();
    if (column_index < 0)
        column_index = window->DC.ColumnCurrent;

    const float w = GetColumnOffset(column_index+1) - GetColumnOffset(column_index);
    return w;
}

static void PushColumnClipRect(int column_index)
{
    ImGuiWindow* window = GetCurrentWindow();
    if (column_index < 0)
        column_index = window->DC.ColumnCurrent;

    const float x1 = window->Pos.x + ImGui::GetColumnOffset(column_index) - 1;
    const float x2 = window->Pos.x + ImGui::GetColumnOffset(column_index+1) - 1;
    ImGui::PushClipRect(ImVec4(x1,-FLT_MAX,x2,+FLT_MAX));
}

void Columns(int columns_count, const char* id, bool border)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();

    if (window->DC.ColumnsCount != 1)
    {
        if (window->DC.ColumnCurrent != 0)
            ImGui::ItemSize(ImVec2(0,0));	// Advance to column 0
        ImGui::PopItemWidth();
        ImGui::PopClipRect();
    }

    if (window->DC.ColumnsCount != columns_count && window->DC.ColumnsCount != 1 && window->DC.ColumnsShowBorders)
    {
        // Draw columns and handle resize
        const float y1 = window->DC.ColumnsStartCursorPos.y;
        const float y2 = window->DC.CursorPos.y;
        for (int i = 1; i < window->DC.ColumnsCount; i++)
        {
            float x = window->Pos.x + GetColumnOffset(i);

            const ImGuiID column_id = ImGuiID(window->DC.ColumnsSetID + i);
            const ImGuiAabb column_aabb(ImVec2(x-4,y1),ImVec2(x+4,y2));

            if (IsClipped(column_aabb))
                continue;

            bool hovered, held;
            ButtonBehaviour(column_aabb, column_id, &hovered, &held);

            // Draw before resize so our items positioning are in sync with the line
            const ImU32 col = window->Color(held ? ImGuiCol_ColumnActive : hovered ? ImGuiCol_ColumnHovered : ImGuiCol_Column);
            window->DrawList->AddLine(ImVec2(x, y1), ImVec2(x, y2), col);

            if (held)
            {
                x -= window->Pos.x;
                x = ImClamp(x + g.IO.MouseDelta.x, ImGui::GetColumnOffset(i-1)+g.Style.ColumnsMinSpacing, ImGui::GetColumnOffset(i+1)-g.Style.ColumnsMinSpacing);
                SetColumnOffset(i, x);
                x += window->Pos.x;
            }
        }
    }

    window->DC.ColumnsSetID = window->GetID(id ? id : "");
    window->DC.ColumnCurrent = 0;
    window->DC.ColumnsCount = columns_count;
    window->DC.ColumnsShowBorders = border;
    window->DC.ColumnsStartCursorPos = window->DC.CursorPos;

    if (window->DC.ColumnsCount != 1)
    {
        ImGui::PushColumnClipRect();
        ImGui::PushItemWidth(ImGui::GetColumnWidth() * 0.65f);
    }
}

void TreePush(const char* str_id)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    window->DC.ColumnStartX += g.Style.TreeNodeSpacing;
    window->DC.CursorPos.x = window->Pos.x + window->DC.ColumnStartX;
    window->DC.TreeDepth++;
    PushID(str_id ? str_id : "#TreePush");
}

void TreePush(const void* ptr_id)
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    window->DC.ColumnStartX += g.Style.TreeNodeSpacing;
    window->DC.CursorPos.x = window->Pos.x + window->DC.ColumnStartX;
    window->DC.TreeDepth++;
    PushID(ptr_id ? ptr_id : (const void*)"#TreePush");
}

void TreePop()
{
    ImGuiState& g = GImGui;
    ImGuiWindow* window = GetCurrentWindow();
    window->DC.ColumnStartX -= g.Style.TreeNodeSpacing;
    window->DC.CursorPos.x = window->Pos.x + window->DC.ColumnStartX;
    window->DC.TreeDepth--;
    PopID();
}

void Value(const char* prefix, bool b)
{
    ImGui::Text("%s: %s", prefix, (b ? "true" : "false"));
}

void Value(const char* prefix, int v)
{
    ImGui::Text("%s: %d", prefix, v);
}

void Value(const char* prefix, unsigned int v)
{
    ImGui::Text("%s: %d", prefix, v);
}

void Value(const char* prefix, float v, const char* float_format)
{
    if (float_format)
    {
        char fmt[64];
        sprintf(fmt, "%%s: %s", float_format);
        ImGui::Text(fmt, prefix, v);
    }
    else
    {
        ImGui::Text("%s: %.3f", prefix, v);
    }
}

void Color(const char* prefix, const ImVec4& v)
{
    ImGui::Text("%s: (%.2f,%.2f,%.2f,%.2f)", prefix, v.x, v.y, v.z, v.w);
    ImGui::SameLine();
    ImGui::ColorButton(v, true);
}

void Color(const char* prefix, unsigned int v)
{
    ImGui::Text("%s: %08X", prefix, v);
    ImGui::SameLine();

    ImVec4 col;
    col.x = (float)((v >> 0) & 0xFF) / 255.0f;
    col.y = (float)((v >> 8) & 0xFF) / 255.0f;
    col.z = (float)((v >> 16) & 0xFF) / 255.0f;
    col.w = (float)((v >> 24) & 0xFF) / 255.0f;
    ImGui::ColorButton(col, true);
}

}; // namespace ImGui

//-----------------------------------------------------------------------------
// ImDrawList
//-----------------------------------------------------------------------------

void ImDrawList::Clear()
{
    commands.resize(0);
    vtx_buffer.resize(0);
    clip_rect_buffer.resize(0);
    vtx_write_ = NULL;
    clip_rect_stack_.resize(0);
}

void ImDrawList::PushClipRect(const ImVec4& clip_rect)
{
    commands.push_back(ImDrawCmd(ImDrawCmdType_PushClipRect));
    clip_rect_buffer.push_back(clip_rect);
    clip_rect_stack_.push_back(clip_rect);
}

void ImDrawList::PopClipRect()
{
    if (!commands.empty() && commands.back().cmd_type == ImDrawCmdType_PushClipRect)
    {
        // Discard push/pop combo because high-level clipping may have discarded the other draw commands already
        commands.pop_back();
        clip_rect_buffer.pop_back();
    }
    else
    {
        commands.push_back(ImDrawCmd(ImDrawCmdType_PopClipRect));
    }
    clip_rect_stack_.pop_back();
}

void ImDrawList::AddCommand(ImDrawCmdType cmd_type, int vtx_count)
{
    // Maximum value that can fit in our u16 vtx_count member
    const int VTX_COUNT_MAX = (1<<16);

    // Merge commands if we can, turning them into less draw calls
    ImDrawCmd* prev = commands.empty() ? NULL : &commands.back();
    if (vtx_count > 0 && prev && prev->cmd_type == (ImU32)cmd_type && prev->vtx_count + vtx_count < VTX_COUNT_MAX)
        prev->vtx_count += vtx_count;
    else
        commands.push_back(ImDrawCmd(cmd_type, vtx_count));

    if (vtx_count > 0)
    {
        vtx_buffer.resize(vtx_buffer.size() + vtx_count);
        vtx_write_ = &vtx_buffer[vtx_buffer.size() - vtx_count];
    }
}

void ImDrawList::AddVtx(const ImVec2& pos, ImU32 col)
{
    vtx_write_->pos = pos;
    vtx_write_->col = col;
    vtx_write_->uv = IMDRAW_TEX_UV_FOR_WHITE;
    vtx_write_++;
}

void ImDrawList::AddVtxLine(const ImVec2& a, const ImVec2& b, ImU32 col)
{
    const ImVec2 n = (b - a) / ImLength(b - a);
    const ImVec2 hn = ImVec2(n.y, -n.x) * 0.5f;

    AddVtx(a - hn, col);
    AddVtx(b - hn, col);
    AddVtx(a + hn, col);

    AddVtx(b - hn, col);
    AddVtx(b + hn, col);
    AddVtx(a + hn, col);
}

void ImDrawList::AddLine(const ImVec2& a, const ImVec2& b, ImU32 col)
{
    if ((col >> 24) == 0)
        return;

    AddCommand(ImDrawCmdType_DrawTriangleList, 6);
    AddVtxLine(a, b, col);
}

void ImDrawList::AddArc(const ImVec2& center, float rad, ImU32 col, int a_min, int a_max, bool tris, const ImVec2& third_point_offset)
{
    static ImVec2 circle_vtx[12];
    static bool circle_vtx_builds = false;
    if (!circle_vtx_builds)
    {
        for (int i = 0; i < ARRAYSIZE(circle_vtx); i++)
        {
            const float a = ((float)i / (float)ARRAYSIZE(circle_vtx)) * 2*PI;
            circle_vtx[i].x = cos(a + PI);
            circle_vtx[i].y = sin(a + PI);
        }
        circle_vtx_builds = true;
    }

    if (tris)
    {
        AddCommand(ImDrawCmdType_DrawTriangleList, (a_max-a_min) * 3);
        for (int a = a_min; a < a_max; a++)
        {
            AddVtx(center + circle_vtx[a % ARRAYSIZE(circle_vtx)] * rad, col);
            AddVtx(center + circle_vtx[(a+1) % ARRAYSIZE(circle_vtx)] * rad, col);
            AddVtx(center + third_point_offset, col);
        }
    }
    else
    {
        AddCommand(ImDrawCmdType_DrawTriangleList, (a_max-a_min) * 6);
        for (int a = a_min; a < a_max; a++)
            AddVtxLine(center + circle_vtx[a % ARRAYSIZE(circle_vtx)] * rad, center + circle_vtx[(a+1) % ARRAYSIZE(circle_vtx)] * rad, col);
    }
}

void ImDrawList::AddRect(const ImVec2& a, const ImVec2& b, ImU32 col, float rounding, int rounding_corners)
{
    if ((col >> 24) == 0)
        return;

    //const float r = ImMin(rounding, ImMin(abs(b.x-a.x), abs(b.y-a.y))*0.5f);
    float r = rounding;
    r = ImMin(r, abs(b.x-a.x) * ( ((rounding_corners&(1|2))==(1|2)) || ((rounding_corners&(4|8))==(4|8)) ? 0.5f : 1.0f ));
    r = ImMin(r, abs(b.y-a.y) * ( ((rounding_corners&(1|8))==(1|8)) || ((rounding_corners&(2|4))==(2|4)) ? 0.5f : 1.0f ));

    if (r == 0.0f || rounding_corners == 0)
    {
        AddCommand(ImDrawCmdType_DrawTriangleList, 4*6);
        AddVtxLine(ImVec2(a.x,a.y), ImVec2(b.x,a.y), col);
        AddVtxLine(ImVec2(b.x,a.y), ImVec2(b.x,b.y), col);
        AddVtxLine(ImVec2(b.x,b.y), ImVec2(a.x,b.y), col);
        AddVtxLine(ImVec2(a.x,b.y), ImVec2(a.x,a.y), col);
    }
    else
    {
        AddCommand(ImDrawCmdType_DrawTriangleList, 4*6);
        AddVtxLine(ImVec2(a.x + ((rounding_corners & 1)?r:0), a.y), ImVec2(b.x - ((rounding_corners & 2)?r:0), a.y), col);
        AddVtxLine(ImVec2(b.x, a.y + ((rounding_corners & 2)?r:0)), ImVec2(b.x, b.y - ((rounding_corners & 4)?r:0)), col);
        AddVtxLine(ImVec2(b.x - ((rounding_corners & 4)?r:0), b.y), ImVec2(a.x + ((rounding_corners & 8)?r:0), b.y), col);
        AddVtxLine(ImVec2(a.x, b.y - ((rounding_corners & 8)?r:0)), ImVec2(a.x, a.y + ((rounding_corners & 1)?r:0)), col);

        if (rounding_corners & 1) AddArc(ImVec2(a.x+r,a.y+r), r, col, 0, 3);
        if (rounding_corners & 2) AddArc(ImVec2(b.x-r,a.y+r), r, col, 3, 6);
        if (rounding_corners & 4) AddArc(ImVec2(b.x-r,b.y-r), r, col, 6, 9);
        if (rounding_corners & 8) AddArc(ImVec2(a.x+r,b.y-r), r, col, 9, 12);
    }
}

void ImDrawList::AddRectFilled(const ImVec2& a, const ImVec2& b, ImU32 col, float rounding, int rounding_corners)
{
    if ((col >> 24) == 0)
        return;

    //const float r = ImMin(rounding, ImMin(abs(b.x-a.x), abs(b.y-a.y))*0.5f);
    float r = rounding;
    r = ImMin(r, abs(b.x-a.x) * ( ((rounding_corners&(1|2))==(1|2)) || ((rounding_corners&(4|8))==(4|8)) ? 0.5f : 1.0f ));
    r = ImMin(r, abs(b.y-a.y) * ( ((rounding_corners&(1|8))==(1|8)) || ((rounding_corners&(2|4))==(2|4)) ? 0.5f : 1.0f ));

    if (r == 0.0f || rounding_corners == 0)
    {
        // Use triangle so we can merge more draw calls together (at the cost of extra vertices)
        AddCommand(ImDrawCmdType_DrawTriangleList, 6);
        AddVtx(ImVec2(a.x,a.y), col);
        AddVtx(ImVec2(b.x,a.y), col);
        AddVtx(ImVec2(b.x,b.y), col);
        AddVtx(ImVec2(a.x,a.y), col);
        AddVtx(ImVec2(b.x,b.y), col);
        AddVtx(ImVec2(a.x,b.y), col);
    }
    else
    {
        AddCommand(ImDrawCmdType_DrawTriangleList, 6+6*2);
        AddVtx(ImVec2(a.x+r,a.y), col);
        AddVtx(ImVec2(b.x-r,a.y), col);
        AddVtx(ImVec2(b.x-r,b.y), col);
        AddVtx(ImVec2(a.x+r,a.y), col);
        AddVtx(ImVec2(b.x-r,b.y), col);
        AddVtx(ImVec2(a.x+r,b.y), col);

        float top_y = (rounding_corners & 1) ? a.y+r : a.y;
        float bot_y = (rounding_corners & 8) ? b.y-r : b.y;
        AddVtx(ImVec2(a.x,top_y), col);
        AddVtx(ImVec2(a.x+r,top_y), col);
        AddVtx(ImVec2(a.x+r,bot_y), col);
        AddVtx(ImVec2(a.x,top_y), col);
        AddVtx(ImVec2(a.x+r,bot_y), col);
        AddVtx(ImVec2(a.x,bot_y), col);

        top_y = (rounding_corners & 2) ? a.y+r : a.y;
        bot_y = (rounding_corners & 4) ? b.y-r : b.y;
        AddVtx(ImVec2(b.x-r,top_y), col);
        AddVtx(ImVec2(b.x,top_y), col);
        AddVtx(ImVec2(b.x,bot_y), col);
        AddVtx(ImVec2(b.x-r,top_y), col);
        AddVtx(ImVec2(b.x,bot_y), col);
        AddVtx(ImVec2(b.x-r,bot_y), col);

        if (rounding_corners & 1) AddArc(ImVec2(a.x+r,a.y+r), r, col, 0, 3, true);
        if (rounding_corners & 2) AddArc(ImVec2(b.x-r,a.y+r), r, col, 3, 6, true);
        if (rounding_corners & 4) AddArc(ImVec2(b.x-r,b.y-r), r, col, 6, 9, true);
        if (rounding_corners & 8) AddArc(ImVec2(a.x+r,b.y-r), r, col, 9, 12,true);
    }
}

void ImDrawList::AddTriangleFilled(const ImVec2& a, const ImVec2& b, const ImVec2& c, ImU32 col)
{
    if ((col >> 24) == 0)
        return;

    AddCommand(ImDrawCmdType_DrawTriangleList, 3);
    AddVtx(a, col);
    AddVtx(b, col);
    AddVtx(c, col);
}

void ImDrawList::AddCircle(const ImVec2& centre, float radius, ImU32 col, int num_segments)
{
    if ((col >> 24) == 0)
        return;

    AddCommand(ImDrawCmdType_DrawTriangleList, num_segments*6);
    const float a_step = 2*PI/(float)num_segments;
    float a0 = 0.0f;
    for (int i = 0; i < num_segments; i++)
    {
        const float a1 = (i + 1) == num_segments ? 0.0f : a0 + a_step;
        AddVtxLine(centre + ImVec2(cos(a0),sin(a0))*radius, centre + ImVec2(cos(a1),sin(a1))*radius, col);
        a0 = a1;
    }
}

void ImDrawList::AddCircleFilled(const ImVec2& centre, float radius, ImU32 col, int num_segments)
{
    if ((col >> 24) == 0)
        return;

    AddCommand(ImDrawCmdType_DrawTriangleList, num_segments*3);
    const float a_step = 2*PI/(float)num_segments;
    float a0 = 0.0f;
    for (int i = 0; i < num_segments; i++)
    {
        const float a1 = (i + 1) == num_segments ? 0.0f : a0 + a_step;
        AddVtx(centre + ImVec2(cos(a0),sin(a0))*radius, col);
        AddVtx(centre + ImVec2(cos(a1),sin(a1))*radius, col);
        AddVtx(centre, col);
        a0 = a1;
    }
}

void ImDrawList::AddText(ImFont font, float font_size, const ImVec2& pos, ImU32 col, const char* text_begin, const char* text_end)
{
    if ((col >> 24) == 0)
        return;

    if (text_end == NULL)
        text_end = text_begin + strlen(text_begin);

    int char_count = text_end - text_begin;
    int vtx_count_max = char_count * 6;
    int vtx_begin = vtx_buffer.size();
    AddCommand(ImDrawCmdType_DrawTriangleList, vtx_count_max);

    font->RenderText(font_size, pos, col, clip_rect_stack_.back(), text_begin, text_end, vtx_write_);
    vtx_buffer.resize(vtx_write_ - &vtx_buffer.front());
    int vtx_count = vtx_buffer.size() - vtx_begin;

    commands.back().vtx_count -= (vtx_count_max - vtx_count);
    vtx_write_ -= (vtx_count_max - vtx_count);
}

//-----------------------------------------------------------------------------
// ImBitmapFont
//-----------------------------------------------------------------------------

ImBitmapFont::ImBitmapFont()
{
    Data = NULL;
    DataOwned = false;
    Info = NULL;
    Common = NULL;
    Glyphs = NULL;
    GlyphsCount = 0;
    TabCount = 4;
}

void	ImBitmapFont::Clear()
{
    if (Data && DataOwned)
        free(Data);
    Data = NULL;
    DataOwned = false;
    Info = NULL;
    Common = NULL;
    Glyphs = NULL;
    GlyphsCount = 0;
    Filenames.clear();
    IndexLookup.clear();
}

bool	ImBitmapFont::LoadFromFile(const char* filename)
{
    // Load file
    FILE* f;
    if ((f = fopen(filename, "rb")) == NULL)
        return false;
    if (fseek(f, 0, SEEK_END))
        return false;
    if ((DataSize = (int)ftell(f)) == -1)
        return false;
    if (fseek(f, 0, SEEK_SET))
        return false;
    if ((Data = (unsigned char*)malloc(DataSize)) == NULL)
    {
        fclose(f);
        return false;
    }
    if (fread(Data, 1, DataSize, f) != DataSize)
    {
        fclose(f);
        free(Data);
        return false;
    }
    fclose(f);
    DataOwned = true;
    return LoadFromMemory(Data, DataSize);
}

bool	ImBitmapFont::LoadFromMemory(const void* data, int data_size)
{
    Data = (unsigned char*)data;
    DataSize = data_size;

    // Parse data
    if (DataSize < 4 || Data[0] != 'B' || Data[1] != 'M' || Data[2] != 'F' || Data[3] != 0x03)
        return false;
    for (const unsigned char* p = Data+4; p < Data + DataSize; )
    {
        const unsigned char block_type = *(unsigned char*)p;
        p += sizeof(unsigned char);
        const ImU32 block_size = *(ImU32*)p;
        p += sizeof(ImU32);

        switch (block_type)
        {
            case 1:
                ZELO_ASSERT(Info == NULL);
                Info = (FntInfo*)p;
                break;
            case 2:
                ZELO_ASSERT(Common == NULL);
                Common = (FntCommon*)p;
                break;
            case 3:
                for (const unsigned char* s = p; s < p+block_size && s < Data+DataSize; s = s + strlen((const char*)s) + 1)
                    Filenames.push_back((const char*)s);
                break;
            case 4:
                ZELO_ASSERT(Glyphs == NULL && GlyphsCount == 0);
                Glyphs = (FntGlyph*)p;
                GlyphsCount = block_size / sizeof(FntGlyph);
                break;
            default:
                ZELO_ASSERT(Kerning == NULL && KerningCount == 0);
                Kerning = (FntKerning*)p;
                KerningCount = block_size / sizeof(FntKerning);
                break;
        }
        p += block_size;
    }

    BuildLookupTable();
    return true;
}

void ImBitmapFont::BuildLookupTable()
{
    ImU32 max_c = 0;
    for (int i = 0; i != GlyphsCount; i++)
        if (max_c < Glyphs[i].Id)
            max_c = Glyphs[i].Id;

    IndexLookup.clear();
    IndexLookup.resize(max_c + 1);
    for (size_t i = 0; i < IndexLookup.size(); i++)
        IndexLookup[i] = -1;
    for (size_t i = 0; i < GlyphsCount; i++)
        IndexLookup[Glyphs[i].Id] = (int)i;
}

const ImBitmapFont::FntGlyph* ImBitmapFont::FindGlyph(unsigned short c) const
{
    if (c < (int)IndexLookup.size())
    {
        const int i = IndexLookup[c];
        if (i >= 0 && i < (int)GlyphsCount)
            return &Glyphs[i];
    }
    return NULL;
}

ImVec2 ImBitmapFont::CalcTextSize(float size, float max_width, const char* text_begin, const char* text_end, const char** remaining) const
{
    if (max_width == 0.0f)
        max_width = FLT_MAX;
    if (!text_end)
        text_end = text_begin + strlen(text_begin);

    const float scale = size / (float)Info->FontSize;
    const float line_height = (float)Info->FontSize * scale;

    ImVec2 text_size = ImVec2(0,0);
    float line_width = 0.0f;

    const char* s = text_begin;
    while (s < text_end)
    {
        const char c = *s;
        if (c == '\n')
        {
            if (text_size.x < line_width)
                text_size.x = line_width;
            text_size.y += line_height;
            line_width = 0;
        }
        if (const FntGlyph* glyph = FindGlyph((unsigned short)c))
        {
            const float char_width = (glyph->XAdvance + Info->SpacingHoriz) * scale;
            const float char_extend = (glyph->XOffset + glyph->Width * scale);
            if (line_width + char_width >= max_width)
                break;
            line_width += char_width;
        }
        else if (c == '\t')
        {
            if (const FntGlyph* glyph = FindGlyph((unsigned short)' '))
                line_width += (glyph->XAdvance + Info->SpacingHoriz) * 4 * scale;
        }

        s += 1;
    }

    if (line_width > 0 || text_size.y == 0.0f)
    {
        if (text_size.x < line_width)
            text_size.x = line_width;
        text_size.y += line_height;
    }

    if (remaining)
        *remaining = s;

    return text_size;
}

void ImBitmapFont::RenderText(float size, ImVec2 pos, ImU32 col, const ImVec4& clip_rect_ref, const char* text_begin, const char* text_end, ImDrawVert*& out_vertices) const
{
    if (!text_end)
        text_end = text_begin + strlen(text_begin);

    const float line_height = (float)Info->FontSize;
    const float scale = size / (float)Info->FontSize;
    const float tex_scale_x = 1.0f / (float)Common->ScaleW;
    const float tex_scale_y = 1.0f / (float)(Common->ScaleH);
    const float outline = (float)Info->Outline;

    // Align to be pixel perfect
    pos.x = (float)(int)pos.x + 0.5f;
    pos.y = (float)(int)pos.y + 0.5f;

    ImVec2 text_size = ImVec2(0,0);
    float line_width = 0.0f;
    const ImVec4 clip_rect = clip_rect_ref;

    float x = pos.x;
    float y = pos.y;
    for (const char* s = text_begin; s < text_end; s++)
    {
        const char c = *s;
        if (c == '\n')
        {
            x = pos.x;
            y += line_height * scale;
            continue;
        }

        if (const FntGlyph* glyph = FindGlyph((unsigned short)c))
        {
            const float char_width = (glyph->XAdvance + Info->SpacingHoriz) * scale;
            const float char_extend = (glyph->XOffset + glyph->Width * scale);

            if (c != ' ' && c != '\n')
            {
                // Clipping due to Y limits is more likely
                const float y1 = (float)(y + (glyph->YOffset + outline*2) * scale);
                const float y2 = (float)(y1 + glyph->Height * scale);
                if (y1 > clip_rect.w || y2 < clip_rect.y)
                {
                    x += char_width;
                    continue;
                }

                const float x1 = (float)(x + (glyph->XOffset + outline) * scale);
                const float x2 = (float)(x1 + glyph->Width * scale);
                if (x1 > clip_rect.z || x2 < clip_rect.x)
                {
                    x += char_width;
                    continue;
                }

                const float s1 = (0.0f + glyph->X) * tex_scale_x;
                const float t1 = (0.0f + glyph->Y) * tex_scale_y;
                const float s2 = (0.0f + glyph->X + glyph->Width) * tex_scale_x;
                const float t2 = (0.0f + glyph->Y + glyph->Height) * tex_scale_y;

                out_vertices[0].pos = ImVec2(x1, y1);
                out_vertices[0].uv  = ImVec2(s1, t1);
                out_vertices[0].col = col;

                out_vertices[1].pos = ImVec2(x2, y1);
                out_vertices[1].uv  = ImVec2(s2, t1);
                out_vertices[1].col = col;

                out_vertices[2].pos = ImVec2(x2, y2);
                out_vertices[2].uv  = ImVec2(s2, t2);
                out_vertices[2].col = col;

                out_vertices[3] = out_vertices[0];
                out_vertices[4] = out_vertices[2];

                out_vertices[5].pos = ImVec2(x1, y2);
                out_vertices[5].uv  = ImVec2(s1, t2);
                out_vertices[5].col = col;

                out_vertices += 6;
            }

            x += char_width;
        }
        else if (c == '\t')
        {
            if (const FntGlyph* glyph = FindGlyph((unsigned short)' '))
                x += (glyph->XAdvance + Info->SpacingHoriz) * 4 * scale;
        }
    }
}

//-----------------------------------------------------------------------------
// HELP
//-----------------------------------------------------------------------------

namespace ImGui
{

void ShowUserGuide()
{
    ImGuiState& g = GImGui;

    ImGui::BulletText("Double-click on title bar to collapse window.");
    ImGui::BulletText("Click and drag on lower right corner to resize window.");
    ImGui::BulletText("Click and drag on any empty space to move window.");
    ImGui::BulletText("Mouse Wheel to scroll.");
    if (g.IO.FontAllowScaling)
        ImGui::BulletText("CTRL+Mouse Wheel to zoom window contents.");
    ImGui::BulletText("TAB/SHIFT+TAB to cycle thru keyboard editable fields.");
    ImGui::BulletText("CTRL+Click on a slider to input text.");
    ImGui::BulletText(
            "While editing text:\n"
            "- Hold SHIFT or use mouse to select text\n"
            "- CTRL+Left/Right to word jump\n"
            "- CTRL+A select all\n"
            "- CTRL+X,CTRL+C,CTRL+V clipboard\n"
            "- CTRL+Z,CTRL+Y undo/redo\n"
            "- ESCAPE to revert\n"
            "- You can apply arithmetic operators +,*,/ on numerical values.\n"
            "  Use +- to subtract.\n");
}

void ShowStyleEditor(ImGuiStyle* ref)
{
    ImGuiState& g = GImGui;
    ImGuiStyle& style = g.Style;

    const ImGuiStyle def;

    if (ImGui::Button("Revert Style"))
        g.Style = ref ? *ref : def;
    if (ref)
    {
        ImGui::SameLine();
        if (ImGui::Button("Save Style"))
            *ref = g.Style;
    }

    ImGui::SliderFloat("Rounding", &style.WindowRounding, 0.0f, 16.0f, "%.0f");

    static ImGuiColorEditMode edit_mode = ImGuiColorEditMode_RGB;
    ImGui::RadioButton("RGB", &edit_mode, ImGuiColorEditMode_RGB);
    ImGui::SameLine();
    ImGui::RadioButton("HSV", &edit_mode, ImGuiColorEditMode_HSV);
    ImGui::SameLine();
    ImGui::RadioButton("HEX", &edit_mode, ImGuiColorEditMode_HEX);

    ImGui::ColorEditMode(edit_mode);
    for (size_t i = 0; i < ImGuiCol_COUNT; i++)
    {
        ImGui::PushID(i);
        ImGui::ColorEdit4(GetStyleColorName(i), (float*)&style.Colors[i], true);
        if (memcmp(&style.Colors[i], (ref ? &ref->Colors[i] : &def.Colors[i]), sizeof(ImVec4)) != 0)
        {
            ImGui::SameLine(); if (ImGui::Button("Revert")) style.Colors[i] = ref ? ref->Colors[i] : def.Colors[i];
            if (ref) { ImGui::SameLine(); if (ImGui::Button("Save")) ref->Colors[i] = style.Colors[i]; }
        }
        ImGui::PopID();
    }
}

//-----------------------------------------------------------------------------
// SAMPLE CODE
//-----------------------------------------------------------------------------

// Demonstrate ImGui features (unfortunately this makes this function a little bloated!)
void ShowTestWindow(bool* open)
{
    static bool no_titlebar = false;
    static bool no_border = true;
    static bool no_resize = false;
    static bool no_move = false;
    static bool no_scrollbar = false;
    static float fill_alpha = 0.65f;

    const ImU32 layout_flags = (no_titlebar ? ImGuiWindowFlags_NoTitleBar : 0) | (no_border ? 0 : ImGuiWindowFlags_ShowBorders) | (no_resize ? ImGuiWindowFlags_NoResize : 0) | (no_move ? ImGuiWindowFlags_NoMove : 0) | (no_scrollbar ? ImGuiWindowFlags_NoScrollbar : 0);
    ImGui::Begin("ImGui Test", open, ImVec2(550,680), fill_alpha, layout_flags);
    ImGui::PushItemWidth(ImGui::GetWindowWidth() * 0.65f);

    ImGui::Text("ImGui says hello.");
    //ImGui::Text("MousePos (%g, %g)", g.IO.MousePos.x, g.IO.MousePos.y);
    //ImGui::Text("MouseWheel %d", g.IO.MouseWheel);

    ImGui::Spacing();
    if (ImGui::CollapsingHeader("Help"))
    {
        ImGui::ShowUserGuide();
    }

    if (ImGui::CollapsingHeader("Window options"))
    {
        ImGui::Checkbox("no titlebar", &no_titlebar); ImGui::SameLine(200);
        ImGui::Checkbox("no border", &no_border); ImGui::SameLine(400);
        ImGui::Checkbox("no resize", &no_resize);
        ImGui::Checkbox("no move", &no_move); ImGui::SameLine(200);
        ImGui::Checkbox("no scrollbar", &no_scrollbar);
        ImGui::SliderFloat("fill alpha", &fill_alpha, 0.0f, 1.0f);
        if (ImGui::TreeNode("Style Editor"))
        {
            ImGui::ShowStyleEditor();
            ImGui::TreePop();
        }

        if (ImGui::TreeNode("Logging"))
        {
            ImGui::LogButtons();
            ImGui::TreePop();
        }
    }

    if (ImGui::CollapsingHeader("Widgets"))
    {
        //ImGui::PushItemWidth(ImGui::GetWindowWidth() - 220);

        static bool a=false;
        if (ImGui::Button("Button")) { printf("Clicked\n"); a ^= 1; }
        if (a)
        {
            ImGui::SameLine();
            ImGui::Text("Thanks for clicking me!");
        }

        static bool check = true;
        ImGui::Checkbox("checkbox", &check);

        if (ImGui::TreeNode("Tree"))
        {
            for (size_t i = 0; i < 5; i++)
            {
                if (ImGui::TreeNode((void*)i, "Child %d", i))
                {
                    ImGui::Text("blah blah");
                    ImGui::SameLine();
                    if (ImGui::SmallButton("print"))
                        printf("Child %d pressed", (int)i);
                    ImGui::TreePop();
                }
            }
            ImGui::TreePop();
        }

        if (ImGui::TreeNode("Bullets"))
        {
            ImGui::BulletText("Bullet point 1");
            ImGui::BulletText("Bullet point 2\nOn multiple lines");
            ImGui::BulletText("Bullet point 3");
            ImGui::TreePop();
        }

        static int e = 0;
        ImGui::RadioButton("radio a", &e, 0); ImGui::SameLine();
        ImGui::RadioButton("radio b", &e, 1); ImGui::SameLine();
        ImGui::RadioButton("radio c", &e, 2);

        ImGui::Text("Hover me");
        if (ImGui::IsHovered())
            ImGui::SetTooltip("I am a tooltip");

        static int item = 1;
        ImGui::Combo("combo", &item, "aaaa\0bbbb\0cccc\0dddd\0eeee\0\0");

        const char* items[] = { "AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "GGGG", "HHHH", "IIII", "JJJJ", "KKKK" };
        static int item2 = -1;
        ImGui::Combo("combo scroll", &item2, items, ARRAYSIZE(items));

        static char str0[128] = "Hello, world!";
        static int i0=123;
        static float f0=0.001f;
        ImGui::InputText("string", str0, ARRAYSIZE(str0));
        ImGui::InputInt("input int", &i0);
        ImGui::InputFloat("input float", &f0, 0.01f, 1.0f);

        static float vec3b[3] = { 0.10f, 0.20f, 0.30f };
        ImGui::InputFloat3("input float3", vec3b);

        static int i1=0;
        static int i2=42;
        ImGui::SliderInt("int 0..3", &i1, 0, 3);
        ImGui::SliderInt("int -100..100", &i2, -100, 100);

        static float f1=1.123f;
        static float f2=0;
        static float f3=0;
        static float f4=123456789.0f;
        ImGui::SliderFloat("float", &f1, 0.0f, 2.0f);
        ImGui::SliderFloat("log float", &f2, 0.0f, 10.0f, "%.4f", 2.0f);
        ImGui::SliderFloat("signed log float", &f3, -10.0f, 10.0f, "%.4f", 3.0f);
        ImGui::SliderFloat("unbound float", &f4, -FLT_MAX, FLT_MAX, "%.4f", 3.0f);
        static float angle = 0.0f;
        ImGui::SliderAngle("angle", &angle);

        static float vec3a[3] = { 0.10f, 0.20f, 0.30f };
        ImGui::SliderFloat3("slider float3", vec3a, 0.0f, 1.0f);

        static float col1[3] = { 1.0f,0.0f,0.2f };
        static float col2[4] = { 0.4f,0.7f,0.0f,0.5f };
        ImGui::ColorEdit3("color 1", col1);
        ImGui::ColorEdit4("color 2", col2);

        //ImGui::PopItemWidth();
    }

    if (ImGui::CollapsingHeader("Graphs widgets"))
    {
        static float arr[] = { 0.6f, 0.1f, 1.0f, 0.5f, 0.92f, 0.1f, 0.2f };
        ImGui::PlotLines("Frame Times", arr, ARRAYSIZE(arr));

        static bool pause;
        static ImVector<float> values; if (values.empty()) { values.resize(100); memset(&values.front(), 0, values.size()*sizeof(float)); }
        static int values_offset = 0;
        if (!pause)
        {
            // create dummy data at 60 hz
            static float refresh_time = -1.0f;
            if (ImGui::GetTime() > refresh_time + 1.0f/60.0f)
            {
                refresh_time = ImGui::GetTime();
                static float phase = 0.0f;
                values[values_offset] = cos(phase);
                values_offset = (values_offset+1)%values.size();
                phase += 0.10f*values_offset;
            }
        }
        ImGui::PlotLines("Frame Times", &values.front(), values.size(), values_offset, "avg 0.0", -1.0f, 1.0f, ImVec2(0,70));

        ImGui::SameLine(); ImGui::Checkbox("pause", &pause);
        ImGui::PlotHistogram("Histogram", arr, ARRAYSIZE(arr), 0, NULL, 0.0f, 1.0f, ImVec2(0,70));
    }

    if (ImGui::CollapsingHeader("Widgets on same line"))
    {
        // Text
        ImGui::Text("Hello");
        ImGui::SameLine();
        ImGui::Text("World");

        // Button
        if (ImGui::Button("Banana")) printf("Pressed!\n");
        ImGui::SameLine();
        ImGui::Button("Apple");
        ImGui::SameLine();
        ImGui::Button("Corniflower");

        // Button
        ImGui::SmallButton("Banana");
        ImGui::SameLine();
        ImGui::SmallButton("Apple");
        ImGui::SameLine();
        ImGui::SmallButton("Corniflower");
        ImGui::SameLine();
        ImGui::Text("Small buttons fit in a text block");

        // Checkbox
        static bool c1=false,c2=false,c3=false,c4=false;
        ImGui::Checkbox("My", &c1);
        ImGui::SameLine();
        ImGui::Checkbox("Tailor", &c2);
        ImGui::SameLine();
        ImGui::Checkbox("Is", &c3);
        ImGui::SameLine();
        ImGui::Checkbox("Rich", &c4);

        // SliderFloat
        static float f0=1.0f, f1=2.0f, f2=3.0f;
        ImGui::PushItemWidth(80);
        ImGui::SliderFloat("f0", &f0, 0.0f,5.0f);
        ImGui::SameLine();
        ImGui::SliderFloat("f1", &f1, 0.0f,5.0f);
        ImGui::SameLine();
        ImGui::SliderFloat("f2", &f2, 0.0f,5.0f);

        // InputText
        static char s0[128] = "one", s1[128] = "two", s2[128] = "three";
        ImGui::InputText("s0", s0, 128);
        ImGui::SameLine();
        ImGui::InputText("s1", s1, 128);
        ImGui::SameLine();
        ImGui::InputText("s2", s2, 128);

        // LabelText
        ImGui::LabelText("l0", "one");
        ImGui::SameLine();
        ImGui::LabelText("l0", "two");
        ImGui::SameLine();
        ImGui::LabelText("l0", "three");
        ImGui::PopItemWidth();
    }

    if (ImGui::CollapsingHeader("Child regions"))
    {
        ImGui::Text("Without border");
        static int line = 50;
        bool goto_line = ImGui::Button("Goto");
        ImGui::SameLine();
        ImGui::PushItemWidth(100);
        ImGui::InputInt("##Line", &line, 0);
        ImGui::PopItemWidth();
        ImGui::BeginChild("Sub1", ImVec2(ImGui::GetWindowWidth()*0.5f,300));
        for (int i = 0; i < 100; i++)
        {
            ImGui::Text("%04d: scrollable region", i);
            if (goto_line && line == i)
                ImGui::SetScrollPosHere();
        }
        if (goto_line && line >= 100)
            ImGui::SetScrollPosHere();
        ImGui::EndChild();

        ImGui::SameLine();

        ImGui::BeginChild("Sub2", ImVec2(0,300), true);
        ImGui::Text("With border");
        ImGui::Columns(2);
        for (int i = 0; i < 100; i++)
        {
            char buf[32];
            ImFormatString(buf, ARRAYSIZE(buf), "%08x", i*5731);
            ImGui::Button(buf);
            ImGui::NextColumn();
        }
        ImGui::EndChild();
    }

    if (ImGui::CollapsingHeader("Columns"))
    {
        ImGui::Columns(4, "data", true);
        ImGui::Text("ID"); ImGui::NextColumn();
        ImGui::Text("Name"); ImGui::NextColumn();
        ImGui::Text("Path"); ImGui::NextColumn();
        ImGui::Text("Flags"); ImGui::NextColumn();
        ImGui::Separator();

        ImGui::Text("0000"); ImGui::NextColumn();
        ImGui::Text("Robert"); ImGui::NextColumn();
        ImGui::Text("/path/robert"); ImGui::NextColumn();
        ImGui::Text("...."); ImGui::NextColumn();

        ImGui::Text("0001"); ImGui::NextColumn();
        ImGui::Text("Stephanie"); ImGui::NextColumn();
        ImGui::Text("/path/stephanie"); ImGui::NextColumn();
        ImGui::Text("...."); ImGui::NextColumn();

        ImGui::Text("0002"); ImGui::NextColumn();
        ImGui::Text("C64"); ImGui::NextColumn();
        ImGui::Text("/path/computer"); ImGui::NextColumn();
        ImGui::Text("...."); ImGui::NextColumn();
        ImGui::Columns(1);

        ImGui::Separator();

        ImGui::Columns(3, "mixed");
        ImGui::Text("Hello"); ImGui::NextColumn();
        ImGui::Text("World"); ImGui::NextColumn();
        ImGui::Text("Hmm..."); ImGui::NextColumn();

        ImGui::Button("Banana"); ImGui::NextColumn();
        ImGui::Button("Apple"); ImGui::NextColumn();
        ImGui::Button("Corniflower"); ImGui::NextColumn();

        static int e = 0;
        ImGui::RadioButton("radio a", &e, 0); ImGui::NextColumn();
        ImGui::RadioButton("radio b", &e, 1); ImGui::NextColumn();
        ImGui::RadioButton("radio c", &e, 2); ImGui::NextColumn();
        ImGui::Columns(1);

        ImGui::Separator();

        ImGui::Columns(2, "multiple components");
        static float foo = 1.0f;
        ImGui::InputFloat("red", &foo, 0.05f, 0, 3); ImGui::NextColumn();
        static float bar = 1.0f;
        ImGui::InputFloat("blue", &foo, 0.05f, 0, 3); ImGui::NextColumn();
        ImGui::Columns(1);

        ImGui::Separator();

        if (ImGui::TreeNode("Inside a tree.."))
        {
            if (ImGui::TreeNode("node 1 (with borders)"))
            {
                ImGui::Columns(4);
                ImGui::Text("aaa"); ImGui::NextColumn();
                ImGui::Text("bbb"); ImGui::NextColumn();
                ImGui::Text("ccc"); ImGui::NextColumn();
                ImGui::Text("ddd"); ImGui::NextColumn();
                ImGui::Text("eee"); ImGui::NextColumn();
                ImGui::Text("fff"); ImGui::NextColumn();
                ImGui::Text("ggg"); ImGui::NextColumn();
                ImGui::Text("hhh"); ImGui::NextColumn();
                ImGui::Columns(1);
                ImGui::TreePop();
            }
            if (ImGui::TreeNode("node 2 (without borders)"))
            {
                ImGui::Columns(4, NULL, false);
                ImGui::Text("aaa"); ImGui::NextColumn();
                ImGui::Text("bbb"); ImGui::NextColumn();
                ImGui::Text("ccc"); ImGui::NextColumn();
                ImGui::Text("ddd"); ImGui::NextColumn();
                ImGui::Text("eee"); ImGui::NextColumn();
                ImGui::Text("fff"); ImGui::NextColumn();
                ImGui::Text("ggg"); ImGui::NextColumn();
                ImGui::Text("hhh"); ImGui::NextColumn();
                ImGui::Columns(1);
                ImGui::TreePop();
            }
            ImGui::TreePop();
        }
    }

    if (ImGui::CollapsingHeader("Filtering"))
    {
        static ImGuiTextFilter filter;
        filter.Draw();
        const char* lines[] = { "aaa1.c", "bbb1.c", "ccc1.c", "aaa2.cpp", "bbb2.cpp", "ccc2.cpp", "abc.h", "hello, world" };
        for (size_t i = 0; i < ARRAYSIZE(lines); i++)
            if (filter.PassFilter(lines[i]))
                ImGui::BulletText("%s", lines[i]);
    }

    if (ImGui::CollapsingHeader("Long text"))
    {
        static ImGuiTextBuffer log;
        static int lines = 0;
        ImGui::Text("Printing unusually long amount of text.");
        ImGui::Text("Buffer contents: %d lines, %d bytes", lines, log.size());
        if (ImGui::Button("Clear")) { log.clear(); lines = 0; }
        ImGui::SameLine();
        if (ImGui::Button("Add 1000 lines"))
        {
            for (size_t i = 0; i < 1000; i++)
                log.Append("%i The quick brown fox jumps over the lazy dog\n", lines+i);
            lines += 1000;
        }
        ImGui::BeginChild("Log");
        ImGui::TextUnformatted(log.begin(), log.end());
        ImGui::EndChild();
    }

    ImGui::End();
}
// End of Sample code

}; // namespace ImGui

//-----------------------------------------------------------------------------
// Font data
// Bitmap exported from proggy_clean.fon (c) by Tristan Grimmer http://www.proggyfonts.net
//-----------------------------------------------------------------------------
namespace ImGui
{

void GetDefaultFontData(const void** fnt_data, unsigned int* fnt_size, const void** png_data, unsigned int* png_size)
{
    if (fnt_data){
        auto fnt = Zelo::Resource("fonts/proggy_clean_13.fnt");
        *fnt_data = fnt.readCopy();
        *fnt_size = fnt.getFileSize();
    }
    if(png_data){
        auto png = Zelo::Resource("fonts/proggy_clean_13.png");
        *png_data = png.readCopy();
        *png_size = png.getFileSize();
    }
}

};

//-----------------------------------------------------------------------------

// @formatter:on
bool ImGuiOncePerFrame::TryIsNewFrame() const {
    const int current_frame = ImGui::GetFrameCount();
    if (LastFrame == current_frame) return false;
    LastFrame = current_frame;
    return true;
}
