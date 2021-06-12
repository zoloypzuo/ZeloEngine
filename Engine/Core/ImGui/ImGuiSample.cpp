// ImGuiSample.cpp.cc
// created on 2021/6/12
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImGuiSample.h"
#include "ImUtil.h"
#include "ImGuiInternal.h"

//-----------------------------------------------------------------------------
// HELP
//-----------------------------------------------------------------------------

namespace ImGui {

void ShowUserGuide() {
    ImGuiState &g = GImGui;

    ImGui::BulletText("Double-click on title bar to collapse window.");
    ImGui::BulletText("Click and drag on lower right corner to resize window.");
    ImGui::BulletText("Click and drag on any empty space to move window.");
    ImGui::BulletText("Mouse Wheel to scroll.");
    if (g.IO.FontAllowScaling)
        ImGui::BulletText("CTRL+Mouse Wheel to zoom window contents.");
    ImGui::BulletText("TAB/SHIFT+TAB to cycle thru keyboard editable fields.");
    ImGui::BulletText("CTRL+Click on a slider to input text.");
    ImGui::BulletText(
            "While editing text:\n"
            "- Hold SHIFT or use mouse to select text\n"
            "- CTRL+Left/Right to word jump\n"
            "- CTRL+A select all\n"
            "- CTRL+X,CTRL+C,CTRL+V clipboard\n"
            "- CTRL+Z,CTRL+Y undo/redo\n"
            "- ESCAPE to revert\n"
            "- You can apply arithmetic operators +,*,/ on numerical values.\n"
            "  Use +- to subtract.\n");
}

void ShowStyleEditor(ImGuiStyle *ref) {
    ImGuiState &g = GImGui;
    ImGuiStyle &style = g.Style;

    const ImGuiStyle def;

    if (ImGui::Button("Revert Style"))
        g.Style = ref ? *ref : def;
    if (ref) {
        ImGui::SameLine();
        if (ImGui::Button("Save Style"))
            *ref = g.Style;
    }

    ImGui::SliderFloat("Rounding", &style.WindowRounding, 0.0f, 16.0f, "%.0f");

    static ImGuiColorEditMode edit_mode = ImGuiColorEditMode_RGB;
    ImGui::RadioButton("RGB", &edit_mode, ImGuiColorEditMode_RGB);
    ImGui::SameLine();
    ImGui::RadioButton("HSV", &edit_mode, ImGuiColorEditMode_HSV);
    ImGui::SameLine();
    ImGui::RadioButton("HEX", &edit_mode, ImGuiColorEditMode_HEX);

    ImGui::ColorEditMode(edit_mode);
    for (size_t i = 0; i < ImGuiCol_COUNT; i++) {
        ImGui::PushID(i);
        ImGui::ColorEdit4(GetStyleColorName(i), (float *) &style.Colors[i], true);
        if (memcmp(&style.Colors[i], (ref ? &ref->Colors[i] : &def.Colors[i]), sizeof(ImVec4)) != 0) {
            ImGui::SameLine();
            if (ImGui::Button("Revert")) style.Colors[i] = ref ? ref->Colors[i] : def.Colors[i];
            if (ref) {
                ImGui::SameLine();
                if (ImGui::Button("Save")) ref->Colors[i] = style.Colors[i];
            }
        }
        ImGui::PopID();
    }
}

//-----------------------------------------------------------------------------
// SAMPLE CODE
//-----------------------------------------------------------------------------

// Demonstrate ImGui features (unfortunately this makes this function a little bloated!)
void ShowTestWindow(bool *open) {
    static bool no_titlebar = false;
    static bool no_border = true;
    static bool no_resize = false;
    static bool no_move = false;
    static bool no_scrollbar = false;
    static float fill_alpha = 0.65f;

    const ImU32 layout_flags =
            (no_titlebar ? ImGuiWindowFlags_NoTitleBar : 0) | (no_border ? 0 : ImGuiWindowFlags_ShowBorders) |
            (no_resize ? ImGuiWindowFlags_NoResize : 0) | (no_move ? ImGuiWindowFlags_NoMove : 0) |
            (no_scrollbar ? ImGuiWindowFlags_NoScrollbar : 0);
    ImGui::Begin("ImGui Test", open, ImVec2(550, 680), fill_alpha, layout_flags);
    ImGui::PushItemWidth(ImGui::GetWindowWidth() * 0.65f);

    ImGui::Text("ImGui says hello.");
    //ImGui::Text("MousePos (%g, %g)", g.IO.MousePos.x, g.IO.MousePos.y);
    //ImGui::Text("MouseWheel %d", g.IO.MouseWheel);

    ImGui::Spacing();
    if (ImGui::CollapsingHeader("Help")) {
        ImGui::ShowUserGuide();
    }

    if (ImGui::CollapsingHeader("Window options")) {
        ImGui::Checkbox("no titlebar", &no_titlebar);
        ImGui::SameLine(200);
        ImGui::Checkbox("no border", &no_border);
        ImGui::SameLine(400);
        ImGui::Checkbox("no resize", &no_resize);
        ImGui::Checkbox("no move", &no_move);
        ImGui::SameLine(200);
        ImGui::Checkbox("no scrollbar", &no_scrollbar);
        ImGui::SliderFloat("fill alpha", &fill_alpha, 0.0f, 1.0f);
        if (ImGui::TreeNode("Style Editor")) {
            ImGui::ShowStyleEditor();
            ImGui::TreePop();
        }

        if (ImGui::TreeNode("Logging")) {
            ImGui::LogButtons();
            ImGui::TreePop();
        }
    }

    if (ImGui::CollapsingHeader("Widgets")) {
        //ImGui::PushItemWidth(ImGui::GetWindowWidth() - 220);

        static bool a = false;
        if (ImGui::Button("Button")) {
            printf("Clicked\n");
            a ^= 1;
        }
        if (a) {
            ImGui::SameLine();
            ImGui::Text("Thanks for clicking me!");
        }

        static bool check = true;
        ImGui::Checkbox("checkbox", &check);

        if (ImGui::TreeNode("Tree")) {
            for (size_t i = 0; i < 5; i++) {
                if (ImGui::TreeNode((void *) i, "Child %d", i)) {
                    ImGui::Text("blah blah");
                    ImGui::SameLine();
                    if (ImGui::SmallButton("print"))
                        printf("Child %d pressed", (int) i);
                    ImGui::TreePop();
                }
            }
            ImGui::TreePop();
        }

        if (ImGui::TreeNode("Bullets")) {
            ImGui::BulletText("Bullet point 1");
            ImGui::BulletText("Bullet point 2\nOn multiple lines");
            ImGui::BulletText("Bullet point 3");
            ImGui::TreePop();
        }

        static int e = 0;
        ImGui::RadioButton("radio a", &e, 0);
        ImGui::SameLine();
        ImGui::RadioButton("radio b", &e, 1);
        ImGui::SameLine();
        ImGui::RadioButton("radio c", &e, 2);

        ImGui::Text("Hover me");
        if (ImGui::IsHovered())
            ImGui::SetTooltip("I am a tooltip");

        static int item = 1;
        ImGui::Combo("combo", &item, "aaaa\0bbbb\0cccc\0dddd\0eeee\0\0");

        const char *items[] = {"AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "GGGG", "HHHH", "IIII", "JJJJ", "KKKK"};
        static int item2 = -1;
        ImGui::Combo("combo scroll", &item2, items, ARRAYSIZE(items));

        static char str0[128] = "Hello, world!";
        static int i0 = 123;
        static float f0 = 0.001f;
        ImGui::InputText("string", str0, ARRAYSIZE(str0));
        ImGui::InputInt("input int", &i0);
        ImGui::InputFloat("input float", &f0, 0.01f, 1.0f);

        static float vec3b[3] = {0.10f, 0.20f, 0.30f};
        ImGui::InputFloat3("input float3", vec3b);

        static int i1 = 0;
        static int i2 = 42;
        ImGui::SliderInt("int 0..3", &i1, 0, 3);
        ImGui::SliderInt("int -100..100", &i2, -100, 100);

        static float f1 = 1.123f;
        static float f2 = 0;
        static float f3 = 0;
        static float f4 = 123456789.0f;
        ImGui::SliderFloat("float", &f1, 0.0f, 2.0f);
        ImGui::SliderFloat("log float", &f2, 0.0f, 10.0f, "%.4f", 2.0f);
        ImGui::SliderFloat("signed log float", &f3, -10.0f, 10.0f, "%.4f", 3.0f);
        ImGui::SliderFloat("unbound float", &f4, -FLT_MAX, FLT_MAX, "%.4f", 3.0f);
        static float angle = 0.0f;
        ImGui::SliderAngle("angle", &angle);

        static float vec3a[3] = {0.10f, 0.20f, 0.30f};
        ImGui::SliderFloat3("slider float3", vec3a, 0.0f, 1.0f);

        static float col1[3] = {1.0f, 0.0f, 0.2f};
        static float col2[4] = {0.4f, 0.7f, 0.0f, 0.5f};
        ImGui::ColorEdit3("color 1", col1);
        ImGui::ColorEdit4("color 2", col2);

        //ImGui::PopItemWidth();
    }

    if (ImGui::CollapsingHeader("Graphs widgets")) {
        static float arr[] = {0.6f, 0.1f, 1.0f, 0.5f, 0.92f, 0.1f, 0.2f};
        ImGui::PlotLines("Frame Times", arr, ARRAYSIZE(arr));

        static bool pause;
        static ImVector<float> values;
        if (values.empty()) {
            values.resize(100);
            memset(&values.front(), 0, values.size() * sizeof(float));
        }
        static int values_offset = 0;
        if (!pause) {
            // create dummy data at 60 hz
            static float refresh_time = -1.0f;
            if (ImGui::GetTime() > refresh_time + 1.0f / 60.0f) {
                refresh_time = ImGui::GetTime();
                static float phase = 0.0f;
                values[values_offset] = cos(phase);
                values_offset = (values_offset + 1) % values.size();
                phase += 0.10f * values_offset;
            }
        }
        ImGui::PlotLines("Frame Times", &values.front(), values.size(), values_offset, "avg 0.0", -1.0f, 1.0f,
                         ImVec2(0, 70));

        ImGui::SameLine();
        ImGui::Checkbox("pause", &pause);
        ImGui::PlotHistogram("Histogram", arr, ARRAYSIZE(arr), 0, NULL, 0.0f, 1.0f, ImVec2(0, 70));
    }

    if (ImGui::CollapsingHeader("Widgets on same line")) {
        // Text
        ImGui::Text("Hello");
        ImGui::SameLine();
        ImGui::Text("World");

        // Button
        if (ImGui::Button("Banana")) printf("Pressed!\n");
        ImGui::SameLine();
        ImGui::Button("Apple");
        ImGui::SameLine();
        ImGui::Button("Corniflower");

        // Button
        ImGui::SmallButton("Banana");
        ImGui::SameLine();
        ImGui::SmallButton("Apple");
        ImGui::SameLine();
        ImGui::SmallButton("Corniflower");
        ImGui::SameLine();
        ImGui::Text("Small buttons fit in a text block");

        // Checkbox
        static bool c1 = false, c2 = false, c3 = false, c4 = false;
        ImGui::Checkbox("My", &c1);
        ImGui::SameLine();
        ImGui::Checkbox("Tailor", &c2);
        ImGui::SameLine();
        ImGui::Checkbox("Is", &c3);
        ImGui::SameLine();
        ImGui::Checkbox("Rich", &c4);

        // SliderFloat
        static float f0 = 1.0f, f1 = 2.0f, f2 = 3.0f;
        ImGui::PushItemWidth(80);
        ImGui::SliderFloat("f0", &f0, 0.0f, 5.0f);
        ImGui::SameLine();
        ImGui::SliderFloat("f1", &f1, 0.0f, 5.0f);
        ImGui::SameLine();
        ImGui::SliderFloat("f2", &f2, 0.0f, 5.0f);

        // InputText
        static char s0[128] = "one", s1[128] = "two", s2[128] = "three";
        ImGui::InputText("s0", s0, 128);
        ImGui::SameLine();
        ImGui::InputText("s1", s1, 128);
        ImGui::SameLine();
        ImGui::InputText("s2", s2, 128);

        // LabelText
        ImGui::LabelText("l0", "one");
        ImGui::SameLine();
        ImGui::LabelText("l0", "two");
        ImGui::SameLine();
        ImGui::LabelText("l0", "three");
        ImGui::PopItemWidth();
    }

    if (ImGui::CollapsingHeader("Child regions")) {
        ImGui::Text("Without border");
        static int line = 50;
        bool goto_line = ImGui::Button("Goto");
        ImGui::SameLine();
        ImGui::PushItemWidth(100);
        ImGui::InputInt("##Line", &line, 0);
        ImGui::PopItemWidth();
        ImGui::BeginChild("Sub1", ImVec2(ImGui::GetWindowWidth() * 0.5f, 300));
        for (int i = 0; i < 100; i++) {
            ImGui::Text("%04d: scrollable region", i);
            if (goto_line && line == i)
                ImGui::SetScrollPosHere();
        }
        if (goto_line && line >= 100)
            ImGui::SetScrollPosHere();
        ImGui::EndChild();

        ImGui::SameLine();

        ImGui::BeginChild("Sub2", ImVec2(0, 300), true);
        ImGui::Text("With border");
        ImGui::Columns(2);
        for (int i = 0; i < 100; i++) {
            char buf[32];
            ImFormatString(buf, ARRAYSIZE(buf), "%08x", i * 5731);
            ImGui::Button(buf);
            ImGui::NextColumn();
        }
        ImGui::EndChild();
    }

    if (ImGui::CollapsingHeader("Columns")) {
        ImGui::Columns(4, "data", true);
        ImGui::Text("ID");
        ImGui::NextColumn();
        ImGui::Text("Name");
        ImGui::NextColumn();
        ImGui::Text("Path");
        ImGui::NextColumn();
        ImGui::Text("Flags");
        ImGui::NextColumn();
        ImGui::Separator();

        ImGui::Text("0000");
        ImGui::NextColumn();
        ImGui::Text("Robert");
        ImGui::NextColumn();
        ImGui::Text("/path/robert");
        ImGui::NextColumn();
        ImGui::Text("....");
        ImGui::NextColumn();

        ImGui::Text("0001");
        ImGui::NextColumn();
        ImGui::Text("Stephanie");
        ImGui::NextColumn();
        ImGui::Text("/path/stephanie");
        ImGui::NextColumn();
        ImGui::Text("....");
        ImGui::NextColumn();

        ImGui::Text("0002");
        ImGui::NextColumn();
        ImGui::Text("C64");
        ImGui::NextColumn();
        ImGui::Text("/path/computer");
        ImGui::NextColumn();
        ImGui::Text("....");
        ImGui::NextColumn();
        ImGui::Columns(1);

        ImGui::Separator();

        ImGui::Columns(3, "mixed");
        ImGui::Text("Hello");
        ImGui::NextColumn();
        ImGui::Text("World");
        ImGui::NextColumn();
        ImGui::Text("Hmm...");
        ImGui::NextColumn();

        ImGui::Button("Banana");
        ImGui::NextColumn();
        ImGui::Button("Apple");
        ImGui::NextColumn();
        ImGui::Button("Corniflower");
        ImGui::NextColumn();

        static int e = 0;
        ImGui::RadioButton("radio a", &e, 0);
        ImGui::NextColumn();
        ImGui::RadioButton("radio b", &e, 1);
        ImGui::NextColumn();
        ImGui::RadioButton("radio c", &e, 2);
        ImGui::NextColumn();
        ImGui::Columns(1);

        ImGui::Separator();

        ImGui::Columns(2, "multiple components");
        static float foo = 1.0f;
        ImGui::InputFloat("red", &foo, 0.05f, 0, 3);
        ImGui::NextColumn();
        static float bar = 1.0f;
        ImGui::InputFloat("blue", &foo, 0.05f, 0, 3);
        ImGui::NextColumn();
        ImGui::Columns(1);

        ImGui::Separator();

        if (ImGui::TreeNode("Inside a tree..")) {
            if (ImGui::TreeNode("node 1 (with borders)")) {
                ImGui::Columns(4);
                ImGui::Text("aaa");
                ImGui::NextColumn();
                ImGui::Text("bbb");
                ImGui::NextColumn();
                ImGui::Text("ccc");
                ImGui::NextColumn();
                ImGui::Text("ddd");
                ImGui::NextColumn();
                ImGui::Text("eee");
                ImGui::NextColumn();
                ImGui::Text("fff");
                ImGui::NextColumn();
                ImGui::Text("ggg");
                ImGui::NextColumn();
                ImGui::Text("hhh");
                ImGui::NextColumn();
                ImGui::Columns(1);
                ImGui::TreePop();
            }
            if (ImGui::TreeNode("node 2 (without borders)")) {
                ImGui::Columns(4, NULL, false);
                ImGui::Text("aaa");
                ImGui::NextColumn();
                ImGui::Text("bbb");
                ImGui::NextColumn();
                ImGui::Text("ccc");
                ImGui::NextColumn();
                ImGui::Text("ddd");
                ImGui::NextColumn();
                ImGui::Text("eee");
                ImGui::NextColumn();
                ImGui::Text("fff");
                ImGui::NextColumn();
                ImGui::Text("ggg");
                ImGui::NextColumn();
                ImGui::Text("hhh");
                ImGui::NextColumn();
                ImGui::Columns(1);
                ImGui::TreePop();
            }
            ImGui::TreePop();
        }
    }

    if (ImGui::CollapsingHeader("Filtering")) {
        static ImGuiTextFilter filter;
        filter.Draw();
        const char *lines[] = {"aaa1.c", "bbb1.c", "ccc1.c", "aaa2.cpp", "bbb2.cpp", "ccc2.cpp", "abc.h",
                               "hello, world"};
        for (size_t i = 0; i < ARRAYSIZE(lines); i++)
            if (filter.PassFilter(lines[i]))
                ImGui::BulletText("%s", lines[i]);
    }

    if (ImGui::CollapsingHeader("Long text")) {
        static ImGuiTextBuffer log;
        static int lines = 0;
        ImGui::Text("Printing unusually long amount of text.");
        ImGui::Text("Buffer contents: %d lines, %d bytes", lines, log.size());
        if (ImGui::Button("Clear")) {
            log.clear();
            lines = 0;
        }
        ImGui::SameLine();
        if (ImGui::Button("Add 1000 lines")) {
            for (size_t i = 0; i < 1000; i++)
                log.Append("%i The quick brown fox jumps over the lazy dog\n", lines + i);
            lines += 1000;
        }
        ImGui::BeginChild("Log");
        ImGui::TextUnformatted(log.begin(), log.end());
        ImGui::EndChild();
    }

    ImGui::End();
}
// End of Sample code

}; // namespace ImGui
