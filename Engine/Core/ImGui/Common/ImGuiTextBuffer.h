// ImGuiTextBuffer.h
// created on 2021/6/12
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/ImGui/ImGuiPrerequisites.h"

// Helper: Text buffer for logging/accumulating text
struct ImGuiTextBuffer {
    ImVector<char> Buf;

    ImGuiTextBuffer() { Buf.push_back(0); }

    const char *begin() const { return &*Buf.begin(); }

    const char *end() const { return &*Buf.end() - 1; }

    size_t size() const { return Buf.size() - 1; }

    bool empty() const { return Buf.empty(); }

    void clear();

    void Append(const char *fmt, ...);
};