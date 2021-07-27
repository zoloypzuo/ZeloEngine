// ImBitmapFont.cpp
// created on 2021/6/12
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImBitmapFont.h"
#include "Core/ImGui/ImUtil.h"

ImBitmapFont::ImBitmapFont() {
    Data = NULL;
    DataOwned = false;
    Info = NULL;
    Common = NULL;
    Glyphs = NULL;
    GlyphsCount = 0;
    TabCount = 4;
}

void ImBitmapFont::Clear() {
    if (Data && DataOwned)
        free(Data);
    Data = NULL;
    DataOwned = false;
    Info = NULL;
    Common = NULL;
    Glyphs = NULL;
    GlyphsCount = 0;
    Filenames.clear();
    IndexLookup.clear();
}

bool ImBitmapFont::LoadFromFile(const char *filename) {
    // Load file
    FILE * f = fopen(filename, "rb");
    if (f == NULL)
        return false;
    if (fseek(f, 0, SEEK_END))
        return false;
    if ((DataSize = (int) ftell(f)) == -1)
        return false;
    if (fseek(f, 0, SEEK_SET))
        return false;
    if ((Data = (unsigned char *) malloc(DataSize)) == NULL) {
        fclose(f);
        return false;
    }
    if (fread(Data, 1, DataSize, f) != DataSize) {
        fclose(f);
        free(Data);
        return false;
    }
    fclose(f);
    DataOwned = true;
    return LoadFromMemory(Data, DataSize);
}

bool ImBitmapFont::LoadFromMemory(const void *data, int data_size) {
    Data = (unsigned char *) data;
    DataSize = data_size;

    if (parseData()) {
        BuildLookupTable();
        return true;
    } else {
        return false;
    }
}

bool ImBitmapFont::parseData() {
    if (DataSize < 4 || Data[0] != 'B' || Data[1] != 'M' || Data[2] != 'F' || Data[3] != 0x03)
        return false;
    for (const unsigned char *p = Data + 4; p < Data + DataSize;) {
        const unsigned char block_type = *(unsigned char *) p;
        p += sizeof(unsigned char);
        const ImU32 block_size = *(ImU32 *) p;
        p += sizeof(ImU32);

        switch (block_type) {
            case 1:
                ZELO_ASSERT(Info == NULL);
                Info = (FntInfo *) p;
                break;
            case 2:
                ZELO_ASSERT(Common == NULL);
                Common = (FntCommon *) p;
                break;
            case 3:
                for (const unsigned char *s = p;
                     s < p + block_size && s < Data + DataSize; s = s + strlen((const char *) s) + 1)
                    Filenames.push_back((const char *) s);
                break;
            case 4:
                ZELO_ASSERT(Glyphs == NULL && GlyphsCount == 0);
                Glyphs = (FntGlyph *) p;
                GlyphsCount = block_size / sizeof(FntGlyph);
                break;
            default:
                ZELO_ASSERT(Kerning == NULL && KerningCount == 0);
                Kerning = (FntKerning *) p;
                KerningCount = block_size / sizeof(FntKerning);
                break;
        }
        p += block_size;
    }

    return true;
}

void ImBitmapFont::BuildLookupTable() {
    ImU32 max_c = 0;
    for (int i = 0; i != GlyphsCount; i++)
        if (max_c < Glyphs[i].Id)
            max_c = Glyphs[i].Id;

    IndexLookup.clear();
    IndexLookup.resize(max_c + 1);
    for (size_t i = 0; i < IndexLookup.size(); i++)
        IndexLookup[i] = -1;
    for (size_t i = 0; i < GlyphsCount; i++)
        IndexLookup[Glyphs[i].Id] = (int) i;
}

const ImBitmapFont::FntGlyph *ImBitmapFont::FindGlyph(unsigned short c) const {
    if (c < (int) IndexLookup.size()) {
        const int i = IndexLookup[c];
        if (i >= 0 && i < (int) GlyphsCount)
            return &Glyphs[i];
    }
    return NULL;
}

ImVec2 ImBitmapFont::CalcTextSize(float size, float max_width, const char *text_begin, const char *text_end,
                                  const char **remaining) const {
    if (max_width == 0.0f)
        max_width = FLT_MAX;
    if (!text_end)
        text_end = text_begin + strlen(text_begin);

    const float scale = size / (float) Info->FontSize;
    const float line_height = (float) Info->FontSize * scale;

    ImVec2 text_size = ImVec2(0, 0);
    float line_width = 0.0f;

    const char *s = text_begin;
    while (s < text_end) {
        const char c = *s;
        if (c == '\n') {
            if (text_size.x < line_width)
                text_size.x = line_width;
            text_size.y += line_height;
            line_width = 0;
        }
        if (const FntGlyph *glyph = FindGlyph((unsigned short) c)) {
            const float char_width = static_cast<float>(glyph->XAdvance + Info->SpacingHoriz) * scale;
//            const float char_extend = (glyph->XOffset + glyph->Width * scale);
            if (line_width + char_width >= max_width)
                break;
            line_width += char_width;
        } else if (c == '\t') {
            if (const FntGlyph *glyph_tab = FindGlyph((unsigned short) ' '))
                line_width += static_cast<float>(glyph_tab->XAdvance + Info->SpacingHoriz) * 4 * scale;
        }

        s += 1;
    }

    if (line_width > 0 || text_size.y == 0.0f) {
        if (text_size.x < line_width)
            text_size.x = line_width;
        text_size.y += line_height;
    }

    if (remaining)
        *remaining = s;

    return text_size;
}

void ImBitmapFont::RenderText(float size, ImVec2 pos, ImU32 col, const ImVec4 &clip_rect_ref, const char *text_begin,
                              const char *text_end, ImDrawVert *&out_vertices) const {
    if (!text_end)
        text_end = text_begin + strlen(text_begin);

    const float line_height = Info->FontSize;
    const float scale = size / static_cast<float>(Info->FontSize);
    const float tex_scale_x = 1.0f / static_cast<float>(Common->ScaleW);
    const float tex_scale_y = 1.0f / static_cast<float>(Common->ScaleH);
    const float outline = Info->Outline;

    // Align to be pixel perfect
    pos.x = (float) (int) pos.x + 0.5f;
    pos.y = (float) (int) pos.y + 0.5f;

    ImVec2 text_size = ImVec2(0, 0);
//    float line_width = 0.0f;
    const ImVec4 clip_rect = clip_rect_ref;

    float x = pos.x;
    float y = pos.y;
    for (const char *s = text_begin; s < text_end; s++) {
        const char c = *s;
        if (c == '\n') {
            x = pos.x;
            y += line_height * scale;
            continue;
        }

        if (const FntGlyph *glyph = FindGlyph((unsigned short) c)) {
            const float char_width = static_cast<float>(glyph->XAdvance + Info->SpacingHoriz) * scale;
//            const float char_extend = (glyph->XOffset + glyph->Width * scale);

            if (c != ' ') {
                // Clipping due to Y limits is more likely
                float yOffset = glyph->YOffset;
                float height = glyph->Height;

                const float y1 = y + (yOffset + outline * 2) * scale;
                const float y2 = y1 + height * scale;
                if (y1 > clip_rect.w || y2 < clip_rect.y) {
                    x += char_width;
                    continue;
                }

                float xOffset = glyph->XOffset;
                float width = glyph->Width;

                const float x1 = (x + (xOffset + outline) * scale);
                const float x2 = (x1 + width * scale);
                if (x1 > clip_rect.z || x2 < clip_rect.x) {
                    x += char_width;
                    continue;
                }

                float x3 = glyph->X;
                float y3 = glyph->Y;

                const float s1 = (0.0f + x3) * tex_scale_x;
                const float t1 = (0.0f + y3) * tex_scale_y;
                const float s2 = (0.0f + x3 + width) * tex_scale_x;
                const float t2 = (0.0f + y3 + height) * tex_scale_y;

                out_vertices[0].pos = ImVec2(x1, y1);
                out_vertices[0].uv = ImVec2(s1, t1);
                out_vertices[0].col = col;

                out_vertices[1].pos = ImVec2(x2, y1);
                out_vertices[1].uv = ImVec2(s2, t1);
                out_vertices[1].col = col;

                out_vertices[2].pos = ImVec2(x2, y2);
                out_vertices[2].uv = ImVec2(s2, t2);
                out_vertices[2].col = col;

                out_vertices[3] = out_vertices[0];
                out_vertices[4] = out_vertices[2];

                out_vertices[5].pos = ImVec2(x1, y2);
                out_vertices[5].uv = ImVec2(s1, t2);
                out_vertices[5].col = col;

                out_vertices += 6;
            }

            x += char_width;
        } else if (c == '\t') {
            if (const FntGlyph *glyph_tab = FindGlyph((unsigned short) ' '))
                x += static_cast<float>(glyph_tab->XAdvance + Info->SpacingHoriz) * 4 * scale;
        }
    }
}
