// ImGuiAabb.cpp
// created on 2021/6/12
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImGuiAabb.h"
#include "ImUtil.h"

void ImGuiAabb::Clip(const ImGuiAabb &clip) {
    Min.x = ImMax(Min.x, clip.Min.x);
    Min.y = ImMax(Min.y, clip.Min.y);
    Max.x = ImMin(Max.x, clip.Max.x);
    Max.y = ImMin(Max.y, clip.Max.y);
}

ImGuiAabb::ImGuiAabb() {
    Min = ImVec2(FLT_MAX, FLT_MAX);
    Max = ImVec2(-FLT_MAX, -FLT_MAX);
}

ImGuiAabb::ImGuiAabb(const ImVec2 &min, const ImVec2 &max) {
    Min = min;
    Max = max;
}

ImGuiAabb::ImGuiAabb(const ImVec4 &v) {
    Min.x = v.x;
    Min.y = v.y;
    Max.x = v.z;
    Max.y = v.w;
}

ImGuiAabb::ImGuiAabb(float x1, float y1, float x2, float y2) {
    Min.x = x1;
    Min.y = y1;
    Max.x = x2;
    Max.y = y2;
}

void ImGuiAabb::Expand(ImVec2 sz) {
    Min -= sz;
    Max += sz;
}

bool ImGuiAabb::Overlaps(const ImGuiAabb &r) const {
    return r.Min.y <= Max.y && r.Max.y >= Min.y && r.Min.x <= Max.x && r.Max.x >= Min.x;
}

bool ImGuiAabb::Contains(const ImGuiAabb &r) const {
    return r.Min.x >= Min.x && r.Min.y >= Min.y && r.Max.x <= Max.x && r.Max.y <= Max.y;
}

bool ImGuiAabb::Contains(ImVec2 p) const {
    return p.x >= Min.x && p.y >= Min.y && p.x <= Max.x && p.y <= Max.y;
}
