// ImDrawList.cpp
// created on 2021/6/12
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImDrawList.h"
#include "Core/ImGui/ImUtil.h"
#include "Core/ImGui/Common/ImBitmapFont.h"

ImDrawCmd::ImDrawCmd(ImDrawCmdType _cmd_type, int16_t _vtx_count) {
    cmd_type = _cmd_type;
    vtx_count = _vtx_count;
}

void ImDrawList::Clear() {
    commands.resize(0);
    vtx_buffer.resize(0);
    clip_rect_buffer.resize(0);
    vtx_write_ = NULL;
    clip_rect_stack_.resize(0);
}

void ImDrawList::PushClipRect(const ImVec4 &clip_rect) {
    commands.push_back(ImDrawCmd(ImDrawCmdType_PushClipRect));
    clip_rect_buffer.push_back(clip_rect);
    clip_rect_stack_.push_back(clip_rect);
}

void ImDrawList::PopClipRect() {
    if (!commands.empty() && commands.back().cmd_type == ImDrawCmdType_PushClipRect) {
        // Discard push/pop combo because high-level clipping may have discarded the other draw commands already
        commands.pop_back();
        clip_rect_buffer.pop_back();
    } else {
        commands.push_back(ImDrawCmd(ImDrawCmdType_PopClipRect));
    }
    clip_rect_stack_.pop_back();
}

void ImDrawList::AddCommand(ImDrawCmdType cmd_type, int vtx_count) {
    // Maximum value that can fit in our u16 vtx_count member
    const int VTX_COUNT_MAX = (1 << 16);

    // Merge commands if we can, turning them into less draw calls
    ImDrawCmd *prev = commands.empty() ? NULL : &commands.back();
    if (vtx_count > 0 && prev && prev->cmd_type == (ImU32) cmd_type && prev->vtx_count + vtx_count < VTX_COUNT_MAX)
        prev->vtx_count += vtx_count;
    else
        commands.push_back(ImDrawCmd(cmd_type, vtx_count));

    if (vtx_count > 0) {
        vtx_buffer.resize(vtx_buffer.size() + vtx_count);
        vtx_write_ = &vtx_buffer[vtx_buffer.size() - vtx_count];
    }
}

void ImDrawList::AddVtx(const ImVec2 &pos, ImU32 col) {
    vtx_write_->pos = pos;
    vtx_write_->col = col;
    vtx_write_->uv = IMDRAW_TEX_UV_FOR_WHITE;
    vtx_write_++;
}

void ImDrawList::AddVtxLine(const ImVec2 &a, const ImVec2 &b, ImU32 col) {
    const ImVec2 n = (b - a) / ImLength(b - a);
    const ImVec2 hn = ImVec2(n.y, -n.x) * 0.5f;

    AddVtx(a - hn, col);
    AddVtx(b - hn, col);
    AddVtx(a + hn, col);

    AddVtx(b - hn, col);
    AddVtx(b + hn, col);
    AddVtx(a + hn, col);
}

void ImDrawList::AddLine(const ImVec2 &a, const ImVec2 &b, ImU32 col) {
    if ((col >> 24) == 0)
        return;

    AddCommand(ImDrawCmdType_DrawTriangleList, 6);
    AddVtxLine(a, b, col);
}

void ImDrawList::AddArc(const ImVec2 &center, float rad, ImU32 col, int a_min, int a_max, bool tris,
                        const ImVec2 &third_point_offset) {
    static ImVec2 circle_vtx[12];
    static bool circle_vtx_builds = false;
    if (!circle_vtx_builds) {
        for (int i = 0; i < ARRAYSIZE(circle_vtx); i++) {
            const float a = ((float) i / (float) ARRAYSIZE(circle_vtx)) * 2 * PI;
            circle_vtx[i].x = cos(a + PI);
            circle_vtx[i].y = sin(a + PI);
        }
        circle_vtx_builds = true;
    }

    if (tris) {
        AddCommand(ImDrawCmdType_DrawTriangleList, (a_max - a_min) * 3);
        for (int a = a_min; a < a_max; a++) {
            AddVtx(center + circle_vtx[a % ARRAYSIZE(circle_vtx)] * rad, col);
            AddVtx(center + circle_vtx[(a + 1) % ARRAYSIZE(circle_vtx)] * rad, col);
            AddVtx(center + third_point_offset, col);
        }
    } else {
        AddCommand(ImDrawCmdType_DrawTriangleList, (a_max - a_min) * 6);
        for (int a = a_min; a < a_max; a++)
            AddVtxLine(center + circle_vtx[a % ARRAYSIZE(circle_vtx)] * rad,
                       center + circle_vtx[(a + 1) % ARRAYSIZE(circle_vtx)] * rad, col);
    }
}

void ImDrawList::AddRect(const ImVec2 &a, const ImVec2 &b, ImU32 col, float rounding, int rounding_corners) {
    if ((col >> 24) == 0)
        return;

    //const float r = ImMin(rounding, ImMin(abs(b.x-a.x), abs(b.y-a.y))*0.5f);
    float r = rounding;
    r = ImMin(r, abs(b.x - a.x) *
                 (((rounding_corners & (1 | 2)) == (1 | 2)) || ((rounding_corners & (4 | 8)) == (4 | 8)) ? 0.5f
                                                                                                         : 1.0f));
    r = ImMin(r, abs(b.y - a.y) *
                 (((rounding_corners & (1 | 8)) == (1 | 8)) || ((rounding_corners & (2 | 4)) == (2 | 4)) ? 0.5f
                                                                                                         : 1.0f));

    if (r == 0.0f || rounding_corners == 0) {
        AddCommand(ImDrawCmdType_DrawTriangleList, 4 * 6);
        AddVtxLine(ImVec2(a.x, a.y), ImVec2(b.x, a.y), col);
        AddVtxLine(ImVec2(b.x, a.y), ImVec2(b.x, b.y), col);
        AddVtxLine(ImVec2(b.x, b.y), ImVec2(a.x, b.y), col);
        AddVtxLine(ImVec2(a.x, b.y), ImVec2(a.x, a.y), col);
    } else {
        AddCommand(ImDrawCmdType_DrawTriangleList, 4 * 6);
        AddVtxLine(ImVec2(a.x + ((rounding_corners & 1) ? r : 0), a.y),
                   ImVec2(b.x - ((rounding_corners & 2) ? r : 0), a.y), col);
        AddVtxLine(ImVec2(b.x, a.y + ((rounding_corners & 2) ? r : 0)),
                   ImVec2(b.x, b.y - ((rounding_corners & 4) ? r : 0)), col);
        AddVtxLine(ImVec2(b.x - ((rounding_corners & 4) ? r : 0), b.y),
                   ImVec2(a.x + ((rounding_corners & 8) ? r : 0), b.y), col);
        AddVtxLine(ImVec2(a.x, b.y - ((rounding_corners & 8) ? r : 0)),
                   ImVec2(a.x, a.y + ((rounding_corners & 1) ? r : 0)), col);

        if (rounding_corners & 1) AddArc(ImVec2(a.x + r, a.y + r), r, col, 0, 3);
        if (rounding_corners & 2) AddArc(ImVec2(b.x - r, a.y + r), r, col, 3, 6);
        if (rounding_corners & 4) AddArc(ImVec2(b.x - r, b.y - r), r, col, 6, 9);
        if (rounding_corners & 8) AddArc(ImVec2(a.x + r, b.y - r), r, col, 9, 12);
    }
}

void ImDrawList::AddRectFilled(const ImVec2 &a, const ImVec2 &b, ImU32 col, float rounding, int rounding_corners) {
    if ((col >> 24) == 0)
        return;

    //const float r = ImMin(rounding, ImMin(abs(b.x-a.x), abs(b.y-a.y))*0.5f);
    float r = rounding;
    r = ImMin(r, abs(b.x - a.x) *
                 (((rounding_corners & (1 | 2)) == (1 | 2)) || ((rounding_corners & (4 | 8)) == (4 | 8)) ? 0.5f
                                                                                                         : 1.0f));
    r = ImMin(r, abs(b.y - a.y) *
                 (((rounding_corners & (1 | 8)) == (1 | 8)) || ((rounding_corners & (2 | 4)) == (2 | 4)) ? 0.5f
                                                                                                         : 1.0f));

    if (r == 0.0f || rounding_corners == 0) {
        // Use triangle so we can merge more draw calls together (at the cost of extra vertices)
        AddCommand(ImDrawCmdType_DrawTriangleList, 6);
        AddVtx(ImVec2(a.x, a.y), col);
        AddVtx(ImVec2(b.x, a.y), col);
        AddVtx(ImVec2(b.x, b.y), col);
        AddVtx(ImVec2(a.x, a.y), col);
        AddVtx(ImVec2(b.x, b.y), col);
        AddVtx(ImVec2(a.x, b.y), col);
    } else {
        AddCommand(ImDrawCmdType_DrawTriangleList, 6 + 6 * 2);
        AddVtx(ImVec2(a.x + r, a.y), col);
        AddVtx(ImVec2(b.x - r, a.y), col);
        AddVtx(ImVec2(b.x - r, b.y), col);
        AddVtx(ImVec2(a.x + r, a.y), col);
        AddVtx(ImVec2(b.x - r, b.y), col);
        AddVtx(ImVec2(a.x + r, b.y), col);

        float top_y = (rounding_corners & 1) ? a.y + r : a.y;
        float bot_y = (rounding_corners & 8) ? b.y - r : b.y;
        AddVtx(ImVec2(a.x, top_y), col);
        AddVtx(ImVec2(a.x + r, top_y), col);
        AddVtx(ImVec2(a.x + r, bot_y), col);
        AddVtx(ImVec2(a.x, top_y), col);
        AddVtx(ImVec2(a.x + r, bot_y), col);
        AddVtx(ImVec2(a.x, bot_y), col);

        top_y = (rounding_corners & 2) ? a.y + r : a.y;
        bot_y = (rounding_corners & 4) ? b.y - r : b.y;
        AddVtx(ImVec2(b.x - r, top_y), col);
        AddVtx(ImVec2(b.x, top_y), col);
        AddVtx(ImVec2(b.x, bot_y), col);
        AddVtx(ImVec2(b.x - r, top_y), col);
        AddVtx(ImVec2(b.x, bot_y), col);
        AddVtx(ImVec2(b.x - r, bot_y), col);

        if (rounding_corners & 1) AddArc(ImVec2(a.x + r, a.y + r), r, col, 0, 3, true);
        if (rounding_corners & 2) AddArc(ImVec2(b.x - r, a.y + r), r, col, 3, 6, true);
        if (rounding_corners & 4) AddArc(ImVec2(b.x - r, b.y - r), r, col, 6, 9, true);
        if (rounding_corners & 8) AddArc(ImVec2(a.x + r, b.y - r), r, col, 9, 12, true);
    }
}

void ImDrawList::AddTriangleFilled(const ImVec2 &a, const ImVec2 &b, const ImVec2 &c, ImU32 col) {
    if ((col >> 24) == 0)
        return;

    AddCommand(ImDrawCmdType_DrawTriangleList, 3);
    AddVtx(a, col);
    AddVtx(b, col);
    AddVtx(c, col);
}

void ImDrawList::AddCircle(const ImVec2 &centre, float radius, ImU32 col, int num_segments) {
    if ((col >> 24) == 0)
        return;

    AddCommand(ImDrawCmdType_DrawTriangleList, num_segments * 6);
    const float a_step = 2 * PI / (float) num_segments;
    float a0 = 0.0f;
    for (int i = 0; i < num_segments; i++) {
        const float a1 = (i + 1) == num_segments ? 0.0f : a0 + a_step;
        AddVtxLine(centre + ImVec2(cos(a0), sin(a0)) * radius, centre + ImVec2(cos(a1), sin(a1)) * radius, col);
        a0 = a1;
    }
}

void ImDrawList::AddCircleFilled(const ImVec2 &centre, float radius, ImU32 col, int num_segments) {
    if ((col >> 24) == 0)
        return;

    AddCommand(ImDrawCmdType_DrawTriangleList, num_segments * 3);
    const float a_step = 2 * PI / (float) num_segments;
    float a0 = 0.0f;
    for (int i = 0; i < num_segments; i++) {
        const float a1 = (i + 1) == num_segments ? 0.0f : a0 + a_step;
        AddVtx(centre + ImVec2(cos(a0), sin(a0)) * radius, col);
        AddVtx(centre + ImVec2(cos(a1), sin(a1)) * radius, col);
        AddVtx(centre, col);
        a0 = a1;
    }
}

void ImDrawList::AddText(ImFont font, float font_size, const ImVec2 &pos, ImU32 col, const char *text_begin,
                         const char *text_end) {
    if ((col >> 24) == 0)
        return;

    if (text_end == NULL)
        text_end = text_begin + strlen(text_begin);

    int char_count = text_end - text_begin;
    int vtx_count_max = char_count * 6;
    int vtx_begin = vtx_buffer.size();
    AddCommand(ImDrawCmdType_DrawTriangleList, vtx_count_max);

    font->RenderText(font_size, pos, col, clip_rect_stack_.back(), text_begin, text_end, vtx_write_);
    vtx_buffer.resize(vtx_write_ - &vtx_buffer.front());
    int vtx_count = vtx_buffer.size() - vtx_begin;

    commands.back().vtx_count -= (vtx_count_max - vtx_count);
    vtx_write_ -= (vtx_count_max - vtx_count);
}

