// ImGuiAabb.h
// created on 2021/6/11
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"

struct ImGuiAabb    // 2D axis aligned bounding-box
{
    ImVec2 Min{};
    ImVec2 Max{};

    ImGuiAabb() {
        Min = ImVec2(FLT_MAX, FLT_MAX);
        Max = ImVec2(-FLT_MAX, -FLT_MAX);
    }

    ImGuiAabb(const ImVec2 &min, const ImVec2 &max) {
        Min = min;
        Max = max;
    }

    explicit ImGuiAabb(const ImVec4 &v) {
        Min.x = v.x;
        Min.y = v.y;
        Max.x = v.z;
        Max.y = v.w;
    }

    ImGuiAabb(float x1, float y1, float x2, float y2) {
        Min.x = x1;
        Min.y = y1;
        Max.x = x2;
        Max.y = y2;
    }

    ImVec2 GetCenter() const { return Min + (Max - Min) * 0.5f; }

    ImVec2 GetSize() const { return Max - Min; }

    float GetWidth() const { return (Max - Min).x; }

    float GetHeight() const { return (Max - Min).y; }

    ImVec2 GetTL() const { return Min; }

    ImVec2 GetTR() const { return ImVec2(Max.x, Min.y); }

    ImVec2 GetBL() const { return ImVec2(Min.x, Max.y); }

    ImVec2 GetBR() const { return Max; }

    bool Contains(ImVec2 p) const { return p.x >= Min.x && p.y >= Min.y && p.x <= Max.x && p.y <= Max.y; }

    bool Contains(const ImGuiAabb &r) const {
        return r.Min.x >= Min.x && r.Min.y >= Min.y && r.Max.x <= Max.x && r.Max.y <= Max.y;
    }

    bool Overlaps(const ImGuiAabb &r) const {
        return r.Min.y <= Max.y && r.Max.y >= Min.y && r.Min.x <= Max.x && r.Max.x >= Min.x;
    }

    void Expand(ImVec2 sz) {
        Min -= sz;
        Max += sz;
    }

    void Clip(const ImGuiAabb &clip) {
        Min.x = ImMax(Min.x, clip.Min.x);
        Min.y = ImMax(Min.y, clip.Min.y);
        Max.x = ImMin(Max.x, clip.Max.x);
        Max.y = ImMin(Max.y, clip.Max.y);
    }
};

