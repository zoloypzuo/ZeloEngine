// ImGuiAabb.h
// created on 2021/6/11
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ImGuiPrerequisites.h"

struct ImGuiAabb    // 2D axis aligned bounding-box
{
    ImVec2 Min{};
    ImVec2 Max{};

    ImGuiAabb();

    ImGuiAabb(const ImVec2 &min, const ImVec2 &max);

    explicit ImGuiAabb(const ImVec4 &v);

    ImGuiAabb(float x1, float y1, float x2, float y2);

    ImVec2 GetCenter() const { return Min + (Max - Min) * 0.5f; }

    ImVec2 GetSize() const { return Max - Min; }

    float GetWidth() const { return (Max - Min).x; }

    float GetHeight() const { return (Max - Min).y; }

    ImVec2 GetTL() const { return Min; }

    ImVec2 GetTR() const { return ImVec2(Max.x, Min.y); }

    ImVec2 GetBL() const { return ImVec2(Min.x, Max.y); }

    ImVec2 GetBR() const { return Max; }

    bool Contains(ImVec2 p) const;

    bool Contains(const ImGuiAabb &r) const;

    bool Overlaps(const ImGuiAabb &r) const;

    void Expand(ImVec2 sz);

    void Clip(const ImGuiAabb &clip);
};
