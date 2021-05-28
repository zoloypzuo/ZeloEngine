// ImRuntime.h
// created on 2021/5/28
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "ImGui.h"

class ImRuntime {

};

//-----------------------------------------------------------------------------
// Helpers
//-----------------------------------------------------------------------------
// Helpers at bottom of the file:
// - if (IMGUI_ONCE_UPON_A_FRAME)		// Execute a block of code once per frame only
// - struct ImGuiTextFilter				// Parse and apply text filter. In format "aaaaa[,bbbb][,ccccc]"
// - struct ImGuiTextBuffer				// Text buffer for logging/accumulating text
// - struct ImGuiStorage				// Custom key value storage (if you need to alter open/close states manually)
// - struct ImDrawList					// Draw command list
// - struct ImBitmapFont				// Bitmap font loader

// Helper: execute a block of code once a frame only
// Usage: if (IMGUI_ONCE_UPON_A_FRAME) {/*do something once a frame*/)
#define IMGUI_ONCE_UPON_A_FRAME			static ImGuiOncePerFrame im = ImGuiOncePerFrame()
struct ImGuiOncePerFrame
{
    ImGuiOncePerFrame() : LastFrame(-1) {}
    operator bool() const { return TryIsNewFrame(); }
private:
    mutable int LastFrame;
    bool		TryIsNewFrame() const	{ const int current_frame = ImGui::GetFrameCount(); if (LastFrame == current_frame) return false; LastFrame = current_frame; return true; }
};

// Helper: Parse and apply text filter. In format "aaaaa[,bbbb][,ccccc]"
struct ImGuiTextFilter
{
    struct TextRange
    {
        const char* b;
        const char* e;

        TextRange() { b = e = NULL; }
        TextRange(const char* _b, const char* _e) { b = _b; e = _e; }
        const char* begin() const { return b; }
        const char* end() const { return e; }
        bool empty() const { return b == e; }
        char front() const { return *b; }
        static bool isblank(char c) { return c == ' ' && c == '\t'; }
        void trim_blanks() { while (b < e && isblank(*b)) b++; while (e > b && isblank(*(e-1))) e--; }
        void split(char separator, ImVector<TextRange>& out);
    };

    char				InputBuf[256];
    ImVector<TextRange>	Filters;
    int					CountGrep;

    ImGuiTextFilter();
    void Clear() { InputBuf[0] = 0; Build(); }
    void Draw(const char* label = "Filter (inc,-exc)", float width = -1.0f);	// Helper calling InputText+Build
    bool PassFilter(const char* val) const;
    bool IsActive() const { return !Filters.empty(); }
    void Build();
};

// Helper: Text buffer for logging/accumulating text
struct ImGuiTextBuffer
{
    ImVector<char>		Buf;

    ImGuiTextBuffer()	{ Buf.push_back(0); }
    const char*			begin() const { return Buf.begin(); }
    const char*			end() const { return Buf.end()-1; }
    size_t				size() const { return Buf.size()-1; }
    bool				empty() { return Buf.empty(); }
    void				clear() { Buf.clear(); Buf.push_back(0); }
    void				Append(const char* fmt, ...);
};

// Helper: Key->value storage
// - Store collapse state for a tree
// - Store color edit options, etc.
// Typically you don't have to worry about this since a storage is held within each Window.
// Declare your own storage if you want to manipulate the open/close state of a particular sub-tree in your interface.
struct ImGuiStorage
{
    struct Pair { ImU32 key; int val; };
    ImVector<Pair>	Data;

    void	Clear();
    int		GetInt(ImU32 key, int default_val = 0);
    void	SetInt(ImU32 key, int val);
    void	SetAllInt(int val);

    int*	Find(ImU32 key);
    void	Insert(ImU32 key, int val);
};

//-----------------------------------------------------------------------------
// Draw List
// Hold a series of drawing commands. The user provide a renderer for ImDrawList
//-----------------------------------------------------------------------------

enum ImDrawCmdType
{
    ImDrawCmdType_DrawTriangleList,
    ImDrawCmdType_PushClipRect,
    ImDrawCmdType_PopClipRect,
};

// sizeof() == 4
struct ImDrawCmd
{
    ImDrawCmdType	cmd_type : 16;
    unsigned int	vtx_count : 16;
    ImDrawCmd(ImDrawCmdType _cmd_type = ImDrawCmdType_DrawTriangleList, unsigned int _vtx_count = 0) { cmd_type = _cmd_type; vtx_count = _vtx_count; }
};

#ifndef IMDRAW_TEX_UV_FOR_WHITE
#define IMDRAW_TEX_UV_FOR_WHITE	ImVec2(0,0)
#endif

// sizeof() == 20
struct ImDrawVert
{
    ImVec2	pos;
    ImVec2  uv;
    ImU32	col;
};

// Draw command list
// User is responsible for providing a renderer for this in ImGuiIO::RenderDrawListFn
struct ImDrawList
{
    ImVector<ImDrawCmd>		commands;
    ImVector<ImDrawVert>	vtx_buffer;			// each command consume ImDrawCmd::vtx_count of those
    ImVector<ImVec4>		clip_rect_buffer;	// each PushClipRect command consume 1 of those
    ImVector<ImVec4>		clip_rect_stack_;	// [internal] clip rect stack while building the command-list (so text command can perform clipping early on)
    ImDrawVert*				vtx_write_;			// [internal] point within vtx_buffer after each add command. allow us to use less [] and .resize on the vector (often slow on windows/debug)

    ImDrawList() { Clear(); }

    void Clear();
    void PushClipRect(const ImVec4& clip_rect);
    void PopClipRect();
    void AddCommand(ImDrawCmdType cmd_type, int vtx_count);
    void AddVtx(const ImVec2& pos, ImU32 col);
    void AddVtxLine(const ImVec2& a, const ImVec2& b, ImU32 col);

    // Primitives
    void AddLine(const ImVec2& a, const ImVec2& b, ImU32 col);
    void AddRect(const ImVec2& a, const ImVec2& b, ImU32 col, float rounding = 0.0f, int rounding_corners=0x0F);
    void AddRectFilled(const ImVec2& a, const ImVec2& b, ImU32 col, float rounding = 0.0f, int rounding_corners=0x0F);
    void AddTriangleFilled(const ImVec2& a, const ImVec2& b, const ImVec2& c, ImU32 col);
    void AddCircle(const ImVec2& centre, float radius, ImU32 col, int num_segments = 12);
    void AddCircleFilled(const ImVec2& centre, float radius, ImU32 col, int num_segments = 12);
    void AddArc(const ImVec2& center, float rad, ImU32 col, int a_min, int a_max, bool tris=false, const ImVec2& third_point_offset = ImVec2(0,0));
    void AddText(ImFont font, float font_size, const ImVec2& pos, ImU32 col, const char* text_begin, const char* text_end);
};

// Optional bitmap font data loader & renderer into vertices
//	#define ImFont to ImBitmapFont to use
// Using the .fnt format exported by BMFont
//  - tool: http://www.angelcode.com/products/bmfont
//  - file-format: http://www.angelcode.com/products/bmfont/doc/file_format.html
// Assume valid file data (won't handle invalid/malicious data)
// Handle a subset of parameters.
//  - kerning pair are not supported (because ImGui code does per-character CalcTextSize calls, need to turn it into something more stateful to allow kerning)
struct ImBitmapFont
{
#pragma pack(push, 1)
    struct FntInfo
    {
        signed short	FontSize;
        unsigned char	BitField;		// bit 0: smooth, bit 1: unicode, bit 2: italic, bit 3: bold, bit 4: fixedHeight, bits 5-7: reserved
        unsigned char	CharSet;
        unsigned short	StretchH;
        unsigned char	AA;
        unsigned char	PaddingUp, PaddingRight, PaddingDown, PaddingLeft;
        unsigned char	SpacingHoriz, SpacingVert;
        unsigned char	Outline;
        //char			FontName[];
    };

    struct FntCommon
    {
        unsigned short	LineHeight;
        unsigned short	Base;
        unsigned short	ScaleW, ScaleH;
        unsigned short	Pages;
        unsigned char	BitField;
        unsigned char	Channels[4];
    };

    struct FntGlyph
    {
        unsigned int	Id;
        unsigned short	X, Y;
        unsigned short	Width, Height;
        signed short	XOffset, YOffset;
        signed short	XAdvance;
        unsigned char	Page;
        unsigned char	Channel;
    };

    struct FntKerning
    {
        unsigned int	IdFirst;
        unsigned int	IdSecond;
        signed short	Amount;
    };
#pragma pack(pop)

    unsigned char*			Data;				// Raw data, content of .fnt file
    int						DataSize;			//
    bool					DataOwned;			//
    const FntInfo*			Info;				// (point into raw data)
    const FntCommon*		Common;				// (point into raw data)
    const FntGlyph*			Glyphs;				// (point into raw data)
    size_t					GlyphsCount;		//
    const FntKerning*		Kerning;			// (point into raw data)
    size_t					KerningCount;		//
    int						TabCount;			// FIXME: mishandled (add fixed amount instead of aligning to column)
    ImVector<const char*>	Filenames;			// (point into raw data)
    ImVector<int>			IndexLookup;		// (built)

    ImBitmapFont();
    ~ImBitmapFont() { Clear(); }

    bool					LoadFromMemory(const void* data, int data_size);
    bool					LoadFromFile(const char* filename);
    void					Clear();
    void					BuildLookupTable();
    const FntGlyph *		FindGlyph(unsigned short c) const;
    float					GetFontSize() const	{ return (float)Info->FontSize; }

    ImVec2					CalcTextSize(float size, float max_width, const char* text_begin, const char* text_end, const char** remaining = NULL) const;
    void					RenderText(float size, ImVec2 pos, ImU32 col, const ImVec4& clip_rect, const char* text_begin, const char* text_end, ImDrawVert*& out_vertices) const;
};



