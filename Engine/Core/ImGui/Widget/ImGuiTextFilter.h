// ImGuiTextFilter.h
// created on 2021/6/12
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/ImGui/ImGuiPrerequisites.h"

// Helper: Parse and apply text filter. In format "aaaaa[,bbbb][,ccccc]"
struct ImGuiTextFilter {
    struct TextRange {
        const char *b;
        const char *e;

        TextRange();

        TextRange(const char *_b, const char *_e);

        const char *begin() const { return b; }

        const char *end() const { return e; }

        bool empty() const { return b == e; }

        char front() const { return *b; }

        static bool isblank(char c) { return c == ' ' || c == '\t'; }

        void trim_blanks();

        void split(char separator, ImVector<TextRange> &out) const;
    };

    // @formatter:off
    char				InputBuf[256]{};
    ImVector<TextRange>	Filters;
    int					CountGrep;
    // @formatter:on

    ImGuiTextFilter();

    void Clear() {
        InputBuf[0] = 0;
        Build();
    }

    // Helper calling InputText+Build
    void Draw(const char *label = "Filter (inc,-exc)", float width = -1.0f);

    bool PassFilter(const char *val) const;

    bool IsActive() const { return !Filters.empty(); }

    void Build();
};

