// ImGui.cpp
// created on 2021/5/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImGui.h"
#include "ImWidget.h"
#include "ImUtil.h"

struct ImGuiColMod	// Color/style modifier, backup of modified data so we can restore it
{
    ImGuiCol	Col;
    ImVec4		PreviousValue;
};

struct ImGuiAabb	// 2D axis aligned bounding-box
{
    ImVec2		Min;
    ImVec2		Max;

    ImGuiAabb()											{ Min = ImVec2(FLT_MAX,FLT_MAX); Max = ImVec2(-FLT_MAX,-FLT_MAX); }
    ImGuiAabb(const ImVec2& min, const ImVec2& max)		{ Min = min; Max = max; }
    ImGuiAabb(const ImVec4& v)							{ Min.x = v.x; Min.y = v.y; Max.x = v.z; Max.y = v.w; }
    ImGuiAabb(float x1, float y1, float x2, float y2)	{ Min.x = x1; Min.y = y1; Max.x = x2; Max.y = y2; }

    ImVec2		GetCenter() const						{ return Min + (Max-Min)*0.5f; }
    ImVec2		GetSize() const							{ return Max-Min; }
    float		GetWidth() const						{ return (Max-Min).x; }
    float		GetHeight() const						{ return (Max-Min).y; }
    ImVec2		GetTL() const							{ return Min; }
    ImVec2		GetTR() const							{ return ImVec2(Max.x,Min.y); }
    ImVec2		GetBL() const							{ return ImVec2(Min.x,Max.y); }
    ImVec2		GetBR() const							{ return Max; }
    bool		Contains(ImVec2 p) const 				{ return p.x >= Min.x && p.y >= Min.y && p.x <= Max.x && p.y <= Max.y; }
    bool		Contains(const ImGuiAabb& r) const		{ return r.Min.x >= Min.x && r.Min.y >= Min.y && r.Max.x <= Max.x && r.Max.y <= Max.y; }
    bool		Overlaps(const ImGuiAabb& r) const		{ return r.Min.y <= Max.y && r.Max.y >= Min.y && r.Min.x <= Max.x && r.Max.x >= Min.x; }
    void		Expand(ImVec2 sz)						{ Min -= sz; Max += sz; }
    void		Clip(const ImGuiAabb& clip)				{ Min.x = ImMax(Min.x, clip.Min.x); Min.y = ImMax(Min.y, clip.Min.y); Max.x = ImMin(Max.x, clip.Max.x); Max.y = ImMin(Max.y, clip.Max.y); }
};

// Temporary per-window data, reset at the beginning of the frame
struct ImGuiDrawContext
{
    ImVec2					CursorPos;
    ImVec2					CursorPosPrevLine;
    ImVec2					CursorStartPos;
    float					CurrentLineHeight;
    float					PrevLineHeight;
    float					LogLineHeight;
    int						TreeDepth;
    bool					LastItemHovered;
    ImVector<ImGuiWindow*>	ChildWindows;
    ImVector<bool>			AllowKeyboardFocus;
    ImVector<float>			ItemWidth;
    ImVector<ImGuiColMod>	ColorModifiers;
    ImGuiColorEditMode		ColorEditMode;
    ImGuiStorage*			StateStorage;
    int						OpenNextNode;

    float					ColumnStartX;
    int						ColumnCurrent;
    int						ColumnsCount;
    bool					ColumnsShowBorders;
    ImVec2					ColumnsStartCursorPos;
    ImGuiID					ColumnsSetID;

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
    char				Text[1024];						// edit buffer, we need to persist but can't guarantee the persistence of the user-provided buffer. so own buffer.
    char				InitialText[1024];				// backup of end-user buffer at focusing time, to ESC key can do a revert. Also used for arithmetic operations (but could use a pre-parsed float there).
    int					MaxLength;						// end-user buffer size <= 1024 (or increase above)
    float				Width;							// widget width
    float				ScrollX;
    STB_TexteditState	StbState;
    float				CursorAnim;
    bool				SelectedAllMouseLock;
    ImFont				Font;
    float				FontSize;

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
    static void			RenderTextScrolledClipped(ImFont font, float font_size, const char* text, ImVec2 pos_base, float width, float scroll_x);
};

struct ImGuiIniData
{
    char*	Name;
    ImVec2	Pos;
    ImVec2	Size;
    bool	Collapsed;

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
    ImGuiID					HoveredId;
    ImGuiID					ActiveId;
    ImGuiID					ActiveIdPreviousFrame;
    bool					ActiveIdIsAlive;
    float					SettingsDirtyTimer;
    ImVector<ImGuiIniData*>	Settings;
    ImVec2					NewWindowDefaultPos;

    // Render
    ImVector<ImDrawList*>	RenderDrawLists;

    // Widget state
    ImGuiTextEditState		InputTextState;
    ImGuiID					SliderAsInputTextId;
    ImGuiStorage			ColorEditModeStorage;				// for user selection
    ImGuiID					ActiveComboID;
    char					Tooltip[1024];

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

struct ImGuiWindow
{
    char*					Name;
    ImGuiID					ID;
    ImGuiWindowFlags		Flags;
    ImVec2					PosFloat;
    ImVec2					Pos;								// Position rounded-up to nearest pixel
    ImVec2					Size;								// Current size (==SizeFull or collapsed title bar size)
    ImVec2					SizeFull;							// Size when non collapsed
    ImVec2					SizeContentsFit;					// Size of contents (extents reach by the drawing cursor) - may not fit within Size.
    float					ScrollY;
    float					NextScrollY;
    bool					ScrollbarY;
    bool					Visible;
    bool					Collapsed;
    bool					Accessed;
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
