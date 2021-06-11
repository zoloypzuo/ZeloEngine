// ImGuiPrerequisites.h
// created on 2021/6/11
// author @zoloypzuo

#pragma once

// forward declaration
struct ImDrawList;
struct ImBitmapFont;
struct ImGuiAabb;
struct ImGuiIO;
struct ImGuiStorage;
struct ImGuiStyle;
struct ImGuiWindow;

// typedef primitive type
typedef unsigned int ImU32;
typedef ImU32 ImGuiID;
typedef int ImGuiCol;                // enum ImGuiCol_
typedef int ImGuiKey;                // enum ImGuiKey_
typedef int ImGuiColorEditMode;        // enum ImGuiColorEditMode_
typedef ImU32 ImGuiWindowFlags;        // enum ImGuiWindowFlags_
typedef ImU32 ImGuiInputTextFlags;    // enum ImGuiInputTextFlags_
typedef ImBitmapFont *ImFont;

// typedef vector2, vector4
typedef glm::vec2 ImVec2;
typedef glm::vec4 ImVec4;

// typedef vector<T>
template<typename T>
using ImVector = std::vector<T>;
