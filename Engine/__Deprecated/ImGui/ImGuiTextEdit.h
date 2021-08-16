// ImGuiTextEdit.h
// created on 2021/6/12
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "ImGuiPrerequisites.h"
#include "ImGui.h"

struct ImGuiTextEditState;
#define STB_TEXTEDIT_STRING    ImGuiTextEditState
#define STB_TEXTEDIT_CHARTYPE char

#include "stb_textedit.h"

// State of the currently focused/edited text input box
struct ImGuiTextEditState {
    char Text[1024]{};                        // edit buffer, we need to persist but can't guarantee the persistence of the user-provided buffer. so own buffer.
    char InitialText[1024]{};                // backup of end-user buffer at focusing time, to ESC key can do a revert. Also used for arithmetic operations (but could use a pre-parsed float there).
    int MaxLength{};                        // end-user buffer size <= 1024 (or increase above)
    float Width{};                            // widget width
    float ScrollX{};
    STB_TexteditState StbState{};
    float CursorAnim{};
    bool SelectedAllMouseLock{};
    ImFont Font{};
    float FontSize{};

    ImGuiTextEditState() { memset(this, 0, sizeof(*this)); }

    // After a user-input the cursor stays on for a while without blinking
    void CursorAnimReset() { CursorAnim = -0.30f; }

    bool CursorIsVisible() const { return CursorAnim <= 0.0f || fmodf(CursorAnim, 1.20f) <= 0.80f; }        // Blinking

    bool HasSelection() const { return StbState.select_start != StbState.select_end; }

    void SelectAll();

    void OnKeyboardPressed(int key);

    void UpdateScrollOffset();

    ImVec2 CalcDisplayOffsetFromCharIdx(int i) const;

    // Static functions because they are used to render non-focused instances of a text input box
    static const char *
    GetTextPointerClipped(ImFont font, float font_size, const char *text, float width, ImVec2 *out_text_size = NULL);

    static void RenderTextScrolledClipped(
            ImFont font, float font_size, const char *buf,
            ImVec2 pos_base, float width, float scroll_x
    );
};

// Wrapper for stb_textedit.h to edit text (our wrapper is for: statically sized buffer, single-line, ASCII, fixed-width font)
int STB_TEXTEDIT_STRINGLEN(const STB_TEXTEDIT_STRING *obj);

char STB_TEXTEDIT_GETCHAR(const STB_TEXTEDIT_STRING *obj, int idx);

float STB_TEXTEDIT_GETWIDTH(STB_TEXTEDIT_STRING *obj, int line_start_idx, int char_idx);

char STB_TEXTEDIT_KEYTOTEXT(int key);

const char STB_TEXTEDIT_NEWLINE = '\n';

void STB_TEXTEDIT_LAYOUTROW(StbTexteditRow *r, STB_TEXTEDIT_STRING *obj, int line_start_idx);

static bool is_white(char c);

static bool is_separator(char c);

#define STB_TEXTEDIT_IS_SPACE(c) (is_white(c) || is_separator(c))

void STB_TEXTEDIT_DELETECHARS(STB_TEXTEDIT_STRING *obj, int idx, int n);

bool STB_TEXTEDIT_INSERTCHARS(STB_TEXTEDIT_STRING *obj, int idx, const char *new_text, int new_text_size);

// @formatter:off
enum
{
    STB_TEXTEDIT_K_LEFT = 1 << 16,	// keyboard input to move cursor left
    STB_TEXTEDIT_K_RIGHT,			// keyboard input to move cursor right
    STB_TEXTEDIT_K_UP,				// keyboard input to move cursor up
    STB_TEXTEDIT_K_DOWN,			// keyboard input to move cursor down
    STB_TEXTEDIT_K_LINESTART,		// keyboard input to move cursor to start of line
    STB_TEXTEDIT_K_LINEEND,			// keyboard input to move cursor to end of line
    STB_TEXTEDIT_K_TEXTSTART,		// keyboard input to move cursor to start of text
    STB_TEXTEDIT_K_TEXTEND,			// keyboard input to move cursor to end of text
    STB_TEXTEDIT_K_DELETE,			// keyboard input to delete selection or character under cursor
    STB_TEXTEDIT_K_BACKSPACE,		// keyboard input to delete selection or character left of cursor
    STB_TEXTEDIT_K_UNDO,			// keyboard input to perform undo
    STB_TEXTEDIT_K_REDO,			// keyboard input to perform redo
    STB_TEXTEDIT_K_WORDLEFT,		// keyboard input to move cursor left one word
    STB_TEXTEDIT_K_WORDRIGHT,		// keyboard input to move cursor right one word
    STB_TEXTEDIT_K_SHIFT = 1 << 17,
};
// @formatter:on
