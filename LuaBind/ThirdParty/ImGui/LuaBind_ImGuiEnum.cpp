// LuaBindImGui.cpp
// created on 2021/8/21
// author @zoloypzuo
#include <imgui.h>
#include <imgui_internal.h>
#include <sol/sol.hpp>

namespace sol_ImGui {
void LuaBind_ImGuiEnum(sol::state &lua) {
// @formatter:off
#pragma region Window Flags
lua["ImGuiWindowFlags"] = lua.create_table_with(
"None", ImGuiWindowFlags_None,
"NoTitleBar", ImGuiWindowFlags_NoTitleBar,
"NoResize", ImGuiWindowFlags_NoResize,
"NoMove", ImGuiWindowFlags_NoMove,
"NoScrollbar", ImGuiWindowFlags_NoScrollbar,
"NoScrollWithMouse", ImGuiWindowFlags_NoScrollWithMouse,
"NoCollapse", ImGuiWindowFlags_NoCollapse,
"AlwaysAutoResize", ImGuiWindowFlags_AlwaysAutoResize,
"NoBackground", ImGuiWindowFlags_NoBackground,
"NoSavedSettings", ImGuiWindowFlags_NoSavedSettings,
"NoMouseInputs", ImGuiWindowFlags_NoMouseInputs,
"MenuBar", ImGuiWindowFlags_MenuBar,
"HorizontalScrollbar", ImGuiWindowFlags_HorizontalScrollbar,
"NoFocusOnAppearing", ImGuiWindowFlags_NoFocusOnAppearing,
"NoBringToFrontOnFocus", ImGuiWindowFlags_NoBringToFrontOnFocus,
"AlwaysVerticalScrollbar", ImGuiWindowFlags_AlwaysVerticalScrollbar,
"AlwaysHorizontalScrollbar", ImGuiWindowFlags_AlwaysHorizontalScrollbar,
"AlwaysUseWindowPadding", ImGuiWindowFlags_AlwaysUseWindowPadding,
"NoNavInputs", ImGuiWindowFlags_NoNavInputs,
"NoNavFocus", ImGuiWindowFlags_NoNavFocus,
"UnsavedDocument", ImGuiWindowFlags_UnsavedDocument,
"NoDocking", ImGuiWindowFlags_NoDocking,

"NoNav", ImGuiWindowFlags_NoNav,
"NoDecoration", ImGuiWindowFlags_NoDecoration,
"NoInputs", ImGuiWindowFlags_NoInputs,

"NavFlattened", ImGuiWindowFlags_NavFlattened,
"ChildWindow", ImGuiWindowFlags_ChildWindow,
"Tooltip", ImGuiWindowFlags_Tooltip,
"Popup", ImGuiWindowFlags_Popup,
"Modal", ImGuiWindowFlags_Modal,
"ChildMenu", ImGuiWindowFlags_ChildMenu,
"DockNodeHost", ImGuiWindowFlags_DockNodeHost
);
#pragma endregion Window Flags

#pragma region Focused Flags
lua["ImGuiFocusedFlags"] = lua.create_table_with(
"None", ImGuiFocusedFlags_None,
"ChildWindows", ImGuiFocusedFlags_ChildWindows,
"RootWindow", ImGuiFocusedFlags_RootWindow,
"AnyWindow", ImGuiFocusedFlags_AnyWindow,
"RootAndChildWindows", ImGuiFocusedFlags_RootAndChildWindows
);
#pragma endregion Focused Flags

#pragma region Hovered Flags
lua["ImGuiHoveredFlags"] = lua.create_table_with(
"None", ImGuiHoveredFlags_None,
"ChildWindows", ImGuiHoveredFlags_ChildWindows,
"RootWindow", ImGuiHoveredFlags_RootWindow,
"AnyWindow", ImGuiHoveredFlags_AnyWindow,
"AllowWhenBlockedByPopup", ImGuiHoveredFlags_AllowWhenBlockedByPopup,
"AllowWhenBlockedByActiveItem", ImGuiHoveredFlags_AllowWhenBlockedByActiveItem,
"AllowWhenOverlapped", ImGuiHoveredFlags_AllowWhenOverlapped,
"AllowWhenDisabled", ImGuiHoveredFlags_AllowWhenDisabled,
"RectOnly", ImGuiHoveredFlags_RectOnly,
"RootAndChildWindows", ImGuiHoveredFlags_RootAndChildWindows
);
#pragma endregion Hovered Flags

#pragma region Cond
lua["ImGuiCond"] = lua.create_table_with(
"None", ImGuiCond_None,
"Always", ImGuiCond_Always,
"Once", ImGuiCond_Once,
"FirstUseEver", ImGuiCond_FirstUseEver,
"Appearing", ImGuiCond_Appearing
);
#pragma endregion Cond

#pragma region Col
lua["ImGuiCol"] = lua.create_table_with(
"Text", ImGuiCol_Text,
"TextDisabled", ImGuiCol_TextDisabled,
"WindowBg", ImGuiCol_WindowBg,
"ChildBg", ImGuiCol_ChildBg,
"PopupBg", ImGuiCol_PopupBg,
"Border", ImGuiCol_Border,
"BorderShadow", ImGuiCol_BorderShadow,
"FrameBg", ImGuiCol_FrameBg,
"FrameBgHovered", ImGuiCol_FrameBgHovered,
"FrameBgActive", ImGuiCol_FrameBgActive,
"TitleBg", ImGuiCol_TitleBg,
"TitleBgActive", ImGuiCol_TitleBgActive,
"TitleBgCollapsed", ImGuiCol_TitleBgCollapsed,
"MenuBarBg", ImGuiCol_MenuBarBg,
"ScrollbarBg", ImGuiCol_ScrollbarBg,
"ScrollbarGrab", ImGuiCol_ScrollbarGrab,
"ScrollbarGrabHovered", ImGuiCol_ScrollbarGrabHovered,
"ScrollbarGrabActive", ImGuiCol_ScrollbarGrabActive,
"CheckMark", ImGuiCol_CheckMark,
"SliderGrab", ImGuiCol_SliderGrab,
"SliderGrabActive", ImGuiCol_SliderGrabActive,
"Button", ImGuiCol_Button,
"ButtonHovered", ImGuiCol_ButtonHovered,
"ButtonActive", ImGuiCol_ButtonActive,
"Header", ImGuiCol_Header,
"HeaderHovered", ImGuiCol_HeaderHovered,
"HeaderActive", ImGuiCol_HeaderActive,
"Separator", ImGuiCol_Separator,
"SeparatorHovered", ImGuiCol_SeparatorHovered,
"SeparatorActive", ImGuiCol_SeparatorActive,
"ResizeGrip", ImGuiCol_ResizeGrip,
"ResizeGripHovered", ImGuiCol_ResizeGripHovered,
"ResizeGripActive", ImGuiCol_ResizeGripActive,
"Tab", ImGuiCol_Tab,
"TabHovered", ImGuiCol_TabHovered,
"TabActive", ImGuiCol_TabActive,
"TabUnfocused", ImGuiCol_TabUnfocused,
"TabUnfocusedActive", ImGuiCol_TabUnfocusedActive,
"DockingPreview", ImGuiCol_DockingPreview,
"DockingEmptyBg", ImGuiCol_DockingEmptyBg,
"PlotLines", ImGuiCol_PlotLines,
"PlotLinesHovered", ImGuiCol_PlotLinesHovered,
"PlotHistogram", ImGuiCol_PlotHistogram,
"PlotHistogramHovered", ImGuiCol_PlotHistogramHovered,
"TextSelectedBg", ImGuiCol_TextSelectedBg,
"DragDropTarget", ImGuiCol_DragDropTarget,
"NavHighlight", ImGuiCol_NavHighlight,
"NavWindowingHighlight", ImGuiCol_NavWindowingHighlight,
"NavWindowingDimBg", ImGuiCol_NavWindowingDimBg,
"ModalWindowDimBg", ImGuiCol_ModalWindowDimBg,
"ModalWindowDarkening", ImGuiCol_ModalWindowDimBg,
"COUNT", ImGuiCol_COUNT
);
#pragma endregion Col

#pragma region Style
lua["ImGuiStyleVar"] = lua.create_table_with(
"Alpha", ImGuiStyleVar_Alpha,
"WindowPadding", ImGuiStyleVar_WindowPadding,
"WindowRounding", ImGuiStyleVar_WindowRounding,
"WindowBorderSize", ImGuiStyleVar_WindowBorderSize,
"WindowMinSize", ImGuiStyleVar_WindowMinSize,
"WindowTitleAlign", ImGuiStyleVar_WindowTitleAlign,
"ChildRounding", ImGuiStyleVar_ChildRounding,
"ChildBorderSize", ImGuiStyleVar_ChildBorderSize,
"PopupRounding", ImGuiStyleVar_PopupRounding,
"PopupBorderSize", ImGuiStyleVar_PopupBorderSize,
"FramePadding", ImGuiStyleVar_FramePadding,
"FrameRounding", ImGuiStyleVar_FrameRounding,
"FrameBorderSize", ImGuiStyleVar_FrameBorderSize,
"ItemSpacing", ImGuiStyleVar_ItemSpacing,
"ItemInnerSpacing", ImGuiStyleVar_ItemInnerSpacing,
"IndentSpacing", ImGuiStyleVar_IndentSpacing,
"ScrollbarSize", ImGuiStyleVar_ScrollbarSize,
"ScrollbarRounding", ImGuiStyleVar_ScrollbarRounding,
"GrabMinSize", ImGuiStyleVar_GrabMinSize,
"GrabRounding", ImGuiStyleVar_GrabRounding,
"TabRounding", ImGuiStyleVar_TabRounding,
"SelectableTextAlign", ImGuiStyleVar_SelectableTextAlign,
"ButtonTextAlign", ImGuiStyleVar_ButtonTextAlign,
"COUNT", ImGuiStyleVar_COUNT
);
#pragma endregion Style

#pragma region Dir
lua["ImGuiDir"] = lua.create_table_with(
"None", ImGuiDir_None,
"Left", ImGuiDir_Left,
"Right", ImGuiDir_Right,
"Up", ImGuiDir_Up,
"Down", ImGuiDir_Down,
"COUNT", ImGuiDir_COUNT
);
#pragma endregion Dir

#pragma region Combo Flags
lua["ImGuiComboFlags"] = lua.create_table_with(
"None", ImGuiComboFlags_None,
"PopupAlignLeft", ImGuiComboFlags_PopupAlignLeft,
"HeightSmall", ImGuiComboFlags_HeightSmall,
"HeightRegular", ImGuiComboFlags_HeightRegular,
"HeightLarge", ImGuiComboFlags_HeightLarge,
"HeightLargest", ImGuiComboFlags_HeightLargest,
"NoArrowButton", ImGuiComboFlags_NoArrowButton,
"NoPreview", ImGuiComboFlags_NoPreview,
"HeightMask", ImGuiComboFlags_HeightMask_
);
#pragma endregion Combo Flags

#pragma region InputText Flags
lua["ImGuiInputTextFlags"] = lua.create_table_with(
"None", ImGuiInputTextFlags_None,
"CharsDecimal", ImGuiInputTextFlags_CharsDecimal,
"CharsHexadecimal", ImGuiInputTextFlags_CharsHexadecimal,
"CharsUppercase", ImGuiInputTextFlags_CharsUppercase,
"CharsNoBlank", ImGuiInputTextFlags_CharsNoBlank,
"AutoSelectAll", ImGuiInputTextFlags_AutoSelectAll,
"EnterReturnsTrue", ImGuiInputTextFlags_EnterReturnsTrue,
"CallbackCompletion", ImGuiInputTextFlags_CallbackCompletion,
"CallbackHistory", ImGuiInputTextFlags_CallbackHistory,
"CallbackAlways", ImGuiInputTextFlags_CallbackAlways,
"CallbackCharFilter", ImGuiInputTextFlags_CallbackCharFilter,
"AllowTabInput", ImGuiInputTextFlags_AllowTabInput,
"CtrlEnterForNewLine", ImGuiInputTextFlags_CtrlEnterForNewLine,
"NoHorizontalScroll", ImGuiInputTextFlags_NoHorizontalScroll,
"AlwaysInsertMode", ImGuiInputTextFlags_AlwaysInsertMode,
"ReadOnly", ImGuiInputTextFlags_ReadOnly,
"Password", ImGuiInputTextFlags_Password,
"NoUndoRedo", ImGuiInputTextFlags_NoUndoRedo,
"CharsScientific", ImGuiInputTextFlags_CharsScientific,
"CallbackResize", ImGuiInputTextFlags_CallbackResize,
"Multiline", ImGuiInputTextFlags_Multiline,
"NoMarkEdited", ImGuiInputTextFlags_NoMarkEdited
);
#pragma endregion InputText Flags

#pragma region ColorEdit Flags
lua["ImGuiColorEditFlags"] = lua.create_table_with(
"None", ImGuiColorEditFlags_None,
"NoAlpha", ImGuiColorEditFlags_NoAlpha,
"NoPicker", ImGuiColorEditFlags_NoPicker,
"NoOptions", ImGuiColorEditFlags_NoOptions,
"NoSmallPreview", ImGuiColorEditFlags_NoSmallPreview,
"NoInputs", ImGuiColorEditFlags_NoInputs,
"NoTooltip", ImGuiColorEditFlags_NoTooltip,
"NoLabel", ImGuiColorEditFlags_NoLabel,
"NoSidePreview", ImGuiColorEditFlags_NoSidePreview,
"NoDragDrop", ImGuiColorEditFlags_NoDragDrop,
"NoBorder", ImGuiColorEditFlags_NoBorder,

"AlphaBar", ImGuiColorEditFlags_AlphaBar,
"AlphaPreview", ImGuiColorEditFlags_AlphaPreview,
"AlphaPreviewHalf", ImGuiColorEditFlags_AlphaPreviewHalf,
"HDR", ImGuiColorEditFlags_HDR,
"DisplayRGB", ImGuiColorEditFlags_DisplayRGB,
"DisplayHSV", ImGuiColorEditFlags_DisplayHSV,
"DisplayHex", ImGuiColorEditFlags_DisplayHex,
"Uint8", ImGuiColorEditFlags_Uint8,
"Float", ImGuiColorEditFlags_Float,
"PickerHueBar", ImGuiColorEditFlags_PickerHueBar,
"PickerHueWheel", ImGuiColorEditFlags_PickerHueWheel,
"InputRGB", ImGuiColorEditFlags_InputRGB,
"InputHSV", ImGuiColorEditFlags_InputHSV,

"_OptionsDefault", ImGuiColorEditFlags_DefaultOptions_,
"_DisplayMask", ImGuiColorEditFlags_DisplayMask_,
"_DataTypeMask", ImGuiColorEditFlags_DataTypeMask_,
"_PickerMask", ImGuiColorEditFlags_PickerMask_,
"_InputMask", ImGuiColorEditFlags_InputMask_,

"RGB", ImGuiColorEditFlags_RGB
);
#pragma endregion ColorEdit Flags

#pragma region TreeNode Flags
lua["ImGuiTreeNodeFlags"] = lua.create_table_with(
"None", ImGuiTreeNodeFlags_None,
"Selected", ImGuiTreeNodeFlags_Selected,
"Framed", ImGuiTreeNodeFlags_Framed,
"AllowItemOverlap", ImGuiTreeNodeFlags_AllowItemOverlap,
"NoTreePushOnOpen", ImGuiTreeNodeFlags_NoTreePushOnOpen,
"NoAutoOpenOnLog", ImGuiTreeNodeFlags_NoAutoOpenOnLog,
"DefaultOpen", ImGuiTreeNodeFlags_DefaultOpen,
"OpenOnDoubleClick", ImGuiTreeNodeFlags_OpenOnDoubleClick,
"OpenOnArrow", ImGuiTreeNodeFlags_OpenOnArrow,
"Leaf", ImGuiTreeNodeFlags_Leaf,
"Bullet", ImGuiTreeNodeFlags_Bullet,
"FramePadding", ImGuiTreeNodeFlags_FramePadding,
"SpanAvailWidth", ImGuiTreeNodeFlags_SpanAvailWidth,
"SpanFullWidth", ImGuiTreeNodeFlags_SpanFullWidth,
"NavLeftJumpsBackHere", ImGuiTreeNodeFlags_NavLeftJumpsBackHere,
"CollapsingHeader", ImGuiTreeNodeFlags_CollapsingHeader
);
#pragma endregion TreeNode Flags

#pragma region Selectable Flags
lua["ImGuiSelectableFlags"] = lua.create_table_with(
"None", ImGuiSelectableFlags_None,
"DontClosePopups", ImGuiSelectableFlags_DontClosePopups,
"SpanAllColumns", ImGuiSelectableFlags_SpanAllColumns,
"AllowDoubleClick", ImGuiSelectableFlags_AllowDoubleClick,
"Disabled", ImGuiSelectableFlags_Disabled,
"AllowItemOverlap", ImGuiSelectableFlags_AllowItemOverlap
);
#pragma endregion Selectable Flags

#pragma region Popup Flags
lua["ImGuiPopupFlags"] = lua.create_table_with(
"None", ImGuiPopupFlags_None,
"MouseButtonLeft", ImGuiPopupFlags_MouseButtonLeft,
"MouseButtonRight", ImGuiPopupFlags_MouseButtonRight,
"MouseButtonMiddle", ImGuiPopupFlags_MouseButtonMiddle,
"MouseButtonMask_", ImGuiPopupFlags_MouseButtonMask_,
"MouseButtonDefault_", ImGuiPopupFlags_MouseButtonDefault_,
"NoOpenOverExistingPopup", ImGuiPopupFlags_NoOpenOverExistingPopup,
"NoOpenOverItems", ImGuiPopupFlags_NoOpenOverItems,
"AnyPopupId", ImGuiPopupFlags_AnyPopupId,
"AnyPopupLevel", ImGuiPopupFlags_AnyPopupLevel,
"AnyPopup", ImGuiPopupFlags_AnyPopup
);
#pragma endregion Popup Flags

#pragma region TabBar Flags
lua["ImGuiTabBarFlags"] = lua.create_table_with(
"None", ImGuiTabBarFlags_None,
"Reorderable", ImGuiTabBarFlags_Reorderable,
"AutoSelectNewTabs", ImGuiTabBarFlags_AutoSelectNewTabs,
"TabListPopupButton", ImGuiTabBarFlags_TabListPopupButton,
"NoCloseWithMiddleMouseButton", ImGuiTabBarFlags_NoCloseWithMiddleMouseButton,
"NoTabListScrollingButtons", ImGuiTabBarFlags_NoTabListScrollingButtons,
"NoTooltip", ImGuiTabBarFlags_NoTooltip,
"FittingPolicyResizeDown", ImGuiTabBarFlags_FittingPolicyResizeDown,
"FittingPolicyScroll", ImGuiTabBarFlags_FittingPolicyScroll,
"FittingPolicyMask_", ImGuiTabBarFlags_FittingPolicyMask_,
"FittingPolicyDefault_", ImGuiTabBarFlags_FittingPolicyDefault_
);
#pragma endregion TabBar Flags

#pragma region TabItem Flags
lua["ImGuiTabItemFlags"] = lua.create_table_with(
"None", ImGuiTabItemFlags_None,
"UnsavedDocument", ImGuiTabItemFlags_UnsavedDocument,
"SetSelected", ImGuiTabItemFlags_SetSelected,
"NoCloseWithMiddleMouseButton", ImGuiTabItemFlags_NoCloseWithMiddleMouseButton,
"NoPushId", ImGuiTabItemFlags_NoPushId,
"NoTooltip", ImGuiTabItemFlags_NoTooltip
);
#pragma endregion TabItem Flags

#pragma region DockNode Flags
lua["ImGuiDockNodeFlags"] = lua.create_table_with(
"None", ImGuiDockNodeFlags_None,
"KeepAliveOnly", ImGuiDockNodeFlags_KeepAliveOnly,
"NoDockingInCentralNode", ImGuiDockNodeFlags_NoDockingInCentralNode,
"PassthruCentralNode", ImGuiDockNodeFlags_PassthruCentralNode,
"NoSplit", ImGuiDockNodeFlags_NoSplit,
"NoResize", ImGuiDockNodeFlags_NoResize,
"AutoHideTabBar", ImGuiDockNodeFlags_AutoHideTabBar
);
#pragma endregion DockNode Flags

#pragma region MouseButton
lua["ImGuiMouseButton"] = lua.create_table_with(
"ImGuiMouseButton_Left", ImGuiMouseButton_Left,
"ImGuiMouseButton_Right", ImGuiMouseButton_Right,
"ImGuiMouseButton_Middle", ImGuiMouseButton_Middle,
"ImGuiMouseButton_COUNT", ImGuiMouseButton_COUNT
);
#pragma endregion MouseButton

#pragma region Key
lua["ImGuiKey"] = lua.create_table_with(
"Tab", ImGuiKey_Tab,
"LeftArrow", ImGuiKey_LeftArrow,
"RightArrow", ImGuiKey_RightArrow,
"UpArrow", ImGuiKey_UpArrow,
"DownArrow", ImGuiKey_DownArrow,
"PageUp", ImGuiKey_PageUp,
"PageDown", ImGuiKey_PageDown,
"Home", ImGuiKey_Home,
"End", ImGuiKey_End,
"Insert", ImGuiKey_Insert,
"Delete", ImGuiKey_Delete,
"Backspace", ImGuiKey_Backspace,
"Space", ImGuiKey_Space,
"Enter", ImGuiKey_Enter,
"Escape", ImGuiKey_Escape,
"KeyPadEnter", ImGuiKey_KeyPadEnter,
"A", ImGuiKey_A,
"C", ImGuiKey_C,
"V", ImGuiKey_V,
"X", ImGuiKey_X,
"Y", ImGuiKey_Y,
"Z", ImGuiKey_Z,
"COUNT", ImGuiKey_COUNT
);
#pragma endregion Key

#pragma region MouseCursor
lua["ImGuiMouseCursor"] = lua.create_table_with(
"None", ImGuiMouseCursor_None,
"Arrow", ImGuiMouseCursor_Arrow,
"TextInput", ImGuiMouseCursor_TextInput,
"ResizeAll", ImGuiMouseCursor_ResizeAll,
"ResizeNS", ImGuiMouseCursor_ResizeNS,
"ResizeEW", ImGuiMouseCursor_ResizeEW,
"ResizeNESW", ImGuiMouseCursor_ResizeNESW,
"ResizeNWSE", ImGuiMouseCursor_ResizeNWSE,
"Hand", ImGuiMouseCursor_Hand,
"NotAllowed", ImGuiMouseCursor_NotAllowed,
"COUNT", ImGuiMouseCursor_COUNT
);
#pragma endregion MouseCursor

lua["ImGuiDragDropFlags"] = lua.create_table_with(
"None", ImGuiDragDropFlags_None,
"SourceNoPreviewTooltip", ImGuiDragDropFlags_SourceNoPreviewTooltip,
"SourceNoDisableHover", ImGuiDragDropFlags_SourceNoDisableHover,
"SourceNoHoldToOpenOthers", ImGuiDragDropFlags_SourceNoHoldToOpenOthers,
"SourceAllowNullID", ImGuiDragDropFlags_SourceAllowNullID,
"SourceExtern", ImGuiDragDropFlags_SourceExtern,
"SourceAutoExpirePayload", ImGuiDragDropFlags_SourceAutoExpirePayload,
"AcceptBeforeDelivery", ImGuiDragDropFlags_AcceptBeforeDelivery,
"AcceptNoDrawDefaultRect", ImGuiDragDropFlags_AcceptNoDrawDefaultRect,
"AcceptNoPreviewTooltip", ImGuiDragDropFlags_AcceptNoPreviewTooltip,
"AcceptPeekOnly", ImGuiDragDropFlags_AcceptPeekOnly
);

lua["ImGuiSliderFlags"] = lua.create_table_with(
"None", ImGuiSliderFlags_None,
"AlwaysClamp", ImGuiSliderFlags_AlwaysClamp,
"Logarithmic", ImGuiSliderFlags_Logarithmic,
"NoRoundToFormat", ImGuiSliderFlags_NoRoundToFormat,
"NoInput", ImGuiSliderFlags_NoInput,
"InvalidMask_", ImGuiSliderFlags_InvalidMask_
);
// @formatter:on
}
}