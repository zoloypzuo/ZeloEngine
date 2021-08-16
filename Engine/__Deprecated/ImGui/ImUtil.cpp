// ImUtil.cpp
// created on 2021/5/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImUtil.h"
#include "ImGuiInternal.h"

int ImStricmp(const char *str1, const char *str2) {
    int d;
    while ((d = toupper(*str2) - toupper(*str1)) == 0 && *str1) {
        str1++;
        str2++;
    }
    return d;
}

const char *ImStristr(const char *haystack, const char *needle, const char *needle_end) {
    if (!needle_end)
        needle_end = needle + strlen(needle);

    const char un0 = toupper(*needle);
    while (*haystack) {
        if (toupper(*haystack) == un0) {
            const char *b = needle + 1;
            for (const char *a = haystack + 1; b < needle_end; a++, b++)
                if (toupper(*a) != toupper(*b))
                    break;
            if (b == needle_end)
                return haystack;
        }
        haystack++;
    }
    return NULL;
}

ImU32 crc32(const void *data, size_t data_size, ImU32 seed) {
    static ImU32 crc32_lut[256] = {0};
    if (!crc32_lut[1]) {
        const ImU32 polynomial = 0xEDB88320;
        for (ImU32 i = 0; i < 256; i++) {
            ImU32 crc = i;
            for (ImU32 j = 0; j < 8; j++)
                crc = (crc >> 1) ^ (-int(crc & 1) & polynomial);
            crc32_lut[i] = crc;
        }
    }
    ImU32 crc = ~seed;
    const unsigned char *current = (const unsigned char *) data;
    while (data_size--)
        crc = (crc >> 8) ^ crc32_lut[(crc & 0xFF) ^ *current++];
    return ~crc;
}

size_t ImFormatString(char *buf, size_t buf_size, const char *fmt, ...) {
    va_list args;
            va_start(args, fmt);
    int w = vsnprintf(buf, buf_size, fmt, args);
            va_end(args);
    buf[buf_size - 1] = 0;
    if (w == -1) w = buf_size;
    return w;
}

size_t ImFormatStringV(char *buf, size_t buf_size, const char *fmt, va_list args) {
    int w = vsnprintf(buf, buf_size, fmt, args);
    buf[buf_size - 1] = 0;
    if (w == -1) w = buf_size;
    return w;
}

ImU32 ImConvertColorFloat4ToU32(const ImVec4 &in) {
    ImU32 out = ((ImU32) (ImSaturate(in.x) * 255.f));
    out |= ((ImU32) (ImSaturate(in.y) * 255.f) << 8);
    out |= ((ImU32) (ImSaturate(in.z) * 255.f) << 16);
    out |= ((ImU32) (ImSaturate(in.w) * 255.f) << 24);
    return out;
}

// Convert rgb floats ([0-1],[0-1],[0-1]) to hsv floats ([0-1],[0-1],[0-1]), from Foley & van Dam p592
// Optimized http://lolengine.net/blog/2013/01/13/fast-rgb-to-hsv
void ImConvertColorRGBtoHSV(float r, float g, float b, float &out_h, float &out_s, float &out_v) {
    float K = 0.f;
    if (g < b) {
        const float tmp = g;
        g = b;
        b = tmp;
        K = -1.f;
    }
    if (r < g) {
        const float tmp = r;
        r = g;
        g = tmp;
        K = -2.f / 6.f - K;
    }

    const float chroma = r - (g < b ? g : b);
    out_h = abs(K + (g - b) / (6.f * chroma + 1e-20f));
    out_s = chroma / (r + 1e-20f);
    out_v = r;
}

// Convert hsv floats ([0-1],[0-1],[0-1]) to rgb floats ([0-1],[0-1],[0-1]), from Foley & van Dam p593
// also http://en.wikipedia.org/wiki/HSL_and_HSV
void ImConvertColorHSVtoRGB(float h, float s, float v, float &out_r, float &out_g, float &out_b) {
    if (s == 0.0f) {
        // gray
        out_r = out_g = out_b = v;
        return;
    }

    h = fmodf(h, 1.0f) / (60.0f / 360.0f);
    int i = (int) h;
    float f = h - (float) i;
    float p = v * (1.0f - s);
    float q = v * (1.0f - s * f);
    float t = v * (1.0f - s * (1.0f - f));

    switch (i) {
        case 0:
            out_r = v;
            out_g = t;
            out_b = p;
            break;
        case 1:
            out_r = q;
            out_g = v;
            out_b = p;
            break;
        case 2:
            out_r = p;
            out_g = v;
            out_b = t;
            break;
        case 3:
            out_r = p;
            out_g = q;
            out_b = v;
            break;
        case 4:
            out_r = t;
            out_g = p;
            out_b = v;
            break;
        case 5:
        default:
            out_r = v;
            out_g = p;
            out_b = q;
            break;
    }
}

//-----------------------------------------------------------------------------

ImGuiOncePerFrame::ImGuiOncePerFrame() : LastFrame(-1) {}

bool ImGuiOncePerFrame::TryIsNewFrame() const {
    const int current_frame = ImGui::GetFrameCount();
    if (LastFrame == current_frame) return false;
    LastFrame = current_frame;
    return true;
}

ImGuiOncePerFrame::operator bool() const { return TryIsNewFrame(); }
