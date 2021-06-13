// ImGuiInternal.h
// created on 2021/6/12
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "Core/ImGui/ImGuiPrerequisites.h"
#include "Core/ImGui/ImGui.h"
#include "Core/ImGui/ImGuiTextEdit.h"

#include "Core/ImGui/Common/ImBitmapFont.h"
#include "Core/ImGui/Common/ImDrawList.h"
#include "Core/ImGui/Common/ImGuiAabb.h"
#include "Core/ImGui/Common/ImGuiStorage.h"
#include "Core/ImGui/Common/ImGuiTextBuffer.h"

// @formatter:off
//-------------------------------------------------------------------------
// Forward Declarations
//-------------------------------------------------------------------------

namespace ImGui
{

bool			ButtonBehaviour(const ImGuiAabb& bb, const ImGuiID& id, bool* out_hovered = NULL, bool* out_held = NULL, bool repeat = false);
void			RenderFrame(ImVec2 p_min, ImVec2 p_max, ImU32 fill_col, bool border = true, float rounding = 0.0f);
void			RenderText(ImVec2 pos, const char* text, const char* text_end = NULL, bool hide_text_after_hash = true);
ImVec2		CalcTextSize(const char* text, const char* text_end = NULL, bool hide_text_after_hash = true);
void			LogText(const ImVec2& ref_pos, const char* text, const char* text_end = NULL);

void			ItemSize(ImVec2 size, ImVec2* adjust_start_offset = NULL);
void			ItemSize(const ImGuiAabb& aabb, ImVec2* adjust_start_offset = NULL);
void			PushColumnClipRect(int column_index = -1);
bool			IsClipped(const ImGuiAabb& aabb);
bool			ClipAdvance(const ImGuiAabb& aabb, bool skip_columns = false);

bool			IsMouseHoveringBox(const ImGuiAabb& box);
bool			IsKeyPressedMap(ImGuiKey key, bool repeat = true);

bool			CloseWindowButton(bool* open = NULL);
void			FocusWindow(ImGuiWindow* window);
ImGuiWindow* FindHoveredWindow(ImVec2 pos, bool excluding_childs);

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

struct ImGuiIniData
{
    char*	Name{};
    ImVec2	Pos{};
    ImVec2	Size{};
    bool	Collapsed{};

    ImGuiIniData() = default;
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

extern ImGuiState	GImGui;

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
    ImU32		Color(ImGuiCol idx, float a=1.f) const;
};

ImGuiWindow*	GetCurrentWindow();

void RegisterAliveId(const ImGuiID& id);

ImGuiIniData *FindWindowSettings(const char *name);

// Zero-tolerance, poor-man .ini parsing
// FIXME: Write something less rubbish
void LoadSettings();

void SaveSettings();

void MarkSettingsDirty();
// @formatter:on