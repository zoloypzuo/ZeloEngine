// ImDrawList.h
// created on 2021/6/12
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "Core/ImGui/ImGuiPrerequisites.h"

//-----------------------------------------------------------------------------
// Draw List
// Hold a series of drawing commands. The user provide a renderer for ImDrawList
//-----------------------------------------------------------------------------

enum ImDrawCmdType {
    ImDrawCmdType_DrawTriangleList,
    ImDrawCmdType_PushClipRect,
    ImDrawCmdType_PopClipRect,
};

// sizeof() == 4
struct ImDrawCmd {
    ImDrawCmdType cmd_type: 16;
    int16_t vtx_count: 16;

    explicit ImDrawCmd(ImDrawCmdType _cmd_type = ImDrawCmdType_DrawTriangleList, int16_t _vtx_count = 0);
};

#ifndef IMDRAW_TEX_UV_FOR_WHITE
#define IMDRAW_TEX_UV_FOR_WHITE    ImVec2(0,0)
#endif

// sizeof() == 20
struct ImDrawVert {
    ImVec2 pos{};
    ImVec2 uv{};
    ImU32 col{};
};

// Draw command list
// User is responsible for providing a renderer for this in ImGuiIO::RenderDrawListFn
struct ImDrawList {
    // @formatter:off
    ImVector<ImDrawCmd>		commands{};
    ImVector<ImDrawVert>	vtx_buffer{};			// each command consume ImDrawCmd::vtx_count of those
    ImVector<ImVec4>		clip_rect_buffer{};	// each PushClipRect command consume 1 of those
    ImVector<ImVec4>		clip_rect_stack_{};	// [internal] clip rect stack while building the command-list (so text command can perform clipping early on)
    ImDrawVert*				vtx_write_{};			// [internal] point within vtx_buffer after each add command. allow us to use less [] and .resize on the vector (often slow on windows/debug)
    // @formatter:on
    ImDrawList() { Clear(); }

    void Clear();

    void PushClipRect(const ImVec4 &clip_rect);

    void PopClipRect();

    void AddCommand(ImDrawCmdType cmd_type, int vtx_count);

    void AddVtx(const ImVec2 &pos, ImU32 col);

    void AddVtxLine(const ImVec2 &a, const ImVec2 &b, ImU32 col);

    // Primitives
    void AddLine(const ImVec2 &a, const ImVec2 &b, ImU32 col);

    void AddRect(const ImVec2 &a, const ImVec2 &b, ImU32 col, float rounding = 0.0f, int rounding_corners = 0x0F);

    void AddRectFilled(const ImVec2 &a, const ImVec2 &b, ImU32 col, float rounding = 0.0f, int rounding_corners = 0x0F);

    void AddTriangleFilled(const ImVec2 &a, const ImVec2 &b, const ImVec2 &c, ImU32 col);

    void AddCircle(const ImVec2 &centre, float radius, ImU32 col, int num_segments = 12);

    void AddCircleFilled(const ImVec2 &centre, float radius, ImU32 col, int num_segments = 12);

    void AddArc(const ImVec2 &center, float rad, ImU32 col, int a_min, int a_max, bool tris = false,
                const ImVec2 &third_point_offset = ImVec2(0, 0));

    void AddText(ImFont font, float font_size, const ImVec2 &pos, ImU32 col,
                 const char *text_begin, const char *text_end);
};
