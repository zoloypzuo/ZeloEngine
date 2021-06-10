// ImUtil.h
// created on 2021/5/28
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "ImGui.h"

class ImUtil {

};
// @formatter:off
#undef ARRAYSIZE
#define ARRAYSIZE(_ARR)            (sizeof(_ARR)/sizeof(*(_ARR)))

#undef PI
const float PI = 3.14159265358979323846f;

// Math bits
// We are keeping those static in the .cpp file so as not to leak them outside,
// in the case the user has implicit cast operators between ImVec2 and its own types.
static inline ImVec2 operator*(const ImVec2& lhs, const float rhs)				{ return ImVec2(lhs.x*rhs, lhs.y*rhs); }
static inline ImVec2 operator/(const ImVec2& lhs, const float rhs)				{ return ImVec2(lhs.x/rhs, lhs.y/rhs); }
static inline ImVec2 operator+(const ImVec2& lhs, const ImVec2& rhs)			{ return ImVec2(lhs.x+rhs.x, lhs.y+rhs.y); }
static inline ImVec2 operator-(const ImVec2& lhs, const ImVec2& rhs)			{ return ImVec2(lhs.x-rhs.x, lhs.y-rhs.y); }
static inline ImVec2 operator*(const ImVec2& lhs, const ImVec2 rhs)				{ return ImVec2(lhs.x*rhs.x, lhs.y*rhs.y); }
static inline ImVec2 operator/(const ImVec2& lhs, const ImVec2 rhs)				{ return ImVec2(lhs.x/rhs.x, lhs.y/rhs.y); }
static inline ImVec2& operator+=(ImVec2& lhs, const ImVec2& rhs)				{ lhs.x += rhs.x; lhs.y += rhs.y; return lhs; }
static inline ImVec2& operator-=(ImVec2& lhs, const ImVec2& rhs)				{ lhs.x -= rhs.x; lhs.y -= rhs.y; return lhs; }
static inline ImVec2& operator*=(ImVec2& lhs, const float rhs)					{ lhs.x *= rhs; lhs.y *= rhs; return lhs; }
static inline ImVec2& operator/=(ImVec2& lhs, const float rhs)					{ lhs.x /= rhs; lhs.y /= rhs; return lhs; }

static inline int    ImMin(int lhs, int rhs)									{ return lhs < rhs ? lhs : rhs; }
static inline int    ImMax(int lhs, int rhs)									{ return lhs >= rhs ? lhs : rhs; }
static inline float  ImMin(float lhs, float rhs)								{ return lhs < rhs ? lhs : rhs; }
static inline float  ImMax(float lhs, float rhs)								{ return lhs >= rhs ? lhs : rhs; }
static inline ImVec2 ImMin(const ImVec2& lhs, const ImVec2& rhs)				{ return ImVec2(ImMin(lhs.x,rhs.x), ImMin(lhs.y,rhs.y)); }
static inline ImVec2 ImMax(const ImVec2& lhs, const ImVec2& rhs)				{ return ImVec2(ImMax(lhs.x,rhs.x), ImMax(lhs.y,rhs.y)); }
static inline float  ImClamp(float f, float mn, float mx)						{ return (f < mn) ? mn : (f > mx) ? mx : f; }
static inline ImVec2 ImClamp(const ImVec2& f, const ImVec2& mn, ImVec2 mx)		{ return ImVec2(ImClamp(f.x,mn.x,mx.x), ImClamp(f.y,mn.y,mx.y)); }
static inline float  ImSaturate(float f)										{ return (f < 0.0f) ? 0.0f : (f > 1.0f) ? 1.0f : f; }
static inline float  ImLerp(float a, float b, float t)							{ return a + (b - a) * t; }
static inline ImVec2 ImLerp(const ImVec2& a, const ImVec2& b, float t)			{ return a + (b - a) * t; }
static inline ImVec2 ImLerp(const ImVec2& a, const ImVec2& b, const ImVec2& t)	{ return ImVec2(a.x + (b.x - a.x) * t.x, a.y + (b.y - a.y) * t.y); }
static inline float  ImLength(const ImVec2& lhs)								{ return sqrt(lhs.x*lhs.x + lhs.y*lhs.y); }

int ImStricmp(const char *str1, const char *str2);

const char *ImStristr(const char *haystack, const char *needle, const char *needle_end);

ImU32 crc32(const void *data, size_t data_size, ImU32 seed = 0);

size_t ImFormatString(char *buf, size_t buf_size, const char *fmt, ...);

size_t ImFormatStringV(char *buf, size_t buf_size, const char *fmt, va_list args);

ImU32 ImConvertColorFloat4ToU32(const ImVec4 &in);

void ImConvertColorRGBtoHSV(float r, float g, float b, float &out_h, float &out_s, float &out_v);

void ImConvertColorHSVtoRGB(float h, float s, float v, float &out_r, float &out_g, float &out_b);
// @formatter:on
