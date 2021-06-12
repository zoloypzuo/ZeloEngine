// ImGui.h
// created on 2021/5/28
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ImGuiPrerequisites.h"

// @formatter:off

// ImGui End-user API
// In a namespace so that user can add extra functions (e.g. Value() helpers for your vector or common types)
namespace ImGui {
    // Main
    ImGuiIO&	GetIO();
    ImGuiStyle&	GetStyle();
    void		NewFrame();
    void		Render();
    void		Shutdown();

    // Window
    bool		Begin(const char* name = "Debug", bool* open = NULL, ImVec2 size = ImVec2(0,0), float fill_alpha = -1.0f, ImGuiWindowFlags flags = 0);
    void		End();
    void		BeginChild(const char* str_id, ImVec2 size = ImVec2(0,0), bool border = false, ImGuiWindowFlags extra_flags = 0);
    void		EndChild();
    bool		GetWindowIsFocused();
    float		GetWindowWidth();
    ImVec2		GetWindowPos();														// you should rarely need/care about the window position, but it can be useful if you want to use your own drawing
    void		SetWindowPos(ImVec2 pos);											// unchecked
    ImVec2		GetWindowSize();
    ImVec2		GetWindowContentRegionMin();
    ImVec2		GetWindowContentRegionMax();
    ImDrawList*	GetWindowDrawList();
    void		SetFontScale(float scale);
    void		SetScrollPosHere();
    void		SetTreeStateStorage(ImGuiStorage* tree);
    void		PushItemWidth(float item_width);
    void		PopItemWidth();
    void		PushAllowKeyboardFocus(bool v);
    void		PopAllowKeyboardFocus();
    void		PushStyleColor(ImGuiCol idx, ImVec4 col);
    void		PopStyleColor();

    // Layout
    void		Separator();														// horizontal line
    void		SameLine(int column_x = 0, int spacing_w = -1);						// call between widgets to layout them horizontally
    void		Spacing();
    void		Columns(int count = 1, const char* id = NULL, bool border=true);	// setup number of columns
    void		NextColumn();														// next column
    float		GetColumnOffset(int column_index = -1);
    void		SetColumnOffset(int column_index, float offset);
    float		GetColumnWidth(int column_index = -1);
    ImVec2		GetCursorPos();														// cursor position relative to window position
    void		SetCursorPos(ImVec2 p);
    void		AlignFirstTextHeightToWidgets();									// call once if the first item on the line is a Text() item and you want to vertically lower it to match higher widgets.
    float		GetTextLineSpacing();
    float		GetTextLineHeight();

    // ID scopes
    void		PushID(const char* str_id);
    void		PushID(const void* ptr_id);
    void		PushID(int int_id);
    void		PopID();

    // Widgets
    void		Text(const char* fmt, ...);
    void		TextV(const char* fmt, va_list args);
    void		TextUnformatted(const char* text, const char* text_end = NULL);		// doesn't require null terminated string if 'text_end' is specified. no copy done to any bounded stack buffer, better for long chunks of text.
    void		LabelText(const char* label, const char* fmt, ...);
    void		BulletText(const char* fmt, ...);
    bool		Button(const char* label, ImVec2 size = ImVec2(0,0), bool repeat_when_held = false);
    bool		SmallButton(const char* label);
    bool		CollapsingHeader(const char* label, const char* str_id = NULL, bool display_frame = true, bool default_open = false);
    bool		SliderFloat(const char* label, float* v, float v_min, float v_max, const char* display_format = "%.3f", float power = 1.0f);
    bool		SliderFloat3(const char* label, float v[3], float v_min, float v_max, const char* display_format = "%.3f", float power = 1.0f);
    bool		SliderAngle(const char* label, float* v, float v_degrees_min = -360.0f, float v_degrees_max = +360.0f);		// *v in radians
    bool		SliderInt(const char* label, int* v, int v_min, int v_max, const char* display_format = "%.0f");
    void		PlotLines(const char* label, const float* values, int values_count, int values_offset = 0, const char* overlay_text = NULL, float scale_min = FLT_MAX, float scale_max = FLT_MAX, ImVec2 graph_size = ImVec2(0,0));
    void		PlotHistogram(const char* label, const float* values, int values_count, int values_offset = 0, const char* overlay_text = NULL, float scale_min = FLT_MAX, float scale_max = FLT_MAX, ImVec2 graph_size = ImVec2(0,0));
    void		Checkbox(const char* label, bool* v);
    void		CheckboxFlags(const char* label, unsigned int* flags, unsigned int flags_value);
    bool		RadioButton(const char* label, bool active);
    bool		RadioButton(const char* label, int* v, int v_button);
    bool		InputFloat(const char* label, float* v, float step = 0.0f, float step_fast = 0.0f, int decimal_precision = -1);
    bool		InputFloat3(const char* label, float v[3], int decimal_precision = -1);
    bool		InputInt(const char* label, int* v, int step = 1, int step_fast = 100);
    bool		InputText(const char* label, char* buf, size_t buf_size, ImGuiInputTextFlags flags = 0);
    bool		Combo(const char* label, int* current_item, const char** items, int items_count, int popup_height_items = 7);
    bool		Combo(const char* label, int* current_item, const char* items_separated_by_zeros, int popup_height_items = 7);		// Separate items with \0, end item-list with \0\0
    bool		Combo(const char* label, int* current_item, bool (*items_getter)(void* data, int idx, const char** out_text), void* data, int items_count, int popup_height_items = 7);
    bool		ColorButton(const ImVec4& col, bool small_height = false, bool outline_border = true);
    bool		ColorEdit3(const char* label, float col[3]);
    bool		ColorEdit4(const char* label, float col[4], bool show_alpha = true);
    void		ColorEditMode(ImGuiColorEditMode mode);
    bool		TreeNode(const char* str_label_id);									// if returning 'true' the user is responsible for calling TreePop
    bool		TreeNode(const char* str_id, const char* fmt, ...);					// "
    bool		TreeNode(const void* ptr_id, const char* fmt, ...);					// "
    void		TreePush(const char* str_id = NULL);								// already called by TreeNode(), but you can call Push/Pop yourself for layout purpose
    void		TreePush(const void* ptr_id = NULL);								// "
    void		TreePop();
    void		OpenNextNode(bool open);											// force open/close the next TreeNode or CollapsingHeader

    // Value helper output "name: value"
    // Freely declare your own in the ImGui namespace.
    void		Value(const char* prefix, bool b);
    void		Value(const char* prefix, int v);
    void		Value(const char* prefix, unsigned int v);
    void		Value(const char* prefix, float v, const char* float_format = NULL);
    void		Color(const char* prefix, const ImVec4& v);
    void		Color(const char* prefix, unsigned int v);

    // Logging
    void		LogButtons();
    void		LogToTTY(int max_depth);
    void		LogToFile(int max_depth, const char* filename);
    void		LogToClipboard(int max_depth);

    // Utilities
    void		SetTooltip(const char* fmt, ...);									// set tooltip under mouse-cursor, typically use with ImGui::IsHovered(). (currently no contention handling, last call win)
    void		SetNewWindowDefaultPos(ImVec2 pos);									// set position of window that do
    bool		IsHovered();														// was the last item active area hovered by mouse?
    bool		IsClipped(ImVec2 item_size);										// to perform coarse clipping on user's side (as an optimisation)
    bool		IsKeyPressed(int key_index, bool repeat = true);					// key_index into the keys_down[512] array, imgui doesn't know the semantic of each entry
    bool		IsMouseClicked(int button, bool repeat = false);
    ImVec2		GetMousePos();
    float		GetTime();
    int			GetFrameCount();
    const char*	GetStyleColorName(ImGuiCol idx);
    void		GetDefaultFontData(const void** fnt_data, unsigned int* fnt_size, const void** png_data, unsigned int* png_size);

// TODO 重构为类
//private:
//    struct ImGuiState;
//    std::unique_ptr<ImGuiState> m_imguiState;
};

// Flags for ImGui::Begin()
enum ImGuiWindowFlags_
{
    // Default: 0
    ImGuiWindowFlags_ShowBorders			= 1 << 0,
    ImGuiWindowFlags_NoTitleBar				= 1 << 1,
    ImGuiWindowFlags_NoResize				= 1 << 2,
    ImGuiWindowFlags_NoMove					= 1 << 3,
    ImGuiWindowFlags_NoScrollbar			= 1 << 4,
    ImGuiWindowFlags_ChildWindow			= 1 << 5,	// For internal use by BeginChild()
    ImGuiWindowFlags_ChildWindowAutoFitX	= 1 << 6,	// For internal use by BeginChild()
    ImGuiWindowFlags_ChildWindowAutoFitY	= 1 << 7,	// For internal use by BeginChild()
    ImGuiWindowFlags_ComboBox				= 1 << 8,	// For internal use by ComboBox()
    ImGuiWindowFlags_Tooltip				= 1 << 9,	// For internal use by Render() when using Tooltip
};

// Flags for ImGui::InputText()
enum ImGuiInputTextFlags_
{
    // Default: 0
    ImGuiInputTextFlags_CharsDecimal		= 1 << 0,
    ImGuiInputTextFlags_CharsHexadecimal	= 1 << 1,
    ImGuiInputTextFlags_AutoSelectAll		= 1 << 2,
    ImGuiInputTextFlags_AlignCenter			= 1 << 3,
};

// User fill ImGuiIO.KeyMap[] array with indices into the ImGuiIO.KeysDown[512] array
enum ImGuiKey_
{
    ImGuiKey_Tab,
    ImGuiKey_LeftArrow,
    ImGuiKey_RightArrow,
    ImGuiKey_UpArrow,
    ImGuiKey_DownArrow,
    ImGuiKey_Home,
    ImGuiKey_End,
    ImGuiKey_Delete,
    ImGuiKey_Backspace,
    ImGuiKey_Enter,
    ImGuiKey_Escape,
    ImGuiKey_A,			// for CTRL+A: select all
    ImGuiKey_C,			// for CTRL+C: copy
    ImGuiKey_V,			// for CTRL+V: paste
    ImGuiKey_X,			// for CTRL+X: cut
    ImGuiKey_Y,			// for CTRL+Y: redo
    ImGuiKey_Z,			// for CTRL+Z: undo
    ImGuiKey_COUNT,
};

enum ImGuiCol_
{
    ImGuiCol_Text,
    ImGuiCol_WindowBg,
    ImGuiCol_Border,
    ImGuiCol_BorderShadow,
    ImGuiCol_FrameBg,				// Background of checkbox, radio button, plot, slider, text input
    ImGuiCol_TitleBg,
    ImGuiCol_TitleBgCollapsed,
    ImGuiCol_ScrollbarBg,
    ImGuiCol_ScrollbarGrab,
    ImGuiCol_ScrollbarGrabHovered,
    ImGuiCol_ScrollbarGrabActive,
    ImGuiCol_ComboBg,
    ImGuiCol_CheckActive,
    ImGuiCol_SliderGrab,
    ImGuiCol_SliderGrabActive,
    ImGuiCol_Button,
    ImGuiCol_ButtonHovered,
    ImGuiCol_ButtonActive,
    ImGuiCol_Header,
    ImGuiCol_HeaderHovered,
    ImGuiCol_HeaderActive,
    ImGuiCol_Column,
    ImGuiCol_ColumnHovered,
    ImGuiCol_ColumnActive,
    ImGuiCol_ResizeGrip,
    ImGuiCol_ResizeGripHovered,
    ImGuiCol_ResizeGripActive,
    ImGuiCol_CloseButton,
    ImGuiCol_CloseButtonHovered,
    ImGuiCol_CloseButtonActive,
    ImGuiCol_PlotLines,
    ImGuiCol_PlotLinesHovered,
    ImGuiCol_PlotHistogram,
    ImGuiCol_PlotHistogramHovered,
    ImGuiCol_TextSelectedBg,
    ImGuiCol_TooltipBg,
    ImGuiCol_COUNT,
};

enum ImGuiColorEditMode_
{
    ImGuiColorEditMode_UserSelect = -1,
    ImGuiColorEditMode_RGB = 0,
    ImGuiColorEditMode_HSV = 1,
    ImGuiColorEditMode_HEX = 2,
};

// See constructor for comments of individual fields.
struct ImGuiStyle
{
    ImVec2		WindowPadding{};
    ImVec2		WindowMinSize{};
    ImVec2		FramePadding{};
    ImVec2		ItemSpacing{};
    ImVec2		ItemInnerSpacing{};
    ImVec2		TouchExtraPadding{};
    ImVec2		AutoFitPadding{};
    float		WindowFillAlphaDefault;
    float		WindowRounding;
    float		TreeNodeSpacing;
    float		ColumnsMinSpacing;
    float		ScrollBarWidth;
    ImVec4		Colors[ImGuiCol_COUNT]{};

    ImGuiStyle();
};
//} __attribute__((aligned(128)));

// This is where your app communicate with ImGui. Call ImGui::GetIO() to access.
// Read 'Programmer guide' section in .cpp file for general usage.
struct ImGuiIO
{
    // Settings (fill once)					// Default value:
    ImVec2		DisplaySize{};				// <unset>					// Display size, in pixels. For clamping windows positions.
    float		DeltaTime;					// = 1.0f/60.0f				// Time elapsed since last frame, in seconds.
    float		IniSavingRate;				// = 5.0f					// Maximum time between saving .ini file, in seconds. Set to a negative value to disable .ini saving.
    const char* IniFilename;				// = "imgui.ini"			// Absolute path to .ini file.
    const char*	LogFilename;				// = "imgui_log.txt"		// Absolute path to .log file.
    float		MouseDoubleClickTime;		// = 0.30f					// Time for a double-click, in seconds.
    float		MouseDoubleClickMaxDist;	// = 6.0f					// Distance threshold to stay in to validate a double-click, in pixels.
    int			KeyMap[ImGuiKey_COUNT]{};		// <unset>					// Map of indices into the KeysDown[512] entries array
    ImFont		Font;						// <auto>					// Gets passed to text functions. Typedef ImFont to the type you want (ImBitmapFont* or your own font).
    float		FontHeight{};					// <auto>					// Default font height, must be the vertical distance between two lines of text, aka == CalcTextSize(" ").y
    bool		FontAllowScaling;			// = false					// Set to allow scaling text with CTRL+Wheel.

    // Settings - Functions (fill once)
    void		(*RenderDrawListsFn)(ImDrawList** const draw_lists, int count){};	// Required
    const char*	(*GetClipboardTextFn)(){};										// Required for clipboard support
    void		(*SetClipboardTextFn)(const char* text, const char* text_end){};	// Required for clipboard support (nb- the string is *NOT* zero-terminated at 'text_end')

    // Input - Fill before calling NewFrame()
    ImVec2		MousePos{};					// Mouse position (set to -1,-1 if no mouse / on another screen, etc.)
    bool		MouseDown[2]{};				// Mouse buttons
    int			MouseWheel{};					// Mouse wheel: -1,0,+1
    bool		KeyCtrl{};					// Keyboard modifier pressed: Control
    bool		KeyShift{};					// Keyboard modifier pressed: Shift
    bool		KeysDown[512]{};				// Keyboard keys that are pressed (in whatever order user naturally has access to keyboard data)
    char		InputCharacters[16]{};		// List of characters input (translated by user from keypress+keyboard state). Fill using AddInputCharacter() helper.

    // Output - Retrieve after calling NewFrame(), you can use them to discard inputs for the rest of your application
    bool		WantCaptureMouse{};			// ImGui is using your mouse input (= window is being hovered or widget is active).
    bool		WantCaptureKeyboard{};		// imGui is using your keyboard input (= widget is active).

    // [Internal] ImGui will maintain those fields for you
    ImVec2		MousePosPrev{};
    ImVec2		MouseDelta{};
    bool		MouseClicked[2]{};
    ImVec2		MouseClickedPos[2]{};
    float		MouseClickedTime[2]{};
    bool		MouseDoubleClicked[2]{};
    float		MouseDownTime[2]{};
    float		KeysDownTime[512]{};

    ImGuiIO();
    void		AddInputCharacter(char c);	// Helper to add a new character into InputCharacters[]
};

// @formatter:on
