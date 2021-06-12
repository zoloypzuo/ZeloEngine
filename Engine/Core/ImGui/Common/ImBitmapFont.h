// ImBitmapFont.h
// created on 2021/6/12
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/ImGui/ImGuiPrerequisites.h"
#include "Core/ImGui/Common/ImDrawList.h"

// Optional bitmap font data loader & renderer into vertices
//	#define ImFont to ImBitmapFont to use
// Using the .fnt format exported by BMFont
//  - tool: http://www.angelcode.com/products/bmfont
//  - file-format: http://www.angelcode.com/products/bmfont/doc/file_format.html
// Assume valid file data (won't handle invalid/malicious data)
// Handle a subset of parameters.
//  - kerning pair are not supported (because ImGui code does per-character CalcTextSize calls, need to turn it into something more stateful to allow kerning)
struct ImBitmapFont {
    // @formatter:off
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

    // @formatter:on
    ImBitmapFont();

    ~ImBitmapFont() { Clear(); }

    bool LoadFromMemory(const void *data, int data_size);

    bool LoadFromFile(const char *filename);

    void Clear();

    void BuildLookupTable();

    const FntGlyph *FindGlyph(unsigned short c) const;

    float GetFontSize() const { return (float) Info->FontSize; }

    ImVec2 CalcTextSize(float size, float max_width,
                        const char *text_begin, const char *text_end,
                        const char **remaining = NULL) const;

    void RenderText(float size, ImVec2 pos, ImU32 col, const ImVec4 &clip_rect,
                    const char *text_begin, const char *text_end,
                    ImDrawVert *&out_vertices) const;
};
