// ImGuiTextBuffer.cpp
// created on 2021/6/12
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImGuiTextBuffer.h"
#include "Core/ImGui/ImUtil.h"

void ImGuiTextBuffer::Append(const char *fmt, ...) {
    va_list args{};
            va_start(args, fmt);
    int len = vsnprintf(NULL, 0, fmt, args);
            va_end(args);

    const size_t write_off = Buf.size();
    if (write_off + len >= Buf.capacity())
        Buf.reserve(Buf.capacity() * 2);

    Buf.resize(write_off + len);

            va_start(args, fmt);
    ImFormatStringV(&Buf[write_off] - 1, len + 1, fmt, args);
            va_end(args);
}

void ImGuiTextBuffer::clear() {
    Buf.clear();
    Buf.push_back(0);
}
