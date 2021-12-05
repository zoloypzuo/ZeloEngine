// LuaBind_ImGuiWindow.cpp
// created on 2021/12/6
// author @zoloypzuo
#include <string>
#include <imgui.h>
#include <sol/sol.hpp>

namespace sol_ImGui {
void LuaBind_ImGuiWindow(sol::table &ImGui);

// Windows
inline bool Begin(const std::string &name) { return ImGui::Begin(name.c_str()); }

inline std::tuple<bool, bool> Begin(const std::string &name, bool open) {
    if (!open) return std::make_tuple(false, false);

    bool shouldDraw = ImGui::Begin(name.c_str(), &open);

    if (!open) {
        ImGui::End();
        return std::make_tuple(false, false);
    }

    return std::make_tuple(open, shouldDraw);
}

inline std::tuple<bool, bool> Begin(const std::string &name, bool open, int flags) {
    if (!open) return std::make_tuple(false, false);
    bool shouldDraw = ImGui::Begin(name.c_str(), &open, static_cast<ImGuiWindowFlags_>(flags));

    if (!open) {
        ImGui::End();
        return std::make_tuple(false, false);
    }

    return std::make_tuple(open, shouldDraw);
}

inline void End() { ImGui::End(); }

// Child Windows
inline bool BeginChild(const std::string &name) { return ImGui::BeginChild(name.c_str()); }

inline bool BeginChild(const std::string &name, float sizeX) { return ImGui::BeginChild(name.c_str(), {sizeX, 0}); }

inline bool BeginChild(const std::string &name, float sizeX, float sizeY) {
    return ImGui::BeginChild(name.c_str(), {sizeX, sizeY});
}

inline bool BeginChild(const std::string &name, float sizeX, float sizeY, bool border) {
    return ImGui::BeginChild(name.c_str(), {sizeX, sizeY}, border);
}

inline bool BeginChild(const std::string &name, float sizeX, float sizeY, bool border, int flags) {
    return ImGui::BeginChild(name.c_str(), {sizeX, sizeY}, border, static_cast<ImGuiWindowFlags>(flags));
}

inline void EndChild() { ImGui::EndChild(); }

// Windows Utilities
inline bool IsWindowAppearing() { return ImGui::IsWindowAppearing(); }

inline bool IsWindowCollapsed() { return ImGui::IsWindowCollapsed(); }

inline bool IsWindowFocused() { return ImGui::IsWindowFocused(); }

inline bool IsWindowFocused(int flags) { return ImGui::IsWindowFocused(static_cast<ImGuiFocusedFlags>(flags)); }

inline bool IsWindowHovered() { return ImGui::IsWindowHovered(); }

inline bool IsWindowHovered(int flags) { return ImGui::IsWindowHovered(static_cast<ImGuiHoveredFlags>(flags)); }

inline float GetWindowDpiScale() { return ImGui::GetWindowDpiScale(); }

inline std::tuple<float, float> GetWindowPos() {
    const auto vec2{ImGui::GetWindowPos()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float> GetWindowSize() {
    const auto vec2{ImGui::GetWindowSize()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline float GetWindowWidth() { return ImGui::GetWindowWidth(); }

inline float GetWindowHeight() { return ImGui::GetWindowHeight(); }

// Prefer using SetNext...
inline void SetNextWindowPos(float posX, float posY) { ImGui::SetNextWindowPos({posX, posY}); }

inline void SetNextWindowPos(float posX, float posY, int cond) {
    ImGui::SetNextWindowPos({posX, posY}, static_cast<ImGuiCond>(cond));
}

inline void SetNextWindowPos(float posX, float posY, int cond, float pivotX, float pivotY) {
    ImGui::SetNextWindowPos({posX, posY}, static_cast<ImGuiCond>(cond), {pivotX, pivotY});
}

inline void SetNextWindowSize(float sizeX, float sizeY) { ImGui::SetNextWindowSize({sizeX, sizeY}); }

inline void SetNextWindowSize(float sizeX, float sizeY, int cond) {
    ImGui::SetNextWindowSize({sizeX, sizeY}, static_cast<ImGuiCond>(cond));
}

inline void SetNextWindowSizeConstraints(float minX, float minY, float maxX, float maxY) {
    ImGui::SetNextWindowSizeConstraints({minX, minY}, {maxX, maxY});
}

inline void SetNextWindowContentSize(float sizeX, float sizeY) { ImGui::SetNextWindowContentSize({sizeX, sizeY}); }

inline void SetNextWindowCollapsed(bool collapsed) { ImGui::SetNextWindowCollapsed(collapsed); }

inline void SetNextWindowCollapsed(bool collapsed, int cond) {
    ImGui::SetNextWindowCollapsed(collapsed, static_cast<ImGuiCond>(cond));
}

inline void SetNextWindowFocus() { ImGui::SetNextWindowFocus(); }

inline void SetNextWindowBgAlpha(float alpha) { ImGui::SetNextWindowBgAlpha(alpha); }

inline void SetWindowPos(float posX, float posY) { ImGui::SetWindowPos({posX, posY}); }

inline void SetWindowPos(float posX, float posY, int cond) {
    ImGui::SetWindowPos({posX, posY}, static_cast<ImGuiCond>(cond));
}

inline void SetWindowSize(float sizeX, float sizeY) { ImGui::SetWindowSize({sizeX, sizeY}); }

inline void SetWindowSize(float sizeX, float sizeY, int cond) {
    ImGui::SetWindowSize({sizeX, sizeY}, static_cast<ImGuiCond>(cond));
}

inline void SetWindowCollapsed(bool collapsed) { ImGui::SetWindowCollapsed(collapsed); }

inline void SetWindowCollapsed(bool collapsed, int cond) {
    ImGui::SetWindowCollapsed(collapsed, static_cast<ImGuiCond>(cond));
}

inline void SetWindowFocus() { ImGui::SetWindowFocus(); }

inline void SetWindowFontScale(float scale) { ImGui::SetWindowFontScale(scale); }

inline void SetWindowPos(const std::string &name, float posX, float posY) {
    ImGui::SetWindowPos(name.c_str(), {posX, posY});
}

inline void SetWindowPos(const std::string &name, float posX, float posY, int cond) {
    ImGui::SetWindowPos(name.c_str(), {posX, posY}, static_cast<ImGuiCond>(cond));
}

inline void SetWindowSize(const std::string &name, float sizeX, float sizeY) {
    ImGui::SetWindowSize(name.c_str(), {sizeX, sizeY});
}

inline void SetWindowSize(const std::string &name, float sizeX, float sizeY, int cond) {
    ImGui::SetWindowSize(name.c_str(), {sizeX, sizeY}, static_cast<ImGuiCond>(cond));
}

inline void SetWindowCollapsed(const std::string &name, bool collapsed) {
    ImGui::SetWindowCollapsed(name.c_str(), collapsed);
}

inline void SetWindowCollapsed(const std::string &name, bool collapsed, int cond) {
    ImGui::SetWindowCollapsed(name.c_str(), collapsed, static_cast<ImGuiCond>(cond));
}

inline void SetWindowFocus(const std::string &name) { ImGui::SetWindowFocus(name.c_str()); }

// Content Region
inline std::tuple<float, float> GetContentRegionMax() {
    const auto vec2{ImGui::GetContentRegionMax()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float> GetContentRegionAvail() {
    const auto vec2{ImGui::GetContentRegionAvail()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float> GetWindowContentRegionMin() {
    const auto vec2{ImGui::GetWindowContentRegionMin()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline std::tuple<float, float> GetWindowContentRegionMax() {
    const auto vec2{ImGui::GetWindowContentRegionMax()};
    return std::make_tuple(vec2.x, vec2.y);
}

inline float GetWindowContentRegionWidth() { return ImGui::GetWindowContentRegionWidth(); }

// Windows Scrolling
inline float GetScrollX() { return ImGui::GetScrollX(); }

inline float GetScrollY() { return ImGui::GetScrollY(); }

inline float GetScrollMaxX() { return ImGui::GetScrollMaxX(); }

inline float GetScrollMaxY() { return ImGui::GetScrollMaxY(); }

inline void SetScrollX(float scrollX) { ImGui::SetScrollX(scrollX); }

inline void SetScrollY(float scrollY) { ImGui::SetScrollY(scrollY); }

inline void SetScrollHereX() { ImGui::SetScrollHereX(); }

inline void SetScrollHereX(float centerXRatio) { ImGui::SetScrollHereX(centerXRatio); }

inline void SetScrollHereY() { ImGui::SetScrollHereY(); }

inline void SetScrollHereY(float centerYRatio) { ImGui::SetScrollHereY(centerYRatio); }

inline void SetScrollFromPosX(float localX) { ImGui::SetScrollFromPosX(localX); }

inline void SetScrollFromPosX(float localX, float centerXRatio) { ImGui::SetScrollFromPosX(localX, centerXRatio); }

inline void SetScrollFromPosY(float localY) { ImGui::SetScrollFromPosY(localY); }

inline void SetScrollFromPosY(float localY, float centerYRatio) { ImGui::SetScrollFromPosY(localY, centerYRatio); }

void LuaBind_ImGuiWindow(sol::table &ImGui) {
#pragma region Windows
    ImGui.set_function("Begin", sol::overload(
            sol::resolve < bool(
    const std::string &)>(Begin),
            sol::resolve < std::tuple<bool, bool>(
    const std::string &, bool)>(Begin),
            sol::resolve < std::tuple<bool, bool>(
    const std::string &, bool, int)>(Begin)
    ));
    ImGui.set_function("End", End);
#pragma endregion Windows

#pragma region Child Windows
    ImGui.set_function("BeginChild", sol::overload(
            sol::resolve < bool(
    const std::string &)>(BeginChild),
            sol::resolve < bool(
    const std::string &, float)>(BeginChild),
            sol::resolve < bool(
    const std::string &, float, float)>(BeginChild),
            sol::resolve < bool(
    const std::string &, float, float, bool)>(BeginChild),
            sol::resolve < bool(
    const std::string &, float, float, bool, int)>(BeginChild)
    ));
    ImGui.set_function("EndChild", EndChild);
#pragma endregion Child Windows

#pragma region Window Utilities
    ImGui.set_function("IsWindowAppearing", IsWindowAppearing);
    ImGui.set_function("IsWindowCollapsed", IsWindowCollapsed);
    ImGui.set_function("IsWindowFocused", sol::overload(
            sol::resolve<bool()>(IsWindowFocused),
            sol::resolve<bool(int)>(IsWindowFocused)
    ));
    ImGui.set_function("IsWindowHovered", sol::overload(
            sol::resolve<bool()>(IsWindowHovered),
            sol::resolve<bool(int)>(IsWindowHovered)
    ));
    ImGui.set_function("GetWindowDpiScale", GetWindowDpiScale);
    ImGui.set_function("GetWindowPos", GetWindowPos);
    ImGui.set_function("GetWindowSize", GetWindowSize);
    ImGui.set_function("GetWindowWidth", GetWindowWidth);
    ImGui.set_function("GetWindowHeight", GetWindowHeight);

    // Prefer  SetNext...
    ImGui.set_function("SetNextWindowPos", sol::overload(
            sol::resolve<void(float, float)>(SetNextWindowPos),
            sol::resolve<void(float, float, int)>(SetNextWindowPos),
            sol::resolve<void(float, float, int, float, float)>(SetNextWindowPos)
    ));
    ImGui.set_function("SetNextWindowSize", sol::overload(
            sol::resolve<void(float, float)>(SetNextWindowSize),
            sol::resolve<void(float, float, int)>(SetNextWindowSize)
    ));
    ImGui.set_function("SetNextWindowSizeConstraints", SetNextWindowSizeConstraints);
    ImGui.set_function("SetNextWindowContentSize", SetNextWindowContentSize);
    ImGui.set_function("SetNextWindowCollapsed", sol::overload(
            sol::resolve<void(bool)>(SetNextWindowCollapsed),
            sol::resolve<void(bool, int)>(SetNextWindowCollapsed)
    ));
    ImGui.set_function("SetNextWindowFocus", SetNextWindowFocus);
    ImGui.set_function("SetNextWindowBgAlpha", SetNextWindowBgAlpha);
    ImGui.set_function("SetWindowPos", sol::overload(
            sol::resolve<void(float, float)>(SetWindowPos),
            sol::resolve<void(float, float, int)>(SetWindowPos),
            sol::resolve < void(
    const std::string &, float, float)>(SetWindowPos),
            sol::resolve < void(
    const std::string &, float, float, int)>(SetWindowPos)
    ));
    ImGui.set_function("SetWindowSize", sol::overload(
            sol::resolve<void(float, float)>(SetWindowSize),
            sol::resolve<void(float, float, int)>(SetWindowSize),
            sol::resolve < void(
    const std::string &, float, float)>(SetWindowSize),
            sol::resolve < void(
    const std::string &, float, float, int)>(SetWindowSize)
    ));
    ImGui.set_function("SetWindowCollapsed", sol::overload(
            sol::resolve<void(bool)>(SetWindowCollapsed),
            sol::resolve<void(bool, int)>(SetWindowCollapsed),
            sol::resolve < void(
    const std::string &, bool)>(SetWindowCollapsed),
            sol::resolve < void(
    const std::string &, bool, int)>(SetWindowCollapsed)
    ));
    ImGui.set_function("SetWindowFocus", sol::overload(
            sol::resolve<void()>(SetWindowFocus),
            sol::resolve < void(
    const std::string &)>(SetWindowFocus)
    ));
    ImGui.set_function("SetWindowFontScale", SetWindowFontScale);
#pragma endregion Window Utilities

#pragma region Content Region
    ImGui.set_function("GetContentRegionMax", GetContentRegionMax);
    ImGui.set_function("GetContentRegionAvail", GetContentRegionAvail);
    ImGui.set_function("GetWindowContentRegionMin", GetWindowContentRegionMin);
    ImGui.set_function("GetWindowContentRegionMax", GetWindowContentRegionMax);
    ImGui.set_function("GetWindowContentRegionWidth", GetWindowContentRegionWidth);
#pragma endregion Content Region

#pragma region Windows Scrolling
    ImGui.set_function("GetScrollX", GetScrollX);
    ImGui.set_function("GetScrollY", GetScrollY);
    ImGui.set_function("GetScrollMaxX", GetScrollMaxX);
    ImGui.set_function("GetScrollMaxY", GetScrollMaxY);
    ImGui.set_function("SetScrollX", SetScrollX);
    ImGui.set_function("SetScrollY", SetScrollY);
    ImGui.set_function("SetScrollHereX", sol::overload(
            sol::resolve<void()>(SetScrollHereX),
            sol::resolve<void(float)>(SetScrollHereX)
    ));
    ImGui.set_function("SetScrollHereY", sol::overload(
            sol::resolve<void()>(SetScrollHereY),
            sol::resolve<void(float)>(SetScrollHereY)
    ));
    ImGui.set_function("SetScrollFromPosX", sol::overload(
            sol::resolve<void(float)>(SetScrollFromPosX),
            sol::resolve<void(float, float)>(SetScrollFromPosX)
    ));
    ImGui.set_function("SetScrollFromPosY", sol::overload(
            sol::resolve<void(float)>(SetScrollFromPosY),
            sol::resolve<void(float, float)>(SetScrollFromPosY)
    ));
#pragma endregion Windows Scrolling
}
}