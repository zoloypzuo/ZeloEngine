// ImGuiTextEdit.cpp.cc
// created on 2021/6/12
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImGuiTextEdit.h"
#include "ImUtil.h"
#include "ImGuiInternal.h"

#define STB_TEXTEDIT_IMPLEMENTATION

#include "stb_textedit.h"

void ImGuiTextEditState::OnKeyboardPressed(int key) {
    stb_textedit_key(this, &StbState, key);
    CursorAnimReset();
}

void ImGuiTextEditState::UpdateScrollOffset() {
    // Scroll in chunks of quarter width
    const float scroll_x_increment = Width * 0.25f;
    const float cursor_offset_x = Font->CalcTextSize(FontSize, 0, Text, Text + StbState.cursor, NULL).x;
    if (ScrollX > cursor_offset_x)
        ScrollX = ImMax(0.0f, cursor_offset_x - scroll_x_increment);
    else if (ScrollX < cursor_offset_x - Width)
        ScrollX = cursor_offset_x - Width + scroll_x_increment;
}

ImVec2 ImGuiTextEditState::CalcDisplayOffsetFromCharIdx(int i) const {
    const char *text_start = GetTextPointerClipped(Font, FontSize, Text, ScrollX, NULL);
    const char *text_end = (Text + i >= text_start) ? Text + i
                                                    : text_start;                    // Clip if requested character is outside of display
    ZELO_ASSERT(text_end >= text_start);

    const ImVec2 offset = Font->CalcTextSize(FontSize, Width, text_start, text_end, NULL);
    return offset;
}

// [Static]
const char *ImGuiTextEditState::GetTextPointerClipped(ImFont font, float font_size, const char *text, float width,
                                                      ImVec2 *out_text_size) {
    if (width <= 0.0f)
        return text;

    const char *text_clipped_end = NULL;
    const ImVec2 text_size = font->CalcTextSize(font_size, width, text, NULL, &text_clipped_end);
    if (out_text_size)
        *out_text_size = text_size;
    return text_clipped_end;
}

// [Static]
void ImGuiTextEditState::RenderTextScrolledClipped(
        ImFont font, float font_size, const char *buf,
        ImVec2 pos, float width, float scroll_x) {
    // NB- We start drawing at character boundary
    ImVec2 text_size;
    const char *text_start = GetTextPointerClipped(font, font_size, buf, scroll_x, NULL);
    const char *text_end = GetTextPointerClipped(font, font_size, text_start, width, &text_size);

    // Draw a little clip symbol if we've got text on either left or right of the box
    const char symbol_c = '~';
    const float symbol_w = font_size * 0.40f;        // FIXME: compute correct width
    const float clip_begin = (text_start > buf && text_start < text_end) ? symbol_w : 0.0f;
    const float clip_end = (text_end[0] != '\0' && text_end > text_start) ? symbol_w : 0.0f;

    // Draw text
    ImGui::RenderText(pos + ImVec2(clip_begin, 0),
                      text_start + (clip_begin ? 1 : 0),
                      text_end - (clip_end ? 1 : 0),
                      false);//, &text_params_with_clipping);

    // Draw the clip symbol
    const char s[2] = {symbol_c, '\0'};
    if (clip_begin > 0.0f)
        ImGui::RenderText(pos, s);
    if (clip_end > 0.0f)
        ImGui::RenderText(pos + ImVec2(width - clip_end, 0.0f), s);
}

void ImGuiTextEditState::SelectAll() {
    StbState.select_start = 0;
    StbState.select_end = strlen(Text);
    StbState.cursor = StbState.select_end;
    StbState.has_preferred_x = false;
}

bool ImGui::InputText(const char *label, char *buf, size_t buf_size, ImGuiInputTextFlags flags) {
    ImGuiState &g = GImGui;
    ImGuiWindow *window = GetCurrentWindow();
    if (window->Collapsed)
        return false;

    const ImGuiIO &io = g.IO;
    const ImGuiStyle &style = g.Style;

    const ImGuiID id = window->GetID(label);
    const float w = window->DC.ItemWidth.back();

    const ImVec2 text_size = CalcTextSize(label);
    const ImGuiAabb frame_bb(window->DC.CursorPos,
                             window->DC.CursorPos + ImVec2(w, text_size.y) + style.FramePadding * 2.0f);
    const ImGuiAabb bb(frame_bb.Min, frame_bb.Max + ImVec2(style.ItemInnerSpacing.x + text_size.x, 0.0f));
    ItemSize(bb);

    if (ClipAdvance(frame_bb))
        return false;

    // NB: we can only read/write if we are the active widget!
    ImGuiTextEditState &edit_state = g.InputTextState;

    const bool is_ctrl_down = io.KeyCtrl;
    const bool is_shift_down = io.KeyShift;
    const bool tab_focus_requested = window->FocusItemRegister(g.ActiveId == id);
    //const bool align_center = (bool)(flags & ImGuiInputTextFlags_AlignCenter);	// FIXME: Unsupported

    const bool hovered = (g.HoveredWindow == window) && (g.HoveredId == 0) && IsMouseHoveringBox(frame_bb);
    if (hovered)
        g.HoveredId = id;

    bool select_all = (g.ActiveId != id) && (flags & ImGuiInputTextFlags_AutoSelectAll) != 0;
    if (tab_focus_requested || (hovered && io.MouseClicked[0])) {
        if (g.ActiveId != id) {
            // Start edition
            strcpy(edit_state.Text, buf);
            strcpy(edit_state.InitialText, buf);
            edit_state.ScrollX = 0.0f;
            edit_state.Width = w;
            stb_textedit_initialize_state(&edit_state.StbState, true);
            edit_state.CursorAnimReset();

            if (tab_focus_requested || is_ctrl_down)
                select_all = true;
        }
        g.ActiveId = id;
    } else if (io.MouseClicked[0]) {
        // Release focus when we click outside
        if (g.ActiveId == id) {
            g.ActiveId = 0;
        }
    }

    bool value_changed = false;
    bool cancel_edit = false;
    if (g.ActiveId == id) {
        edit_state.MaxLength = buf_size < ARRAYSIZE(edit_state.Text) ? buf_size : ARRAYSIZE(edit_state.Text);
        edit_state.Font = window->Font();
        edit_state.FontSize = window->FontSize();

        const float mx = g.IO.MousePos.x - frame_bb.Min.x - style.FramePadding.x;
        const float my = window->FontSize() * 0.5f;    // Better for single line

        edit_state.UpdateScrollOffset();
        if (select_all || (hovered && io.MouseDoubleClicked[0])) {
            edit_state.SelectAll();
            edit_state.SelectedAllMouseLock = true;
        } else if (io.MouseClicked[0] && !edit_state.SelectedAllMouseLock) {
            stb_textedit_click(&edit_state, &edit_state.StbState, mx + edit_state.ScrollX, my);
            edit_state.CursorAnimReset();

        } else if (io.MouseDown[0] && !edit_state.SelectedAllMouseLock) {
            stb_textedit_drag(&edit_state, &edit_state.StbState, mx + edit_state.ScrollX, my);
            edit_state.CursorAnimReset();
        }
        if (edit_state.SelectedAllMouseLock && !io.MouseDown[0])
            edit_state.SelectedAllMouseLock = false;

        const int k_mask = (is_shift_down ? STB_TEXTEDIT_K_SHIFT : 0);
        if (IsKeyPressedMap(ImGuiKey_LeftArrow))
            edit_state.OnKeyboardPressed(
                    is_ctrl_down ? STB_TEXTEDIT_K_WORDLEFT | k_mask : STB_TEXTEDIT_K_LEFT | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_RightArrow))
            edit_state.OnKeyboardPressed(
                    is_ctrl_down ? STB_TEXTEDIT_K_WORDRIGHT | k_mask : STB_TEXTEDIT_K_RIGHT | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_UpArrow)) edit_state.OnKeyboardPressed(STB_TEXTEDIT_K_UP | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_DownArrow)) edit_state.OnKeyboardPressed(STB_TEXTEDIT_K_DOWN | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_Home))
            edit_state.OnKeyboardPressed(
                    is_ctrl_down ? STB_TEXTEDIT_K_TEXTSTART | k_mask : STB_TEXTEDIT_K_LINESTART | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_End))
            edit_state.OnKeyboardPressed(
                    is_ctrl_down ? STB_TEXTEDIT_K_TEXTEND | k_mask : STB_TEXTEDIT_K_LINEEND | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_Delete)) edit_state.OnKeyboardPressed(STB_TEXTEDIT_K_DELETE | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_Backspace)) edit_state.OnKeyboardPressed(STB_TEXTEDIT_K_BACKSPACE | k_mask);
        else if (IsKeyPressedMap(ImGuiKey_Enter)) { g.ActiveId = 0; }
        else if (IsKeyPressedMap(ImGuiKey_Escape)) {
            g.ActiveId = 0;
            cancel_edit = true;
        } else if (is_ctrl_down && IsKeyPressedMap(ImGuiKey_Z))
            edit_state.OnKeyboardPressed(
                    STB_TEXTEDIT_K_UNDO);        // I don't want to use shortcuts but we should probably have an Input-catch stack
        else if (is_ctrl_down && IsKeyPressedMap(ImGuiKey_Y)) edit_state.OnKeyboardPressed(STB_TEXTEDIT_K_REDO);
        else if (is_ctrl_down && IsKeyPressedMap(ImGuiKey_A)) edit_state.SelectAll();
        else if (is_ctrl_down && IsKeyPressedMap(ImGuiKey_X)) {
            if (!edit_state.HasSelection())
                edit_state.SelectAll();

            const int ib = ImMin(edit_state.StbState.select_start, edit_state.StbState.select_end);
            const int ie = ImMax(edit_state.StbState.select_start, edit_state.StbState.select_end);
            if (g.IO.SetClipboardTextFn)
                g.IO.SetClipboardTextFn(edit_state.Text + ib, edit_state.Text + ie);
            stb_textedit_cut(&edit_state, &edit_state.StbState);
        } else if (is_ctrl_down && IsKeyPressedMap(ImGuiKey_C)) {
            const int ib = edit_state.HasSelection() ? ImMin(edit_state.StbState.select_start,
                                                             edit_state.StbState.select_end) : 0;
            const int ie = edit_state.HasSelection() ? ImMax(edit_state.StbState.select_start,
                                                             edit_state.StbState.select_end) : (int) strlen(
                    edit_state.Text);
            if (g.IO.SetClipboardTextFn)
                g.IO.SetClipboardTextFn(edit_state.Text + ib, edit_state.Text + ie);
        } else if (is_ctrl_down && IsKeyPressedMap(ImGuiKey_V)) {
            if (g.IO.GetClipboardTextFn)
                if (const char *clipboard = g.IO.GetClipboardTextFn()) {
                    // Remove new-line from pasted buffer
                    int clipboard_len = strlen(clipboard);
                    char *clipboard_filtered = (char *) malloc(clipboard_len + 1);
                    int clipboard_filtered_len = 0;
                    for (int i = 0; clipboard[i]; i++) {
                        const char c = clipboard[i];
                        if (c == '\n' || c == '\r')
                            continue;
                        clipboard_filtered[clipboard_filtered_len++] = clipboard[i];
                    }
                    clipboard_filtered[clipboard_filtered_len] = 0;
                    stb_textedit_paste(&edit_state, &edit_state.StbState, clipboard_filtered, clipboard_filtered_len);
                    free(clipboard_filtered);
                }
        } else if (g.IO.InputCharacters[0]) {
            // Text input
            for (int n = 0; n < ARRAYSIZE(g.IO.InputCharacters) && g.IO.InputCharacters[n]; n++) {
                const char c = g.IO.InputCharacters[n];
                if (c) {
                    // Filter
                    if (!isprint(c) && c != ' ')
                        continue;
                    if (flags & ImGuiInputTextFlags_CharsDecimal)
                        if (!(c >= '0' && c <= '9') && (c != '.') && (c != '-') && (c != '+') && (c != '*') &&
                            (c != '/'))
                            continue;
                    if (flags & ImGuiInputTextFlags_CharsHexadecimal)
                        if (!(c >= '0' && c <= '9') && !(c >= 'a' && c <= 'f') && !(c >= 'A' && c <= 'F'))
                            continue;

                    // Insert character!
                    edit_state.OnKeyboardPressed(c);
                }
            }
        }

        edit_state.CursorAnim += g.IO.DeltaTime;
        edit_state.UpdateScrollOffset();

        if (cancel_edit) {
            // Restore initial value
            ImFormatString(buf, buf_size, "%s", edit_state.InitialText);
            value_changed = true;
        } else {
            // Apply new value immediately - copy modified buffer back
            if (strcmp(edit_state.Text, buf) != 0) {
                ImFormatString(buf, buf_size, "%s", edit_state.Text);
                value_changed = true;
            }
        }
    }

    RenderFrame(frame_bb.Min, frame_bb.Max, window->Color(ImGuiCol_FrameBg), true);//, style.Rounding);

    const ImVec2 font_off_up = ImVec2(0.0f, window->FontSize() + 1.0f);    // FIXME: this should be part of the font API
    const ImVec2 font_off_dn = ImVec2(0.0f, 2.0f);

    if (g.ActiveId == id) {
        // Draw selection
        const int select_begin_idx = edit_state.StbState.select_start;
        const int select_end_idx = edit_state.StbState.select_end;
        if (select_begin_idx != select_end_idx) {
            const ImVec2 select_begin_pos = frame_bb.Min + style.FramePadding + edit_state.CalcDisplayOffsetFromCharIdx(
                    ImMin(select_begin_idx, select_end_idx));
            const ImVec2 select_end_pos = frame_bb.Min + style.FramePadding + edit_state.CalcDisplayOffsetFromCharIdx(
                    ImMax(select_begin_idx, select_end_idx));
            window->DrawList->AddRectFilled(select_begin_pos - font_off_up, select_end_pos + font_off_dn,
                                            window->Color(ImGuiCol_TextSelectedBg));
        }
    }

    // FIXME: 'align_center' unsupported
    ImGuiTextEditState::RenderTextScrolledClipped(window->Font(), window->FontSize(), buf,
                                                  frame_bb.Min + style.FramePadding, w,
                                                  (g.ActiveId == id) ? edit_state.ScrollX : 0.0f);

    if (g.ActiveId == id) {
        // Draw blinking cursor
        if (g.InputTextState.CursorIsVisible()) {
            const ImVec2 cursor_pos = frame_bb.Min + style.FramePadding +
                                      edit_state.CalcDisplayOffsetFromCharIdx(edit_state.StbState.cursor);
            window->DrawList->AddRect(cursor_pos - font_off_up + ImVec2(0, 2), cursor_pos + font_off_dn - ImVec2(0, 3),
                                      window->Color(ImGuiCol_Text));
        }
    }

    RenderText(ImVec2(frame_bb.Max.x + style.ItemInnerSpacing.x, frame_bb.Min.y + style.FramePadding.y), label);

    return value_changed;
}

bool STB_TEXTEDIT_INSERTCHARS(ImGuiTextEditState *obj, int idx, const char *new_text, int new_text_size) {
    char *buf_end = obj->Text + obj->MaxLength;
    int text_size = strlen(obj->Text);

    if (new_text_size > buf_end - (obj->Text + text_size + 1))
        return false;

    memmove(obj->Text + idx + new_text_size, obj->Text + idx, text_size - idx);
    memcpy(obj->Text + idx, new_text, new_text_size);
    obj->Text[text_size + new_text_size] = 0;

    return true;
}

void STB_TEXTEDIT_DELETECHARS(ImGuiTextEditState *obj, int idx, int n) {
    char *dst = obj->Text + idx;
    const char *src = obj->Text + idx + n;
    while (char c = *src++) *dst++ = c;
    *dst = '\0';
}

int STB_TEXTEDIT_STRINGLEN(const ImGuiTextEditState *obj) { return (int) strlen(obj->Text); }

char STB_TEXTEDIT_GETCHAR(const ImGuiTextEditState *obj, int idx) { return (char) obj->Text[idx]; }

float STB_TEXTEDIT_GETWIDTH(ImGuiTextEditState *obj, int line_start_idx, int char_idx) {
    return obj->Font->CalcTextSize(obj->FontSize, 0, &obj->Text[char_idx], &obj->Text[char_idx] + 1, NULL).x;
}

char STB_TEXTEDIT_KEYTOTEXT(int key) { return key >= 0x10000 ? 0 : (char) key; }

void STB_TEXTEDIT_LAYOUTROW(StbTexteditRow *r, ImGuiTextEditState *obj, int line_start_idx) {
    const char *text_remaining = NULL;
    const ImVec2 size = obj->Font->CalcTextSize(
            obj->FontSize, FLT_MAX,
            obj->Text + line_start_idx, NULL,
            &text_remaining);
    r->x0 = 0.0f;
    r->x1 = size.x;
    r->baseline_y_delta = size.y;
    r->ymin = 0.0f;
    r->ymax = size.y;
    r->num_chars = (int) (text_remaining - (obj->Text + line_start_idx));
}

bool is_white(char c) {
    return c == 0 || c == ' ' || c == '\t' || c == '\r' || c == '\n';
}

bool is_separator(char c) {
    return c == ',' || c == ';' || c == '(' || c == ')' || c == '{' || c == '}' || c == '[' || c == ']' || c == '|';
}
