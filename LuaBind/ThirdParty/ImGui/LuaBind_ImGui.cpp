// LuaBindImGui.cpp
// created on 2021/8/21
// author @zoloypzuo
// TODO [] BeginChild, , PushClipRect, IsMouseHoveringRect, too many params
#include <imgui.h>
#include <string>
#include <sol/sol.hpp>

#include "LuaBindImGui.h"  // ImVec2, ImVec4

void LuaBind_ImGui(sol::state &luaState);

namespace sol_ImGui {

void LuaBind_ImGuiWindow(sol::table &ImGui);

void LuaBind_ImGuiWidget(sol::table &ImGui);

// Parameters stacks (shared)
inline void PushFont(ImFont *pFont) { ImGui::PushFont(pFont); }

inline void PopFont() { ImGui::PopFont(); }

inline void PushStyleColor(int idx, const ImVec4 &col) {
    ImGui::PushStyleColor(static_cast<ImGuiCol>(idx), col);
}

inline void PopStyleColor() { ImGui::PopStyleColor(); }

inline void PopStyleColor(int count) { ImGui::PopStyleColor(count); }

inline void PushStyleVar(int idx, float val) { ImGui::PushStyleVar(static_cast<ImGuiStyleVar>(idx), val); }

inline void PushStyleVar(int idx, float valX, float valY) {
    ImGui::PushStyleVar(static_cast<ImGuiStyleVar>(idx), {valX, valY});
}

inline void PopStyleVar() { ImGui::PopStyleVar(); }

inline void PopStyleVar(int count) { ImGui::PopStyleVar(count); }

inline std::tuple<float, float, float, float> GetStyleColorVec4(int idx) {
    const auto col{ImGui::GetStyleColorVec4(static_cast<ImGuiCol>(idx))};
    return std::make_tuple(col.x, col.y, col.z, col.w);
}

inline ImFont *GetFont() { return ImGui::GetFont(); }

inline float GetFontSize() { return ImGui::GetFontSize(); }

inline std::tuple<float, float> GetFontTexUvWhitePixel() {
    const auto vec2{ImGui::GetFontTexUvWhitePixel()};
    return std::make_tuple(vec2.x, vec2.y);
}

// Parameters stacks (current window)
inline void PushItemWidth(float itemWidth) { ImGui::PushItemWidth(itemWidth); }

inline void PopItemWidth() { ImGui::PopItemWidth(); }

inline void SetNextItemWidth(float itemWidth) { ImGui::SetNextItemWidth(itemWidth); }

inline float CalcItemWidth() { return ImGui::CalcItemWidth(); }

inline void PushTextWrapPos() { ImGui::PushTextWrapPos(); }

inline void PushTextWrapPos(float wrapLocalPosX) { ImGui::PushTextWrapPos(wrapLocalPosX); }

inline void PopTextWrapPos() { ImGui::PopTextWrapPos(); }

inline void PushAllowKeyboardFocus(bool allowKeyboardFocus) { ImGui::PushAllowKeyboardFocus(allowKeyboardFocus); }

inline void PopAllowKeyboardFocus() { ImGui::PopAllowKeyboardFocus(); }

inline void PushButtonRepeat(bool repeat) { ImGui::PushButtonRepeat(repeat); }

inline void PopButtonRepeat() { ImGui::PopButtonRepeat(); }

// Cursor / Layout
inline void Separator() { ImGui::Separator(); }

inline void SameLine() { ImGui::SameLine(); }

inline void SameLine(float offsetFromStartX) { ImGui::SameLine(offsetFromStartX); }

inline void SameLine(float offsetFromStartX, float spacing) { ImGui::SameLine(offsetFromStartX, spacing); }

inline void NewLine() { ImGui::NewLine(); }

inline void Spacing() { ImGui::Spacing(); }

inline void Dummy(float sizeX, float sizeY) { ImGui::Dummy({sizeX, sizeY}); }

inline void Indent() { ImGui::Indent(); }

inline void Indent(float indentW) { ImGui::Indent(indentW); }

inline void Unindent() { ImGui::Unindent(); }

inline void Unindent(float indentW) { ImGui::Unindent(indentW); }

inline void BeginGroup() { ImGui::BeginGroup(); }

inline void EndGroup() { ImGui::EndGroup(); }

inline std::tuple<float, float> GetCursorPos() {
    const auto vec2{ImGui::GetCursorPos()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline float GetCursorPosX() { return ImGui::GetCursorPosX(); }

inline float GetCursorPosY() { return ImGui::GetCursorPosY(); }

inline void SetCursorPos(float localX, float localY) { ImGui::SetCursorPos({localX, localY}); }

inline void SetCursorPosX(float localX) { ImGui::SetCursorPosX(localX); }

inline void SetCursorPosY(float localY) { ImGui::SetCursorPosY(localY); }

inline std::tuple<float, float> GetCursorStartPos() {
    const auto vec2{ImGui::GetCursorStartPos()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float> GetCursorScreenPos() {
    const auto vec2{ImGui::GetCursorScreenPos()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline void SetCursorScreenPos(float posX, float posY) { ImGui::SetCursorScreenPos({posX, posY}); }

inline void AlignTextToFramePadding() { ImGui::AlignTextToFramePadding(); }

inline float GetTextLineHeight() { return ImGui::GetTextLineHeight(); }

inline float GetTextLineHeightWithSpacing() { return ImGui::GetTextLineHeightWithSpacing(); }

inline float GetFrameHeight() { return ImGui::GetFrameHeight(); }

inline float GetFrameHeightWithSpacing() { return ImGui::GetFrameHeightWithSpacing(); }

// ID stack / scopes
inline void PushID(const std::string &stringID) { ImGui::PushID(stringID.c_str()); }

inline void PushID(const std::string &stringIDBegin, const std::string &stringIDEnd) {
    ImGui::PushID(stringIDBegin.c_str(), stringIDEnd.c_str());
}

inline void PushID(int intID) { ImGui::PushID(intID); }

inline void PopID() { ImGui::PopID(); }

inline ImGuiID GetID(const std::string &stringID) { return ImGui::GetID(stringID.c_str()); }

inline ImGuiID GetID(const std::string &stringIDBegin, const std::string &stringIDEnd) {
    return ImGui::GetID(stringIDBegin.c_str(), stringIDEnd.c_str());
}

// Tooltips
inline void BeginTooltip() { ImGui::BeginTooltip(); }

inline void EndTooltip() { ImGui::EndTooltip(); }

inline void SetTooltip(const std::string &fmt) { ImGui::SetTooltip("%s", fmt.c_str()); }

// Popups, Modals
inline bool BeginPopup(const std::string &str_id) { return ImGui::BeginPopup(str_id.c_str()); }

inline bool BeginPopup(const std::string &str_id, int flags) {
    return ImGui::BeginPopup(str_id.c_str(), static_cast<ImGuiWindowFlags>(flags));
}

inline bool BeginPopupModal(const std::string &name) { return ImGui::BeginPopupModal(name.c_str()); }

inline bool BeginPopupModal(const std::string &name, bool open) { return ImGui::BeginPopupModal(name.c_str(), &open); }

inline bool BeginPopupModal(const std::string &name, bool open, int flags) {
    return ImGui::BeginPopupModal(name.c_str(), &open, static_cast<ImGuiWindowFlags>(flags));
}

inline void EndPopup() { ImGui::EndPopup(); }

inline void OpenPopup(const std::string &str_id) { ImGui::OpenPopup(str_id.c_str()); }

inline void OpenPopup(const std::string &str_id, int popup_flags) {
    ImGui::OpenPopup(str_id.c_str(), static_cast<ImGuiPopupFlags>(popup_flags));
}

inline void CloseCurrentPopup() { ImGui::CloseCurrentPopup(); }

inline bool BeginPopupContextItem() { return ImGui::BeginPopupContextItem(); }

inline bool BeginPopupContextItem(const std::string &str_id) { return ImGui::BeginPopupContextItem(str_id.c_str()); }

inline bool BeginPopupContextItem(const std::string &str_id, int popup_flags) {
    return ImGui::BeginPopupContextItem(str_id.c_str(), static_cast<ImGuiPopupFlags>(popup_flags));
}

inline bool BeginPopupContextWindow() { return ImGui::BeginPopupContextWindow(); }

inline bool BeginPopupContextWindow(const std::string &str_id) {
    return ImGui::BeginPopupContextWindow(str_id.c_str());
}

inline bool BeginPopupContextWindow(const std::string &str_id, int popup_flags) {
    return ImGui::BeginPopupContextWindow(str_id.c_str(), static_cast<ImGuiPopupFlags>(popup_flags));
}

inline bool BeginPopupContextVoid() { return ImGui::BeginPopupContextVoid(); }

inline bool BeginPopupContextVoid(const std::string &str_id) { return ImGui::BeginPopupContextVoid(str_id.c_str()); }

inline bool BeginPopupContextVoid(const std::string &str_id, int popup_flags) {
    return ImGui::BeginPopupContextVoid(str_id.c_str(), static_cast<ImGuiPopupFlags>(popup_flags));
}

inline bool IsPopupOpen(const std::string &str_id) { return ImGui::IsPopupOpen(str_id.c_str()); }

inline bool IsPopupOpen(const std::string &str_id, int popup_flags) {
    return ImGui::IsPopupOpen(str_id.c_str(), popup_flags);
}

// Columns
inline void Columns() { ImGui::Columns(); }

inline void Columns(int count) { ImGui::Columns(count); }

inline void Columns(int count, const std::string &id) { ImGui::Columns(count, id.c_str()); }

inline void Columns(int count, const std::string &id, bool border) { ImGui::Columns(count, id.c_str(), border); }

inline void NextColumn() { ImGui::NextColumn(); }

inline int GetColumnIndex() { return ImGui::GetColumnIndex(); }

inline float GetColumnWidth() { return ImGui::GetColumnWidth(); }

inline float GetColumnWidth(int column_index) { return ImGui::GetColumnWidth(column_index); }

inline void SetColumnWidth(int column_index, float width) { ImGui::SetColumnWidth(column_index, width); }

inline float GetColumnOffset() { return ImGui::GetColumnOffset(); }

inline float GetColumnOffset(int column_index) { return ImGui::GetColumnOffset(column_index); }

inline void SetColumnOffset(int column_index, float offset_x) { ImGui::SetColumnOffset(column_index, offset_x); }

inline int GetColumnsCount() { return ImGui::GetColumnsCount(); }

// Tab Bars, Tabs
inline bool BeginTabBar(const std::string &str_id) { return ImGui::BeginTabBar(str_id.c_str()); }

inline bool BeginTabBar(const std::string &str_id, int flags) {
    return ImGui::BeginTabBar(str_id.c_str(), static_cast<ImGuiTabBarFlags>(flags));
}

inline void EndTabBar() { ImGui::EndTabBar(); }

inline bool BeginTabItem(const std::string &label) { return ImGui::BeginTabItem(label.c_str()); }

inline std::tuple<bool, bool> BeginTabItem(const std::string &label, bool open) {
    bool selected = ImGui::BeginTabItem(label.c_str(), &open);
    return std::make_tuple(open, selected);
}

inline std::tuple<bool, bool> BeginTabItem(const std::string &label, bool open, int flags) {
    bool selected = ImGui::BeginTabItem(label.c_str(), &open, static_cast<ImGuiTabItemFlags>(flags));
    return std::make_tuple(open, selected);
}

inline void EndTabItem() { ImGui::EndTabItem(); }

inline void SetTabItemClosed(const std::string &tab_or_docked_window_label) {
    ImGui::SetTabItemClosed(tab_or_docked_window_label.c_str());
}

// Docking
inline void DockSpace(unsigned int id) { ImGui::DockSpace(id); }

inline void DockSpace(unsigned int id, float sizeX, float sizeY) { ImGui::DockSpace(id, {sizeX, sizeY}); }

inline void DockSpace(unsigned int id, float sizeX, float sizeY, int flags) {
    ImGui::DockSpace(id, {sizeX, sizeY}, static_cast<ImGuiDockNodeFlags>(flags));
}

inline void SetNextWindowDockID(unsigned int dock_id) { ImGui::SetNextWindowDockID(dock_id); }

inline void SetNextWindowDockID(unsigned int dock_id, int cond) {
    ImGui::SetNextWindowDockID(dock_id, static_cast<ImGuiCond>(cond));
}

inline unsigned int GetWindowDockID() { return ImGui::GetWindowDockID(); }

inline bool IsWindowDocked() { return ImGui::IsWindowDocked(); }

// Logging
inline void LogToTTY() { ImGui::LogToTTY(); }

inline void LogToTTY(int auto_open_depth) { ImGui::LogToTTY(auto_open_depth); }

inline void LogToFile() { ImGui::LogToFile(); }

inline void LogToFile(int auto_open_depth) { ImGui::LogToFile(auto_open_depth); }

inline void LogToFile(int auto_open_depth, const std::string &filename) {
    ImGui::LogToFile(auto_open_depth, filename.c_str());
}

inline void LogToClipboard() { ImGui::LogToClipboard(); }

inline void LogToClipboard(int auto_open_depth) { ImGui::LogToClipboard(auto_open_depth); }

inline void LogFinish() { ImGui::LogFinish(); }

inline void LogButtons() { ImGui::LogButtons(); }

inline void LogText(const std::string &fmt) { ImGui::LogText("%s", fmt.c_str()); }

// Drag and Drop
// Clipping
inline void PushClipRect(float min_x, float min_y, float max_x, float max_y, bool intersect_current) {
    ImGui::PushClipRect({min_x, min_y}, {max_x, max_y}, intersect_current);
}

inline void PopClipRect() { ImGui::PopClipRect(); }

// Focus, Activation
inline void SetItemDefaultFocus() { ImGui::SetItemDefaultFocus(); }

inline void SetKeyboardFocusHere() { ImGui::SetKeyboardFocusHere(); }

inline void SetKeyboardFocusHere(int offset) { ImGui::SetKeyboardFocusHere(offset); }

// Item/Widgets Utilities
inline bool IsItemHovered() { return ImGui::IsItemHovered(); }

inline bool IsItemHovered(int flags) { return ImGui::IsItemHovered(static_cast<ImGuiHoveredFlags>(flags)); }

inline bool IsItemActive() { return ImGui::IsItemActive(); }

inline bool IsItemFocused() { return ImGui::IsItemFocused(); }

inline bool IsItemClicked() { return ImGui::IsItemClicked(); }

inline bool IsItemClicked(int mouse_button) {
    return ImGui::IsItemClicked(static_cast<ImGuiMouseButton>(mouse_button));
}

inline bool IsItemVisible() { return ImGui::IsItemVisible(); }

inline bool IsItemEdited() { return ImGui::IsItemEdited(); }

inline bool IsItemActivated() { return ImGui::IsItemActivated(); }

inline bool IsItemDeactivated() { return ImGui::IsItemDeactivated(); }

inline bool IsItemDeactivatedAfterEdit() { return ImGui::IsItemDeactivatedAfterEdit(); }

inline bool IsItemToggledOpen() { return ImGui::IsItemToggledOpen(); }

inline bool IsAnyItemHovered() { return ImGui::IsAnyItemHovered(); }

inline bool IsAnyItemActive() { return ImGui::IsAnyItemActive(); }

inline bool IsAnyItemFocused() { return ImGui::IsAnyItemFocused(); }

inline std::tuple<float, float> GetItemRectMin() {
    const auto vec2{ImGui::GetItemRectMin()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float> GetItemRectMax() {
    const auto vec2{ImGui::GetItemRectMax()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float> GetItemRectSize() {
    const auto vec2{ImGui::GetItemRectSize()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline void SetItemAllowOverlap() { ImGui::SetItemAllowOverlap(); }

// Miscellaneous Utilities
inline bool IsRectVisible(float sizeX, float sizeY) { return ImGui::IsRectVisible({sizeX, sizeY}); }

inline bool IsRectVisible(float minX, float minY, float maxX, float maxY) {
    return ImGui::IsRectVisible({minX, minY}, {maxX, maxY});
}

inline double GetTime() { return ImGui::GetTime(); }

inline int GetFrameCount() { return ImGui::GetFrameCount(); }

inline std::string GetStyleColorName(int idx) {
    return std::string(ImGui::GetStyleColorName(static_cast<ImGuiCol>(idx)));
}

inline bool BeginChildFrame(unsigned int id, float sizeX, float sizeY) {
    return ImGui::BeginChildFrame(id, {sizeX, sizeY});
}

inline bool BeginChildFrame(unsigned int id, float sizeX, float sizeY, int flags) {
    return ImGui::BeginChildFrame(id, {sizeX, sizeY}, static_cast<ImGuiWindowFlags>(flags));
}

inline void EndChildFrame() { return ImGui::EndChildFrame(); }

// Text Utilities
inline std::tuple<float, float> CalcTextSize(const std::string &text) {
    const auto vec2{ImGui::CalcTextSize(text.c_str())};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float> CalcTextSize(const std::string &text, const std::string &text_end) {
    const auto vec2{ImGui::CalcTextSize(text.c_str(), text_end.c_str())};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float>
CalcTextSize(const std::string &text, const std::string &text_end, bool hide_text_after_double_hash) {
    const auto vec2{ImGui::CalcTextSize(text.c_str(), text_end.c_str(), hide_text_after_double_hash)};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float>
CalcTextSize(const std::string &text, const std::string &text_end, bool hide_text_after_double_hash, float wrap_width) {
    const auto vec2{ImGui::CalcTextSize(text.c_str(), text_end.c_str(), hide_text_after_double_hash, wrap_width)};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float, float> ColorConvertRGBtoHSV(float r, float g, float b) {
    float h{}, s{}, v{};
    ImGui::ColorConvertRGBtoHSV(r, g, b, h, s, v);
    return std::make_tuple(h, s, v);
}

inline std::tuple<float, float, float> ColorConvertHSVtoRGB(float h, float s, float v) {
    float r{}, g{}, b{};
    ImGui::ColorConvertHSVtoRGB(h, s, v, r, g, b);
    return std::make_tuple(r, g, b);
}

// Inputs Utilities: Keyboard
inline int GetKeyIndex(int imgui_key) { return ImGui::GetKeyIndex(static_cast<ImGuiKey>(imgui_key)); }

inline bool IsKeyDown(int user_key_index) { return ImGui::IsKeyDown(user_key_index); }

inline bool IsKeyPressed(int user_key_index) { return ImGui::IsKeyPressed(user_key_index); }

inline bool IsKeyPressed(int user_key_index, bool repeat) { return ImGui::IsKeyPressed(user_key_index, repeat); }

inline bool IsKeyReleased(int user_key_index) { return ImGui::IsKeyReleased(user_key_index); }

inline int GetKeyPressedAmount(int key_index, float repeat_delay, float rate) {
    return ImGui::GetKeyPressedAmount(key_index, repeat_delay, rate);
}

inline void CaptureKeyboardFromApp() { ImGui::CaptureKeyboardFromApp(); }

inline void CaptureKeyboardFromApp(bool want_capture_keyboard_value) {
    ImGui::CaptureKeyboardFromApp(want_capture_keyboard_value);
}

// Inputs Utilities: Mouse
inline bool IsMouseDown(int button) { return ImGui::IsMouseDown(static_cast<ImGuiMouseButton>(button)); }

inline bool IsMouseClicked(int button) { return ImGui::IsMouseClicked(static_cast<ImGuiMouseButton>(button)); }

inline bool IsMouseClicked(int button, bool repeat) {
    return ImGui::IsMouseClicked(static_cast<ImGuiMouseButton>(button), repeat);
}

inline bool IsMouseReleased(int button) { return ImGui::IsMouseReleased(static_cast<ImGuiMouseButton>(button)); }

inline bool IsMouseDoubleClicked(int button) {
    return ImGui::IsMouseDoubleClicked(static_cast<ImGuiMouseButton>(button));
}

inline bool IsMouseHoveringRect(float min_x, float min_y, float max_x, float max_y) {
    return ImGui::IsMouseHoveringRect({min_x, min_y}, {max_x, max_y});
}

inline bool IsMouseHoveringRect(float min_x, float min_y, float max_x, float max_y, bool clip) {
    return ImGui::IsMouseHoveringRect({min_x, min_y}, {max_x, max_y}, clip);
}

inline bool IsAnyMouseDown() { return ImGui::IsAnyMouseDown(); }

inline std::tuple<float, float> GetMousePos() {
    const auto vec2{ImGui::GetMousePos()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float> GetMousePosOnOpeningCurrentPopup() {
    const auto vec2{ImGui::GetMousePosOnOpeningCurrentPopup()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline bool IsMouseDragging(int button) { return ImGui::IsMouseDragging(static_cast<ImGuiMouseButton>(button)); }

inline bool IsMouseDragging(int button, float lock_threshold) {
    return ImGui::IsMouseDragging(static_cast<ImGuiMouseButton>(button), lock_threshold);
}

inline std::tuple<float, float> GetMouseDragDelta() {
    const auto vec2{ImGui::GetMouseDragDelta()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float> GetMouseDragDelta(int button) {
    const auto vec2{ImGui::GetMouseDragDelta(static_cast<ImGuiMouseButton>(button))};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float> GetMouseDragDelta(int button, float lock_threshold) {
    const auto vec2{ImGui::GetMouseDragDelta(static_cast<ImGuiMouseButton>(button), lock_threshold)};
    return std::make_tuple(vec2.x, vec2.y);
}

inline void ResetMouseDragDelta() { ImGui::ResetMouseDragDelta(); }

inline void ResetMouseDragDelta(int button) { ImGui::ResetMouseDragDelta(static_cast<ImGuiMouseButton>(button)); }

inline int GetMouseCursor() { return ImGui::GetMouseCursor(); }

inline void SetMouseCursor(int cursor_type) { ImGui::SetMouseCursor(static_cast<ImGuiMouseCursor>(cursor_type)); }

inline void CaptureMouseFromApp() { ImGui::CaptureMouseFromApp(); }

inline void CaptureMouseFromApp(bool want_capture_mouse_value) { ImGui::CaptureMouseFromApp(want_capture_mouse_value); }

// Clipboard Utilities
inline std::string GetClipboardText() { return std::string(ImGui::GetClipboardText()); }

inline void SetClipboardText(const std::string &text) { ImGui::SetClipboardText(text.c_str()); }

inline void ShowDemoWindow() { ImGui::ShowDemoWindow(); }

inline void ShowMetricsWindow() { ImGui::ShowMetricsWindow(); }

inline void ShowAboutWindow() { ImGui::ShowAboutWindow(); }

inline void ShowStyleEditor() { ImGui::ShowStyleEditor(); }

inline void ShowStyleSelector(const std::string &label) { ImGui::ShowStyleSelector(label.c_str()); }

inline void ShowFontSelector(const std::string &label) { ImGui::ShowFontSelector(label.c_str()); }

inline void ShowUserGuide() { ImGui::ShowUserGuide(); }

void init1(sol::table &ImGui) {
#pragma region Parameters stacks (shared)
    ImGui.set_function("PushFont", PushFont);
    ImGui.set_function("PopFont", PopFont);
    ImGui.set_function("PushStyleColor", PushStyleColor);
    ImGui.set_function("PopStyleColor", sol::overload(
            sol::resolve<void()>(PopStyleColor),
            sol::resolve<void(int)>(PopStyleColor)
    ));
    ImGui.set_function("PushStyleVar", sol::overload(
            sol::resolve<void(int, float)>(PushStyleVar),
            sol::resolve<void(int, float, float)>(PushStyleVar)
    ));
    ImGui.set_function("PopStyleVar", sol::overload(
            sol::resolve<void()>(PopStyleVar),
            sol::resolve<void(int)>(PopStyleVar)
    ));
    ImGui.set_function("GetStyleColorVec4", GetStyleColorVec4);
    ImGui.set_function("GetFont", GetFont);
    ImGui.set_function("GetFontSize", GetFontSize);
    ImGui.set_function("GetFontTexUvWhitePixel", GetFontTexUvWhitePixel);
#pragma endregion Parameters stacks (shared)

#pragma region Parameters stacks (current window)
    ImGui.set_function("PushItemWidth", PushItemWidth);
    ImGui.set_function("PopItemWidth", PopItemWidth);
    ImGui.set_function("SetNextItemWidth", SetNextItemWidth);
    ImGui.set_function("CalcItemWidth", CalcItemWidth);
    ImGui.set_function("PushTextWrapPos", sol::overload(
            sol::resolve<void()>(PushTextWrapPos),
            sol::resolve<void(float)>(PushTextWrapPos)
    ));
    ImGui.set_function("PopTextWrapPos", PopTextWrapPos);
    ImGui.set_function("PushAllowKeyboardFocus", PushAllowKeyboardFocus);
    ImGui.set_function("PopAllowKeyboardFocus", PopAllowKeyboardFocus);
    ImGui.set_function("PushButtonRepeat", PushButtonRepeat);
    ImGui.set_function("PopButtonRepeat", PopButtonRepeat);
#pragma endregion Parameters stacks (current window)

#pragma region Cursor / Layout
    ImGui.set_function("Separator", Separator);
    ImGui.set_function("SameLine", sol::overload(
            sol::resolve<void()>(SameLine),
            sol::resolve<void(float)>(SameLine)
    ));
    ImGui.set_function("NewLine", NewLine);
    ImGui.set_function("Spacing", Spacing);
    ImGui.set_function("Dummy", Dummy);
    ImGui.set_function("Indent", sol::overload(
            sol::resolve<void()>(Indent),
            sol::resolve<void(float)>(Indent)
    ));
    ImGui.set_function("Unindent", sol::overload(
            sol::resolve<void()>(Unindent),
            sol::resolve<void(float)>(Unindent)
    ));
    ImGui.set_function("BeginGroup", BeginGroup);
    ImGui.set_function("EndGroup", EndGroup);
    ImGui.set_function("GetCursorPos", GetCursorPos);
    ImGui.set_function("GetCursorPosX", GetCursorPosX);
    ImGui.set_function("GetCursorPosY", GetCursorPosY);
    ImGui.set_function("SetCursorPos", SetCursorPos);
    ImGui.set_function("SetCursorPosX", SetCursorPosX);
    ImGui.set_function("SetCursorPosY", SetCursorPosY);
    ImGui.set_function("GetCursorStartPos", GetCursorStartPos);
    ImGui.set_function("GetCursorScreenPos", GetCursorScreenPos);
    ImGui.set_function("SetCursorScreenPos", SetCursorScreenPos);
    ImGui.set_function("AlignTextToFramePadding", AlignTextToFramePadding);
    ImGui.set_function("GetTextLineHeight", GetTextLineHeight);
    ImGui.set_function("GetTextLineHeightWithSpacing", GetTextLineHeightWithSpacing);
    ImGui.set_function("GetFrameHeight", GetFrameHeight);
    ImGui.set_function("GetFrameHeightWithSpacing", GetFrameHeightWithSpacing);
#pragma endregion Cursor / Layout
}

void init2(sol::table &ImGui) {
#pragma region ID stack / scopes
    ImGui.set_function("PushID", sol::overload(
            sol::resolve<void(const std::string &)>(PushID),
            sol::resolve<void(const std::string &, const std::string &)>(PushID),
            sol::resolve<void(int)>(PushID)
    ));
    ImGui.set_function("PopID", PopID);
    ImGui.set_function("GetID", sol::overload(
            sol::resolve<ImGuiID(const std::string &)>(GetID),
            sol::resolve<ImGuiID(const std::string &, const std::string &)>(GetID)
    ));
#pragma endregion ID stack / scopes

#pragma region Tooltips
    ImGui.set_function("BeginTooltip", BeginTooltip);
    ImGui.set_function("EndTooltip", EndTooltip);
    ImGui.set_function("SetTooltip", SetTooltip);
#pragma endregion Tooltips

#pragma region Popups, Modals
    ImGui.set_function("BeginPopup", sol::overload(
            sol::resolve<bool(const std::string &)>(BeginPopup),
            sol::resolve<bool(const std::string &, int)>(BeginPopup)
    ));
    ImGui.set_function("BeginPopupModal", sol::overload(
            sol::resolve<bool(const std::string &)>(BeginPopupModal),
            sol::resolve<bool(const std::string &, bool)>(BeginPopupModal),
            sol::resolve<bool(const std::string &, bool, int)>(BeginPopupModal)
    ));
    ImGui.set_function("EndPopup", EndPopup);
    ImGui.set_function("OpenPopup", sol::overload(
            sol::resolve<void(const std::string &)>(OpenPopup),
            sol::resolve<void(const std::string &, int)>(OpenPopup)
    ));
    ImGui.set_function("CloseCurrentPopup", CloseCurrentPopup);
    ImGui.set_function("BeginPopupContextItem", sol::overload(
            sol::resolve<bool()>(BeginPopupContextItem),
            sol::resolve<bool(const std::string &)>(BeginPopupContextItem),
            sol::resolve<bool(const std::string &, int)>(BeginPopupContextItem)
    ));
    ImGui.set_function("BeginPopupContextWindow", sol::overload(
            sol::resolve<bool()>(BeginPopupContextWindow),
            sol::resolve<bool(const std::string &)>(BeginPopupContextWindow),
            sol::resolve<bool(const std::string &, int)>(BeginPopupContextWindow)
    ));
    ImGui.set_function("BeginPopupContextVoid", sol::overload(
            sol::resolve<bool()>(BeginPopupContextVoid),
            sol::resolve<bool(const std::string &)>(BeginPopupContextVoid),
            sol::resolve<bool(const std::string &, int)>(BeginPopupContextVoid)
    ));
    ImGui.set_function("IsPopupOpen", sol::overload(
            sol::resolve<bool(const std::string &)>(IsPopupOpen),
            sol::resolve<bool(const std::string &, int)>(IsPopupOpen)
    ));
#pragma endregion Popups, Modals
}

void init3(sol::table &ImGui) {
#pragma region Columns
    ImGui.set_function("Columns", sol::overload(
            sol::resolve<void()>(Columns),
            sol::resolve<void(int)>(Columns),
            sol::resolve<void(int, const std::string &)>(Columns),
            sol::resolve<void(int, const std::string &, bool)>(Columns)
    ));
    ImGui.set_function("NextColumn", NextColumn);
    ImGui.set_function("GetColumnIndex", GetColumnIndex);
    ImGui.set_function("GetColumnWidth", sol::overload(
            sol::resolve<float()>(GetColumnWidth),
            sol::resolve<float(int)>(GetColumnWidth)
    ));
    ImGui.set_function("SetColumnWidth", SetColumnWidth);
    ImGui.set_function("GetColumnOffset", sol::overload(
            sol::resolve<float()>(GetColumnOffset),
            sol::resolve<float(int)>(GetColumnOffset)
    ));
    ImGui.set_function("SetColumnOffset", SetColumnOffset);
    ImGui.set_function("GetColumnsCount", GetColumnsCount);
#pragma endregion Columns

#pragma region Tab Bars, Tabs
    ImGui.set_function("BeginTabBar", sol::overload(
            sol::resolve<bool(const std::string &)>(BeginTabBar),
            sol::resolve<bool(const std::string &, int)>(BeginTabBar)
    ));
    ImGui.set_function("EndTabBar", EndTabBar);
    ImGui.set_function("BeginTabItem", sol::overload(
            sol::resolve<bool(const std::string &)>(BeginTabItem),
            sol::resolve<std::tuple<bool, bool>(const std::string &, bool)>(BeginTabItem),
            sol::resolve<std::tuple<bool, bool>(const std::string &, bool, int)>(BeginTabItem)
    ));
    ImGui.set_function("EndTabItem", EndTabItem);
    ImGui.set_function("SetTabItemClosed", SetTabItemClosed);
#pragma endregion Tab Bars, Tabs

#pragma region Docking
    ImGui.set_function("DockSpace", sol::overload(
            sol::resolve<void(unsigned int)>(DockSpace),
            sol::resolve<void(unsigned int, float, float)>(DockSpace),
            sol::resolve<void(unsigned int, float, float, int)>(DockSpace)
    ));
    ImGui.set_function("SetNextWindowDockID", sol::overload(
            sol::resolve<void(unsigned int)>(SetNextWindowDockID),
            sol::resolve<void(unsigned int, int)>(SetNextWindowDockID)
    ));
    ImGui.set_function("GetWindowDockID", GetWindowDockID);
    ImGui.set_function("IsWindowDocked", IsWindowDocked);
#pragma endregion Docking

#pragma region Logging / Capture
    ImGui.set_function("LogToTTY", sol::overload(
            sol::resolve<void()>(LogToTTY),
            sol::resolve<void(int)>(LogToTTY)
    ));
    ImGui.set_function("LogToFile", sol::overload(
            sol::resolve<void(int)>(LogToFile),
            sol::resolve<void(int, const std::string &)>(LogToFile)
    ));
    ImGui.set_function("LogToClipboard", sol::overload(
            sol::resolve<void()>(LogToClipboard),
            sol::resolve<void(int)>(LogToClipboard)
    ));
    ImGui.set_function("LogFinish", LogFinish);
    ImGui.set_function("LogButtons", LogButtons);
    ImGui.set_function("LogText", LogText);
#pragma endregion Logging / Capture

#pragma region Clipping
    ImGui.set_function("PushClipRect", PushClipRect);
    ImGui.set_function("PopClipRect", PopClipRect);
#pragma endregion Clipping
}

void init4(sol::table &ImGui) {
#pragma region Focus, Activation
    ImGui.set_function("SetItemDefaultFocus", SetItemDefaultFocus);
    ImGui.set_function("SetKeyboardFocusHere", sol::overload(
            sol::resolve<void()>(SetKeyboardFocusHere),
            sol::resolve<void(int)>(SetKeyboardFocusHere)
    ));
#pragma endregion Focus, Activation

#pragma region Item/Widgets Utilities
    ImGui.set_function("IsItemHovered", sol::overload(
            sol::resolve<bool()>(IsItemHovered),
            sol::resolve<bool(int)>(IsItemHovered)
    ));
    ImGui.set_function("IsItemActive", IsItemActive);
    ImGui.set_function("IsItemFocused", IsItemFocused);
    ImGui.set_function("IsItemClicked", sol::overload(
            sol::resolve<bool()>(IsItemClicked),
            sol::resolve<bool(int)>(IsItemClicked)
    ));
    ImGui.set_function("IsItemVisible", IsItemVisible);
    ImGui.set_function("IsItemEdited", IsItemEdited);
    ImGui.set_function("IsItemActivated", IsItemActivated);
    ImGui.set_function("IsItemDeactivated", IsItemDeactivated);
    ImGui.set_function("IsItemDeactivatedAfterEdit", IsItemDeactivatedAfterEdit);
    ImGui.set_function("IsItemToggledOpen", IsItemToggledOpen);
    ImGui.set_function("IsAnyItemHovered", IsAnyItemHovered);
    ImGui.set_function("IsAnyItemActive", IsAnyItemActive);
    ImGui.set_function("IsAnyItemFocused", IsAnyItemFocused);
    ImGui.set_function("GetItemRectMin", GetItemRectMin);
    ImGui.set_function("GetItemRectMax", GetItemRectMax);
    ImGui.set_function("GetItemRectSize", GetItemRectSize);
    ImGui.set_function("SetItemAllowOverlap", SetItemAllowOverlap);
#pragma endregion Item/Widgets Utilities

#pragma region Miscellaneous Utilities
    ImGui.set_function("IsRectVisible", sol::overload(
            sol::resolve<bool(float, float)>(IsRectVisible),
            sol::resolve<bool(float, float, float, float)>(IsRectVisible)
    ));
    ImGui.set_function("GetTime", GetTime);
    ImGui.set_function("GetFrameCount", GetFrameCount);
    ImGui.set_function("GetStyleColorName", GetStyleColorName);
    ImGui.set_function("BeginChildFrame", sol::overload(
            sol::resolve<bool(unsigned int, float, float)>(BeginChildFrame),
            sol::resolve<bool(unsigned int, float, float, int)>(BeginChildFrame)
    ));
    ImGui.set_function("EndChildFrame", EndChildFrame);
#pragma endregion Miscellaneous Utilities

#pragma region Text Utilities
    ImGui.set_function("CalcTextSize", sol::overload(
            sol::resolve<std::tuple<float, float>(const std::string &)>(CalcTextSize),
            sol::resolve<std::tuple<float, float>(const std::string &, const std::string &)>(CalcTextSize),
            sol::resolve<std::tuple<float, float>(const std::string &, const std::string &, bool)>(CalcTextSize),
            sol::resolve<std::tuple<float, float>(const std::string &, const std::string &, bool, float)>(CalcTextSize)
    ));
#pragma endregion Text Utilities

#pragma region Color Utilities
    ImGui.set_function("ColorConvertRGBtoHSV", ColorConvertRGBtoHSV);
    ImGui.set_function("ColorConvertHSVtoRGB", ColorConvertHSVtoRGB);
#pragma endregion Color Utilities

#pragma region Inputs Utilities: Keyboard
    ImGui.set_function("GetKeyIndex", GetKeyIndex);
    ImGui.set_function("IsKeyDown", IsKeyDown);
    ImGui.set_function("IsKeyPressed", sol::overload(
            sol::resolve<bool(int)>(IsKeyPressed),
            sol::resolve<bool(int, bool)>(IsKeyPressed)
    ));
    ImGui.set_function("IsKeyReleased", IsKeyReleased);
    ImGui.set_function("CaptureKeyboardFromApp", sol::overload(
            sol::resolve<void()>(CaptureKeyboardFromApp),
            sol::resolve<void(bool)>(CaptureKeyboardFromApp)
    ));
#pragma endregion Inputs Utilities: Keyboard

#pragma region Inputs Utilities: Mouse
    ImGui.set_function("IsMouseDown", IsMouseDown);
    ImGui.set_function("IsMouseClicked", sol::overload(
            sol::resolve<bool(int)>(IsMouseClicked),
            sol::resolve<bool(int, bool)>(IsMouseClicked)
    ));
    ImGui.set_function("IsMouseReleased", IsMouseReleased);
    ImGui.set_function("IsMouseDoubleClicked", IsMouseDoubleClicked);
    ImGui.set_function("IsMouseHoveringRect", sol::overload(
            sol::resolve<bool(float, float, float, float)>(IsMouseHoveringRect),
            sol::resolve<bool(float, float, float, float, bool)>(IsMouseHoveringRect)
    ));
    ImGui.set_function("IsAnyMouseDown", IsAnyMouseDown);
    ImGui.set_function("GetMousePos", GetMousePos);
    ImGui.set_function("GetMousePosOnOpeningCurrentPopup", GetMousePosOnOpeningCurrentPopup);
    ImGui.set_function("IsMouseDragging", sol::overload(
            sol::resolve<bool(int)>(IsMouseDragging),
            sol::resolve<bool(int, float)>(IsMouseDragging)
    ));
    ImGui.set_function("GetMouseDragDelta", sol::overload(
            sol::resolve<std::tuple<float, float>()>(GetMouseDragDelta),
            sol::resolve<std::tuple<float, float>(int)>(GetMouseDragDelta),
            sol::resolve<std::tuple<float, float>(int, float)>(GetMouseDragDelta)
    ));
    ImGui.set_function("ResetMouseDragDelta", sol::overload(
            sol::resolve<void()>(ResetMouseDragDelta),
            sol::resolve<void(int)>(ResetMouseDragDelta)
    ));
    ImGui.set_function("GetMouseCursor", GetMouseCursor);
    ImGui.set_function("SetMouseCursor", SetMouseCursor);
    ImGui.set_function("CaptureMouseFromApp", sol::overload(
            sol::resolve<void()>(CaptureMouseFromApp),
            sol::resolve<void(bool)>(CaptureMouseFromApp)
    ));
#pragma endregion Inputs Utilities: Mouse

#pragma region Clipboard Utilities
    ImGui.set_function("GetClipboardText", GetClipboardText);
    ImGui.set_function("SetClipboardText", SetClipboardText);
#pragma endregion Clipboard Utilities
}

inline void Init(sol::table &ImGui) {
    init1(ImGui);
    init2(ImGui);
    init3(ImGui);
    init4(ImGui);

    ImGui.set_function("ShowDemoWindow", ShowDemoWindow);
    ImGui.set_function("ShowMetricsWindow", ShowMetricsWindow);
    ImGui.set_function("ShowAboutWindow", ShowAboutWindow);
    ImGui.set_function("ShowStyleEditor", ShowStyleEditor);
    ImGui.set_function("ShowStyleSelector", ShowStyleSelector);
    ImGui.set_function("ShowFontSelector", ShowFontSelector);
    ImGui.set_function("ShowUserGuide", ShowUserGuide);
}
}

void LuaBind_ImGui(sol::state &luaState) {
    sol::table ImGui = luaState.create_named_table("ImGui");
    sol_ImGui::LuaBind_ImGuiWindow(ImGui);
    sol_ImGui::LuaBind_ImGuiWidget(ImGui);
    sol_ImGui::Init(ImGui);
}
