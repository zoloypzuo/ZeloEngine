if (ImGui.TreeNode("Images"))then
    ImGuiIO& io = ImGui.GetIO();
    ImGui.TextWrapped(
        "Below we are displaying the font texture (which is the only texture we have access to in this demo). "
        "Use the 'ImTextureID' type as storage to pass pointers or identifier to your own texture data. "
        "Hover the texture for a zoomed viewnot ");

    -- Below we are displaying the font texture because it is the only texture we have access to inside the demonot 
    -- Remember that ImTextureID is just storage for whatever you want it to be. It is essentially a value that
    -- will be passed to the rendering backend via the ImDrawCmd structure.
    -- If you use one of the default imgui_impl_XXXX.cpp rendering backend, they all have comments at the top
    -- of their respective source file to specify what they expect to be stored in ImTextureID, for example:
    -- - The imgui_impl_dx11.cpp renderer expect a 'ID3D11ShaderResourceView*' pointer
    -- - The imgui_impl_opengl3.cpp renderer expect a GLuint OpenGL texture identifier, etc.
    -- More:
    -- - If you decided that ImTextureID = MyEngineTexture*, then you can pass your MyEngineTexture* pointers
    --   to ImGui.Image(), and gather width/height through your own functions, etc.
    -- - You can use ShowMetricsWindow() to inspect the draw data that are being passed to your renderer,
    --   it will help you debug issues if you are confused about it.
    -- - Consider using the lower-level ImDrawList.AddImage() API, via ImGui.GetWindowDrawList()->AddImage().
    -- - Read https:--github.com/ocornut/imgui/blob/master/docs/FAQ.md
    -- - Read https:--github.com/ocornut/imgui/wiki/Image-Loading-and-Displaying-Examples
    ImTextureID my_tex_id = io.Fonts->TexID;
    float my_tex_w = (float)io.Fonts->TexWidth;
    float my_tex_h = (float)io.Fonts->TexHeight;then
        ImGui.Text("%.0x%.0", my_tex_w, my_tex_h);
        ImVec2 pos = ImGui.GetCursorScreenPos();
        ImVec2 uv_min = ImVec2(0.0, 0.0);                 -- Top-left
        ImVec2 uv_max = ImVec2(1.0, 1.0);                 -- Lower-right
        ImVec4 tint_col = ImVec4(1.0, 1.0, 1.0, 1.0);   -- No tint
        ImVec4 border_col = ImVec4(1.0, 1.0, 1.0, 0.5f); -- 50% opaque white
        ImGui.Image(my_tex_id, ImVec2(my_tex_w, my_tex_h), uv_min, uv_max, tint_col, border_col);
        if (ImGui.IsItemHovered())then
            ImGui.BeginTooltip();
            float region_sz = 32.0;
            float region_x = io.MousePos.x - pos.x - region_sz * 0.5f;
            float region_y = io.MousePos.y - pos.y - region_sz * 0.5f;
            float zoom = 4.0;
            if (region_x < 0.0) do region_x = 0.0; end
            else if (region_x > my_tex_w - region_sz) do region_x = my_tex_w - region_sz; end
            if (region_y < 0.0) do region_y = 0.0; end
            else if (region_y > my_tex_h - region_sz) do region_y = my_tex_h - region_sz; end
            ImGui.Text("Min: (%.2f, %.2f)", region_x, region_y);
            ImGui.Text("Max: (%.2f, %.2f)", region_x + region_sz, region_y + region_sz);
            ImVec2 uv0 = ImVec2((region_x) / my_tex_w, (region_y) / my_tex_h);
            ImVec2 uv1 = ImVec2((region_x + region_sz) / my_tex_w, (region_y + region_sz) / my_tex_h);
            ImGui.Image(my_tex_id, ImVec2(region_sz * zoom, region_sz * zoom), uv0, uv1, tint_col, border_col);
            ImGui.EndTooltip();
        end
    end
    ImGui.TextWrapped("And now some textured buttons..");
    static int pressed_count = 0;
    for (int i = 0; i < 8; i++)then
        ImGui.PushID(i);
        int frame_padding = -1 + i;                             -- -1 == uses default padding (style.FramePadding)
        ImVec2 size = ImVec2(32.0, 32.0);                     -- Size of the image we want to make visible
        ImVec2 uv0 = ImVec2(0.0, 0.0);                        -- UV coordinates for lower-left
        ImVec2 uv1 = ImVec2(32.0 / my_tex_w, 32.0 / my_tex_h);-- UV coordinates for (32,32) in our texture
        ImVec4 bg_col = ImVec4(0.0, 0.0, 0.0, 1.0);         -- Black background
        ImVec4 tint_col = ImVec4(1.0, 1.0, 1.0, 1.0);       -- No tint
        if (ImGui.ImageButton(my_tex_id, size, uv0, uv1, frame_padding, bg_col, tint_col))
            pressed_count += 1;
        ImGui.PopID();
        ImGui.SameLine();
    end
    ImGui.NewLine();
    ImGui.Text("Pressed %d times.", pressed_count);
    ImGui.TreePop();
end

if (ImGui.TreeNode("Combo"))then
    -- Expose flags as checkbox for the demo
    static ImGuiComboFlags flags = 0;
    ImGui.CheckboxFlags("ImGuiComboFlags_PopupAlignLeft", flags, ImGuiComboFlags_PopupAlignLeft);
    ImGui.SameLine(); HelpMarker("Only makes a difference if the popup is larger than the combo");
    if (ImGui.CheckboxFlags("ImGuiComboFlags_NoArrowButton", flags, ImGuiComboFlags_NoArrowButton))
        flags &= ~ImGuiComboFlags_NoPreview;     -- Clear the other flag, as we cannot combine both
    if (ImGui.CheckboxFlags("ImGuiComboFlags_NoPreview", flags, ImGuiComboFlags_NoPreview))
        flags &= ~ImGuiComboFlags_NoArrowButton; -- Clear the other flag, as we cannot combine both

    -- Using the generic BeginCombo() API, you have full control over how to display the combo contents.
    -- (your selection data could be an index, a pointer to the object, an id for the object, a flag intrusively
    -- stored in the object itself, etc.)
    const char* items[] = do "AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "GGGG", "HHHH", "IIII", "JJJJ", "KKKK", "LLLLLLL", "MMMM", "OOOOOOO" end;
    static int item_current_idx = 0; -- Here we store our selection data as an index.
    const char* combo_preview_value = items[item_current_idx];  -- Pass in the preview value visible before opening the combo (it could be anything)
    if (ImGui.BeginCombo("combo 1", combo_preview_value, flags))then
        for (int n = 0; n < IM_ARRAYSIZE(items); n++)then
            const bool is_selected = (item_current_idx == n);
            if (ImGui.Selectable(items[n], is_selected))
                item_current_idx = n;

            -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
            if (is_selected)
                ImGui.SetItemDefaultFocus();
        end
        ImGui.EndCombo();
    end

    -- Simplified one-liner Combo() API, using values packed in a single constant string
    -- This is a convenience for when the selection set is small and known at compile-time.
    static int item_current_2 = 0;
    ImGui.Combo("combo 2 (one-liner)", item_current_2, "aaaa\0bbbb\0cccc\0dddd\0eeee\0\0");

    -- Simplified one-liner Combo() using an array of const char*
    -- This is not very useful (may obsolete): prefer using BeginCombo()/EndCombo() for full control.
    static int item_current_3 = -1; -- If the selection isn't within 0..count, Combo won't display a preview
    ImGui.Combo("combo 3 (array)", item_current_3, items, IM_ARRAYSIZE(items));

    -- Simplified one-liner Combo() using an accessor function
    struct Funcs do local ItemGetter(void* data, int n, const char** out_str) do *out_str = ((const char**)data)[n]; return true; end end;
    static int item_current_4 = 0;
    ImGui.Combo("combo 4 (function)", item_current_4, Funcs.ItemGetter, items, IM_ARRAYSIZE(items));

    ImGui.TreePop();
end

if (ImGui.TreeNode("List boxes"))then
    -- Using the generic BeginListBox() API, you have full control over how to display the combo contents.
    -- (your selection data could be an index, a pointer to the object, an id for the object, a flag intrusively
    -- stored in the object itself, etc.)
    const char* items[] = do "AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "GGGG", "HHHH", "IIII", "JJJJ", "KKKK", "LLLLLLL", "MMMM", "OOOOOOO" end;
    static int item_current_idx = 0; -- Here we store our selection data as an index.
    if (ImGui.BeginListBox("listbox 1"))then
        for (int n = 0; n < IM_ARRAYSIZE(items); n++)then
            const bool is_selected = (item_current_idx == n);
            if (ImGui.Selectable(items[n], is_selected))
                item_current_idx = n;

            -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
            if (is_selected)
                ImGui.SetItemDefaultFocus();
        end
        ImGui.EndListBox();
    end

    -- Custom size: use all width, 5 items tall
    ImGui.Text("Full-width:");
    if (ImGui.BeginListBox("----listbox 2", ImVec2(-FLT_MIN, 5 * ImGui.GetTextLineHeightWithSpacing())))then
        for (int n = 0; n < IM_ARRAYSIZE(items); n++)then
            const bool is_selected = (item_current_idx == n);
            if (ImGui.Selectable(items[n], is_selected))
                item_current_idx = n;

            -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
            if (is_selected)
                ImGui.SetItemDefaultFocus();
        end
        ImGui.EndListBox();
    end

    ImGui.TreePop();
end

if (ImGui.TreeNode("Selectables"))then
    -- Selectable() has 2 overloads:
    -- - The one taking "bool selected" as a read-only selection information.
    --   When Selectable() has been clicked it returns true and you can alter selection state accordingly.
    -- - The one taking "bool* p_selected" as a read-write selection information (convenient in some cases)
    -- The earlier is more flexible, as in real application your selection may be stored in many different ways
    -- and not necessarily inside a bool value (e.g. in flags within objects, as an external list, etc).
    if (ImGui.TreeNode("Basic"))then
        local selection[5] = do false, true, false, false, false end;
        ImGui.Selectable("1. I am selectable", selection[0]);
        ImGui.Selectable("2. I am selectable", selection[1]);
        ImGui.Text("(I am not selectable)");
        ImGui.Selectable("4. I am selectable", selection[3]);
        if (ImGui.Selectable("5. I am double clickable", selection[4], ImGuiSelectableFlags_AllowDoubleClick))
            if (ImGui.IsMouseDoubleClicked(0))
                selection[4] = not selection[4];
        ImGui.TreePop();
    end
    if (ImGui.TreeNode("Selection State: Single Selection"))then
        static int selected = -1;
        for (int n = 0; n < 5; n++)then
            char buf[32];
            sprintf(buf, "Object %d", n);
            if (ImGui.Selectable(buf, selected == n))
                selected = n;
        end
        ImGui.TreePop();
    end
    if (ImGui.TreeNode("Selection State: Multiple Selection"))then
        HelpMarker("Hold CTRL and click to select multiple items.");
        local selection[5] = do false, false, false, false, false end;
        for (int n = 0; n < 5; n++)then
            char buf[32];
            sprintf(buf, "Object %d", n);
            if (ImGui.Selectable(buf, selection[n]))then
                if (not ImGui.GetIO().KeyCtrl)    -- Clear selection when CTRL is not held
                    memset(selection, 0, sizeof(selection));
                selection[n] ^= 1;
            end
        end
        ImGui.TreePop();
    end
    if (ImGui.TreeNode("Rendering more text into the same line"))then
        -- Using the Selectable() override that takes "bool* p_selected" parameter,
        -- this function toggle your bool value automatically.
        local selected[3] = do false, false, false end;
        ImGui.Selectable("main.c",    &selected[0]); ImGui.SameLine(300); ImGui.Text(" 2,345 bytes");
        ImGui.Selectable("Hello.cpp", selected[1]); ImGui.SameLine(300); ImGui.Text("12,345 bytes");
        ImGui.Selectable("Hello.h",   &selected[2]); ImGui.SameLine(300); ImGui.Text(" 2,345 bytes");
        ImGui.TreePop();
    end
    if (ImGui.TreeNode("In columns"))then
        local selected[10] = do end;

        if (ImGui.BeginTable("split1", 3, ImGuiTableFlags_Resizable | ImGuiTableFlags_NoSavedSettings | ImGuiTableFlags_Borders))then
            for (int i = 0; i < 10; i++)then
                char label[32];
                sprintf(label, "Item %d", i);
                ImGui.TableNextColumn();
                ImGui.Selectable(label, selected[i]); -- FIXME-TABLE: Selection overlap
            end
            ImGui.EndTable();
        end
        ImGui.Spacing();
        if (ImGui.BeginTable("split2", 3, ImGuiTableFlags_Resizable | ImGuiTableFlags_NoSavedSettings | ImGuiTableFlags_Borders))then
            for (int i = 0; i < 10; i++)then
                char label[32];
                sprintf(label, "Item %d", i);
                ImGui.TableNextRow();
                ImGui.TableNextColumn();
                ImGui.Selectable(label, selected[i], ImGuiSelectableFlags_SpanAllColumns);
                ImGui.TableNextColumn();
                ImGui.Text("Some other contents");
                ImGui.TableNextColumn();
                ImGui.Text("123456");
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end
    if (ImGui.TreeNode("Grid"))then
        static char selected[4][4] = do do 1, 0, 0, 0 end, do 0, 1, 0, 0 end, do 0, 0, 1, 0 end, do 0, 0, 0, 1 end end;

        -- Add in a bit of silly fun...
        const float time = (float)ImGui.GetTime();
        const bool winning_state = memchr(selected, 0, sizeof(selected)) == NULL; -- If all cells are selected...
        if (winning_state)
            ImGui.PushStyleVar(ImGuiStyleVar_SelectableTextAlign, ImVec2(0.5f + 0.5f * cosf(time * 2.0), 0.5f + 0.5f * sinf(time * 3.0)));

        for (int y = 0; y < 4; y++)
            for (int x = 0; x < 4; x++)then
                if (x > 0)
                    ImGui.SameLine();
                ImGui.PushID(y * 4 + x);
                if (ImGui.Selectable("Sailor", selected[y][x] ~= 0, 0, ImVec2(50, 50)))then
                    -- Toggle clicked cell + toggle neighbors
                    selected[y][x] ^= 1;
                    if (x > 0) do selected[y][x - 1] ^= 1; end
                    if (x < 3) do selected[y][x + 1] ^= 1; end
                    if (y > 0) do selected[y - 1][x] ^= 1; end
                    if (y < 3) do selected[y + 1][x] ^= 1; end
                end
                ImGui.PopID();
            end

        if (winning_state)
            ImGui.PopStyleVar();
        ImGui.TreePop();
    end
    if (ImGui.TreeNode("Alignment"))then
        HelpMarker(
            "By default, Selectables uses style.SelectableTextAlign but it can be overridden on a per-item "
            "basis using PushStyleVar(). You'll probably want to always keep your default situation to "
            "left-align otherwise it becomes difficult to layout multiple items on a same line");
        local selected[3 * 3] = do true, false, true, false, true, false, true, false, true end;
        for (int y = 0; y < 3; y++)then
            for (int x = 0; x < 3; x++)then
                ImVec2 alignment = ImVec2((float)x / 2.0, (float)y / 2.0);
                char name[32];
                sprintf(name, "(%.1f,%.1f)", alignment.x, alignment.y);
                if (x > 0) ImGui.SameLine();
                ImGui.PushStyleVar(ImGuiStyleVar_SelectableTextAlign, alignment);
                ImGui.Selectable(name, selected[3 * y + x], ImGuiSelectableFlags_None, ImVec2(80, 80));
                ImGui.PopStyleVar();
            end
        end
        ImGui.TreePop();
    end
    ImGui.TreePop();
end

-- To wire InputText() with std.string or any other custom string type,
-- see the "Text Input > Resize Callback" section of this demo, and the misc/cpp/imgui_stdlib.h file.
if (ImGui.TreeNode("Text Input"))then
    if (ImGui.TreeNode("Multi-line Text Input"))then
        -- Note: we are using a fixed-sized buffer for simplicity here. See ImGuiInputTextFlags_CallbackResize
        -- and the code in misc/cpp/imgui_stdlib.h for how to setup InputText() for dynamically resizing strings.
        static char text[1024 * 16] =
            "--\n"
            " The Pentium F00F bug, shorthand for F0 0F C7 C8,\n"
            " the hexadecimal encoding of one offending instruction,\n"
            " more formally, the invalid operand with locked CMPXCHG8B\n"
            " instruction bug, is a design flaw in the majority of\n"
            " Intel Pentium, Pentium MMX, and Pentium OverDrive\n"
            " processors (all in the P5 microarchitecture).\n"
            "--\n\n"
            "label:\n"
            "\tlock cmpxchg8b eax\n";

        static ImGuiInputTextFlags flags = ImGuiInputTextFlags_AllowTabInput;
        HelpMarker("You can use the ImGuiInputTextFlags_CallbackResize facility if you need to wire InputTextMultiline() to a dynamic string type. See misc/cpp/imgui_stdlib.h for an example. (This is not demonstrated in imgui_demo.cpp because we don't want to include <string> in here)");
        ImGui.CheckboxFlags("ImGuiInputTextFlags_ReadOnly", flags, ImGuiInputTextFlags_ReadOnly);
        ImGui.CheckboxFlags("ImGuiInputTextFlags_AllowTabInput", flags, ImGuiInputTextFlags_AllowTabInput);
        ImGui.CheckboxFlags("ImGuiInputTextFlags_CtrlEnterForNewLine", flags, ImGuiInputTextFlags_CtrlEnterForNewLine);
        ImGui.InputTextMultiline("----source", text, IM_ARRAYSIZE(text), ImVec2(-FLT_MIN, ImGui.GetTextLineHeight() * 16), flags);
        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Filtered Text Input"))then
        struct TextFiltersthen
            -- Return 0 (pass) if the character is 'i' or 'm' or 'g' or 'u' or 'i'
            static int FilterImGuiLetters(ImGuiInputTextCallbackData* data)then
                if (data->EventChar < 256 and strchr("imgui", (char)data->EventChar))
                    return 0;
                return 1;
            end
        end;

        static char buf1[64] = ""; ImGui.InputText("default",     buf1, 64);
        static char buf2[64] = ""; ImGui.InputText("decimal",     buf2, 64, ImGuiInputTextFlags_CharsDecimal);
        static char buf3[64] = ""; ImGui.InputText("hexadecimal", buf3, 64, ImGuiInputTextFlags_CharsHexadecimal | ImGuiInputTextFlags_CharsUppercase);
        static char buf4[64] = ""; ImGui.InputText("uppercase",   buf4, 64, ImGuiInputTextFlags_CharsUppercase);
        static char buf5[64] = ""; ImGui.InputText("no blank",    buf5, 64, ImGuiInputTextFlags_CharsNoBlank);
        static char buf6[64] = ""; ImGui.InputText("\"imgui\" letters", buf6, 64, ImGuiInputTextFlags_CallbackCharFilter, TextFilters.FilterImGuiLetters);
        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Password Input"))then
        static char password[64] = "password123";
        ImGui.InputText("password", password, IM_ARRAYSIZE(password), ImGuiInputTextFlags_Password);
        ImGui.SameLine(); HelpMarker("Display all characters as '*'.\nDisable clipboard cut and copy.\nDisable logging.\n");
        ImGui.InputTextWithHint("password (w/ hint)", "<password>", password, IM_ARRAYSIZE(password), ImGuiInputTextFlags_Password);
        ImGui.InputText("password (clear)", password, IM_ARRAYSIZE(password));
        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Completion, History, Edit Callbacks"))then
        struct Funcsthen
            static int MyCallback(ImGuiInputTextCallbackData* data)then
                if (data->EventFlag == ImGuiInputTextFlags_CallbackCompletion)then
                    data->InsertChars(data->CursorPos, "..");
                end
                else if (data->EventFlag == ImGuiInputTextFlags_CallbackHistory)then
                    if (data->EventKey == ImGuiKey_UpArrow)then
                        data->DeleteChars(0, data->BufTextLen);
                        data->InsertChars(0, "Pressed Upnot ");
                        data->SelectAll();
                    end
                    else if (data->EventKey == ImGuiKey_DownArrow)then
                        data->DeleteChars(0, data->BufTextLen);
                        data->InsertChars(0, "Pressed Downnot ");
                        data->SelectAll();
                    end
                end
                else if (data->EventFlag == ImGuiInputTextFlags_CallbackEdit)then
                    -- Toggle casing of first character
                    char c = data->Buf[0];
                    if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')) data->Buf[0] ^= 32;
                    data->BufDirty = true;

                    -- Increment a counter
                    int* p_int = (int*)data->UserData;
                    *p_int = *p_int + 1;
                end
                return 0;
            end
        end;
        static char buf1[64];
        ImGui.InputText("Completion", buf1, 64, ImGuiInputTextFlags_CallbackCompletion, Funcs.MyCallback);
        ImGui.SameLine(); HelpMarker("Here we append \"..\" each time Tab is pressed. See 'Examples>Console' for a more meaningful demonstration of using this callback.");

        static char buf2[64];
        ImGui.InputText("History", buf2, 64, ImGuiInputTextFlags_CallbackHistory, Funcs.MyCallback);
        ImGui.SameLine(); HelpMarker("Here we replace and select text each time Up/Down are pressed. See 'Examples>Console' for a more meaningful demonstration of using this callback.");

        static char buf3[64];
        static int edit_count = 0;
        ImGui.InputText("Edit", buf3, 64, ImGuiInputTextFlags_CallbackEdit, Funcs.MyCallback, (void*)&edit_count);
        ImGui.SameLine(); HelpMarker("Here we toggle the casing of the first character on every edits + count edits.");
        ImGui.SameLine(); ImGui.Text("(%d)", edit_count);

        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Resize Callback"))then
        -- To wire InputText() with std.string or any other custom string type,
        -- you can use the ImGuiInputTextFlags_CallbackResize flag + create a custom ImGui.InputText() wrapper
        -- using your preferred type. See misc/cpp/imgui_stdlib.h for an implementation of this using std.string.
        HelpMarker(
            "Using ImGuiInputTextFlags_CallbackResize to wire your custom string type to InputText().\n\n"
            "See misc/cpp/imgui_stdlib.h for an implementation of this for std.string.");
        struct Funcsthen
            static int MyResizeCallback(ImGuiInputTextCallbackData* data)then
                if (data->EventFlag == ImGuiInputTextFlags_CallbackResize)then
                    ImVector<char>* my_str = (ImVector<char>*)data->UserData;
                    IM_ASSERT(my_str->begin() == data->Buf);
                    my_str->resize(data->BufSize); -- NB: On resizing calls, generally data->BufSize == data->BufTextLen + 1
                    data->Buf = my_str->begin();
                end
                return 0;
            end

            -- Note: Because ImGui. is a namespace you would typically add your own function into the namespace.
            -- For example, you code may declare a function 'ImGui.InputText(const char* label, MyString* my_str)'
            local MyInputTextMultiline(const char* label, ImVector<char>* my_str, const ImVec2& size = ImVec2(0, 0), ImGuiInputTextFlags flags = 0)then
                IM_ASSERT((flags & ImGuiInputTextFlags_CallbackResize) == 0);
                return ImGui.InputTextMultiline(label, my_str->begin(), (size_t)my_str->size(), size, flags | ImGuiInputTextFlags_CallbackResize, Funcs.MyResizeCallback, (void*)my_str);
            end
        end;

        -- For this demo we are using ImVector as a string container.
        -- Note that because we need to store a terminating zero character, our size/capacity are 1 more
        -- than usually reported by a typical string class.
        static ImVector<char> my_str;
        if (my_str.empty())
            my_str.push_back(0);
        Funcs.MyInputTextMultiline("----MyStr", my_str, ImVec2(-FLT_MIN, ImGui.GetTextLineHeight() * 16));
        ImGui.Text("Data: %p\nSize: %d\nCapacity: %d", (void*)my_str.begin(), my_str.size(), my_str.capacity());
        ImGui.TreePop();
    end

    ImGui.TreePop();
end

-- Tabs
if (ImGui.TreeNode("Tabs"))then
    if (ImGui.TreeNode("Basic"))then
        ImGuiTabBarFlags tab_bar_flags = ImGuiTabBarFlags_None;
        if (ImGui.BeginTabBar("MyTabBar", tab_bar_flags))then
            if (ImGui.BeginTabItem("Avocado"))then
                ImGui.Text("This is the Avocado tabnot \nblah blah blah blah blah");
                ImGui.EndTabItem();
            end
            if (ImGui.BeginTabItem("Broccoli"))then
                ImGui.Text("This is the Broccoli tabnot \nblah blah blah blah blah");
                ImGui.EndTabItem();
            end
            if (ImGui.BeginTabItem("Cucumber"))then
                ImGui.Text("This is the Cucumber tabnot \nblah blah blah blah blah");
                ImGui.EndTabItem();
            end
            ImGui.EndTabBar();
        end
        ImGui.Separator();
        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Advanced & Close Button"))then
        -- Expose a couple of the available flags. In most cases you may just call BeginTabBar() with no flags (0).
        static ImGuiTabBarFlags tab_bar_flags = ImGuiTabBarFlags_Reorderable;
        ImGui.CheckboxFlags("ImGuiTabBarFlags_Reorderable", tab_bar_flags, ImGuiTabBarFlags_Reorderable);
        ImGui.CheckboxFlags("ImGuiTabBarFlags_AutoSelectNewTabs", tab_bar_flags, ImGuiTabBarFlags_AutoSelectNewTabs);
        ImGui.CheckboxFlags("ImGuiTabBarFlags_TabListPopupButton", tab_bar_flags, ImGuiTabBarFlags_TabListPopupButton);
        ImGui.CheckboxFlags("ImGuiTabBarFlags_NoCloseWithMiddleMouseButton", tab_bar_flags, ImGuiTabBarFlags_NoCloseWithMiddleMouseButton);
        if ((tab_bar_flags & ImGuiTabBarFlags_FittingPolicyMask_) == 0)
            tab_bar_flags |= ImGuiTabBarFlags_FittingPolicyDefault_;
        if (ImGui.CheckboxFlags("ImGuiTabBarFlags_FittingPolicyResizeDown", tab_bar_flags, ImGuiTabBarFlags_FittingPolicyResizeDown))
            tab_bar_flags &= ~(ImGuiTabBarFlags_FittingPolicyMask_ ^ ImGuiTabBarFlags_FittingPolicyResizeDown);
        if (ImGui.CheckboxFlags("ImGuiTabBarFlags_FittingPolicyScroll", tab_bar_flags, ImGuiTabBarFlags_FittingPolicyScroll))
            tab_bar_flags &= ~(ImGuiTabBarFlags_FittingPolicyMask_ ^ ImGuiTabBarFlags_FittingPolicyScroll);

        -- Tab Bar
        const char* names[4] = do "Artichoke", "Beetroot", "Celery", "Daikon" end;
        local opened[4] = do true, true, true, true end; -- Persistent user state
        for (int n = 0; n < IM_ARRAYSIZE(opened); n++)then
            if (n > 0) do ImGui.SameLine(); end
            ImGui.Checkbox(names[n], opened[n]);
        end

        -- Passing a bool* to BeginTabItem() is similar to passing one to Begin():
        -- the underlying bool will be set to false when the tab is closed.
        if (ImGui.BeginTabBar("MyTabBar", tab_bar_flags))then
            for (int n = 0; n < IM_ARRAYSIZE(opened); n++)
                if (opened[n] and ImGui.BeginTabItem(names[n], opened[n], ImGuiTabItemFlags_None))then
                    ImGui.Text("This is the %s tabnot ", names[n]);
                    if (n & 1)
                        ImGui.Text("I am an odd tab.");
                    ImGui.EndTabItem();
                end
            ImGui.EndTabBar();
        end
        ImGui.Separator();
        ImGui.TreePop();
    end

    if (ImGui.TreeNode("TabItemButton & Leading/Trailing flags"))then
        static ImVector<int> active_tabs;
        static int next_tab_id = 0;
        if (next_tab_id == 0) -- Initialize with some default tabs
            for (int i = 0; i < 3; i++)
                active_tabs.push_back(next_tab_id++);

        -- TabItemButton() and Leading/Trailing flags are distinct features which we will demo together.
        -- (It is possible to submit regular tabs with Leading/Trailing flags, or TabItemButton tabs without Leading/Trailing flags...
        -- but they tend to make more sense together)
        local show_leading_button = true;
        local show_trailing_button = true;
        ImGui.Checkbox("Show Leading TabItemButton()", show_leading_button);
        ImGui.Checkbox("Show Trailing TabItemButton()", show_trailing_button);

        -- Expose some other flags which are useful to showcase how they interact with Leading/Trailing tabs
        static ImGuiTabBarFlags tab_bar_flags = ImGuiTabBarFlags_AutoSelectNewTabs | ImGuiTabBarFlags_Reorderable | ImGuiTabBarFlags_FittingPolicyResizeDown;
        ImGui.CheckboxFlags("ImGuiTabBarFlags_TabListPopupButton", tab_bar_flags, ImGuiTabBarFlags_TabListPopupButton);
        if (ImGui.CheckboxFlags("ImGuiTabBarFlags_FittingPolicyResizeDown", tab_bar_flags, ImGuiTabBarFlags_FittingPolicyResizeDown))
            tab_bar_flags &= ~(ImGuiTabBarFlags_FittingPolicyMask_ ^ ImGuiTabBarFlags_FittingPolicyResizeDown);
        if (ImGui.CheckboxFlags("ImGuiTabBarFlags_FittingPolicyScroll", tab_bar_flags, ImGuiTabBarFlags_FittingPolicyScroll))
            tab_bar_flags &= ~(ImGuiTabBarFlags_FittingPolicyMask_ ^ ImGuiTabBarFlags_FittingPolicyScroll);

        if (ImGui.BeginTabBar("MyTabBar", tab_bar_flags))then
            -- Demo a Leading TabItemButton(): click the "?" button to open a menu
            if (show_leading_button)
                if (ImGui.TabItemButton("?", ImGuiTabItemFlags_Leading | ImGuiTabItemFlags_NoTooltip))
                    ImGui.OpenPopup("MyHelpMenu");
            if (ImGui.BeginPopup("MyHelpMenu"))then
                ImGui.Selectable("Hellonot ");
                ImGui.EndPopup();
            end

            -- Demo Trailing Tabs: click the "+" button to add a new tab (in your app you may want to use a font icon instead of the "+")
            -- Note that we submit it before the regular tabs, but because of the ImGuiTabItemFlags_Trailing flag it will always appear at the end.
            if (show_trailing_button)
                if (ImGui.TabItemButton("+", ImGuiTabItemFlags_Trailing | ImGuiTabItemFlags_NoTooltip))
                    active_tabs.push_back(next_tab_id++); -- Add new tab

            -- Submit our regular tabs
            for (int n = 0; n < active_tabs.Size; )then
                bool open = true;
                char name[16];
                snprintf(name, IM_ARRAYSIZE(name), "%04d", active_tabs[n]);
                if (ImGui.BeginTabItem(name, open, ImGuiTabItemFlags_None))then
                    ImGui.Text("This is the %s tabnot ", name);
                    ImGui.EndTabItem();
                end

                if (not open)
                    active_tabs.erase(active_tabs.Data + n);
                else
                    n++;
            end

            ImGui.EndTabBar();
        end
        ImGui.Separator();
        ImGui.TreePop();
    end
    ImGui.TreePop();
end

-- Plot/Graph widgets are not very good.
-- Consider writing your own, or using a third-party one, see:
-- - ImPlot https:--github.com/epezent/implot
-- - others https:--github.com/ocornut/imgui/wiki/Useful-Extensions
if (ImGui.TreeNode("Plots Widgets"))then
    local animate = true;
    ImGui.Checkbox("Animate", animate);

    static float arr[] = do 0.6f, 0.1f, 1.0, 0.5f, 0.92f, 0.1f, 0.2f end;
    ImGui.PlotLines("Frame Times", arr, IM_ARRAYSIZE(arr));

    -- Fill an array of contiguous float values to plot
    -- Tip: If your float aren't contiguous but part of a structure, you can pass a pointer to your first float
    -- and the sizeof() of your structure in the "stride" parameter.
    static float values[90] = do end;
    static int values_offset = 0;
    static double refresh_time = 0.0;
    if (not animate or refresh_time == 0.0)
        refresh_time = ImGui.GetTime();
    while (refresh_time < ImGui.GetTime()) -- Create data at fixed 60 Hz rate for the demothen
        static float phase = 0.0;
        values[values_offset] = cosf(phase);
        values_offset = (values_offset + 1) % IM_ARRAYSIZE(values);
        phase += 0..0 * values_offset;
        refresh_time += 1.0 / 60.0;
    end

    -- Plots can display overlay texts
    -- (in this example, we will display an average value)then
        float average = 0.0;
        for (int n = 0; n < IM_ARRAYSIZE(values); n++)
            average += values[n];
        average /= (float)IM_ARRAYSIZE(values);
        char overlay[32];
        sprintf(overlay, "avg %f", average);
        ImGui.PlotLines("Lines", values, IM_ARRAYSIZE(values), values_offset, overlay, -1.0, 1.0, ImVec2(0, 80.0));
    end
    ImGui.PlotHistogram("Histogram", arr, IM_ARRAYSIZE(arr), 0, NULL, 0.0, 1.0, ImVec2(0, 80.0));

    -- Use functions to generate output
    -- FIXME: This is rather awkward because current plot API only pass in indices.
    -- We probably want an API passing floats and user provide sample rate/count.
    struct Funcsthen
        static float Sin(void*, int i) do return sinf(i * 0.1f); end
        static float Saw(void*, int i) do return (i & 1) ? 1.0 : -1.0; end
    end;
    static int func_type = 0, display_count = 70;
    ImGui.Separator();
    ImGui.SetNextItemWidth(ImGui.GetFontSize() * 8);
    ImGui.Combo("func", func_type, "Sin\0Saw\0");
    ImGui.SameLine();
    ImGui.SliderInt("Sample count", display_count, 1, 400);
    float (*func)(void*, int) = (func_type == 0) ? Funcs.Sin : Funcs.Saw;
    ImGui.PlotLines("Lines", func, NULL, display_count, 0, NULL, -1.0, 1.0, ImVec2(0, 80));
    ImGui.PlotHistogram("Histogram", func, NULL, display_count, 0, NULL, -1.0, 1.0, ImVec2(0, 80));
    ImGui.Separator();

    -- Animate a simple progress bar
    static float progress = 0.0, progress_dir = 1.0;
    if (animate)then
        progress += progress_dir * 0.4f * ImGui.GetIO().DeltaTime;
        if (progress >= +1.1f) do progress = +1.1f; progress_dir *= -1.0; end
        if (progress <= -0.1f) do progress = -0.1f; progress_dir *= -1.0; end
    end

    -- Typically we would use ImVec2(-1.0,0.0) or ImVec2(-FLT_MIN,0.0) to use all available width,
    -- or ImVec2(width,0.0) for a specified width. ImVec2(0.0,0.0) uses ItemWidth.
    ImGui.ProgressBar(progress, ImVec2(0.0, 0.0));
    ImGui.SameLine(0.0, ImGui.GetStyle().ItemInnerSpacing.x);
    ImGui.Text("Progress Bar");

    float progress_saturated = IM_CLAMP(progress, 0.0, 1.0);
    char buf[32];
    sprintf(buf, "%d/%d", (int)(progress_saturated * 1753), 1753);
    ImGui.ProgressBar(progress, ImVec2(0.f, 0.f), buf);
    ImGui.TreePop();
end

if (ImGui.TreeNode("Color/Picker Widgets"))then
    static ImVec4 color = ImVec4(114.0 / 255.0, 144.0 / 255.0, 154.0 / 255.0, 200.0 / 255.0);

    local alpha_preview = true;
    local alpha_half_preview = false;
    local drag_and_drop = true;
    local options_menu = true;
    local hdr = false;
    ImGui.Checkbox("With Alpha Preview", alpha_preview);
    ImGui.Checkbox("With Half Alpha Preview", alpha_half_preview);
    ImGui.Checkbox("With Drag and Drop", drag_and_drop);
    ImGui.Checkbox("With Options Menu", options_menu); ImGui.SameLine(); HelpMarker("Right-click on the individual color widget to show options.");
    ImGui.Checkbox("With HDR", hdr); ImGui.SameLine(); HelpMarker("Currently all this does is to lift the 0..1 limits on dragging widgets.");
    ImGuiColorEditFlags misc_flags = (hdr ? ImGuiColorEditFlags_HDR : 0) | (drag_and_drop ? 0 : ImGuiColorEditFlags_NoDragDrop) | (alpha_half_preview ? ImGuiColorEditFlags_AlphaPreviewHalf : (alpha_preview ? ImGuiColorEditFlags_AlphaPreview : 0)) | (options_menu ? 0 : ImGuiColorEditFlags_NoOptions);

    ImGui.Text("Color widget:");
    ImGui.SameLine(); HelpMarker(
        "Click on the color square to open a color picker.\n"
        "CTRL+click on individual component to input value.\n");
    ImGui.ColorEdit3("MyColor----1", (float*)&color, misc_flags);

    ImGui.Text("Color widget HSV with Alpha:");
    ImGui.ColorEdit4("MyColor----2", (float*)&color, ImGuiColorEditFlags_DisplayHSV | misc_flags);

    ImGui.Text("Color widget with Float Display:");
    ImGui.ColorEdit4("MyColor----2f", (float*)&color, ImGuiColorEditFlags_Float | misc_flags);

    ImGui.Text("Color button with Picker:");
    ImGui.SameLine(); HelpMarker(
        "With the ImGuiColorEditFlags_NoInputs flag you can hide all the slider/text inputs.\n"
        "With the ImGuiColorEditFlags_NoLabel flag you can pass a non-empty label which will only "
        "be used for the tooltip and picker popup.");
    ImGui.ColorEdit4("MyColor----3", (float*)&color, ImGuiColorEditFlags_NoInputs | ImGuiColorEditFlags_NoLabel | misc_flags);

    ImGui.Text("Color button with Custom Picker Popup:");

    -- Generate a default palette. The palette will persist and can be edited.
    local saved_palette_init = true;
    static ImVec4 saved_palette[32] = do end;
    if (saved_palette_init)then
        for (int n = 0; n < IM_ARRAYSIZE(saved_palette); n++)then
            ImGui.ColorConvertHSVtoRGB(n / 31.0, 0.8f, 0.8f,
                saved_palette[n].x, saved_palette[n].y, saved_palette[n].z);
            saved_palette[n].w = 1.0; -- Alpha
        end
        saved_palette_init = false;
    end

    static ImVec4 backup_color;
    bool open_popup = ImGui.ColorButton("MyColor----3b", color, misc_flags);
    ImGui.SameLine(0, ImGui.GetStyle().ItemInnerSpacing.x);
    open_popup |= ImGui.Button("Palette");
    if (open_popup)then
        ImGui.OpenPopup("mypicker");
        backup_color = color;
    end
    if (ImGui.BeginPopup("mypicker"))then
        ImGui.Text("MY CUSTOM COLOR PICKER WITH AN AMAZING PALETTEnot ");
        ImGui.Separator();
        ImGui.ColorPicker4("----picker", (float*)&color, misc_flags | ImGuiColorEditFlags_NoSidePreview | ImGuiColorEditFlags_NoSmallPreview);
        ImGui.SameLine();

        ImGui.BeginGroup(); -- Lock X position
        ImGui.Text("Current");
        ImGui.ColorButton("----current", color, ImGuiColorEditFlags_NoPicker | ImGuiColorEditFlags_AlphaPreviewHalf, ImVec2(60, 40));
        ImGui.Text("Previous");
        if (ImGui.ColorButton("----previous", backup_color, ImGuiColorEditFlags_NoPicker | ImGuiColorEditFlags_AlphaPreviewHalf, ImVec2(60, 40)))
            color = backup_color;
        ImGui.Separator();
        ImGui.Text("Palette");
        for (int n = 0; n < IM_ARRAYSIZE(saved_palette); n++)then
            ImGui.PushID(n);
            if ((n % 8) ~= 0)
                ImGui.SameLine(0.0, ImGui.GetStyle().ItemSpacing.y);

            ImGuiColorEditFlags palette_button_flags = ImGuiColorEditFlags_NoAlpha | ImGuiColorEditFlags_NoPicker | ImGuiColorEditFlags_NoTooltip;
            if (ImGui.ColorButton("----palette", saved_palette[n], palette_button_flags, ImVec2(20, 20)))
                color = ImVec4(saved_palette[n].x, saved_palette[n].y, saved_palette[n].z, color.w); -- Preserve alphanot 

            -- Allow user to drop colors into each palette entry. Note that ColorButton() is already a
            -- drag source by default, unless specifying the ImGuiColorEditFlags_NoDragDrop flag.
            if (ImGui.BeginDragDropTarget())then
                if (const ImGuiPayload* payload = ImGui.AcceptDragDropPayload(IMGUI_PAYLOAD_TYPE_COLOR_3F))
                    memcpy((float*)&saved_palette[n], payload->Data, sizeof(float) * 3);
                if (const ImGuiPayload* payload = ImGui.AcceptDragDropPayload(IMGUI_PAYLOAD_TYPE_COLOR_4F))
                    memcpy((float*)&saved_palette[n], payload->Data, sizeof(float) * 4);
                ImGui.EndDragDropTarget();
            end

            ImGui.PopID();
        end
        ImGui.EndGroup();
        ImGui.EndPopup();
    end

    ImGui.Text("Color button only:");
    local no_border = false;
    ImGui.Checkbox("ImGuiColorEditFlags_NoBorder", no_border);
    ImGui.ColorButton("MyColor----3c", *(ImVec4*)&color, misc_flags | (no_border ? ImGuiColorEditFlags_NoBorder : 0), ImVec2(80, 80));

    ImGui.Text("Color picker:");
    local alpha = true;
    local alpha_bar = true;
    local side_preview = true;
    local ref_color = false;
    static ImVec4 ref_color_v(1.0, 0.0, 1.0, 0.5f);
    static int display_mode = 0;
    static int picker_mode = 0;
    ImGui.Checkbox("With Alpha", alpha);
    ImGui.Checkbox("With Alpha Bar", alpha_bar);
    ImGui.Checkbox("With Side Preview", side_preview);
    if (side_preview)then
        ImGui.SameLine();
        ImGui.Checkbox("With Ref Color", ref_color);
        if (ref_color)then
            ImGui.SameLine();
            ImGui.ColorEdit4("----RefColor", ref_color_v.x, ImGuiColorEditFlags_NoInputs | misc_flags);
        end
    end
    ImGui.Combo("Display Mode", display_mode, "Auto/Current\0None\0RGB Only\0HSV Only\0Hex Only\0");
    ImGui.SameLine(); HelpMarker(
        "ColorEdit defaults to displaying RGB inputs if you don't specify a display mode, "
        "but the user can change it with a right-click.\n\nColorPicker defaults to displaying RGB+HSV+Hex "
        "if you don't specify a display mode.\n\nYou can change the defaults using SetColorEditOptions().");
    ImGui.Combo("Picker Mode", picker_mode, "Auto/Current\0Hue bar + SV rect\0Hue wheel + SV triangle\0");
    ImGui.SameLine(); HelpMarker("User can right-click the picker to change mode.");
    ImGuiColorEditFlags flags = misc_flags;
    if (not alpha)            flags |= ImGuiColorEditFlags_NoAlpha;        -- This is by default if you call ColorPicker3() instead of ColorPicker4()
    if (alpha_bar)         flags |= ImGuiColorEditFlags_AlphaBar;
    if (not side_preview)     flags |= ImGuiColorEditFlags_NoSidePreview;
    if (picker_mode == 1)  flags |= ImGuiColorEditFlags_PickerHueBar;
    if (picker_mode == 2)  flags |= ImGuiColorEditFlags_PickerHueWheel;
    if (display_mode == 1) flags |= ImGuiColorEditFlags_NoInputs;       -- Disable all RGB/HSV/Hex displays
    if (display_mode == 2) flags |= ImGuiColorEditFlags_DisplayRGB;     -- Override display mode
    if (display_mode == 3) flags |= ImGuiColorEditFlags_DisplayHSV;
    if (display_mode == 4) flags |= ImGuiColorEditFlags_DisplayHex;
    ImGui.ColorPicker4("MyColor----4", (float*)&color, flags, ref_color ? &ref_color_v.x : NULL);

    ImGui.Text("Set defaults in code:");
    ImGui.SameLine(); HelpMarker(
        "SetColorEditOptions() is designed to allow you to set boot-time default.\n"
        "We don't have Push/Pop functions because you can force options on a per-widget basis if needed,"
        "and the user can change non-forced ones with the options menu.\nWe don't have a getter to avoid"
        "encouraging you to persistently save values that aren't forward-compatible.");
    if (ImGui.Button("Default: Uint8 + HSV + Hue Bar"))
        ImGui.SetColorEditOptions(ImGuiColorEditFlags_Uint8 | ImGuiColorEditFlags_DisplayHSV | ImGuiColorEditFlags_PickerHueBar);
    if (ImGui.Button("Default: Float + HDR + Hue Wheel"))
        ImGui.SetColorEditOptions(ImGuiColorEditFlags_Float | ImGuiColorEditFlags_HDR | ImGuiColorEditFlags_PickerHueWheel);

    -- HSV encoded support (to avoid RGB<>HSV round trips and singularities when S==0 or V==0)
    static ImVec4 color_hsv(0.23f, 1.0, 1.0, 1.0); -- Stored as HSVnot 
    ImGui.Spacing();
    ImGui.Text("HSV encoded colors");
    ImGui.SameLine(); HelpMarker(
        "By default, colors are given to ColorEdit and ColorPicker in RGB, but ImGuiColorEditFlags_InputHSV"
        "allows you to store colors as HSV and pass them to ColorEdit and ColorPicker as HSV. This comes with the"
        "added benefit that you can manipulate hue values with the picker even when saturation or value are zero.");
    ImGui.Text("Color widget with InputHSV:");
    ImGui.ColorEdit4("HSV shown as RGB----1", (float*)&color_hsv, ImGuiColorEditFlags_DisplayRGB | ImGuiColorEditFlags_InputHSV | ImGuiColorEditFlags_Float);
    ImGui.ColorEdit4("HSV shown as HSV----1", (float*)&color_hsv, ImGuiColorEditFlags_DisplayHSV | ImGuiColorEditFlags_InputHSV | ImGuiColorEditFlags_Float);
    ImGui.DragFloat4("Raw HSV values", (float*)&color_hsv, 0.01f, 0.0, 1.0);

    ImGui.TreePop();
end

if (ImGui.TreeNode("Drag/Slider Flags"))then
    -- Demonstrate using advanced flags for DragXXX and SliderXXX functions. Note that the flags are the samenot 
    static ImGuiSliderFlags flags = ImGuiSliderFlags_None;
    ImGui.CheckboxFlags("ImGuiSliderFlags_AlwaysClamp", flags, ImGuiSliderFlags_AlwaysClamp);
    ImGui.SameLine(); HelpMarker("Always clamp value to min/max bounds (if any) when input manually with CTRL+Click.");
    ImGui.CheckboxFlags("ImGuiSliderFlags_Logarithmic", flags, ImGuiSliderFlags_Logarithmic);
    ImGui.SameLine(); HelpMarker("Enable logarithmic editing (more precision for small values).");
    ImGui.CheckboxFlags("ImGuiSliderFlags_NoRoundToFormat", flags, ImGuiSliderFlags_NoRoundToFormat);
    ImGui.SameLine(); HelpMarker("Disable rounding underlying value to match precision of the format string (e.g. %.3f values are rounded to those 3 digits).");
    ImGui.CheckboxFlags("ImGuiSliderFlags_NoInput", flags, ImGuiSliderFlags_NoInput);
    ImGui.SameLine(); HelpMarker("Disable CTRL+Click or Enter key allowing to input text directly into the widget.");

    -- Drags
    static float drag_f = 0.5f;
    static int drag_i = 50;
    ImGui.Text("Underlying float value: %f", drag_f);
    ImGui.DragFloat("DragFloat (0 -> 1)", drag_f, 0.005f, 0.0, 1.0, "%.3f", flags);
    ImGui.DragFloat("DragFloat (0 -> +inf)", drag_f, 0.005f, 0.0, FLT_MAX, "%.3f", flags);
    ImGui.DragFloat("DragFloat (-inf -> 1)", drag_f, 0.005f, -FLT_MAX, 1.0, "%.3f", flags);
    ImGui.DragFloat("DragFloat (-inf -> +inf)", drag_f, 0.005f, -FLT_MAX, +FLT_MAX, "%.3f", flags);
    ImGui.DragInt("DragInt (0 -> 100)", drag_i, 0.5f, 0, 100, "%d", flags);

    -- Sliders
    static float slider_f = 0.5f;
    static int slider_i = 50;
    ImGui.Text("Underlying float value: %f", slider_f);
    ImGui.SliderFloat("SliderFloat (0 -> 1)", slider_f, 0.0, 1.0, "%.3f", flags);
    ImGui.SliderInt("SliderInt (0 -> 100)", slider_i, 0, 100, "%d", flags);

    ImGui.TreePop();
end

if (ImGui.TreeNode("Range Widgets"))then
    static float begin = 10, end = 90;
    static int begin_i = 100, end_i = 1000;
    ImGui.DragFloatRange2("range float", begin, end, 0.25f, 0.0, 100.0, "Min: %.1f %%", "Max: %.1f %%", ImGuiSliderFlags_AlwaysClamp);
    ImGui.DragIntRange2("range int", begin_i, end_i, 5, 0, 1000, "Min: %d units", "Max: %d units");
    ImGui.DragIntRange2("range int (no bounds)", begin_i, end_i, 5, 0, 0, "Min: %d units", "Max: %d units");
    ImGui.TreePop();
end

if (ImGui.TreeNode("Data Types"))then
    -- DragScalar/InputScalar/SliderScalar functions allow various data types
    -- - signed/unsigned
    -- - 8/16/32/64-bits
    -- - integer/float/double
    -- To avoid polluting the public API with all possible combinations, we use the ImGuiDataType enum
    -- to pass the type, and passing all arguments by pointer.
    -- This is the reason the test code below creates local variables to hold "zero" "one" etc. for each types.
    -- In practice, if you frequently use a given type that is not covered by the normal API entry points,
    -- you can wrap it yourself inside a 1 line function which can take typed argument as value instead of void*,
    -- and then pass their address to the generic function. For example:
    --   bool MySliderU64(const char *label, u64* value, u64 min = 0, u64 max = 0, const char* format = "%lld")
    --   do
    --      return SliderScalar(label, ImGuiDataType_U64, value, min, max, format);
    --   end

    -- Setup limits (as helper variables so we can take their address, as explained above)
    -- Note: SliderScalar() functions have a maximum usable range of half the natural type maximum, hence the /2.
    --ifndef LLONG_MIN
    ImS64 LLONG_MIN = -9223372036854775807LL - 1;
    ImS64 LLONG_MAX = 9223372036854775807LL;
    ImU64 ULLONG_MAX = (2ULL * 9223372036854775807LL + 1);
    --endif
    const char    s8_zero  = 0,   s8_one  = 1,   s8_fifty  = 50, s8_min  = -128,        s8_max = 127;
    const ImU8    u8_zero  = 0,   u8_one  = 1,   u8_fifty  = 50, u8_min  = 0,           u8_max = 255;
    const short   s16_zero = 0,   s16_one = 1,   s16_fifty = 50, s16_min = -32768,      s16_max = 32767;
    const ImU16   u16_zero = 0,   u16_one = 1,   u16_fifty = 50, u16_min = 0,           u16_max = 65535;
    const ImS32   s32_zero = 0,   s32_one = 1,   s32_fifty = 50, s32_min = INT_MIN/2,   s32_max = INT_MAX/2,    s32_hi_a = INT_MAX/2 - 100,    s32_hi_b = INT_MAX/2;
    const ImU32   u32_zero = 0,   u32_one = 1,   u32_fifty = 50, u32_min = 0,           u32_max = UINT_MAX/2,   u32_hi_a = UINT_MAX/2 - 100,   u32_hi_b = UINT_MAX/2;
    const ImS64   s64_zero = 0,   s64_one = 1,   s64_fifty = 50, s64_min = LLONG_MIN/2, s64_max = LLONG_MAX/2,  s64_hi_a = LLONG_MAX/2 - 100,  s64_hi_b = LLONG_MAX/2;
    const ImU64   u64_zero = 0,   u64_one = 1,   u64_fifty = 50, u64_min = 0,           u64_max = ULLONG_MAX/2, u64_hi_a = ULLONG_MAX/2 - 100, u64_hi_b = ULLONG_MAX/2;
    const float   f32_zero = 0.f, f32_one = 1.f, f32_lo_a = -10000000000.0, f32_hi_a = +10000000000.0;
    const double  f64_zero = 0.,  f64_one = 1.,  f64_lo_a = -1000000000000000.0, f64_hi_a = +1000000000000000.0;

    -- State
    static char   s8_v  = 127;
    static ImU8   u8_v  = 255;
    static short  s16_v = 32767;
    static ImU16  u16_v = 65535;
    static ImS32  s32_v = -1;
    static ImU32  u32_v = (ImU32)-1;
    static ImS64  s64_v = -1;
    static ImU64  u64_v = (ImU64)-1;
    static float  f32_v = 0.123f;
    static double f64_v = 90000.01234567890123456789;

    const float drag_speed = 0.2f;
    local drag_clamp = false;
    ImGui.Text("Drags:");
    ImGui.Checkbox("Clamp integers to 0..50", drag_clamp);
    ImGui.SameLine(); HelpMarker(
        "As with every widgets in dear imgui, we never modify values unless there is a user interaction.\n"
        "You can override the clamping limits by using CTRL+Click to input a value.");
    ImGui.DragScalar("drag s8",        ImGuiDataType_S8,     &s8_v,  drag_speed, drag_clamp ? &s8_zero  : NULL, drag_clamp ? &s8_fifty  : NULL);
    ImGui.DragScalar("drag u8",        ImGuiDataType_U8,     &u8_v,  drag_speed, drag_clamp ? &u8_zero  : NULL, drag_clamp ? &u8_fifty  : NULL, "%u ms");
    ImGui.DragScalar("drag s16",       ImGuiDataType_S16,    &s16_v, drag_speed, drag_clamp ? &s16_zero : NULL, drag_clamp ? &s16_fifty : NULL);
    ImGui.DragScalar("drag u16",       ImGuiDataType_U16,    &u16_v, drag_speed, drag_clamp ? &u16_zero : NULL, drag_clamp ? &u16_fifty : NULL, "%u ms");
    ImGui.DragScalar("drag s32",       ImGuiDataType_S32,    &s32_v, drag_speed, drag_clamp ? &s32_zero : NULL, drag_clamp ? &s32_fifty : NULL);
    ImGui.DragScalar("drag u32",       ImGuiDataType_U32,    &u32_v, drag_speed, drag_clamp ? &u32_zero : NULL, drag_clamp ? &u32_fifty : NULL, "%u ms");
    ImGui.DragScalar("drag s64",       ImGuiDataType_S64,    &s64_v, drag_speed, drag_clamp ? &s64_zero : NULL, drag_clamp ? &s64_fifty : NULL);
    ImGui.DragScalar("drag u64",       ImGuiDataType_U64,    &u64_v, drag_speed, drag_clamp ? &u64_zero : NULL, drag_clamp ? &u64_fifty : NULL);
    ImGui.DragScalar("drag float",     ImGuiDataType_Float,  &f32_v, 0.005f,  &f32_zero, f32_one, "%f");
    ImGui.DragScalar("drag float log", ImGuiDataType_Float,  &f32_v, 0.005f,  &f32_zero, f32_one, "%f", ImGuiSliderFlags_Logarithmic);
    ImGui.DragScalar("drag double",    ImGuiDataType_Double, f64_v, 0.0005f, f64_zero, NULL,     "%..0 grams");
    ImGui.DragScalar("drag double log",ImGuiDataType_Double, f64_v, 0.0005f, f64_zero, f64_one, "0 < %..0 < 1", ImGuiSliderFlags_Logarithmic);

    ImGui.Text("Sliders");
    ImGui.SliderScalar("slider s8 full",       ImGuiDataType_S8,     &s8_v,  &s8_min,   &s8_max,   "%d");
    ImGui.SliderScalar("slider u8 full",       ImGuiDataType_U8,     &u8_v,  &u8_min,   &u8_max,   "%u");
    ImGui.SliderScalar("slider s16 full",      ImGuiDataType_S16,    &s16_v, s16_min,  &s16_max,  "%d");
    ImGui.SliderScalar("slider u16 full",      ImGuiDataType_U16,    &u16_v, u16_min,  &u16_max,  "%u");
    ImGui.SliderScalar("slider s32 low",       ImGuiDataType_S32,    &s32_v, s32_zero, s32_fifty,"%d");
    ImGui.SliderScalar("slider s32 high",      ImGuiDataType_S32,    &s32_v, s32_hi_a, s32_hi_b, "%d");
    ImGui.SliderScalar("slider s32 full",      ImGuiDataType_S32,    &s32_v, s32_min,  &s32_max,  "%d");
    ImGui.SliderScalar("slider u32 low",       ImGuiDataType_U32,    &u32_v, u32_zero, u32_fifty,"%u");
    ImGui.SliderScalar("slider u32 high",      ImGuiDataType_U32,    &u32_v, u32_hi_a, u32_hi_b, "%u");
    ImGui.SliderScalar("slider u32 full",      ImGuiDataType_U32,    &u32_v, u32_min,  &u32_max,  "%u");
    ImGui.SliderScalar("slider s64 low",       ImGuiDataType_S64,    &s64_v, s64_zero, s64_fifty,"%" IM_PRId64);
    ImGui.SliderScalar("slider s64 high",      ImGuiDataType_S64,    &s64_v, s64_hi_a, s64_hi_b, "%" IM_PRId64);
    ImGui.SliderScalar("slider s64 full",      ImGuiDataType_S64,    &s64_v, s64_min,  &s64_max,  "%" IM_PRId64);
    ImGui.SliderScalar("slider u64 low",       ImGuiDataType_U64,    &u64_v, u64_zero, u64_fifty,"%" IM_PRIu64 " ms");
    ImGui.SliderScalar("slider u64 high",      ImGuiDataType_U64,    &u64_v, u64_hi_a, u64_hi_b, "%" IM_PRIu64 " ms");
    ImGui.SliderScalar("slider u64 full",      ImGuiDataType_U64,    &u64_v, u64_min,  &u64_max,  "%" IM_PRIu64 " ms");
    ImGui.SliderScalar("slider float low",     ImGuiDataType_Float,  &f32_v, f32_zero, f32_one);
    ImGui.SliderScalar("slider float low log", ImGuiDataType_Float,  &f32_v, f32_zero, f32_one,  "%..0", ImGuiSliderFlags_Logarithmic);
    ImGui.SliderScalar("slider float high",    ImGuiDataType_Float,  &f32_v, f32_lo_a, f32_hi_a, "%e");
    ImGui.SliderScalar("slider double low",    ImGuiDataType_Double, f64_v, f64_zero, f64_one,  "%..0 grams");
    ImGui.SliderScalar("slider double low log",ImGuiDataType_Double, f64_v, f64_zero, f64_one,  "%..0", ImGuiSliderFlags_Logarithmic);
    ImGui.SliderScalar("slider double high",   ImGuiDataType_Double, f64_v, f64_lo_a, f64_hi_a, "%e grams");

    ImGui.Text("Sliders (reverse)");
    ImGui.SliderScalar("slider s8 reverse",    ImGuiDataType_S8,   &s8_v,  &s8_max,    &s8_min,   "%d");
    ImGui.SliderScalar("slider u8 reverse",    ImGuiDataType_U8,   &u8_v,  &u8_max,    &u8_min,   "%u");
    ImGui.SliderScalar("slider s32 reverse",   ImGuiDataType_S32,  &s32_v, s32_fifty, s32_zero, "%d");
    ImGui.SliderScalar("slider u32 reverse",   ImGuiDataType_U32,  &u32_v, u32_fifty, u32_zero, "%u");
    ImGui.SliderScalar("slider s64 reverse",   ImGuiDataType_S64,  &s64_v, s64_fifty, s64_zero, "%" IM_PRId64);
    ImGui.SliderScalar("slider u64 reverse",   ImGuiDataType_U64,  &u64_v, u64_fifty, u64_zero, "%" IM_PRIu64 " ms");

    local inputs_step = true;
    ImGui.Text("Inputs");
    ImGui.Checkbox("Show step buttons", inputs_step);
    ImGui.InputScalar("input s8",      ImGuiDataType_S8,     &s8_v,  inputs_step ? &s8_one  : NULL, NULL, "%d");
    ImGui.InputScalar("input u8",      ImGuiDataType_U8,     &u8_v,  inputs_step ? &u8_one  : NULL, NULL, "%u");
    ImGui.InputScalar("input s16",     ImGuiDataType_S16,    &s16_v, inputs_step ? &s16_one : NULL, NULL, "%d");
    ImGui.InputScalar("input u16",     ImGuiDataType_U16,    &u16_v, inputs_step ? &u16_one : NULL, NULL, "%u");
    ImGui.InputScalar("input s32",     ImGuiDataType_S32,    &s32_v, inputs_step ? &s32_one : NULL, NULL, "%d");
    ImGui.InputScalar("input s32 hex", ImGuiDataType_S32,    &s32_v, inputs_step ? &s32_one : NULL, NULL, "%08X", ImGuiInputTextFlags_CharsHexadecimal);
    ImGui.InputScalar("input u32",     ImGuiDataType_U32,    &u32_v, inputs_step ? &u32_one : NULL, NULL, "%u");
    ImGui.InputScalar("input u32 hex", ImGuiDataType_U32,    &u32_v, inputs_step ? &u32_one : NULL, NULL, "%08X", ImGuiInputTextFlags_CharsHexadecimal);
    ImGui.InputScalar("input s64",     ImGuiDataType_S64,    &s64_v, inputs_step ? &s64_one : NULL);
    ImGui.InputScalar("input u64",     ImGuiDataType_U64,    &u64_v, inputs_step ? &u64_one : NULL);
    ImGui.InputScalar("input float",   ImGuiDataType_Float,  &f32_v, inputs_step ? &f32_one : NULL);
    ImGui.InputScalar("input double",  ImGuiDataType_Double, f64_v, inputs_step ? &f64_one : NULL);

    ImGui.TreePop();
end

if (ImGui.TreeNode("Multi-component Widgets"))then
    static float vec4f[4] = do 0..0, 0..0, 0..0, 0.44f end;
    static int vec4i[4] = do 1, 5, 100, 255 end;

    ImGui.InputFloat2("input float2", vec4f);
    ImGui.DragFloat2("drag float2", vec4f, 0.01f, 0.0, 1.0);
    ImGui.SliderFloat2("slider float2", vec4f, 0.0, 1.0);
    ImGui.InputInt2("input int2", vec4i);
    ImGui.DragInt2("drag int2", vec4i, 1, 0, 255);
    ImGui.SliderInt2("slider int2", vec4i, 0, 255);
    ImGui.Spacing();

    ImGui.InputFloat3("input float3", vec4f);
    ImGui.DragFloat3("drag float3", vec4f, 0.01f, 0.0, 1.0);
    ImGui.SliderFloat3("slider float3", vec4f, 0.0, 1.0);
    ImGui.InputInt3("input int3", vec4i);
    ImGui.DragInt3("drag int3", vec4i, 1, 0, 255);
    ImGui.SliderInt3("slider int3", vec4i, 0, 255);
    ImGui.Spacing();

    ImGui.InputFloat4("input float4", vec4f);
    ImGui.DragFloat4("drag float4", vec4f, 0.01f, 0.0, 1.0);
    ImGui.SliderFloat4("slider float4", vec4f, 0.0, 1.0);
    ImGui.InputInt4("input int4", vec4i);
    ImGui.DragInt4("drag int4", vec4i, 1, 0, 255);
    ImGui.SliderInt4("slider int4", vec4i, 0, 255);

    ImGui.TreePop();
end

if (ImGui.TreeNode("Vertical Sliders"))then
    const float spacing = 4;
    ImGui.PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(spacing, spacing));

    static int int_value = 0;
    ImGui.VSliderInt("----int", ImVec2(18, 160), int_value, 0, 5);
    ImGui.SameLine();

    static float values[7] = do 0.0, 0..0, 0.35f, 0.9f, 0..0, 0..0, 0.0 end;
    ImGui.PushID("set1");
    for (int i = 0; i < 7; i++)then
        if (i > 0) ImGui.SameLine();
        ImGui.PushID(i);
        ImGui.PushStyleColor(ImGuiCol_FrameBg, (ImVec4)ImColor.HSV(i / 7.0, 0.5f, 0.5f));
        ImGui.PushStyleColor(ImGuiCol_FrameBgHovered, (ImVec4)ImColor.HSV(i / 7.0, 0.6f, 0.5f));
        ImGui.PushStyleColor(ImGuiCol_FrameBgActive, (ImVec4)ImColor.HSV(i / 7.0, 0.7f, 0.5f));
        ImGui.PushStyleColor(ImGuiCol_SliderGrab, (ImVec4)ImColor.HSV(i / 7.0, 0.9f, 0.9f));
        ImGui.VSliderFloat("----v", ImVec2(18, 160), values[i], 0.0, 1.0, "");
        if (ImGui.IsItemActive() or ImGui.IsItemHovered())
            ImGui.SetTooltip("%.3f", values[i]);
        ImGui.PopStyleColor(4);
        ImGui.PopID();
    end
    ImGui.PopID();

    ImGui.SameLine();
    ImGui.PushID("set2");
    static float values2[4] = do 0..0, 0..0, 0..0, 0.25f end;
    const int rows = 3;
    const ImVec2 small_slider_size(18, (float)(int)((160.0 - (rows - 1) * spacing) / rows));
    for (int nx = 0; nx < 4; nx++)then
        if (nx > 0) ImGui.SameLine();
        ImGui.BeginGroup();
        for (int ny = 0; ny < rows; ny++)then
            ImGui.PushID(nx * rows + ny);
            ImGui.VSliderFloat("----v", small_slider_size, values2[nx], 0.0, 1.0, "");
            if (ImGui.IsItemActive() or ImGui.IsItemHovered())
                ImGui.SetTooltip("%.3f", values2[nx]);
            ImGui.PopID();
        end
        ImGui.EndGroup();
    end
    ImGui.PopID();

    ImGui.SameLine();
    ImGui.PushID("set3");
    for (int i = 0; i < 4; i++)then
        if (i > 0) ImGui.SameLine();
        ImGui.PushID(i);
        ImGui.PushStyleVar(ImGuiStyleVar_GrabMinSize, 40);
        ImGui.VSliderFloat("----v", ImVec2(40, 160), values[i], 0.0, 1.0, "%.2f\nsec");
        ImGui.PopStyleVar();
        ImGui.PopID();
    end
    ImGui.PopID();
    ImGui.PopStyleVar();
    ImGui.TreePop();
end

if (ImGui.TreeNode("Drag and Drop"))then
    if (ImGui.TreeNode("Drag and drop in standard widgets"))then
        -- ColorEdit widgets automatically act as drag source and drag target.
        -- They are using standardized payload strings IMGUI_PAYLOAD_TYPE_COLOR_3F and IMGUI_PAYLOAD_TYPE_COLOR_4F
        -- to allow your own widgets to use colors in their drag and drop interaction.
        -- Also see 'Demo->Widgets->Color/Picker Widgets->Palette' demo.
        HelpMarker("You can drag from the color squares.");
        static float col1[3] = do 1.0, 0.0, 0.2f end;
        static float col2[4] = do 0.4f, 0.7f, 0.0, 0.5f end;
        ImGui.ColorEdit3("color 1", col1);
        ImGui.ColorEdit4("color 2", col2);
        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Drag and drop to copy/swap items"))then
        enum Modethen
            Mode_Copy,
            Mode_Move,
            Mode_Swap
        end;
        static int mode = 0;
        if (ImGui.RadioButton("Copy", mode == Mode_Copy)) do mode = Mode_Copy; end ImGui.SameLine();
        if (ImGui.RadioButton("Move", mode == Mode_Move)) do mode = Mode_Move; end ImGui.SameLine();
        if (ImGui.RadioButton("Swap", mode == Mode_Swap)) do mode = Mode_Swap; end
        static const char* names[9] =then
            "Bobby", "Beatrice", "Betty",
            "Brianna", "Barry", "Bernard",
            "Bibi", "Blaine", "Bryn"
        end;
        for (int n = 0; n < IM_ARRAYSIZE(names); n++)then
            ImGui.PushID(n);
            if ((n % 3) ~= 0)
                ImGui.SameLine();
            ImGui.Button(names[n], ImVec2(60, 60));

            -- Our buttons are both drag sources and drag targets herenot 
            if (ImGui.BeginDragDropSource(ImGuiDragDropFlags_None))then
                -- Set payload to carry the index of our item (could be anything)
                ImGui.SetDragDropPayload("DND_DEMO_CELL", n, sizeof(int));

                -- Display preview (could be anything, e.g. when dragging an image we could decide to display
                -- the filename and a small preview of the image, etc.)
                if (mode == Mode_Copy) do ImGui.Text("Copy %s", names[n]); end
                if (mode == Mode_Move) do ImGui.Text("Move %s", names[n]); end
                if (mode == Mode_Swap) do ImGui.Text("Swap %s", names[n]); end
                ImGui.EndDragDropSource();
            end
            if (ImGui.BeginDragDropTarget())then
                if (const ImGuiPayload* payload = ImGui.AcceptDragDropPayload("DND_DEMO_CELL"))then
                    IM_ASSERT(payload->DataSize == sizeof(int));
                    int payload_n = *(const int*)payload->Data;
                    if (mode == Mode_Copy)then
                        names[n] = names[payload_n];
                    end
                    if (mode == Mode_Move)then
                        names[n] = names[payload_n];
                        names[payload_n] = "";
                    end
                    if (mode == Mode_Swap)then
                        const char* tmp = names[n];
                        names[n] = names[payload_n];
                        names[payload_n] = tmp;
                    end
                end
                ImGui.EndDragDropTarget();
            end
            ImGui.PopID();
        end
        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Drag to reorder items (simple)"))then
        -- Simple reordering
        HelpMarker(
            "We don't use the drag and drop api at all herenot  "
            "Instead we query when the item is held but not hovered, and order items accordingly.");
        static const char* item_names[] = do "Item One", "Item Two", "Item Three", "Item Four", "Item Five" end;
        for (int n = 0; n < IM_ARRAYSIZE(item_names); n++)then
            const char* item = item_names[n];
            ImGui.Selectable(item);

            if (ImGui.IsItemActive() and not ImGui.IsItemHovered())then
                int n_next = n + (ImGui.GetMouseDragDelta(0).y < 0.f ? -1 : 1);
                if (n_next >= 0 and n_next < IM_ARRAYSIZE(item_names))then
                    item_names[n] = item_names[n_next];
                    item_names[n_next] = item;
                    ImGui.ResetMouseDragDelta();
                end
            end
        end
        ImGui.TreePop();
    end

    ImGui.TreePop();
end

if (ImGui.TreeNode("Querying Status (Edited/Active/Hovered etc.)"))then
    -- Select an item type
    const char* item_names[] =then
        "Text", "Button", "Button (w/ repeat)", "Checkbox", "SliderFloat", "InputText", "InputFloat",
        "InputFloat3", "ColorEdit4", "Selectable", "MenuItem", "TreeNode", "TreeNode (w/ double-click)", "Combo", "ListBox"
    end;
    static int item_type = 4;
    local item_disabled = false;
    ImGui.Combo("Item Type", item_type, item_names, IM_ARRAYSIZE(item_names), IM_ARRAYSIZE(item_names));
    ImGui.SameLine();
    HelpMarker("Testing how various types of items are interacting with the IsItemXXX functions. Note that the bool return value of most ImGui function is generally equivalent to calling ImGui.IsItemHovered().");
    ImGui.Checkbox("Item Disabled",  &item_disabled);

    -- Submit selected item item so we can query their status in the code following it.
    bool ret = false;
    local b = false;
    static float col4f[4] = do 1.0, 0.5, 0.0, 1.0 end;
    static char str[16] = do end;
    if (item_disabled)
        ImGui.BeginDisabled(true);
    if (item_type == 0) do ImGui.Text("ITEM: Text"); end                                              -- Testing text items with no identifier/interaction
    if (item_type == 1) do ret = ImGui.Button("ITEM: Button"); end                                    -- Testing button
    if (item_type == 2) do ImGui.PushButtonRepeat(true); ret = ImGui.Button("ITEM: Button"); ImGui.PopButtonRepeat(); end -- Testing button (with repeater)
    if (item_type == 3) do ret = ImGui.Checkbox("ITEM: Checkbox", b); end                            -- Testing checkbox
    if (item_type == 4) do ret = ImGui.SliderFloat("ITEM: SliderFloat", col4f[0], 0.0, 1.0); end   -- Testing basic item
    if (item_type == 5) do ret = ImGui.InputText("ITEM: InputText", str[0], IM_ARRAYSIZE(str)); end  -- Testing input text (which handles tabbing)
    if (item_type == 6) do ret = ImGui.InputFloat("ITEM: InputFloat", col4f, 1.0); end               -- Testing +/- buttons on scalar input
    if (item_type == 7) do ret = ImGui.InputFloat3("ITEM: InputFloat3", col4f); end                   -- Testing multi-component items (IsItemXXX flags are reported merged)
    if (item_type == 8) do ret = ImGui.ColorEdit4("ITEM: ColorEdit4", col4f); end                     -- Testing multi-component items (IsItemXXX flags are reported merged)
    if (item_type == 9) do ret = ImGui.Selectable("ITEM: Selectable"); end                            -- Testing selectable item
    if (item_type == 10)do ret = ImGui.MenuItem("ITEM: MenuItem"); end                                -- Testing menu item (they use ImGuiButtonFlags_PressedOnRelease button policy)
    if (item_type == 11)do ret = ImGui.TreeNode("ITEM: TreeNode"); if (ret) ImGui.TreePop(); end     -- Testing tree node
    if (item_type == 12)do ret = ImGui.TreeNodeEx("ITEM: TreeNode w/ ImGuiTreeNodeFlags_OpenOnDoubleClick", ImGuiTreeNodeFlags_OpenOnDoubleClick | ImGuiTreeNodeFlags_NoTreePushOnOpen); end -- Testing tree node with ImGuiButtonFlags_PressedOnDoubleClick button policy.
    if (item_type == 13)do const char* items[] = do "Apple", "Banana", "Cherry", "Kiwi" end; static int current = 1; ret = ImGui.Combo("ITEM: Combo", current, items, IM_ARRAYSIZE(items)); end
    if (item_type == 14)do const char* items[] = do "Apple", "Banana", "Cherry", "Kiwi" end; static int current = 1; ret = ImGui.ListBox("ITEM: ListBox", current, items, IM_ARRAYSIZE(items), IM_ARRAYSIZE(items)); end

    -- Display the values of IsItemHovered() and other common item state functions.
    -- Note that the ImGuiHoveredFlags_XXX flags can be combined.
    -- Because BulletText is an item itself and that would affect the output of IsItemXXX functions,
    -- we query every state in a single call to avoid storing them and to simplify the code.
    ImGui.BulletText(
        "Return value = %d\n"
        "IsItemFocused() = %d\n"
        "IsItemHovered() = %d\n"
        "IsItemHovered(_AllowWhenBlockedByPopup) = %d\n"
        "IsItemHovered(_AllowWhenBlockedByActiveItem) = %d\n"
        "IsItemHovered(_AllowWhenOverlapped) = %d\n"
        "IsItemHovered(_AllowWhenDisabled) = %d\n"
        "IsItemHovered(_RectOnly) = %d\n"
        "IsItemActive() = %d\n"
        "IsItemEdited() = %d\n"
        "IsItemActivated() = %d\n"
        "IsItemDeactivated() = %d\n"
        "IsItemDeactivatedAfterEdit() = %d\n"
        "IsItemVisible() = %d\n"
        "IsItemClicked() = %d\n"
        "IsItemToggledOpen() = %d\n"
        "GetItemRectMin() = (%.1f, %.1f)\n"
        "GetItemRectMax() = (%.1f, %.1f)\n"
        "GetItemRectSize() = (%.1f, %.1f)",
        ret,
        ImGui.IsItemFocused(),
        ImGui.IsItemHovered(),
        ImGui.IsItemHovered(ImGuiHoveredFlags_AllowWhenBlockedByPopup),
        ImGui.IsItemHovered(ImGuiHoveredFlags_AllowWhenBlockedByActiveItem),
        ImGui.IsItemHovered(ImGuiHoveredFlags_AllowWhenOverlapped),
        ImGui.IsItemHovered(ImGuiHoveredFlags_AllowWhenDisabled),
        ImGui.IsItemHovered(ImGuiHoveredFlags_RectOnly),
        ImGui.IsItemActive(),
        ImGui.IsItemEdited(),
        ImGui.IsItemActivated(),
        ImGui.IsItemDeactivated(),
        ImGui.IsItemDeactivatedAfterEdit(),
        ImGui.IsItemVisible(),
        ImGui.IsItemClicked(),
        ImGui.IsItemToggledOpen(),
        ImGui.GetItemRectMin().x, ImGui.GetItemRectMin().y,
        ImGui.GetItemRectMax().x, ImGui.GetItemRectMax().y,
        ImGui.GetItemRectSize().x, ImGui.GetItemRectSize().y
    );

    if (item_disabled)
        ImGui.EndDisabled();

    local embed_all_inside_a_child_window = false;
    ImGui.Checkbox("Embed everything inside a child window (for additional testing)", embed_all_inside_a_child_window);
    if (embed_all_inside_a_child_window)
        ImGui.BeginChild("outer_child", ImVec2(0, ImGui.GetFontSize() * 20.0), true);

    -- Testing IsWindowFocused() function with its various flags.
    -- Note that the ImGuiFocusedFlags_XXX flags can be combined.
    ImGui.BulletText(
        "IsWindowFocused() = %d\n"
        "IsWindowFocused(_ChildWindows) = %d\n"
        "IsWindowFocused(_ChildWindows|_RootWindow) = %d\n"
        "IsWindowFocused(_RootWindow) = %d\n"
        "IsWindowFocused(_AnyWindow) = %d\n",
        ImGui.IsWindowFocused(),
        ImGui.IsWindowFocused(ImGuiFocusedFlags_ChildWindows),
        ImGui.IsWindowFocused(ImGuiFocusedFlags_ChildWindows | ImGuiFocusedFlags_RootWindow),
        ImGui.IsWindowFocused(ImGuiFocusedFlags_RootWindow),
        ImGui.IsWindowFocused(ImGuiFocusedFlags_AnyWindow));

    -- Testing IsWindowHovered() function with its various flags.
    -- Note that the ImGuiHoveredFlags_XXX flags can be combined.
    ImGui.BulletText(
        "IsWindowHovered() = %d\n"
        "IsWindowHovered(_AllowWhenBlockedByPopup) = %d\n"
        "IsWindowHovered(_AllowWhenBlockedByActiveItem) = %d\n"
        "IsWindowHovered(_ChildWindows) = %d\n"
        "IsWindowHovered(_ChildWindows|_RootWindow) = %d\n"
        "IsWindowHovered(_ChildWindows|_AllowWhenBlockedByPopup) = %d\n"
        "IsWindowHovered(_RootWindow) = %d\n"
        "IsWindowHovered(_AnyWindow) = %d\n",
        ImGui.IsWindowHovered(),
        ImGui.IsWindowHovered(ImGuiHoveredFlags_AllowWhenBlockedByPopup),
        ImGui.IsWindowHovered(ImGuiHoveredFlags_AllowWhenBlockedByActiveItem),
        ImGui.IsWindowHovered(ImGuiHoveredFlags_ChildWindows),
        ImGui.IsWindowHovered(ImGuiHoveredFlags_ChildWindows | ImGuiHoveredFlags_RootWindow),
        ImGui.IsWindowHovered(ImGuiHoveredFlags_ChildWindows | ImGuiHoveredFlags_AllowWhenBlockedByPopup),
        ImGui.IsWindowHovered(ImGuiHoveredFlags_RootWindow),
        ImGui.IsWindowHovered(ImGuiHoveredFlags_AnyWindow));

    ImGui.BeginChild("child", ImVec2(0, 50), true);
    ImGui.Text("This is another child window for testing the _ChildWindows flag.");
    ImGui.EndChild();
    if (embed_all_inside_a_child_window)
        ImGui.EndChild();

    static char unused_str[] = "This widget is only here to be able to tab-out of the widgets above.";
    ImGui.InputText("unused", unused_str, IM_ARRAYSIZE(unused_str), ImGuiInputTextFlags_ReadOnly);

    -- Calling IsItemHovered() after begin returns the hovered status of the title bar.
    -- This is useful in particular if you want to create a context menu associated to the title bar of a window.
    -- This will also work when docked into a Tab (the Tab replace the Title Bar and guarantee the same properties).
    local test_window = false;
    ImGui.Checkbox("Hovered/Active tests after Begin() for title bar testing", test_window);
    if (test_window)then
        -- FIXME-DOCK: This window cannot be docked within the ImGui Demo window, this will cause a feedback loop and get them stuck.
        -- Could we fix this through an ImGuiWindowClass feature? Or an API call to tag our parent as "don't skip items"?
        ImGui.Begin("Title bar Hovered/Active tests", test_window);
        if (ImGui.BeginPopupContextItem()) -- <-- This is using IsItemHovered()then
            if (ImGui.MenuItem("Close")) do test_window = false; end
            ImGui.EndPopup();
        end
        ImGui.Text(
            "IsItemHovered() after begin = %d (== is title bar hovered)\n"
            "IsItemActive() after begin = %d (== is window being clicked/moved)\n",
            ImGui.IsItemHovered(), ImGui.IsItemActive());
        ImGui.End();
    end

    ImGui.TreePop();
end


end

function ShowDemoWindowLayout()
    if (not ImGui.CollapsingHeader("Layout & Scrolling"))
        return;

    if (ImGui.TreeNode("Child windows"))then
        HelpMarker("Use child windows to begin into a self-contained independent scrolling/clipping regions within a host window.");
        local disable_mouse_wheel = false;
        local disable_menu = false;
        ImGui.Checkbox("Disable Mouse Wheel", disable_mouse_wheel);
        ImGui.Checkbox("Disable Menu", disable_menu);

        -- Child 1: no border, enable horizontal scrollbarthen
            ImGuiWindowFlags window_flags = ImGuiWindowFlags_HorizontalScrollbar;
            if (disable_mouse_wheel)
                window_flags |= ImGuiWindowFlags_NoScrollWithMouse;
            ImGui.BeginChild("ChildL", ImVec2(ImGui.GetContentRegionAvail().x * 0.5f, 260), false, window_flags);
            for (int i = 0; i < 100; i++)
                ImGui.Text("%04d: scrollable region", i);
            ImGui.EndChild();
        end

        ImGui.SameLine();

        -- Child 2: rounded borderthen
            ImGuiWindowFlags window_flags = ImGuiWindowFlags_None;
            if (disable_mouse_wheel)
                window_flags |= ImGuiWindowFlags_NoScrollWithMouse;
            if (not disable_menu)
                window_flags |= ImGuiWindowFlags_MenuBar;
            ImGui.PushStyleVar(ImGuiStyleVar_ChildRounding, 5.0);
            ImGui.BeginChild("ChildR", ImVec2(0, 260), true, window_flags);
            if (not disable_menu and ImGui.BeginMenuBar())then
                if (ImGui.BeginMenu("Menu"))then
                    ShowExampleMenuFile();
                    ImGui.EndMenu();
                end
                ImGui.EndMenuBar();
            end
            if (ImGui.BeginTable("split", 2, ImGuiTableFlags_Resizable | ImGuiTableFlags_NoSavedSettings))then
                for (int i = 0; i < 100; i++)then
                    char buf[32];
                    sprintf(buf, "%03d", i);
                    ImGui.TableNextColumn();
                    ImGui.Button(buf, ImVec2(-FLT_MIN, 0.0));
                end
                ImGui.EndTable();
            end
            ImGui.EndChild();
            ImGui.PopStyleVar();
        end

        ImGui.Separator();

        -- Demonstrate a few extra things
        -- - Changing ImGuiCol_ChildBg (which is transparent black in default styles)
        -- - Using SetCursorPos() to position child window (the child window is an item from the POV of parent window)
        --   You can also call SetNextWindowPos() to position the child window. The parent window will effectively
        --   layout from this position.
        -- - Using ImGui.GetItemRectMin/Max() to query the "item" state (because the child window is an item from
        --   the POV of the parent window). See 'Demo->Querying Status (Edited/Active/Hovered etc.)' for details.then
            static int offset_x = 0;
            ImGui.SetNextItemWidth(ImGui.GetFontSize() * 8);
            ImGui.DragInt("Offset X", offset_x, 1.0, -1000, 1000);

            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + (float)offset_x);
            ImGui.PushStyleColor(ImGuiCol_ChildBg, IM_COL32(255, 0, 0, 100));
            ImGui.BeginChild("Red", ImVec2(200, 100), true, ImGuiWindowFlags_None);
            for (int n = 0; n < 50; n++)
                ImGui.Text("Some test %d", n);
            ImGui.EndChild();
            bool child_is_hovered = ImGui.IsItemHovered();
            ImVec2 child_rect_min = ImGui.GetItemRectMin();
            ImVec2 child_rect_max = ImGui.GetItemRectMax();
            ImGui.PopStyleColor();
            ImGui.Text("Hovered: %d", child_is_hovered);
            ImGui.Text("Rect of child window is: (%.0,%.0) (%.0,%.0)", child_rect_min.x, child_rect_min.y, child_rect_max.x, child_rect_max.y);
        end

        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Widgets Width"))then
        static float f = 0.0;
        local show_indented_items = true;
        ImGui.Checkbox("Show indented items", show_indented_items);

        -- Use SetNextItemWidth() to set the width of a single upcoming item.
        -- Use PushItemWidth()/PopItemWidth() to set the width of a group of items.
        -- In real code use you'll probably want to choose width values that are proportional to your font size
        -- e.g. Using '20.0 * GetFontSize()' as width instead of '200.0', etc.

        ImGui.Text("SetNextItemWidth/PushItemWidth(100)");
        ImGui.SameLine(); HelpMarker("Fixed width.");
        ImGui.PushItemWidth(100);
        ImGui.DragFloat("float----1b", f);
        if (show_indented_items)then
            ImGui.Indent();
            ImGui.DragFloat("float (indented)----1b", f);
            ImGui.Unindent();
        end
        ImGui.PopItemWidth();

        ImGui.Text("SetNextItemWidth/PushItemWidth(-100)");
        ImGui.SameLine(); HelpMarker("Align to right edge minus 100");
        ImGui.PushItemWidth(-100);
        ImGui.DragFloat("float----2a", f);
        if (show_indented_items)then
            ImGui.Indent();
            ImGui.DragFloat("float (indented)----2b", f);
            ImGui.Unindent();
        end
        ImGui.PopItemWidth();

        ImGui.Text("SetNextItemWidth/PushItemWidth(GetContentRegionAvail().x * 0.5f)");
        ImGui.SameLine(); HelpMarker("Half of available width.\n(~ right-cursor_pos)\n(works within a column set)");
        ImGui.PushItemWidth(ImGui.GetContentRegionAvail().x * 0.5f);
        ImGui.DragFloat("float----3a", f);
        if (show_indented_items)then
            ImGui.Indent();
            ImGui.DragFloat("float (indented)----3b", f);
            ImGui.Unindent();
        end
        ImGui.PopItemWidth();

        ImGui.Text("SetNextItemWidth/PushItemWidth(-GetContentRegionAvail().x * 0.5f)");
        ImGui.SameLine(); HelpMarker("Align to right edge minus half");
        ImGui.PushItemWidth(-ImGui.GetContentRegionAvail().x * 0.5f);
        ImGui.DragFloat("float----4a", f);
        if (show_indented_items)then
            ImGui.Indent();
            ImGui.DragFloat("float (indented)----4b", f);
            ImGui.Unindent();
        end
        ImGui.PopItemWidth();

        -- Demonstrate using PushItemWidth to surround three items.
        -- Calling SetNextItemWidth() before each of them would have the same effect.
        ImGui.Text("SetNextItemWidth/PushItemWidth(-FLT_MIN)");
        ImGui.SameLine(); HelpMarker("Align to right edge");
        ImGui.PushItemWidth(-FLT_MIN);
        ImGui.DragFloat("----float5a", f);
        if (show_indented_items)then
            ImGui.Indent();
            ImGui.DragFloat("float (indented)----5b", f);
            ImGui.Unindent();
        end
        ImGui.PopItemWidth();

        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Basic Horizontal Layout"))then
        ImGui.TextWrapped("(Use ImGui.SameLine() to keep adding items to the right of the preceding item)");

        -- Text
        ImGui.Text("Two items: Hello"); ImGui.SameLine();
        ImGui.TextColored(ImVec4(1,1,0,1), "Sailor");

        -- Adjust spacing
        ImGui.Text("More spacing: Hello"); ImGui.SameLine(0, 20);
        ImGui.TextColored(ImVec4(1,1,0,1), "Sailor");

        -- Button
        ImGui.AlignTextToFramePadding();
        ImGui.Text("Normal buttons"); ImGui.SameLine();
        ImGui.Button("Banana"); ImGui.SameLine();
        ImGui.Button("Apple"); ImGui.SameLine();
        ImGui.Button("Corniflower");

        -- Button
        ImGui.Text("Small buttons"); ImGui.SameLine();
        ImGui.SmallButton("Like this one"); ImGui.SameLine();
        ImGui.Text("can fit within a text block.");

        -- Aligned to arbitrary position. Easy/cheap column.
        ImGui.Text("Aligned");
        ImGui.SameLine(150); ImGui.Text("x=150");
        ImGui.SameLine(300); ImGui.Text("x=300");
        ImGui.Text("Aligned");
        ImGui.SameLine(150); ImGui.SmallButton("x=150");
        ImGui.SameLine(300); ImGui.SmallButton("x=300");

        -- Checkbox
        local c1 = false, c2 = false, c3 = false, c4 = false;
        ImGui.Checkbox("My", c1); ImGui.SameLine();
        ImGui.Checkbox("Tailor", c2); ImGui.SameLine();
        ImGui.Checkbox("Is", c3); ImGui.SameLine();
        ImGui.Checkbox("Rich", c4);

        -- Various
        static float f0 = 1.0, f1 = 2.0, f2 = 3.0;
        ImGui.PushItemWidth(80);
        const char* items[] = do "AAAA", "BBBB", "CCCC", "DDDD" end;
        static int item = -1;
        ImGui.Combo("Combo", item, items, IM_ARRAYSIZE(items)); ImGui.SameLine();
        ImGui.SliderFloat("X", f0, 0.0, 5.0); ImGui.SameLine();
        ImGui.SliderFloat("Y", f1, 0.0, 5.0); ImGui.SameLine();
        ImGui.SliderFloat("Z", f2, 0.0, 5.0);
        ImGui.PopItemWidth();

        ImGui.PushItemWidth(80);
        ImGui.Text("Lists:");
        static int selection[4] = do 0, 1, 2, 3 end;
        for (int i = 0; i < 4; i++)then
            if (i > 0) ImGui.SameLine();
            ImGui.PushID(i);
            ImGui.ListBox("", selection[i], items, IM_ARRAYSIZE(items));
            ImGui.PopID();
            --if (ImGui.IsItemHovered()) ImGui.SetTooltip("ListBox %d hovered", i);
        end
        ImGui.PopItemWidth();

        -- Dummy
        ImVec2 button_sz(40, 40);
        ImGui.Button("A", button_sz); ImGui.SameLine();
        ImGui.Dummy(button_sz); ImGui.SameLine();
        ImGui.Button("B", button_sz);

        -- Manually wrapping
        -- (we should eventually provide this as an automatic layout feature, but for now you can do it manually)
        ImGui.Text("Manually wrapping:");
        ImGuiStyle& style = ImGui.GetStyle();
        int buttons_count = 20;
        float window_visible_x2 = ImGui.GetWindowPos().x + ImGui.GetWindowContentRegionMax().x;
        for (int n = 0; n < buttons_count; n++)then
            ImGui.PushID(n);
            ImGui.Button("Box", button_sz);
            float last_button_x2 = ImGui.GetItemRectMax().x;
            float next_button_x2 = last_button_x2 + style.ItemSpacing.x + button_sz.x; -- Expected position if next button was on same line
            if (n + 1 < buttons_count and next_button_x2 < window_visible_x2)
                ImGui.SameLine();
            ImGui.PopID();
        end

        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Groups"))then
        HelpMarker(
            "BeginGroup() basically locks the horizontal position for new line. "
            "EndGroup() bundles the whole group so that you can use \"item\" functions such as "
            "IsItemHovered()/IsItemActive() or SameLine() etc. on the whole group.");
        ImGui.BeginGroup();then
            ImGui.BeginGroup();
            ImGui.Button("AAA");
            ImGui.SameLine();
            ImGui.Button("BBB");
            ImGui.SameLine();
            ImGui.BeginGroup();
            ImGui.Button("CCC");
            ImGui.Button("DDD");
            ImGui.EndGroup();
            ImGui.SameLine();
            ImGui.Button("EEE");
            ImGui.EndGroup();
            if (ImGui.IsItemHovered())
                ImGui.SetTooltip("First group hovered");
        end
        -- Capture the group size and create widgets using the same size
        ImVec2 size = ImGui.GetItemRectSize();
        const float values[5] = do 0.5f, 0..0, 0..0, 0..0, 0.25f end;
        ImGui.PlotHistogram("----values", values, IM_ARRAYSIZE(values), 0, NULL, 0.0, 1.0, size);

        ImGui.Button("ACTION", ImVec2((size.x - ImGui.GetStyle().ItemSpacing.x) * 0.5f, size.y));
        ImGui.SameLine();
        ImGui.Button("REACTION", ImVec2((size.x - ImGui.GetStyle().ItemSpacing.x) * 0.5f, size.y));
        ImGui.EndGroup();
        ImGui.SameLine();

        ImGui.Button("LEVERAGE\nBUZZWORD", size);
        ImGui.SameLine();

        if (ImGui.BeginListBox("List", size))then
            ImGui.Selectable("Selected", true);
            ImGui.Selectable("Not Selected", false);
            ImGui.EndListBox();
        end

        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Text Baseline Alignment"))thenthen
            ImGui.BulletText("Text baseline:");
            ImGui.SameLine(); HelpMarker(
                "This is testing the vertical alignment that gets applied on text to keep it aligned with widgets. "
                "Lines only composed of text or \"small\" widgets use less vertical space than lines with framed widgets.");
            ImGui.Indent();

            ImGui.Text("KO Blahblah"); ImGui.SameLine();
            ImGui.Button("Some framed item"); ImGui.SameLine();
            HelpMarker("Baseline of button will look misaligned with text..");

            -- If your line starts with text, call AlignTextToFramePadding() to align text to upcoming widgets.
            -- (because we don't know what's coming after the Text() statement, we need to move the text baseline
            -- down by FramePadding.y ahead of time)
            ImGui.AlignTextToFramePadding();
            ImGui.Text("OK Blahblah"); ImGui.SameLine();
            ImGui.Button("Some framed item"); ImGui.SameLine();
            HelpMarker("We call AlignTextToFramePadding() to vertically align the text baseline by +FramePadding.y");

            -- SmallButton() uses the same vertical padding as Text
            ImGui.Button("TEST----1"); ImGui.SameLine();
            ImGui.Text("TEST"); ImGui.SameLine();
            ImGui.SmallButton("TEST----2");

            -- If your line starts with text, call AlignTextToFramePadding() to align text to upcoming widgets.
            ImGui.AlignTextToFramePadding();
            ImGui.Text("Text aligned to framed item"); ImGui.SameLine();
            ImGui.Button("Item----1"); ImGui.SameLine();
            ImGui.Text("Item"); ImGui.SameLine();
            ImGui.SmallButton("Item----2"); ImGui.SameLine();
            ImGui.Button("Item----3");

            ImGui.Unindent();
        end

        ImGui.Spacing();then
            ImGui.BulletText("Multi-line text:");
            ImGui.Indent();
            ImGui.Text("One\nTwo\nThree"); ImGui.SameLine();
            ImGui.Text("Hello\nWorld"); ImGui.SameLine();
            ImGui.Text("Banana");

            ImGui.Text("Banana"); ImGui.SameLine();
            ImGui.Text("Hello\nWorld"); ImGui.SameLine();
            ImGui.Text("One\nTwo\nThree");

            ImGui.Button("HOP----1"); ImGui.SameLine();
            ImGui.Text("Banana"); ImGui.SameLine();
            ImGui.Text("Hello\nWorld"); ImGui.SameLine();
            ImGui.Text("Banana");

            ImGui.Button("HOP----2"); ImGui.SameLine();
            ImGui.Text("Hello\nWorld"); ImGui.SameLine();
            ImGui.Text("Banana");
            ImGui.Unindent();
        end

        ImGui.Spacing();then
            ImGui.BulletText("Misc items:");
            ImGui.Indent();

            -- SmallButton() sets FramePadding to zero. Text baseline is aligned to match baseline of previous Button.
            ImGui.Button("80x80", ImVec2(80, 80));
            ImGui.SameLine();
            ImGui.Button("50x50", ImVec2(50, 50));
            ImGui.SameLine();
            ImGui.Button("Button()");
            ImGui.SameLine();
            ImGui.SmallButton("SmallButton()");

            -- Tree
            const float spacing = ImGui.GetStyle().ItemInnerSpacing.x;
            ImGui.Button("Button----1");
            ImGui.SameLine(0.0, spacing);
            if (ImGui.TreeNode("Node----1"))then
                -- Placeholder tree data
                for (int i = 0; i < 6; i++)
                    ImGui.BulletText("Item %d..", i);
                ImGui.TreePop();
            end

            -- Vertically align text node a bit lower so it'll be vertically centered with upcoming widget.
            -- Otherwise you can use SmallButton() (smaller fit).
            ImGui.AlignTextToFramePadding();

            -- Common mistake to avoid: if we want to SameLine after TreeNode we need to do it before we add
            -- other contents below the node.
            bool node_open = ImGui.TreeNode("Node----2");
            ImGui.SameLine(0.0, spacing); ImGui.Button("Button----2");
            if (node_open)then
                -- Placeholder tree data
                for (int i = 0; i < 6; i++)
                    ImGui.BulletText("Item %d..", i);
                ImGui.TreePop();
            end

            -- Bullet
            ImGui.Button("Button----3");
            ImGui.SameLine(0.0, spacing);
            ImGui.BulletText("Bullet text");

            ImGui.AlignTextToFramePadding();
            ImGui.BulletText("Node");
            ImGui.SameLine(0.0, spacing); ImGui.Button("Button----4");
            ImGui.Unindent();
        end

        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Scrolling"))then
        -- Vertical scroll functions
        HelpMarker("Use SetScrollHereY() or SetScrollFromPosY() to scroll to a given vertical position.");

        static int track_item = 50;
        local enable_track = true;
        local enable_extra_decorations = false;
        static float scroll_to_off_px = 0.0;
        static float scroll_to_pos_px = 200.0;

        ImGui.Checkbox("Decoration", enable_extra_decorations);

        ImGui.Checkbox("Track", enable_track);
        ImGui.PushItemWidth(100);
        ImGui.SameLine(140); enable_track |= ImGui.DragInt("----item", track_item, 0.25f, 0, 99, "Item = %d");

        bool scroll_to_off = ImGui.Button("Scroll Offset");
        ImGui.SameLine(140); scroll_to_off |= ImGui.DragFloat("----off", scroll_to_off_px, 1..0, 0, FLT_MAX, "+%.0 px");

        bool scroll_to_pos = ImGui.Button("Scroll To Pos");
        ImGui.SameLine(140); scroll_to_pos |= ImGui.DragFloat("----pos", scroll_to_pos_px, 1..0, -10, FLT_MAX, "X/Y = %.0 px");
        ImGui.PopItemWidth();

        if (scroll_to_off or scroll_to_pos)
            enable_track = false;

        ImGuiStyle& style = ImGui.GetStyle();
        float child_w = (ImGui.GetContentRegionAvail().x - 4 * style.ItemSpacing.x) / 5;
        if (child_w < 1.0)
            child_w = 1.0;
        ImGui.PushID("----VerticalScrolling");
        for (int i = 0; i < 5; i++)then
            if (i > 0) ImGui.SameLine();
            ImGui.BeginGroup();
            const char* names[] = do "Top", "25%", "Center", "75%", "Bottom" end;
            ImGui.TextUnformatted(names[i]);

            const ImGuiWindowFlags child_flags = enable_extra_decorations ? ImGuiWindowFlags_MenuBar : 0;
            const ImGuiID child_id = ImGui.GetID((void*)(intptr_t)i);
            const bool child_is_visible = ImGui.BeginChild(child_id, ImVec2(child_w, 200.0), true, child_flags);
            if (ImGui.BeginMenuBar())then
                ImGui.TextUnformatted("abc");
                ImGui.EndMenuBar();
            end
            if (scroll_to_off)
                ImGui.SetScrollY(scroll_to_off_px);
            if (scroll_to_pos)
                ImGui.SetScrollFromPosY(ImGui.GetCursorStartPos().y + scroll_to_pos_px, i * 0.25f);
            if (child_is_visible) -- Avoid calling SetScrollHereY when running with culled itemsthen
                for (int item = 0; item < 100; item++)then
                    if (enable_track and item == track_item)then
                        ImGui.TextColored(ImVec4(1, 1, 0, 1), "Item %d", item);
                        ImGui.SetScrollHereY(i * 0.25f); -- 0.0:top, 0.5f:center, 1.0:bottom
                    end
                    elsethen
                        ImGui.Text("Item %d", item);
                    end
                end
            end
            float scroll_y = ImGui.GetScrollY();
            float scroll_max_y = ImGui.GetScrollMaxY();
            ImGui.EndChild();
            ImGui.Text("%.0/%.0", scroll_y, scroll_max_y);
            ImGui.EndGroup();
        end
        ImGui.PopID();

        -- Horizontal scroll functions
        ImGui.Spacing();
        HelpMarker(
            "Use SetScrollHereX() or SetScrollFromPosX() to scroll to a given horizontal position.\n\n"
            "Because the clipping rectangle of most window hides half worth of WindowPadding on the "
            "left/right, using SetScrollFromPosX(+1) will usually result in clipped text whereas the "
            "equivalent SetScrollFromPosY(+1) wouldn't.");
        ImGui.PushID("----HorizontalScrolling");
        for (int i = 0; i < 5; i++)then
            float child_height = ImGui.GetTextLineHeight() + style.ScrollbarSize + style.WindowPadding.y * 2.0;
            ImGuiWindowFlags child_flags = ImGuiWindowFlags_HorizontalScrollbar | (enable_extra_decorations ? ImGuiWindowFlags_AlwaysVerticalScrollbar : 0);
            ImGuiID child_id = ImGui.GetID((void*)(intptr_t)i);
            bool child_is_visible = ImGui.BeginChild(child_id, ImVec2(-100, child_height), true, child_flags);
            if (scroll_to_off)
                ImGui.SetScrollX(scroll_to_off_px);
            if (scroll_to_pos)
                ImGui.SetScrollFromPosX(ImGui.GetCursorStartPos().x + scroll_to_pos_px, i * 0.25f);
            if (child_is_visible) -- Avoid calling SetScrollHereY when running with culled itemsthen
                for (int item = 0; item < 100; item++)then
                    if (item > 0)
                        ImGui.SameLine();
                    if (enable_track and item == track_item)then
                        ImGui.TextColored(ImVec4(1, 1, 0, 1), "Item %d", item);
                        ImGui.SetScrollHereX(i * 0.25f); -- 0.0:left, 0.5f:center, 1.0:right
                    end
                    elsethen
                        ImGui.Text("Item %d", item);
                    end
                end
            end
            float scroll_x = ImGui.GetScrollX();
            float scroll_max_x = ImGui.GetScrollMaxX();
            ImGui.EndChild();
            ImGui.SameLine();
            const char* names[] = do "Left", "25%", "Center", "75%", "Right" end;
            ImGui.Text("%s\n%.0/%.0", names[i], scroll_x, scroll_max_x);
            ImGui.Spacing();
        end
        ImGui.PopID();

        -- Miscellaneous Horizontal Scrolling Demo
        HelpMarker(
            "Horizontal scrolling for a window is enabled via the ImGuiWindowFlags_HorizontalScrollbar flag.\n\n"
            "You may want to also explicitly specify content width by using SetNextWindowContentWidth() before Begin().");
        static int lines = 7;
        ImGui.SliderInt("Lines", lines, 1, 15);
        ImGui.PushStyleVar(ImGuiStyleVar_FrameRounding, 3.0);
        ImGui.PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(2.0, 1.0));
        ImVec2 scrolling_child_size = ImVec2(0, ImGui.GetFrameHeightWithSpacing() * 7 + 30);
        ImGui.BeginChild("scrolling", scrolling_child_size, true, ImGuiWindowFlags_HorizontalScrollbar);
        for (int line = 0; line < lines; line++)then
            -- Display random stuff. For the sake of this trivial demo we are using basic Button() + SameLine()
            -- If you want to create your own time line for a real application you may be better off manipulating
            -- the cursor position yourself, aka using SetCursorPos/SetCursorScreenPos to position the widgets
            -- yourself. You may also want to use the lower-level ImDrawList API.
            int num_buttons = 10 + ((line & 1) ? line * 9 : line * 3);
            for (int n = 0; n < num_buttons; n++)then
                if (n > 0) ImGui.SameLine();
                ImGui.PushID(n + line * 1000);
                char num_buf[16];
                sprintf(num_buf, "%d", n);
                const char* label = (not (n % 15)) ? "FizzBuzz" : (not (n % 3)) ? "Fizz" : (not (n % 5)) ? "Buzz" : num_buf;
                float hue = n * 0.05f;
                ImGui.PushStyleColor(ImGuiCol_Button, (ImVec4)ImColor.HSV(hue, 0.6f, 0.6f));
                ImGui.PushStyleColor(ImGuiCol_ButtonHovered, (ImVec4)ImColor.HSV(hue, 0.7f, 0.7f));
                ImGui.PushStyleColor(ImGuiCol_ButtonActive, (ImVec4)ImColor.HSV(hue, 0.8f, 0.8f));
                ImGui.Button(label, ImVec2(40.0 + sinf((float)(line + n)) * 20.0, 0.0));
                ImGui.PopStyleColor(3);
                ImGui.PopID();
            end
        end
        float scroll_x = ImGui.GetScrollX();
        float scroll_max_x = ImGui.GetScrollMaxX();
        ImGui.EndChild();
        ImGui.PopStyleVar(2);
        float scroll_x_delta = 0.0;
        ImGui.SmallButton("<<");
        if (ImGui.IsItemActive())
            scroll_x_delta = -ImGui.GetIO().DeltaTime * 1000.0;
        ImGui.SameLine();
        ImGui.Text("Scroll from code"); ImGui.SameLine();
        ImGui.SmallButton(">>");
        if (ImGui.IsItemActive())
            scroll_x_delta = +ImGui.GetIO().DeltaTime * 1000.0;
        ImGui.SameLine();
        ImGui.Text("%.0/%.0", scroll_x, scroll_max_x);
        if (scroll_x_delta ~= 0.0)then
            -- Demonstrate a trick: you can use Begin to set yourself in the context of another window
            -- (here we are already out of your child window)
            ImGui.BeginChild("scrolling");
            ImGui.SetScrollX(ImGui.GetScrollX() + scroll_x_delta);
            ImGui.EndChild();
        end
        ImGui.Spacing();

        local show_horizontal_contents_size_demo_window = false;
        ImGui.Checkbox("Show Horizontal contents size demo window", show_horizontal_contents_size_demo_window);

        if (show_horizontal_contents_size_demo_window)then
            local show_h_scrollbar = true;
            local show_button = true;
            local show_tree_nodes = true;
            local show_text_wrapped = false;
            local show_columns = true;
            local show_tab_bar = true;
            local show_child = false;
            local explicit_content_size = false;
            static float contents_size_x = 300.0;
            if (explicit_content_size)
                ImGui.SetNextWindowContentSize(ImVec2(contents_size_x, 0.0));
            ImGui.Begin("Horizontal contents size demo window", show_horizontal_contents_size_demo_window, show_h_scrollbar ? ImGuiWindowFlags_HorizontalScrollbar : 0);
            ImGui.PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(2, 0));
            ImGui.PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(2, 0));
            HelpMarker("Test of different widgets react and impact the work rectangle growing when horizontal scrolling is enabled.\n\nUse 'Metrics->Tools->Show windows rectangles' to visualize rectangles.");
            ImGui.Checkbox("H-scrollbar", show_h_scrollbar);
            ImGui.Checkbox("Button", show_button);            -- Will grow contents size (unless explicitly overwritten)
            ImGui.Checkbox("Tree nodes", show_tree_nodes);    -- Will grow contents size and display highlight over full width
            ImGui.Checkbox("Text wrapped", show_text_wrapped);-- Will grow and use contents size
            ImGui.Checkbox("Columns", show_columns);          -- Will use contents size
            ImGui.Checkbox("Tab bar", show_tab_bar);          -- Will use contents size
            ImGui.Checkbox("Child", show_child);              -- Will grow and use contents size
            ImGui.Checkbox("Explicit content size", explicit_content_size);
            ImGui.Text("Scroll %.1f/%.1f %.1f/%.1f", ImGui.GetScrollX(), ImGui.GetScrollMaxX(), ImGui.GetScrollY(), ImGui.GetScrollMaxY());
            if (explicit_content_size)then
                ImGui.SameLine();
                ImGui.SetNextItemWidth(100);
                ImGui.DragFloat("----csx", contents_size_x);
                ImVec2 p = ImGui.GetCursorScreenPos();
                ImGui.GetWindowDrawList()->AddRectFilled(p, ImVec2(p.x + 10, p.y + 10), IM_COL32_WHITE);
                ImGui.GetWindowDrawList()->AddRectFilled(ImVec2(p.x + contents_size_x - 10, p.y), ImVec2(p.x + contents_size_x, p.y + 10), IM_COL32_WHITE);
                ImGui.Dummy(ImVec2(0, 10));
            end
            ImGui.PopStyleVar(2);
            ImGui.Separator();
            if (show_button)then
                ImGui.Button("this is a 300-wide button", ImVec2(300, 0));
            end
            if (show_tree_nodes)then
                bool open = true;
                if (ImGui.TreeNode("this is a tree node"))then
                    if (ImGui.TreeNode("another one of those tree node..."))then
                        ImGui.Text("Some tree contents");
                        ImGui.TreePop();
                    end
                    ImGui.TreePop();
                end
                ImGui.CollapsingHeader("CollapsingHeader", open);
            end
            if (show_text_wrapped)then
                ImGui.TextWrapped("This text should automatically wrap on the edge of the work rectangle.");
            end
            if (show_columns)then
                ImGui.Text("Tables:");
                if (ImGui.BeginTable("table", 4, ImGuiTableFlags_Borders))then
                    for (int n = 0; n < 4; n++)then
                        ImGui.TableNextColumn();
                        ImGui.Text("Width %.2f", ImGui.GetContentRegionAvail().x);
                    end
                    ImGui.EndTable();
                end
                ImGui.Text("Columns:");
                ImGui.Columns(4);
                for (int n = 0; n < 4; n++)then
                    ImGui.Text("Width %.2f", ImGui.GetColumnWidth());
                    ImGui.NextColumn();
                end
                ImGui.Columns(1);
            end
            if (show_tab_bar and ImGui.BeginTabBar("Hello"))then
                if (ImGui.BeginTabItem("OneOneOne")) do ImGui.EndTabItem(); end
                if (ImGui.BeginTabItem("TwoTwoTwo")) do ImGui.EndTabItem(); end
                if (ImGui.BeginTabItem("ThreeThreeThree")) do ImGui.EndTabItem(); end
                if (ImGui.BeginTabItem("FourFourFour")) do ImGui.EndTabItem(); end
                ImGui.EndTabBar();
            end
            if (show_child)then
                ImGui.BeginChild("child", ImVec2(0, 0), true);
                ImGui.EndChild();
            end
            ImGui.End();
        end

        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Clipping"))then
        static ImVec2 size(100.0, 100.0);
        static ImVec2 offset(30.0, 30.0);
        ImGui.DragFloat2("size", (float*)&size, 0.5f, 1.0, 200.0, "%.0");
        ImGui.TextWrapped("(Click and drag to scroll)");

        for (int n = 0; n < 3; n++)then
            if (n > 0)
                ImGui.SameLine();
            ImGui.PushID(n);
            ImGui.BeginGroup(); -- Lock X position

            ImGui.InvisibleButton("----empty", size);
            if (ImGui.IsItemActive() and ImGui.IsMouseDragging(ImGuiMouseButton_Left))then
                offset.x += ImGui.GetIO().MouseDelta.x;
                offset.y += ImGui.GetIO().MouseDelta.y;
            end
            const ImVec2 p0 = ImGui.GetItemRectMin();
            const ImVec2 p1 = ImGui.GetItemRectMax();
            const char* text_str = "Line 1 hello\nLine 2 clip menot ";
            const ImVec2 text_pos = ImVec2(p0.x + offset.x, p0.y + offset.y);
            ImDrawList* draw_list = ImGui.GetWindowDrawList();

            switch (n)then
            case 0:
                HelpMarker(
                    "Using ImGui.PushClipRect():\n"
                    "Will alter ImGui hit-testing logic + ImDrawList rendering.\n"
                    "(use this if you want your clipping rectangle to affect interactions)");
                ImGui.PushClipRect(p0, p1, true);
                draw_list->AddRectFilled(p0, p1, IM_COL32(90, 90, 120, 255));
                draw_list->AddText(text_pos, IM_COL32_WHITE, text_str);
                ImGui.PopClipRect();
                break;
            case 1:
                HelpMarker(
                    "Using ImDrawList.PushClipRect():\n"
                    "Will alter ImDrawList rendering only.\n"
                    "(use this as a shortcut if you are only using ImDrawList calls)");
                draw_list->PushClipRect(p0, p1, true);
                draw_list->AddRectFilled(p0, p1, IM_COL32(90, 90, 120, 255));
                draw_list->AddText(text_pos, IM_COL32_WHITE, text_str);
                draw_list->PopClipRect();
                break;
            case 2:
                HelpMarker(
                    "Using ImDrawList.AddText() with a fine ClipRect:\n"
                    "Will alter only this specific ImDrawList.AddText() rendering.\n"
                    "(this is often used internally to avoid altering the clipping rectangle and minimize draw calls)");
                ImVec4 clip_rect(p0.x, p0.y, p1.x, p1.y); -- AddText() takes a ImVec4* here so let's convert.
                draw_list->AddRectFilled(p0, p1, IM_COL32(90, 90, 120, 255));
                draw_list->AddText(ImGui.GetFont(), ImGui.GetFontSize(), text_pos, IM_COL32_WHITE, text_str, NULL, 0.0, clip_rect);
                break;
            end
            ImGui.EndGroup();
            ImGui.PopID();
        end

        ImGui.TreePop();
    end
end


-- Dummy data structure that we use for the Table demo.
-- (pre-C++11 doesn't allow us to instantiate ImVector<MyItem> template if this structure if defined inside the demo function)
--namespace
--do
-- We are passing our own identifier to TableSetupColumn() to facilitate identifying columns in the sorting code.
-- This identifier will be passed down into ImGuiTableSortSpec.ColumnUserID.
-- But it is possible to omit the user id parameter of TableSetupColumn() and just use the column index insteadnot  (ImGuiTableSortSpec.ColumnIndex)
-- If you don't use sorting, you will generally never care about giving column an IDnot 
enum MyItemColumnID
    MyItemColumnID_ID,
    MyItemColumnID_Name,
    MyItemColumnID_Action,
    MyItemColumnID_Quantity,
    MyItemColumnID_Description
end;

struct MyItem
    int         ID;
    const char* Name;
    int         Quantity;

    -- We have a problem which is affecting _only this demo_ and should not affect your code:
    -- As we don't rely on std. or other third-party library to compile dear imgui, we only have reliable access to qsort(),
    -- however qsort doesn't allow passing user data to comparing function.
    -- As a workaround, we are storing the sort specs in a static/global for the comparing function to access.
    -- In your own use case you would probably pass the sort specs to your sorting/comparing functions directly and not use a global.
    -- We could technically call ImGui.TableGetSortSpecs() in CompareWithSortSpecs(), but considering that this function is called
    -- very often by the sorting algorithm it would be a little wasteful.
    static const ImGuiTableSortSpecs* s_current_sort_specs;

    -- Compare function to be used by qsort()
    static int IMGUI_CDECL CompareWithSortSpecs(const void* lhs, const void* rhs)then
        const MyItem* a = (const MyItem*)lhs;
        const MyItem* b = (const MyItem*)rhs;
        for (int n = 0; n < s_current_sort_specs->SpecsCount; n++)then
            -- Here we identify columns using the ColumnUserID value that we ourselves passed to TableSetupColumn()
            -- We could also choose to identify columns based on their index (sort_spec->ColumnIndex), which is simplernot 
            const ImGuiTableColumnSortSpecs* sort_spec = &s_current_sort_specs->Specs[n];
            int delta = 0;
            switch (sort_spec->ColumnUserID)then
            case MyItemColumnID_ID:             delta = (a->ID - b->ID);                break;
            case MyItemColumnID_Name:           delta = (strcmp(a->Name, b->Name));     break;
            case MyItemColumnID_Quantity:       delta = (a->Quantity - b->Quantity);    break;
            case MyItemColumnID_Description:    delta = (strcmp(a->Name, b->Name));     break;
            default: IM_ASSERT(0); break;
            end
            if (delta > 0)
                return (sort_spec->SortDirection == ImGuiSortDirection_Ascending) ? +1 : -1;
            if (delta < 0)
                return (sort_spec->SortDirection == ImGuiSortDirection_Ascending) ? -1 : +1;
        end

        -- qsort() is instable so always return a way to differenciate items.
        -- Your own compare function may want to avoid fallback on implicit sort specs e.g. a Name compare if it wasn't already part of the sort specs.
        return (a->ID - b->ID);
    end
end;
const ImGuiTableSortSpecs* MyItem.s_current_sort_specs = NULL;
--end

-- Make the UI compact because there are so many fields
function PushStyleCompact()
    ImGuiStyle& style = ImGui.GetStyle();
    ImGui.PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(style.FramePadding.x, (float)(int)(style.FramePadding.y * 0..0)));
    ImGui.PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(style.ItemSpacing.x, (float)(int)(style.ItemSpacing.y * 0..0)));
end

function PopStyleCompact()
    ImGui.PopStyleVar(2);
end

-- Show a combo box with a choice of sizing policies
function EditTableSizingFlags(ImGuiTableFlags* p_flags)
    struct EnumDesc do ImGuiTableFlags Value; const char* Name; const char* Tooltip; end;
    static const EnumDesc policies[] =thenthen ImGuiTableFlags_None,               "Default",                            "Use default sizing policy:\n- ImGuiTableFlags_SizingFixedFit if ScrollX is on or if host window has ImGuiWindowFlags_AlwaysAutoResize.\n- ImGuiTableFlags_SizingStretchSame otherwise." end,then ImGuiTableFlags_SizingFixedFit,     "ImGuiTableFlags_SizingFixedFit",     "Columns default to _WidthFixed (if resizable) or _WidthAuto (if not resizable), matching contents width." end,then ImGuiTableFlags_SizingFixedSame,    "ImGuiTableFlags_SizingFixedSame",    "Columns are all the same width, matching the maximum contents width.\nImplicitly disable ImGuiTableFlags_Resizable and enable ImGuiTableFlags_NoKeepColumnsVisible." end,then ImGuiTableFlags_SizingStretchProp,  "ImGuiTableFlags_SizingStretchProp",  "Columns default to _WidthStretch with weights proportional to their widths." end,then ImGuiTableFlags_SizingStretchSame,  "ImGuiTableFlags_SizingStretchSame",  "Columns default to _WidthStretch with same weights." end
    end;
    int idx;
    for (idx = 0; idx < IM_ARRAYSIZE(policies); idx++)
        if (policies[idx].Value == (*p_flags & ImGuiTableFlags_SizingMask_))
            break;
    const char* preview_text = (idx < IM_ARRAYSIZE(policies)) ? policies[idx].Name + (idx > 0 ? strlen("ImGuiTableFlags") : 0) : "";
    if (ImGui.BeginCombo("Sizing Policy", preview_text))then
        for (int n = 0; n < IM_ARRAYSIZE(policies); n++)
            if (ImGui.Selectable(policies[n].Name, idx == n))
                *p_flags = (*p_flags & ~ImGuiTableFlags_SizingMask_) | policies[n].Value;
        ImGui.EndCombo();
    end
    ImGui.SameLine();
    ImGui.TextDisabled("(?)");
    if (ImGui.IsItemHovered())then
        ImGui.BeginTooltip();
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 50.0);
        for (int m = 0; m < IM_ARRAYSIZE(policies); m++)then
            ImGui.Separator();
            ImGui.Text("%s:", policies[m].Name);
            ImGui.Separator();
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + ImGui.GetStyle().IndentSpacing * 0.5f);
            ImGui.TextUnformatted(policies[m].Tooltip);
        end
        ImGui.PopTextWrapPos();
        ImGui.EndTooltip();
    end
end

function EditTableColumnsFlags(ImGuiTableColumnFlags* p_flags)
    ImGui.CheckboxFlags("_Disabled", p_flags, ImGuiTableColumnFlags_Disabled); ImGui.SameLine(); HelpMarker("Master disable flag (also hide from context menu)");
    ImGui.CheckboxFlags("_DefaultHide", p_flags, ImGuiTableColumnFlags_DefaultHide);
    ImGui.CheckboxFlags("_DefaultSort", p_flags, ImGuiTableColumnFlags_DefaultSort);
    if (ImGui.CheckboxFlags("_WidthStretch", p_flags, ImGuiTableColumnFlags_WidthStretch))
        *p_flags &= ~(ImGuiTableColumnFlags_WidthMask_ ^ ImGuiTableColumnFlags_WidthStretch);
    if (ImGui.CheckboxFlags("_WidthFixed", p_flags, ImGuiTableColumnFlags_WidthFixed))
        *p_flags &= ~(ImGuiTableColumnFlags_WidthMask_ ^ ImGuiTableColumnFlags_WidthFixed);
    ImGui.CheckboxFlags("_NoResize", p_flags, ImGuiTableColumnFlags_NoResize);
    ImGui.CheckboxFlags("_NoReorder", p_flags, ImGuiTableColumnFlags_NoReorder);
    ImGui.CheckboxFlags("_NoHide", p_flags, ImGuiTableColumnFlags_NoHide);
    ImGui.CheckboxFlags("_NoClip", p_flags, ImGuiTableColumnFlags_NoClip);
    ImGui.CheckboxFlags("_NoSort", p_flags, ImGuiTableColumnFlags_NoSort);
    ImGui.CheckboxFlags("_NoSortAscending", p_flags, ImGuiTableColumnFlags_NoSortAscending);
    ImGui.CheckboxFlags("_NoSortDescending", p_flags, ImGuiTableColumnFlags_NoSortDescending);
    ImGui.CheckboxFlags("_NoHeaderLabel", p_flags, ImGuiTableColumnFlags_NoHeaderLabel);
    ImGui.CheckboxFlags("_NoHeaderWidth", p_flags, ImGuiTableColumnFlags_NoHeaderWidth);
    ImGui.CheckboxFlags("_PreferSortAscending", p_flags, ImGuiTableColumnFlags_PreferSortAscending);
    ImGui.CheckboxFlags("_PreferSortDescending", p_flags, ImGuiTableColumnFlags_PreferSortDescending);
    ImGui.CheckboxFlags("_IndentEnable", p_flags, ImGuiTableColumnFlags_IndentEnable); ImGui.SameLine(); HelpMarker("Default for column 0");
    ImGui.CheckboxFlags("_IndentDisable", p_flags, ImGuiTableColumnFlags_IndentDisable); ImGui.SameLine(); HelpMarker("Default for column >0");
end

function ShowTableColumnsStatusFlags(ImGuiTableColumnFlags flags)
    ImGui.CheckboxFlags("_IsEnabled", flags, ImGuiTableColumnFlags_IsEnabled);
    ImGui.CheckboxFlags("_IsVisible", flags, ImGuiTableColumnFlags_IsVisible);
    ImGui.CheckboxFlags("_IsSorted", flags, ImGuiTableColumnFlags_IsSorted);
    ImGui.CheckboxFlags("_IsHovered", flags, ImGuiTableColumnFlags_IsHovered);
end

function ShowDemoWindowTables()
    --ImGui.SetNextItemOpen(true, ImGuiCond_Once);
    if (not ImGui.CollapsingHeader("Tables & Columns"))
        return;

    -- Using those as a base value to create width/height that are factor of the size of our font
    const float TEXT_BASE_WIDTH = ImGui.CalcTextSize("A").x;
    const float TEXT_BASE_HEIGHT = ImGui.GetTextLineHeightWithSpacing();

    ImGui.PushID("Tables");

    int open_action = -1;
    if (ImGui.Button("Open all"))
        open_action = 1;
    ImGui.SameLine();
    if (ImGui.Button("Close all"))
        open_action = 0;
    ImGui.SameLine();

    -- Options
    local disable_indent = false;
    ImGui.Checkbox("Disable tree indentation", disable_indent);
    ImGui.SameLine();
    HelpMarker("Disable the indenting of tree nodes so demo tables can use the full window width.");
    ImGui.Separator();
    if (disable_indent)
        ImGui.PushStyleVar(ImGuiStyleVar_IndentSpacing, 0.0);

    -- About Styling of tables
    -- Most settings are configured on a per-table basis via the flags passed to BeginTable() and TableSetupColumns APIs.
    -- There are however a few settings that a shared and part of the ImGuiStyle structure:
    --   style.CellPadding                          -- Padding within each cell
    --   style.Colors[ImGuiCol_TableHeaderBg]       -- Table header background
    --   style.Colors[ImGuiCol_TableBorderStrong]   -- Table outer and header borders
    --   style.Colors[ImGuiCol_TableBorderLight]    -- Table inner borders
    --   style.Colors[ImGuiCol_TableRowBg]          -- Table row background when ImGuiTableFlags_RowBg is enabled (even rows)
    --   style.Colors[ImGuiCol_TableRowBgAlt]       -- Table row background when ImGuiTableFlags_RowBg is enabled (odds rows)

    -- Demos
    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Basic"))then
        -- Here we will showcase three different ways to output a table.
        -- They are very simple variations of a same thingnot 

        -- [Method 1] Using TableNextRow() to create a new row, and TableSetColumnIndex() to select the column.
        -- In many situations, this is the most flexible and easy to use pattern.
        HelpMarker("Using TableNextRow() + calling TableSetColumnIndex() _before_ each cell, in a loop.");
        if (ImGui.BeginTable("table1", 3))then
            for (int row = 0; row < 4; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 3; column++)then
                    ImGui.TableSetColumnIndex(column);
                    ImGui.Text("Row %d Column %d", row, column);
                end
            end
            ImGui.EndTable();
        end

        -- [Method 2] Using TableNextColumn() called multiple times, instead of using a for loop + TableSetColumnIndex().
        -- This is generally more convenient when you have code manually submitting the contents of each columns.
        HelpMarker("Using TableNextRow() + calling TableNextColumn() _before_ each cell, manually.");
        if (ImGui.BeginTable("table2", 3))then
            for (int row = 0; row < 4; row++)then
                ImGui.TableNextRow();
                ImGui.TableNextColumn();
                ImGui.Text("Row %d", row);
                ImGui.TableNextColumn();
                ImGui.Text("Some contents");
                ImGui.TableNextColumn();
                ImGui.Text("123.456");
            end
            ImGui.EndTable();
        end

        -- [Method 3] We call TableNextColumn() _before_ each cell. We never call TableNextRow(),
        -- as TableNextColumn() will automatically wrap around and create new roes as needed.
        -- This is generally more convenient when your cells all contains the same type of data.
        HelpMarker(
            "Only using TableNextColumn(), which tends to be convenient for tables where every cells contains the same type of contents.\n"
            "This is also more similar to the old NextColumn() function of the Columns API, and provided to facilitate the Columns->Tables API transition.");
        if (ImGui.BeginTable("table3", 3))then
            for (int item = 0; item < 14; item++)then
                ImGui.TableNextColumn();
                ImGui.Text("Item %d", item);
            end
            ImGui.EndTable();
        end

        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Borders, background"))then
        -- Expose a few Borders related flags interactively
        enum ContentsType do CT_Text, CT_FillButton end;
        static ImGuiTableFlags flags = ImGuiTableFlags_Borders | ImGuiTableFlags_RowBg;
        local display_headers = false;
        static int contents_type = CT_Text;

        PushStyleCompact();
        ImGui.CheckboxFlags("ImGuiTableFlags_RowBg", flags, ImGuiTableFlags_RowBg);
        ImGui.CheckboxFlags("ImGuiTableFlags_Borders", flags, ImGuiTableFlags_Borders);
        ImGui.SameLine(); HelpMarker("ImGuiTableFlags_Borders\n = ImGuiTableFlags_BordersInnerV\n | ImGuiTableFlags_BordersOuterV\n | ImGuiTableFlags_BordersInnerV\n | ImGuiTableFlags_BordersOuterH");
        ImGui.Indent();

        ImGui.CheckboxFlags("ImGuiTableFlags_BordersH", flags, ImGuiTableFlags_BordersH);
        ImGui.Indent();
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersOuterH", flags, ImGuiTableFlags_BordersOuterH);
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersInnerH", flags, ImGuiTableFlags_BordersInnerH);
        ImGui.Unindent();

        ImGui.CheckboxFlags("ImGuiTableFlags_BordersV", flags, ImGuiTableFlags_BordersV);
        ImGui.Indent();
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersOuterV", flags, ImGuiTableFlags_BordersOuterV);
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersInnerV", flags, ImGuiTableFlags_BordersInnerV);
        ImGui.Unindent();

        ImGui.CheckboxFlags("ImGuiTableFlags_BordersOuter", flags, ImGuiTableFlags_BordersOuter);
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersInner", flags, ImGuiTableFlags_BordersInner);
        ImGui.Unindent();

        ImGui.AlignTextToFramePadding(); ImGui.Text("Cell contents:");
        ImGui.SameLine(); ImGui.RadioButton("Text", contents_type, CT_Text);
        ImGui.SameLine(); ImGui.RadioButton("FillButton", contents_type, CT_FillButton);
        ImGui.Checkbox("Display headers", display_headers);
        ImGui.CheckboxFlags("ImGuiTableFlags_NoBordersInBody", flags, ImGuiTableFlags_NoBordersInBody); ImGui.SameLine(); HelpMarker("Disable vertical borders in columns Body (borders will always appears in Headers");
        PopStyleCompact();

        if (ImGui.BeginTable("table1", 3, flags))then
            -- Display headers so we can inspect their interaction with borders.
            -- (Headers are not the main purpose of this section of the demo, so we are not elaborating on them too much. See other sections for details)
            if (display_headers)then
                ImGui.TableSetupColumn("One");
                ImGui.TableSetupColumn("Two");
                ImGui.TableSetupColumn("Three");
                ImGui.TableHeadersRow();
            end

            for (int row = 0; row < 5; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 3; column++)then
                    ImGui.TableSetColumnIndex(column);
                    char buf[32];
                    sprintf(buf, "Hello %d,%d", column, row);
                    if (contents_type == CT_Text)
                        ImGui.TextUnformatted(buf);
                    else if (contents_type)
                        ImGui.Button(buf, ImVec2(-FLT_MIN, 0.0));
                end
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Resizable, stretch"))then
        -- By default, if we don't enable ScrollX the sizing policy for each columns is "Stretch"
        -- Each columns maintain a sizing weight, and they will occupy all available width.
        static ImGuiTableFlags flags = ImGuiTableFlags_SizingStretchSame | ImGuiTableFlags_Resizable | ImGuiTableFlags_BordersOuter | ImGuiTableFlags_BordersV | ImGuiTableFlags_ContextMenuInBody;
        PushStyleCompact();
        ImGui.CheckboxFlags("ImGuiTableFlags_Resizable", flags, ImGuiTableFlags_Resizable);
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersV", flags, ImGuiTableFlags_BordersV);
        ImGui.SameLine(); HelpMarker("Using the _Resizable flag automatically enables the _BordersInnerV flag as well, this is why the resize borders are still showing when unchecking this.");
        PopStyleCompact();

        if (ImGui.BeginTable("table1", 3, flags))then
            for (int row = 0; row < 5; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 3; column++)then
                    ImGui.TableSetColumnIndex(column);
                    ImGui.Text("Hello %d,%d", column, row);
                end
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Resizable, fixed"))then
        -- Here we use ImGuiTableFlags_SizingFixedFit (even though _ScrollX is not set)
        -- So columns will adopt the "Fixed" policy and will maintain a fixed width regardless of the whole available width (unless table is small)
        -- If there is not enough available width to fit all columns, they will however be resized down.
        -- FIXME-TABLE: Providing a stretch-on-init would make sense especially for tables which don't have saved settings
        HelpMarker(
            "Using _Resizable + _SizingFixedFit flags.\n"
            "Fixed-width columns generally makes more sense if you want to use horizontal scrolling.\n\n"
            "Double-click a column border to auto-fit the column to its contents.");
        PushStyleCompact();
        static ImGuiTableFlags flags = ImGuiTableFlags_SizingFixedFit | ImGuiTableFlags_Resizable | ImGuiTableFlags_BordersOuter | ImGuiTableFlags_BordersV | ImGuiTableFlags_ContextMenuInBody;
        ImGui.CheckboxFlags("ImGuiTableFlags_NoHostExtendX", flags, ImGuiTableFlags_NoHostExtendX);
        PopStyleCompact();

        if (ImGui.BeginTable("table1", 3, flags))then
            for (int row = 0; row < 5; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 3; column++)then
                    ImGui.TableSetColumnIndex(column);
                    ImGui.Text("Hello %d,%d", column, row);
                end
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Resizable, mixed"))then
        HelpMarker(
            "Using TableSetupColumn() to alter resizing policy on a per-column basis.\n\n"
            "When combining Fixed and Stretch columns, generally you only want one, maybe two trailing columns to use _WidthStretch.");
        static ImGuiTableFlags flags = ImGuiTableFlags_SizingFixedFit | ImGuiTableFlags_RowBg | ImGuiTableFlags_Borders | ImGuiTableFlags_Resizable | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable;

        if (ImGui.BeginTable("table1", 3, flags))then
            ImGui.TableSetupColumn("AAA", ImGuiTableColumnFlags_WidthFixed);
            ImGui.TableSetupColumn("BBB", ImGuiTableColumnFlags_WidthFixed);
            ImGui.TableSetupColumn("CCC", ImGuiTableColumnFlags_WidthStretch);
            ImGui.TableHeadersRow();
            for (int row = 0; row < 5; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 3; column++)then
                    ImGui.TableSetColumnIndex(column);
                    ImGui.Text("%s %d,%d", (column == 2) ? "Stretch" : "Fixed", column, row);
                end
            end
            ImGui.EndTable();
        end
        if (ImGui.BeginTable("table2", 6, flags))then
            ImGui.TableSetupColumn("AAA", ImGuiTableColumnFlags_WidthFixed);
            ImGui.TableSetupColumn("BBB", ImGuiTableColumnFlags_WidthFixed);
            ImGui.TableSetupColumn("CCC", ImGuiTableColumnFlags_WidthFixed | ImGuiTableColumnFlags_DefaultHide);
            ImGui.TableSetupColumn("DDD", ImGuiTableColumnFlags_WidthStretch);
            ImGui.TableSetupColumn("EEE", ImGuiTableColumnFlags_WidthStretch);
            ImGui.TableSetupColumn("FFF", ImGuiTableColumnFlags_WidthStretch | ImGuiTableColumnFlags_DefaultHide);
            ImGui.TableHeadersRow();
            for (int row = 0; row < 5; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 6; column++)then
                    ImGui.TableSetColumnIndex(column);
                    ImGui.Text("%s %d,%d", (column >= 3) ? "Stretch" : "Fixed", column, row);
                end
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Reorderable, hideable, with headers"))then
        HelpMarker(
            "Click and drag column headers to reorder columns.\n\n"
            "Right-click on a header to open a context menu.");
        static ImGuiTableFlags flags = ImGuiTableFlags_Resizable | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable | ImGuiTableFlags_BordersOuter | ImGuiTableFlags_BordersV;
        PushStyleCompact();
        ImGui.CheckboxFlags("ImGuiTableFlags_Resizable", flags, ImGuiTableFlags_Resizable);
        ImGui.CheckboxFlags("ImGuiTableFlags_Reorderable", flags, ImGuiTableFlags_Reorderable);
        ImGui.CheckboxFlags("ImGuiTableFlags_Hideable", flags, ImGuiTableFlags_Hideable);
        ImGui.CheckboxFlags("ImGuiTableFlags_NoBordersInBody", flags, ImGuiTableFlags_NoBordersInBody);
        ImGui.CheckboxFlags("ImGuiTableFlags_NoBordersInBodyUntilResize", flags, ImGuiTableFlags_NoBordersInBodyUntilResize); ImGui.SameLine(); HelpMarker("Disable vertical borders in columns Body until hovered for resize (borders will always appears in Headers)");
        PopStyleCompact();

        if (ImGui.BeginTable("table1", 3, flags))then
            -- Submit columns name with TableSetupColumn() and call TableHeadersRow() to create a row with a header in each column.
            -- (Later we will show how TableSetupColumn() has other uses, optional flags, sizing weight etc.)
            ImGui.TableSetupColumn("One");
            ImGui.TableSetupColumn("Two");
            ImGui.TableSetupColumn("Three");
            ImGui.TableHeadersRow();
            for (int row = 0; row < 6; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 3; column++)then
                    ImGui.TableSetColumnIndex(column);
                    ImGui.Text("Hello %d,%d", column, row);
                end
            end
            ImGui.EndTable();
        end

        -- Use outer_size.x == 0.0 instead of default to make the table as tight as possible (only valid when no scrolling and no stretch column)
        if (ImGui.BeginTable("table2", 3, flags | ImGuiTableFlags_SizingFixedFit, ImVec2(0.0, 0.0)))then
            ImGui.TableSetupColumn("One");
            ImGui.TableSetupColumn("Two");
            ImGui.TableSetupColumn("Three");
            ImGui.TableHeadersRow();
            for (int row = 0; row < 6; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 3; column++)then
                    ImGui.TableSetColumnIndex(column);
                    ImGui.Text("Fixed %d,%d", column, row);
                end
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Padding"))then
        -- First example: showcase use of padding flags and effect of BorderOuterV/BorderInnerV on X padding.
        -- We don't expose BorderOuterH/BorderInnerH here because they have no effect on X padding.
        HelpMarker(
            "We often want outer padding activated when any using features which makes the edges of a column visible:\n"
            "e.g.:\n"
            "- BorderOuterV\n"
            "- any form of row selection\n"
            "Because of this, activating BorderOuterV sets the default to PadOuterX. Using PadOuterX or NoPadOuterX you can override the default.\n\n"
            "Actual padding values are using style.CellPadding.\n\n"
            "In this demo we don't show horizontal borders to emphasis how they don't affect default horizontal padding.");

        static ImGuiTableFlags flags1 = ImGuiTableFlags_BordersV;
        PushStyleCompact();
        ImGui.CheckboxFlags("ImGuiTableFlags_PadOuterX", flags1, ImGuiTableFlags_PadOuterX);
        ImGui.SameLine(); HelpMarker("Enable outer-most padding (default if ImGuiTableFlags_BordersOuterV is set)");
        ImGui.CheckboxFlags("ImGuiTableFlags_NoPadOuterX", flags1, ImGuiTableFlags_NoPadOuterX);
        ImGui.SameLine(); HelpMarker("Disable outer-most padding (default if ImGuiTableFlags_BordersOuterV is not set)");
        ImGui.CheckboxFlags("ImGuiTableFlags_NoPadInnerX", flags1, ImGuiTableFlags_NoPadInnerX);
        ImGui.SameLine(); HelpMarker("Disable inner padding between columns (double inner padding if BordersOuterV is on, single inner padding if BordersOuterV is off)");
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersOuterV", flags1, ImGuiTableFlags_BordersOuterV);
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersInnerV", flags1, ImGuiTableFlags_BordersInnerV);
        local show_headers = false;
        ImGui.Checkbox("show_headers", show_headers);
        PopStyleCompact();

        if (ImGui.BeginTable("table_padding", 3, flags1))then
            if (show_headers)then
                ImGui.TableSetupColumn("One");
                ImGui.TableSetupColumn("Two");
                ImGui.TableSetupColumn("Three");
                ImGui.TableHeadersRow();
            end

            for (int row = 0; row < 5; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 3; column++)then
                    ImGui.TableSetColumnIndex(column);
                    if (row == 0)then
                        ImGui.Text("Avail %.2f", ImGui.GetContentRegionAvail().x);
                    end
                    elsethen
                        char buf[32];
                        sprintf(buf, "Hello %d,%d", column, row);
                        ImGui.Button(buf, ImVec2(-FLT_MIN, 0.0));
                    end
                    --if (ImGui.TableGetColumnFlags() & ImGuiTableColumnFlags_IsHovered)
                    --    ImGui.TableSetBgColor(ImGuiTableBgTarget_CellBg, IM_COL32(0, 100, 0, 255));
                end
            end
            ImGui.EndTable();
        end

        -- Second example: set style.CellPadding to (0.0) or a custom value.
        -- FIXME-TABLE: Vertical border effectively not displayed the same way as horizontal one...
        HelpMarker("Setting style.CellPadding to (0,0) or a custom value.");
        static ImGuiTableFlags flags2 = ImGuiTableFlags_Borders | ImGuiTableFlags_RowBg;
        static ImVec2 cell_padding(0.0, 0.0);
        local show_widget_frame_bg = true;

        PushStyleCompact();
        ImGui.CheckboxFlags("ImGuiTableFlags_Borders", flags2, ImGuiTableFlags_Borders);
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersH", flags2, ImGuiTableFlags_BordersH);
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersV", flags2, ImGuiTableFlags_BordersV);
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersInner", flags2, ImGuiTableFlags_BordersInner);
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersOuter", flags2, ImGuiTableFlags_BordersOuter);
        ImGui.CheckboxFlags("ImGuiTableFlags_RowBg", flags2, ImGuiTableFlags_RowBg);
        ImGui.CheckboxFlags("ImGuiTableFlags_Resizable", flags2, ImGuiTableFlags_Resizable);
        ImGui.Checkbox("show_widget_frame_bg", show_widget_frame_bg);
        ImGui.SliderFloat2("CellPadding", cell_padding.x, 0.0, 10.0, "%.0");
        PopStyleCompact();

        ImGui.PushStyleVar(ImGuiStyleVar_CellPadding, cell_padding);
        if (ImGui.BeginTable("table_padding_2", 3, flags2))then
            static char text_bufs[3 * 5][16]; -- Mini text storage for 3x5 cells
            local init = true;
            if (not show_widget_frame_bg)
                ImGui.PushStyleColor(ImGuiCol_FrameBg, 0);
            for (int cell = 0; cell < 3 * 5; cell++)then
                ImGui.TableNextColumn();
                if (init)
                    strcpy(text_bufs[cell], "edit me");
                ImGui.SetNextItemWidth(-FLT_MIN);
                ImGui.PushID(cell);
                ImGui.InputText("----cell", text_bufs[cell], IM_ARRAYSIZE(text_bufs[cell]));
                ImGui.PopID();
            end
            if (not show_widget_frame_bg)
                ImGui.PopStyleColor();
            init = false;
            ImGui.EndTable();
        end
        ImGui.PopStyleVar();

        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Sizing policies"))then
        static ImGuiTableFlags flags1 = ImGuiTableFlags_BordersV | ImGuiTableFlags_BordersOuterH | ImGuiTableFlags_RowBg | ImGuiTableFlags_ContextMenuInBody;
        PushStyleCompact();
        ImGui.CheckboxFlags("ImGuiTableFlags_Resizable", flags1, ImGuiTableFlags_Resizable);
        ImGui.CheckboxFlags("ImGuiTableFlags_NoHostExtendX", flags1, ImGuiTableFlags_NoHostExtendX);
        PopStyleCompact();

        static ImGuiTableFlags sizing_policy_flags[4] = do ImGuiTableFlags_SizingFixedFit, ImGuiTableFlags_SizingFixedSame, ImGuiTableFlags_SizingStretchProp, ImGuiTableFlags_SizingStretchSame end;
        for (int table_n = 0; table_n < 4; table_n++)then
            ImGui.PushID(table_n);
            ImGui.SetNextItemWidth(TEXT_BASE_WIDTH * 30);
            EditTableSizingFlags(&sizing_policy_flags[table_n]);

            -- To make it easier to understand the different sizing policy,
            -- For each policy: we display one table where the columns have equal contents width, and one where the columns have different contents width.
            if (ImGui.BeginTable("table1", 3, sizing_policy_flags[table_n] | flags1))then
                for (int row = 0; row < 3; row++)then
                    ImGui.TableNextRow();
                    ImGui.TableNextColumn(); ImGui.Text("Oh dear");
                    ImGui.TableNextColumn(); ImGui.Text("Oh dear");
                    ImGui.TableNextColumn(); ImGui.Text("Oh dear");
                end
                ImGui.EndTable();
            end
            if (ImGui.BeginTable("table2", 3, sizing_policy_flags[table_n] | flags1))then
                for (int row = 0; row < 3; row++)then
                    ImGui.TableNextRow();
                    ImGui.TableNextColumn(); ImGui.Text("AAAA");
                    ImGui.TableNextColumn(); ImGui.Text("BBBBBBBB");
                    ImGui.TableNextColumn(); ImGui.Text("CCCCCCCCCCCC");
                end
                ImGui.EndTable();
            end
            ImGui.PopID();
        end

        ImGui.Spacing();
        ImGui.TextUnformatted("Advanced");
        ImGui.SameLine();
        HelpMarker("This section allows you to interact and see the effect of various sizing policies depending on whether Scroll is enabled and the contents of your columns.");

        enum ContentsType do CT_ShowWidth, CT_ShortText, CT_LongText, CT_Button, CT_FillButton, CT_InputText end;
        static ImGuiTableFlags flags = ImGuiTableFlags_ScrollY | ImGuiTableFlags_Borders | ImGuiTableFlags_RowBg | ImGuiTableFlags_Resizable;
        static int contents_type = CT_ShowWidth;
        static int column_count = 3;

        PushStyleCompact();
        ImGui.PushID("Advanced");
        ImGui.PushItemWidth(TEXT_BASE_WIDTH * 30);
        EditTableSizingFlags(&flags);
        ImGui.Combo("Contents", contents_type, "Show width\0Short Text\0Long Text\0Button\0Fill Button\0InputText\0");
        if (contents_type == CT_FillButton)then
            ImGui.SameLine();
            HelpMarker("Be mindful that using right-alignment (e.g. size.x = -FLT_MIN) creates a feedback loop where contents width can feed into auto-column width can feed into contents width.");
        end
        ImGui.DragInt("Columns", column_count, 0.1f, 1, 64, "%d", ImGuiSliderFlags_AlwaysClamp);
        ImGui.CheckboxFlags("ImGuiTableFlags_Resizable", flags, ImGuiTableFlags_Resizable);
        ImGui.CheckboxFlags("ImGuiTableFlags_PreciseWidths", flags, ImGuiTableFlags_PreciseWidths);
        ImGui.SameLine(); HelpMarker("Disable distributing remainder width to stretched columns (width allocation on a 100-wide table with 3 columns: Without this flag: 33,33,34. With this flag: 33,33,33). With larger number of columns, resizing will appear to be less smooth.");
        ImGui.CheckboxFlags("ImGuiTableFlags_ScrollX", flags, ImGuiTableFlags_ScrollX);
        ImGui.CheckboxFlags("ImGuiTableFlags_ScrollY", flags, ImGuiTableFlags_ScrollY);
        ImGui.CheckboxFlags("ImGuiTableFlags_NoClip", flags, ImGuiTableFlags_NoClip);
        ImGui.PopItemWidth();
        ImGui.PopID();
        PopStyleCompact();

        if (ImGui.BeginTable("table2", column_count, flags, ImVec2(0.0, TEXT_BASE_HEIGHT * 7)))then
            for (int cell = 0; cell < 10 * column_count; cell++)then
                ImGui.TableNextColumn();
                int column = ImGui.TableGetColumnIndex();
                int row = ImGui.TableGetRowIndex();

                ImGui.PushID(cell);
                char label[32];
                static char text_buf[32] = "";
                sprintf(label, "Hello %d,%d", column, row);
                switch (contents_type)then
                case CT_ShortText:  ImGui.TextUnformatted(label); break;
                case CT_LongText:   ImGui.Text("Some %s text %d,%d\nOver two lines..", column == 0 ? "long" : "longeeer", column, row); break;
                case CT_ShowWidth:  ImGui.Text("W: %.1f", ImGui.GetContentRegionAvail().x); break;
                case CT_Button:     ImGui.Button(label); break;
                case CT_FillButton: ImGui.Button(label, ImVec2(-FLT_MIN, 0.0)); break;
                case CT_InputText:  ImGui.SetNextItemWidth(-FLT_MIN); ImGui.InputText("----", text_buf, IM_ARRAYSIZE(text_buf)); break;
                end
                ImGui.PopID();
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Vertical scrolling, with clipping"))then
        HelpMarker("Here we activate ScrollY, which will create a child window container to allow hosting scrollable contents.\n\nWe also demonstrate using ImGuiListClipper to virtualize the submission of many items.");
        static ImGuiTableFlags flags = ImGuiTableFlags_ScrollY | ImGuiTableFlags_RowBg | ImGuiTableFlags_BordersOuter | ImGuiTableFlags_BordersV | ImGuiTableFlags_Resizable | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable;

        PushStyleCompact();
        ImGui.CheckboxFlags("ImGuiTableFlags_ScrollY", flags, ImGuiTableFlags_ScrollY);
        PopStyleCompact();

        -- When using ScrollX or ScrollY we need to specify a size for our table containernot 
        -- Otherwise by default the table will fit all available space, like a BeginChild() call.
        ImVec2 outer_size = ImVec2(0.0, TEXT_BASE_HEIGHT * 8);
        if (ImGui.BeginTable("table_scrolly", 3, flags, outer_size))then
            ImGui.TableSetupScrollFreeze(0, 1); -- Make top row always visible
            ImGui.TableSetupColumn("One", ImGuiTableColumnFlags_None);
            ImGui.TableSetupColumn("Two", ImGuiTableColumnFlags_None);
            ImGui.TableSetupColumn("Three", ImGuiTableColumnFlags_None);
            ImGui.TableHeadersRow();

            -- Demonstrate using clipper for large vertical lists
            ImGuiListClipper clipper;
            clipper.Begin(1000);
            while (clipper.Step())then
                for (int row = clipper.DisplayStart; row < clipper.DisplayEnd; row++)then
                    ImGui.TableNextRow();
                    for (int column = 0; column < 3; column++)then
                        ImGui.TableSetColumnIndex(column);
                        ImGui.Text("Hello %d,%d", column, row);
                    end
                end
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Horizontal scrolling"))then
        HelpMarker(
            "When ScrollX is enabled, the default sizing policy becomes ImGuiTableFlags_SizingFixedFit, "
            "as automatically stretching columns doesn't make much sense with horizontal scrolling.\n\n"
            "Also note that as of the current version, you will almost always want to enable ScrollY along with ScrollX,"
            "because the container window won't automatically extend vertically to fix contents (this may be improved in future versions).");
        static ImGuiTableFlags flags = ImGuiTableFlags_ScrollX | ImGuiTableFlags_ScrollY | ImGuiTableFlags_RowBg | ImGuiTableFlags_BordersOuter | ImGuiTableFlags_BordersV | ImGuiTableFlags_Resizable | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable;
        static int freeze_cols = 1;
        static int freeze_rows = 1;

        PushStyleCompact();
        ImGui.CheckboxFlags("ImGuiTableFlags_Resizable", flags, ImGuiTableFlags_Resizable);
        ImGui.CheckboxFlags("ImGuiTableFlags_ScrollX", flags, ImGuiTableFlags_ScrollX);
        ImGui.CheckboxFlags("ImGuiTableFlags_ScrollY", flags, ImGuiTableFlags_ScrollY);
        ImGui.SetNextItemWidth(ImGui.GetFrameHeight());
        ImGui.DragInt("freeze_cols", freeze_cols, 0.2f, 0, 9, NULL, ImGuiSliderFlags_NoInput);
        ImGui.SetNextItemWidth(ImGui.GetFrameHeight());
        ImGui.DragInt("freeze_rows", freeze_rows, 0.2f, 0, 9, NULL, ImGuiSliderFlags_NoInput);
        PopStyleCompact();

        -- When using ScrollX or ScrollY we need to specify a size for our table containernot 
        -- Otherwise by default the table will fit all available space, like a BeginChild() call.
        ImVec2 outer_size = ImVec2(0.0, TEXT_BASE_HEIGHT * 8);
        if (ImGui.BeginTable("table_scrollx", 7, flags, outer_size))then
            ImGui.TableSetupScrollFreeze(freeze_cols, freeze_rows);
            ImGui.TableSetupColumn("Line --", ImGuiTableColumnFlags_NoHide); -- Make the first column not hideable to match our use of TableSetupScrollFreeze()
            ImGui.TableSetupColumn("One");
            ImGui.TableSetupColumn("Two");
            ImGui.TableSetupColumn("Three");
            ImGui.TableSetupColumn("Four");
            ImGui.TableSetupColumn("Five");
            ImGui.TableSetupColumn("Six");
            ImGui.TableHeadersRow();
            for (int row = 0; row < 20; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 7; column++)then
                    -- Both TableNextColumn() and TableSetColumnIndex() return true when a column is visible or performing width measurement.
                    -- Because here we know that:
                    -- - A) all our columns are contributing the same to row height
                    -- - B) column 0 is always visible,
                    -- We only always submit this one column and can skip others.
                    -- More advanced per-column clipping behaviors may benefit from polling the status flags via TableGetColumnFlags().
                    if (not ImGui.TableSetColumnIndex(column) and column > 0)
                        continue;
                    if (column == 0)
                        ImGui.Text("Line %d", row);
                    else
                        ImGui.Text("Hello world %d,%d", column, row);
                end
            end
            ImGui.EndTable();
        end

        ImGui.Spacing();
        ImGui.TextUnformatted("Stretch + ScrollX");
        ImGui.SameLine();
        HelpMarker(
            "Showcase using Stretch columns + ScrollX together: "
            "this is rather unusual and only makes sense when specifying an 'inner_width' for the tablenot \n"
            "Without an explicit value, inner_width is == outer_size.x and therefore using Stretch columns + ScrollX together doesn't make sense.");
        static ImGuiTableFlags flags2 = ImGuiTableFlags_SizingStretchSame | ImGuiTableFlags_ScrollX | ImGuiTableFlags_ScrollY | ImGuiTableFlags_BordersOuter | ImGuiTableFlags_RowBg | ImGuiTableFlags_ContextMenuInBody;
        static float inner_width = 1000.0;
        PushStyleCompact();
        ImGui.PushID("flags3");
        ImGui.PushItemWidth(TEXT_BASE_WIDTH * 30);
        ImGui.CheckboxFlags("ImGuiTableFlags_ScrollX", flags2, ImGuiTableFlags_ScrollX);
        ImGui.DragFloat("inner_width", inner_width, 1.0, 0.0, FLT_MAX, "%.1f");
        ImGui.PopItemWidth();
        ImGui.PopID();
        PopStyleCompact();
        if (ImGui.BeginTable("table2", 7, flags2, outer_size, inner_width))then
            for (int cell = 0; cell < 20 * 7; cell++)then
                ImGui.TableNextColumn();
                ImGui.Text("Hello world %d,%d", ImGui.TableGetColumnIndex(), ImGui.TableGetRowIndex());
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Columns flags"))then
        -- Create a first table just to show all the options/flags we want to make visible in our examplenot 
        const int column_count = 3;
        const char* column_names[column_count] = do "One", "Two", "Three" end;
        static ImGuiTableColumnFlags column_flags[column_count] = do ImGuiTableColumnFlags_DefaultSort, ImGuiTableColumnFlags_None, ImGuiTableColumnFlags_DefaultHide end;
        static ImGuiTableColumnFlags column_flags_out[column_count] = do 0, 0, 0 end; -- Output from TableGetColumnFlags()

        if (ImGui.BeginTable("table_columns_flags_checkboxes", column_count, ImGuiTableFlags_None))then
            PushStyleCompact();
            for (int column = 0; column < column_count; column++)then
                ImGui.TableNextColumn();
                ImGui.PushID(column);
                ImGui.AlignTextToFramePadding(); -- FIXME-TABLE: Workaround for wrong text baseline propagation
                ImGui.Text("'%s'", column_names[column]);
                ImGui.Spacing();
                ImGui.Text("Input flags:");
                EditTableColumnsFlags(&column_flags[column]);
                ImGui.Spacing();
                ImGui.Text("Output flags:");
                ShowTableColumnsStatusFlags(column_flags_out[column]);
                ImGui.PopID();
            end
            PopStyleCompact();
            ImGui.EndTable();
        end

        -- Create the real table we care about for the examplenot 
        -- We use a scrolling table to be able to showcase the difference between the _IsEnabled and _IsVisible flags above, otherwise in
        -- a non-scrolling table columns are always visible (unless using ImGuiTableFlags_NoKeepColumnsVisible + resizing the parent window down)
        const ImGuiTableFlags flags
            = ImGuiTableFlags_SizingFixedFit | ImGuiTableFlags_ScrollX | ImGuiTableFlags_ScrollY
            | ImGuiTableFlags_RowBg | ImGuiTableFlags_BordersOuter | ImGuiTableFlags_BordersV
            | ImGuiTableFlags_Resizable | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable | ImGuiTableFlags_Sortable;
        ImVec2 outer_size = ImVec2(0.0, TEXT_BASE_HEIGHT * 9);
        if (ImGui.BeginTable("table_columns_flags", column_count, flags, outer_size))then
            for (int column = 0; column < column_count; column++)
                ImGui.TableSetupColumn(column_names[column], column_flags[column]);
            ImGui.TableHeadersRow();
            for (int column = 0; column < column_count; column++)
                column_flags_out[column] = ImGui.TableGetColumnFlags(column);
            float indent_step = (float)((int)TEXT_BASE_WIDTH / 2);
            for (int row = 0; row < 8; row++)then
                ImGui.Indent(indent_step); -- Add some indentation to demonstrate usage of per-column IndentEnable/IndentDisable flags.
                ImGui.TableNextRow();
                for (int column = 0; column < column_count; column++)then
                    ImGui.TableSetColumnIndex(column);
                    ImGui.Text("%s %s", (column == 0) ? "Indented" : "Hello", ImGui.TableGetColumnName(column));
                end
            end
            ImGui.Unindent(indent_step * 8.0);

            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Columns widths"))then
        HelpMarker("Using TableSetupColumn() to setup default width.");

        static ImGuiTableFlags flags1 = ImGuiTableFlags_Borders | ImGuiTableFlags_NoBordersInBodyUntilResize;
        PushStyleCompact();
        ImGui.CheckboxFlags("ImGuiTableFlags_Resizable", flags1, ImGuiTableFlags_Resizable);
        ImGui.CheckboxFlags("ImGuiTableFlags_NoBordersInBodyUntilResize", flags1, ImGuiTableFlags_NoBordersInBodyUntilResize);
        PopStyleCompact();
        if (ImGui.BeginTable("table1", 3, flags1))then
            -- We could also set ImGuiTableFlags_SizingFixedFit on the table and all columns will default to ImGuiTableColumnFlags_WidthFixed.
            ImGui.TableSetupColumn("one", ImGuiTableColumnFlags_WidthFixed, 100.0); -- Default to 100.0
            ImGui.TableSetupColumn("two", ImGuiTableColumnFlags_WidthFixed, 200.0); -- Default to 200.0
            ImGui.TableSetupColumn("three", ImGuiTableColumnFlags_WidthFixed);       -- Default to auto
            ImGui.TableHeadersRow();
            for (int row = 0; row < 4; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 3; column++)then
                    ImGui.TableSetColumnIndex(column);
                    if (row == 0)
                        ImGui.Text("(w: %5.1f)", ImGui.GetContentRegionAvail().x);
                    else
                        ImGui.Text("Hello %d,%d", column, row);
                end
            end
            ImGui.EndTable();
        end

        HelpMarker("Using TableSetupColumn() to setup explicit width.\n\nUnless _NoKeepColumnsVisible is set, fixed columns with set width may still be shrunk down if there's not enough space in the host.");

        static ImGuiTableFlags flags2 = ImGuiTableFlags_None;
        PushStyleCompact();
        ImGui.CheckboxFlags("ImGuiTableFlags_NoKeepColumnsVisible", flags2, ImGuiTableFlags_NoKeepColumnsVisible);
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersInnerV", flags2, ImGuiTableFlags_BordersInnerV);
        ImGui.CheckboxFlags("ImGuiTableFlags_BordersOuterV", flags2, ImGuiTableFlags_BordersOuterV);
        PopStyleCompact();
        if (ImGui.BeginTable("table2", 4, flags2))then
            -- We could also set ImGuiTableFlags_SizingFixedFit on the table and all columns will default to ImGuiTableColumnFlags_WidthFixed.
            ImGui.TableSetupColumn("", ImGuiTableColumnFlags_WidthFixed, 100.0);
            ImGui.TableSetupColumn("", ImGuiTableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 15.0);
            ImGui.TableSetupColumn("", ImGuiTableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 30.0);
            ImGui.TableSetupColumn("", ImGuiTableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 15.0);
            for (int row = 0; row < 5; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 4; column++)then
                    ImGui.TableSetColumnIndex(column);
                    if (row == 0)
                        ImGui.Text("(w: %5.1f)", ImGui.GetContentRegionAvail().x);
                    else
                        ImGui.Text("Hello %d,%d", column, row);
                end
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Nested tables"))then
        HelpMarker("This demonstrate embedding a table into another table cell.");

        if (ImGui.BeginTable("table_nested1", 2, ImGuiTableFlags_Borders | ImGuiTableFlags_Resizable | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable))then
            ImGui.TableSetupColumn("A0");
            ImGui.TableSetupColumn("A1");
            ImGui.TableHeadersRow();

            ImGui.TableNextColumn();
            ImGui.Text("A0 Row 0");then
                float rows_height = TEXT_BASE_HEIGHT * 2;
                if (ImGui.BeginTable("table_nested2", 2, ImGuiTableFlags_Borders | ImGuiTableFlags_Resizable | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable))then
                    ImGui.TableSetupColumn("B0");
                    ImGui.TableSetupColumn("B1");
                    ImGui.TableHeadersRow();

                    ImGui.TableNextRow(ImGuiTableRowFlags_None, rows_height);
                    ImGui.TableNextColumn();
                    ImGui.Text("B0 Row 0");
                    ImGui.TableNextColumn();
                    ImGui.Text("B1 Row 0");
                    ImGui.TableNextRow(ImGuiTableRowFlags_None, rows_height);
                    ImGui.TableNextColumn();
                    ImGui.Text("B0 Row 1");
                    ImGui.TableNextColumn();
                    ImGui.Text("B1 Row 1");

                    ImGui.EndTable();
                end
            end
            ImGui.TableNextColumn(); ImGui.Text("A1 Row 0");
            ImGui.TableNextColumn(); ImGui.Text("A0 Row 1");
            ImGui.TableNextColumn(); ImGui.Text("A1 Row 1");
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Row height"))then
        HelpMarker("You can pass a 'min_row_height' to TableNextRow().\n\nRows are padded with 'style.CellPadding.y' on top and bottom, so effectively the minimum row height will always be >= 'style.CellPadding.y * 2.0'.\n\nWe cannot honor a _maximum_ row height as that would requires a unique clipping rectangle per row.");
        if (ImGui.BeginTable("table_row_height", 1, ImGuiTableFlags_BordersOuter | ImGuiTableFlags_BordersInnerV))then
            for (int row = 0; row < 10; row++)then
                float min_row_height = (float)(int)(TEXT_BASE_HEIGHT * 0..0 * row);
                ImGui.TableNextRow(ImGuiTableRowFlags_None, min_row_height);
                ImGui.TableNextColumn();
                ImGui.Text("min_row_height = %.2f", min_row_height);
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Outer size"))then
        -- Showcasing use of ImGuiTableFlags_NoHostExtendX and ImGuiTableFlags_NoHostExtendY
        -- Important to that note how the two flags have slightly different behaviorsnot 
        ImGui.Text("Using NoHostExtendX and NoHostExtendY:");
        PushStyleCompact();
        static ImGuiTableFlags flags = ImGuiTableFlags_Borders | ImGuiTableFlags_Resizable | ImGuiTableFlags_ContextMenuInBody | ImGuiTableFlags_RowBg | ImGuiTableFlags_SizingFixedFit | ImGuiTableFlags_NoHostExtendX;
        ImGui.CheckboxFlags("ImGuiTableFlags_NoHostExtendX", flags, ImGuiTableFlags_NoHostExtendX);
        ImGui.SameLine(); HelpMarker("Make outer width auto-fit to columns, overriding outer_size.x value.\n\nOnly available when ScrollX/ScrollY are disabled and Stretch columns are not used.");
        ImGui.CheckboxFlags("ImGuiTableFlags_NoHostExtendY", flags, ImGuiTableFlags_NoHostExtendY);
        ImGui.SameLine(); HelpMarker("Make outer height stop exactly at outer_size.y (prevent auto-extending table past the limit).\n\nOnly available when ScrollX/ScrollY are disabled. Data below the limit will be clipped and not visible.");
        PopStyleCompact();

        ImVec2 outer_size = ImVec2(0.0, TEXT_BASE_HEIGHT * 5.5f);
        if (ImGui.BeginTable("table1", 3, flags, outer_size))then
            for (int row = 0; row < 10; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 3; column++)then
                    ImGui.TableNextColumn();
                    ImGui.Text("Cell %d,%d", column, row);
                end
            end
            ImGui.EndTable();
        end
        ImGui.SameLine();
        ImGui.Text("Hellonot ");

        ImGui.Spacing();

        ImGui.Text("Using explicit size:");
        if (ImGui.BeginTable("table2", 3, ImGuiTableFlags_Borders | ImGuiTableFlags_RowBg, ImVec2(TEXT_BASE_WIDTH * 30, 0.0)))then
            for (int row = 0; row < 5; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 3; column++)then
                    ImGui.TableNextColumn();
                    ImGui.Text("Cell %d,%d", column, row);
                end
            end
            ImGui.EndTable();
        end
        ImGui.SameLine();
        if (ImGui.BeginTable("table3", 3, ImGuiTableFlags_Borders | ImGuiTableFlags_RowBg, ImVec2(TEXT_BASE_WIDTH * 30, 0.0)))then
            for (int row = 0; row < 3; row++)then
                ImGui.TableNextRow(0, TEXT_BASE_HEIGHT * 1.5f);
                for (int column = 0; column < 3; column++)then
                    ImGui.TableNextColumn();
                    ImGui.Text("Cell %d,%d", column, row);
                end
            end
            ImGui.EndTable();
        end

        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Background color"))then
        static ImGuiTableFlags flags = ImGuiTableFlags_RowBg;
        static int row_bg_type = 1;
        static int row_bg_target = 1;
        static int cell_bg_type = 1;

        PushStyleCompact();
        ImGui.CheckboxFlags("ImGuiTableFlags_Borders", flags, ImGuiTableFlags_Borders);
        ImGui.CheckboxFlags("ImGuiTableFlags_RowBg", flags, ImGuiTableFlags_RowBg);
        ImGui.SameLine(); HelpMarker("ImGuiTableFlags_RowBg automatically sets RowBg0 to alternative colors pulled from the Style.");
        ImGui.Combo("row bg type", (int*)&row_bg_type, "None\0Red\0Gradient\0");
        ImGui.Combo("row bg target", (int*)&row_bg_target, "RowBg0\0RowBg1\0"); ImGui.SameLine(); HelpMarker("Target RowBg0 to override the alternating odd/even colors,\nTarget RowBg1 to blend with them.");
        ImGui.Combo("cell bg type", (int*)&cell_bg_type, "None\0Blue\0"); ImGui.SameLine(); HelpMarker("We are colorizing cells to B1->C2 here.");
        IM_ASSERT(row_bg_type >= 0 and row_bg_type <= 2);
        IM_ASSERT(row_bg_target >= 0 and row_bg_target <= 1);
        IM_ASSERT(cell_bg_type >= 0 and cell_bg_type <= 1);
        PopStyleCompact();

        if (ImGui.BeginTable("table1", 5, flags))then
            for (int row = 0; row < 6; row++)then
                ImGui.TableNextRow();

                -- Demonstrate setting a row background color with 'ImGui.TableSetBgColor(ImGuiTableBgTarget_RowBgX, ...)'
                -- We use a transparent color so we can see the one behind in case our target is RowBg1 and RowBg0 was already targeted by the ImGuiTableFlags_RowBg flag.
                if (row_bg_type ~= 0)then
                    ImU32 row_bg_color = ImGui.GetColorU32(row_bg_type == 1 ? ImVec4(0.7f, 0.3f, 0.3f, 0.65f) : ImVec4(0.2f + row * 0.1f, 0.2f, 0.2f, 0.65f)); -- Flat or Gradient?
                    ImGui.TableSetBgColor(ImGuiTableBgTarget_RowBg0 + row_bg_target, row_bg_color);
                end

                -- Fill cells
                for (int column = 0; column < 5; column++)then
                    ImGui.TableSetColumnIndex(column);
                    ImGui.Text("%c%c", 'A' + row, '0' + column);

                    -- Change background of Cells B1->C2
                    -- Demonstrate setting a cell background color with 'ImGui.TableSetBgColor(ImGuiTableBgTarget_CellBg, ...)'
                    -- (the CellBg color will be blended over the RowBg and ColumnBg colors)
                    -- We can also pass a column number as a third parameter to TableSetBgColor() and do this outside the column loop.
                    if (row >= 1 and row <= 2 and column >= 1 and column <= 2 and cell_bg_type == 1)then
                        ImU32 cell_bg_color = ImGui.GetColorU32(ImVec4(0.3f, 0.3f, 0.7f, 0.65f));
                        ImGui.TableSetBgColor(ImGuiTableBgTarget_CellBg, cell_bg_color);
                    end
                end
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Tree view"))then
        static ImGuiTableFlags flags = ImGuiTableFlags_BordersV | ImGuiTableFlags_BordersOuterH | ImGuiTableFlags_Resizable | ImGuiTableFlags_RowBg | ImGuiTableFlags_NoBordersInBody;

        if (ImGui.BeginTable("3ways", 3, flags))then
            -- The first column will use the default _WidthStretch when ScrollX is Off and _WidthFixed when ScrollX is On
            ImGui.TableSetupColumn("Name", ImGuiTableColumnFlags_NoHide);
            ImGui.TableSetupColumn("Size", ImGuiTableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 12.0);
            ImGui.TableSetupColumn("Type", ImGuiTableColumnFlags_WidthFixed, TEXT_BASE_WIDTH * 18.0);
            ImGui.TableHeadersRow();

            -- Simple storage to output a dummy file-system.
            struct MyTreeNodethen
                const char*     Name;
                const char*     Type;
                int             Size;
                int             ChildIdx;
                int             ChildCount;
                function DisplayNode(const MyTreeNode* node, const MyTreeNode* all_nodes)then
                    ImGui.TableNextRow();
                    ImGui.TableNextColumn();
                    const bool is_folder = (node->ChildCount > 0);
                    if (is_folder)then
                        bool open = ImGui.TreeNodeEx(node->Name, ImGuiTreeNodeFlags_SpanFullWidth);
                        ImGui.TableNextColumn();
                        ImGui.TextDisabled("--");
                        ImGui.TableNextColumn();
                        ImGui.TextUnformatted(node->Type);
                        if (open)then
                            for (int child_n = 0; child_n < node->ChildCount; child_n++)
                                DisplayNode(&all_nodes[node->ChildIdx + child_n], all_nodes);
                            ImGui.TreePop();
                        end
                    end
                    elsethen
                        ImGui.TreeNodeEx(node->Name, ImGuiTreeNodeFlags_Leaf | ImGuiTreeNodeFlags_Bullet | ImGuiTreeNodeFlags_NoTreePushOnOpen | ImGuiTreeNodeFlags_SpanFullWidth);
                        ImGui.TableNextColumn();
                        ImGui.Text("%d", node->Size);
                        ImGui.TableNextColumn();
                        ImGui.TextUnformatted(node->Type);
                    end
                end
            end;
            static const MyTreeNode nodes[] =thenthen "Root",                         "Folder",       -1,       1, 3    end, -- 0then "Music",                        "Folder",       -1,       4, 2    end, -- 1then "Textures",                     "Folder",       -1,       6, 3    end, -- 2then "desktop.ini",                  "System file",  1024,    -1,-1    end, -- 3then "File1_a.wav",                  "Audio file",   123000,  -1,-1    end, -- 4then "File1_b.wav",                  "Audio file",   456000,  -1,-1    end, -- 5then "Image001.png",                 "Image file",   203128,  -1,-1    end, -- 6then "Copy of Image001.png",         "Image file",   203256,  -1,-1    end, -- 7then "Copy of Image001 (Final2).png","Image file",   203512,  -1,-1    end, -- 8
            end;

            MyTreeNode.DisplayNode(&nodes[0], nodes);

            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Item width"))then
        HelpMarker(
            "Showcase using PushItemWidth() and how it is preserved on a per-column basis.\n\n"
            "Note that on auto-resizing non-resizable fixed columns, querying the content width for e.g. right-alignment doesn't make sense.");
        if (ImGui.BeginTable("table_item_width", 3, ImGuiTableFlags_Borders))then
            ImGui.TableSetupColumn("small");
            ImGui.TableSetupColumn("half");
            ImGui.TableSetupColumn("right-align");
            ImGui.TableHeadersRow();

            for (int row = 0; row < 3; row++)then
                ImGui.TableNextRow();
                if (row == 0)then
                    -- Setup ItemWidth once (instead of setting up every time, which is also possible but less efficient)
                    ImGui.TableSetColumnIndex(0);
                    ImGui.PushItemWidth(TEXT_BASE_WIDTH * 3.0); -- Small
                    ImGui.TableSetColumnIndex(1);
                    ImGui.PushItemWidth(-ImGui.GetContentRegionAvail().x * 0.5f);
                    ImGui.TableSetColumnIndex(2);
                    ImGui.PushItemWidth(-FLT_MIN); -- Right-aligned
                end

                -- Draw our contents
                static float dummy_f = 0.0;
                ImGui.PushID(row);
                ImGui.TableSetColumnIndex(0);
                ImGui.SliderFloat("float0", dummy_f, 0.0, 1.0);
                ImGui.TableSetColumnIndex(1);
                ImGui.SliderFloat("float1", dummy_f, 0.0, 1.0);
                ImGui.TableSetColumnIndex(2);
                ImGui.SliderFloat("float2", dummy_f, 0.0, 1.0);
                ImGui.PopID();
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    -- Demonstrate using TableHeader() calls instead of TableHeadersRow()
    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Custom headers"))then
        const int COLUMNS_COUNT = 3;
        if (ImGui.BeginTable("table_custom_headers", COLUMNS_COUNT, ImGuiTableFlags_Borders | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable))then
            ImGui.TableSetupColumn("Apricot");
            ImGui.TableSetupColumn("Banana");
            ImGui.TableSetupColumn("Cherry");

            -- Dummy entire-column selection storage
            -- FIXME: It would be nice to actually demonstrate full-featured selection using those checkbox.
            local column_selected[3] = do end;

            -- Instead of calling TableHeadersRow() we'll submit custom headers ourselves
            ImGui.TableNextRow(ImGuiTableRowFlags_Headers);
            for (int column = 0; column < COLUMNS_COUNT; column++)then
                ImGui.TableSetColumnIndex(column);
                const char* column_name = ImGui.TableGetColumnName(column); -- Retrieve name passed to TableSetupColumn()
                ImGui.PushID(column);
                ImGui.PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(0, 0));
                ImGui.Checkbox("----checkall", column_selected[column]);
                ImGui.PopStyleVar();
                ImGui.SameLine(0.0, ImGui.GetStyle().ItemInnerSpacing.x);
                ImGui.TableHeader(column_name);
                ImGui.PopID();
            end

            for (int row = 0; row < 5; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < 3; column++)then
                    char buf[32];
                    sprintf(buf, "Cell %d,%d", column, row);
                    ImGui.TableSetColumnIndex(column);
                    ImGui.Selectable(buf, column_selected[column]);
                end
            end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    -- Demonstrate creating custom context menus inside columns, while playing it nice with context menus provided by TableHeadersRow()/TableHeader()
    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Context menus"))then
        HelpMarker("By default, right-clicking over a TableHeadersRow()/TableHeader() line will open the default context-menu.\nUsing ImGuiTableFlags_ContextMenuInBody we also allow right-clicking over columns body.");
        static ImGuiTableFlags flags1 = ImGuiTableFlags_Resizable | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable | ImGuiTableFlags_Borders | ImGuiTableFlags_ContextMenuInBody;

        PushStyleCompact();
        ImGui.CheckboxFlags("ImGuiTableFlags_ContextMenuInBody", flags1, ImGuiTableFlags_ContextMenuInBody);
        PopStyleCompact();

        -- Context Menus: first example
        -- [1.1] Right-click on the TableHeadersRow() line to open the default table context menu.
        -- [1.2] Right-click in columns also open the default table context menu (if ImGuiTableFlags_ContextMenuInBody is set)
        const int COLUMNS_COUNT = 3;
        if (ImGui.BeginTable("table_context_menu", COLUMNS_COUNT, flags1))then
            ImGui.TableSetupColumn("One");
            ImGui.TableSetupColumn("Two");
            ImGui.TableSetupColumn("Three");

            -- [1.1]] Right-click on the TableHeadersRow() line to open the default table context menu.
            ImGui.TableHeadersRow();

            -- Submit dummy contents
            for (int row = 0; row < 4; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < COLUMNS_COUNT; column++)then
                    ImGui.TableSetColumnIndex(column);
                    ImGui.Text("Cell %d,%d", column, row);
                end
            end
            ImGui.EndTable();
        end

        -- Context Menus: second example
        -- [2.1] Right-click on the TableHeadersRow() line to open the default table context menu.
        -- [2.2] Right-click on the ".." to open a custom popup
        -- [2.3] Right-click in columns to open another custom popup
        HelpMarker("Demonstrate mixing table context menu (over header), item context button (over button) and custom per-colum context menu (over column body).");
        ImGuiTableFlags flags2 = ImGuiTableFlags_Resizable | ImGuiTableFlags_SizingFixedFit | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable | ImGuiTableFlags_Borders;
        if (ImGui.BeginTable("table_context_menu_2", COLUMNS_COUNT, flags2))then
            ImGui.TableSetupColumn("One");
            ImGui.TableSetupColumn("Two");
            ImGui.TableSetupColumn("Three");

            -- [2.1] Right-click on the TableHeadersRow() line to open the default table context menu.
            ImGui.TableHeadersRow();
            for (int row = 0; row < 4; row++)then
                ImGui.TableNextRow();
                for (int column = 0; column < COLUMNS_COUNT; column++)then
                    -- Submit dummy contents
                    ImGui.TableSetColumnIndex(column);
                    ImGui.Text("Cell %d,%d", column, row);
                    ImGui.SameLine();

                    -- [2.2] Right-click on the ".." to open a custom popup
                    ImGui.PushID(row * COLUMNS_COUNT + column);
                    ImGui.SmallButton("..");
                    if (ImGui.BeginPopupContextItem())then
                        ImGui.Text("This is the popup for Button(\"..\") in Cell %d,%d", column, row);
                        if (ImGui.Button("Close"))
                            ImGui.CloseCurrentPopup();
                        ImGui.EndPopup();
                    end
                    ImGui.PopID();
                end
            end

            -- [2.3] Right-click anywhere in columns to open another custom popup
            -- (instead of testing for not IsAnyItemHovered() we could also call OpenPopup() with ImGuiPopupFlags_NoOpenOverExistingPopup
            -- to manage popup priority as the popups triggers, here "are we hovering a column" are overlapping)
            int hovered_column = -1;
            for (int column = 0; column < COLUMNS_COUNT + 1; column++)then
                ImGui.PushID(column);
                if (ImGui.TableGetColumnFlags(column) & ImGuiTableColumnFlags_IsHovered)
                    hovered_column = column;
                if (hovered_column == column and not ImGui.IsAnyItemHovered() and ImGui.IsMouseReleased(1))
                    ImGui.OpenPopup("MyPopup");
                if (ImGui.BeginPopup("MyPopup"))then
                    if (column == COLUMNS_COUNT)
                        ImGui.Text("This is a custom popup for unused space after the last column.");
                    else
                        ImGui.Text("This is a custom popup for Column %d", column);
                    if (ImGui.Button("Close"))
                        ImGui.CloseCurrentPopup();
                    ImGui.EndPopup();
                end
                ImGui.PopID();
            end

            ImGui.EndTable();
            ImGui.Text("Hovered column: %d", hovered_column);
        end
        ImGui.TreePop();
    end

    -- Demonstrate creating multiple tables with the same ID
    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Synced instances"))then
        HelpMarker("Multiple tables with the same identifier will share their settings, width, visibility, order etc.");
        for (int n = 0; n < 3; n++)then
            char buf[32];
            sprintf(buf, "Synced Table %d", n);
            bool open = ImGui.CollapsingHeader(buf, ImGuiTreeNodeFlags_DefaultOpen);
            if (open and ImGui.BeginTable("Table", 3, ImGuiTableFlags_Resizable | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable | ImGuiTableFlags_Borders | ImGuiTableFlags_SizingFixedFit | ImGuiTableFlags_NoSavedSettings))then
                ImGui.TableSetupColumn("One");
                ImGui.TableSetupColumn("Two");
                ImGui.TableSetupColumn("Three");
                ImGui.TableHeadersRow();
                for (int cell = 0; cell < 9; cell++)then
                    ImGui.TableNextColumn();
                    ImGui.Text("this cell %d", cell);
                end
                ImGui.EndTable();
            end
        end
        ImGui.TreePop();
    end

    -- Demonstrate using Sorting facilities
    -- This is a simplified version of the "Advanced" example, where we mostly focus on the code necessary to handle sorting.
    -- Note that the "Advanced" example also showcase manually triggering a sort (e.g. if item quantities have been modified)
    static const char* template_items_names[] =then
        "Banana", "Apple", "Cherry", "Watermelon", "Grapefruit", "Strawberry", "Mango",
        "Kiwi", "Orange", "Pineapple", "Blueberry", "Plum", "Coconut", "Pear", "Apricot"
    end;
    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Sorting"))then
        -- Create item list
        static ImVector<MyItem> items;
        if (items.Size == 0)then
            items.resize(50, MyItem());
            for (int n = 0; n < items.Size; n++)then
                const int template_n = n % IM_ARRAYSIZE(template_items_names);
                MyItem& item = items[n];
                item.ID = n;
                item.Name = template_items_names[template_n];
                item.Quantity = (n * n - n) % 20; -- Assign default quantities
            end
        end

        -- Options
        static ImGuiTableFlags flags =
            ImGuiTableFlags_Resizable | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable | ImGuiTableFlags_Sortable | ImGuiTableFlags_SortMulti
            | ImGuiTableFlags_RowBg | ImGuiTableFlags_BordersOuter | ImGuiTableFlags_BordersV | ImGuiTableFlags_NoBordersInBody
            | ImGuiTableFlags_ScrollY;
        PushStyleCompact();
        ImGui.CheckboxFlags("ImGuiTableFlags_SortMulti", flags, ImGuiTableFlags_SortMulti);
        ImGui.SameLine(); HelpMarker("When sorting is enabled: hold shift when clicking headers to sort on multiple column. TableGetSortSpecs() may return specs where (SpecsCount > 1).");
        ImGui.CheckboxFlags("ImGuiTableFlags_SortTristate", flags, ImGuiTableFlags_SortTristate);
        ImGui.SameLine(); HelpMarker("When sorting is enabled: allow no sorting, disable default sorting. TableGetSortSpecs() may return specs where (SpecsCount == 0).");
        PopStyleCompact();

        if (ImGui.BeginTable("table_sorting", 4, flags, ImVec2(0.0, TEXT_BASE_HEIGHT * 15), 0.0))then
            -- Declare columns
            -- We use the "user_id" parameter of TableSetupColumn() to specify a user id that will be stored in the sort specifications.
            -- This is so our sort function can identify a column given our own identifier. We could also identify them based on their indexnot 
            -- Demonstrate using a mixture of flags among available sort-related flags:
            -- - ImGuiTableColumnFlags_DefaultSort
            -- - ImGuiTableColumnFlags_NoSort / ImGuiTableColumnFlags_NoSortAscending / ImGuiTableColumnFlags_NoSortDescending
            -- - ImGuiTableColumnFlags_PreferSortAscending / ImGuiTableColumnFlags_PreferSortDescending
            ImGui.TableSetupColumn("ID",       ImGuiTableColumnFlags_DefaultSort          | ImGuiTableColumnFlags_WidthFixed,   0.0, MyItemColumnID_ID);
            ImGui.TableSetupColumn("Name",                                                  ImGuiTableColumnFlags_WidthFixed,   0.0, MyItemColumnID_Name);
            ImGui.TableSetupColumn("Action",   ImGuiTableColumnFlags_NoSort               | ImGuiTableColumnFlags_WidthFixed,   0.0, MyItemColumnID_Action);
            ImGui.TableSetupColumn("Quantity", ImGuiTableColumnFlags_PreferSortDescending | ImGuiTableColumnFlags_WidthStretch, 0.0, MyItemColumnID_Quantity);
            ImGui.TableSetupScrollFreeze(0, 1); -- Make row always visible
            ImGui.TableHeadersRow();

            -- Sort our data if sort specs have been changednot 
            if (ImGuiTableSortSpecs* sorts_specs = ImGui.TableGetSortSpecs())
                if (sorts_specs->SpecsDirty)then
                    MyItem.s_current_sort_specs = sorts_specs; -- Store in variable accessible by the sort function.
                    if (items.Size > 1)
                        qsort(&items[0], (size_t)items.Size, sizeof(items[0]), MyItem.CompareWithSortSpecs);
                    MyItem.s_current_sort_specs = NULL;
                    sorts_specs->SpecsDirty = false;
                end

            -- Demonstrate using clipper for large vertical lists
            ImGuiListClipper clipper;
            clipper.Begin(items.Size);
            while (clipper.Step())
                for (int row_n = clipper.DisplayStart; row_n < clipper.DisplayEnd; row_n++)then
                    -- Display a data item
                    MyItem* item = &items[row_n];
                    ImGui.PushID(item->ID);
                    ImGui.TableNextRow();
                    ImGui.TableNextColumn();
                    ImGui.Text("%04d", item->ID);
                    ImGui.TableNextColumn();
                    ImGui.TextUnformatted(item->Name);
                    ImGui.TableNextColumn();
                    ImGui.SmallButton("None");
                    ImGui.TableNextColumn();
                    ImGui.Text("%d", item->Quantity);
                    ImGui.PopID();
                end
            ImGui.EndTable();
        end
        ImGui.TreePop();
    end

    -- In this example we'll expose most table flags and settings.
    -- For specific flags and settings refer to the corresponding section for more detailed explanation.
    -- This section is mostly useful to experiment with combining certain flags or settings with each others.
    --ImGui.SetNextItemOpen(true, ImGuiCond_Once); -- [DEBUG]
    if (open_action ~= -1)
        ImGui.SetNextItemOpen(open_action ~= 0);
    if (ImGui.TreeNode("Advanced"))then
        static ImGuiTableFlags flags =
            ImGuiTableFlags_Resizable | ImGuiTableFlags_Reorderable | ImGuiTableFlags_Hideable
            | ImGuiTableFlags_Sortable | ImGuiTableFlags_SortMulti
            | ImGuiTableFlags_RowBg | ImGuiTableFlags_Borders | ImGuiTableFlags_NoBordersInBody
            | ImGuiTableFlags_ScrollX | ImGuiTableFlags_ScrollY
            | ImGuiTableFlags_SizingFixedFit;

        enum ContentsType do CT_Text, CT_Button, CT_SmallButton, CT_FillButton, CT_Selectable, CT_SelectableSpanRow end;
        static int contents_type = CT_SelectableSpanRow;
        const char* contents_type_names[] = do "Text", "Button", "SmallButton", "FillButton", "Selectable", "Selectable (span row)" end;
        static int freeze_cols = 1;
        static int freeze_rows = 1;
        static int items_count = IM_ARRAYSIZE(template_items_names) * 2;
        static ImVec2 outer_size_value = ImVec2(0.0, TEXT_BASE_HEIGHT * 12);
        static float row_min_height = 0.0; -- Auto
        static float inner_width_with_scroll = 0.0; -- Auto-extend
        local outer_size_enabled = true;
        local show_headers = true;
        local show_wrapped_text = false;
        --static ImGuiTextFilter filter;
        --ImGui.SetNextItemOpen(true, ImGuiCond_Once); -- FIXME-TABLE: Enabling this results in initial clipped first pass on table which tend to affects column sizing
        if (ImGui.TreeNode("Options"))then
            -- Make the UI compact because there are so many fields
            PushStyleCompact();
            ImGui.PushItemWidth(TEXT_BASE_WIDTH * 28.0);

            if (ImGui.TreeNodeEx("Features:", ImGuiTreeNodeFlags_DefaultOpen))then
                ImGui.CheckboxFlags("ImGuiTableFlags_Resizable", flags, ImGuiTableFlags_Resizable);
                ImGui.CheckboxFlags("ImGuiTableFlags_Reorderable", flags, ImGuiTableFlags_Reorderable);
                ImGui.CheckboxFlags("ImGuiTableFlags_Hideable", flags, ImGuiTableFlags_Hideable);
                ImGui.CheckboxFlags("ImGuiTableFlags_Sortable", flags, ImGuiTableFlags_Sortable);
                ImGui.CheckboxFlags("ImGuiTableFlags_NoSavedSettings", flags, ImGuiTableFlags_NoSavedSettings);
                ImGui.CheckboxFlags("ImGuiTableFlags_ContextMenuInBody", flags, ImGuiTableFlags_ContextMenuInBody);
                ImGui.TreePop();
            end

            if (ImGui.TreeNodeEx("Decorations:", ImGuiTreeNodeFlags_DefaultOpen))then
                ImGui.CheckboxFlags("ImGuiTableFlags_RowBg", flags, ImGuiTableFlags_RowBg);
                ImGui.CheckboxFlags("ImGuiTableFlags_BordersV", flags, ImGuiTableFlags_BordersV);
                ImGui.CheckboxFlags("ImGuiTableFlags_BordersOuterV", flags, ImGuiTableFlags_BordersOuterV);
                ImGui.CheckboxFlags("ImGuiTableFlags_BordersInnerV", flags, ImGuiTableFlags_BordersInnerV);
                ImGui.CheckboxFlags("ImGuiTableFlags_BordersH", flags, ImGuiTableFlags_BordersH);
                ImGui.CheckboxFlags("ImGuiTableFlags_BordersOuterH", flags, ImGuiTableFlags_BordersOuterH);
                ImGui.CheckboxFlags("ImGuiTableFlags_BordersInnerH", flags, ImGuiTableFlags_BordersInnerH);
                ImGui.CheckboxFlags("ImGuiTableFlags_NoBordersInBody", flags, ImGuiTableFlags_NoBordersInBody); ImGui.SameLine(); HelpMarker("Disable vertical borders in columns Body (borders will always appears in Headers");
                ImGui.CheckboxFlags("ImGuiTableFlags_NoBordersInBodyUntilResize", flags, ImGuiTableFlags_NoBordersInBodyUntilResize); ImGui.SameLine(); HelpMarker("Disable vertical borders in columns Body until hovered for resize (borders will always appears in Headers)");
                ImGui.TreePop();
            end

            if (ImGui.TreeNodeEx("Sizing:", ImGuiTreeNodeFlags_DefaultOpen))then
                EditTableSizingFlags(&flags);
                ImGui.SameLine(); HelpMarker("In the Advanced demo we override the policy of each column so those table-wide settings have less effect that typical.");
                ImGui.CheckboxFlags("ImGuiTableFlags_NoHostExtendX", flags, ImGuiTableFlags_NoHostExtendX);
                ImGui.SameLine(); HelpMarker("Make outer width auto-fit to columns, overriding outer_size.x value.\n\nOnly available when ScrollX/ScrollY are disabled and Stretch columns are not used.");
                ImGui.CheckboxFlags("ImGuiTableFlags_NoHostExtendY", flags, ImGuiTableFlags_NoHostExtendY);
                ImGui.SameLine(); HelpMarker("Make outer height stop exactly at outer_size.y (prevent auto-extending table past the limit).\n\nOnly available when ScrollX/ScrollY are disabled. Data below the limit will be clipped and not visible.");
                ImGui.CheckboxFlags("ImGuiTableFlags_NoKeepColumnsVisible", flags, ImGuiTableFlags_NoKeepColumnsVisible);
                ImGui.SameLine(); HelpMarker("Only available if ScrollX is disabled.");
                ImGui.CheckboxFlags("ImGuiTableFlags_PreciseWidths", flags, ImGuiTableFlags_PreciseWidths);
                ImGui.SameLine(); HelpMarker("Disable distributing remainder width to stretched columns (width allocation on a 100-wide table with 3 columns: Without this flag: 33,33,34. With this flag: 33,33,33). With larger number of columns, resizing will appear to be less smooth.");
                ImGui.CheckboxFlags("ImGuiTableFlags_NoClip", flags, ImGuiTableFlags_NoClip);
                ImGui.SameLine(); HelpMarker("Disable clipping rectangle for every individual columns (reduce draw command count, items will be able to overflow into other columns). Generally incompatible with ScrollFreeze options.");
                ImGui.TreePop();
            end

            if (ImGui.TreeNodeEx("Padding:", ImGuiTreeNodeFlags_DefaultOpen))then
                ImGui.CheckboxFlags("ImGuiTableFlags_PadOuterX", flags, ImGuiTableFlags_PadOuterX);
                ImGui.CheckboxFlags("ImGuiTableFlags_NoPadOuterX", flags, ImGuiTableFlags_NoPadOuterX);
                ImGui.CheckboxFlags("ImGuiTableFlags_NoPadInnerX", flags, ImGuiTableFlags_NoPadInnerX);
                ImGui.TreePop();
            end

            if (ImGui.TreeNodeEx("Scrolling:", ImGuiTreeNodeFlags_DefaultOpen))then
                ImGui.CheckboxFlags("ImGuiTableFlags_ScrollX", flags, ImGuiTableFlags_ScrollX);
                ImGui.SameLine();
                ImGui.SetNextItemWidth(ImGui.GetFrameHeight());
                ImGui.DragInt("freeze_cols", freeze_cols, 0.2f, 0, 9, NULL, ImGuiSliderFlags_NoInput);
                ImGui.CheckboxFlags("ImGuiTableFlags_ScrollY", flags, ImGuiTableFlags_ScrollY);
                ImGui.SameLine();
                ImGui.SetNextItemWidth(ImGui.GetFrameHeight());
                ImGui.DragInt("freeze_rows", freeze_rows, 0.2f, 0, 9, NULL, ImGuiSliderFlags_NoInput);
                ImGui.TreePop();
            end

            if (ImGui.TreeNodeEx("Sorting:", ImGuiTreeNodeFlags_DefaultOpen))then
                ImGui.CheckboxFlags("ImGuiTableFlags_SortMulti", flags, ImGuiTableFlags_SortMulti);
                ImGui.SameLine(); HelpMarker("When sorting is enabled: hold shift when clicking headers to sort on multiple column. TableGetSortSpecs() may return specs where (SpecsCount > 1).");
                ImGui.CheckboxFlags("ImGuiTableFlags_SortTristate", flags, ImGuiTableFlags_SortTristate);
                ImGui.SameLine(); HelpMarker("When sorting is enabled: allow no sorting, disable default sorting. TableGetSortSpecs() may return specs where (SpecsCount == 0).");
                ImGui.TreePop();
            end

            if (ImGui.TreeNodeEx("Other:", ImGuiTreeNodeFlags_DefaultOpen))then
                ImGui.Checkbox("show_headers", show_headers);
                ImGui.Checkbox("show_wrapped_text", show_wrapped_text);

                ImGui.DragFloat2("----OuterSize", outer_size_value.x);
                ImGui.SameLine(0.0, ImGui.GetStyle().ItemInnerSpacing.x);
                ImGui.Checkbox("outer_size", outer_size_enabled);
                ImGui.SameLine();
                HelpMarker("If scrolling is disabled (ScrollX and ScrollY not set):\n"
                    "- The table is output directly in the parent window.\n"
                    "- OuterSize.x < 0.0 will right-align the table.\n"
                    "- OuterSize.x = 0.0 will narrow fit the table unless there are any Stretch column.\n"
                    "- OuterSize.y then becomes the minimum size for the table, which will extend vertically if there are more rows (unless NoHostExtendY is set).");

                -- From a user point of view we will tend to use 'inner_width' differently depending on whether our table is embedding scrolling.
                -- To facilitate toying with this demo we will actually pass 0.0 to the BeginTable() when ScrollX is disabled.
                ImGui.DragFloat("inner_width (when ScrollX active)", inner_width_with_scroll, 1.0, 0.0, FLT_MAX);

                ImGui.DragFloat("row_min_height", row_min_height, 1.0, 0.0, FLT_MAX);
                ImGui.SameLine(); HelpMarker("Specify height of the Selectable item.");

                ImGui.DragInt("items_count", items_count, 0.1f, 0, 9999);
                ImGui.Combo("items_type (first column)", contents_type, contents_type_names, IM_ARRAYSIZE(contents_type_names));
                --filter.Draw("filter");
                ImGui.TreePop();
            end

            ImGui.PopItemWidth();
            PopStyleCompact();
            ImGui.Spacing();
            ImGui.TreePop();
        end

        -- Update item list if we changed the number of items
        static ImVector<MyItem> items;
        static ImVector<int> selection;
        local items_need_sort = false;
        if (items.Size ~= items_count)then
            items.resize(items_count, MyItem());
            for (int n = 0; n < items_count; n++)then
                const int template_n = n % IM_ARRAYSIZE(template_items_names);
                MyItem& item = items[n];
                item.ID = n;
                item.Name = template_items_names[template_n];
                item.Quantity = (template_n == 3) ? 10 : (template_n == 4) ? 20 : 0; -- Assign default quantities
            end
        end

        const ImDrawList* parent_draw_list = ImGui.GetWindowDrawList();
        const int parent_draw_list_draw_cmd_count = parent_draw_list->CmdBuffer.Size;
        ImVec2 table_scroll_cur, table_scroll_max; -- For debug display
        const ImDrawList* table_draw_list = NULL;  -- "

        -- Submit table
        const float inner_width_to_use = (flags & ImGuiTableFlags_ScrollX) ? inner_width_with_scroll : 0.0;
        if (ImGui.BeginTable("table_advanced", 6, flags, outer_size_enabled ? outer_size_value : ImVec2(0, 0), inner_width_to_use))then
            -- Declare columns
            -- We use the "user_id" parameter of TableSetupColumn() to specify a user id that will be stored in the sort specifications.
            -- This is so our sort function can identify a column given our own identifier. We could also identify them based on their indexnot 
            ImGui.TableSetupColumn("ID",           ImGuiTableColumnFlags_DefaultSort | ImGuiTableColumnFlags_WidthFixed | ImGuiTableColumnFlags_NoHide, 0.0, MyItemColumnID_ID);
            ImGui.TableSetupColumn("Name",         ImGuiTableColumnFlags_WidthFixed, 0.0, MyItemColumnID_Name);
            ImGui.TableSetupColumn("Action",       ImGuiTableColumnFlags_NoSort | ImGuiTableColumnFlags_WidthFixed, 0.0, MyItemColumnID_Action);
            ImGui.TableSetupColumn("Quantity",     ImGuiTableColumnFlags_PreferSortDescending, 0.0, MyItemColumnID_Quantity);
            ImGui.TableSetupColumn("Description",  (flags & ImGuiTableFlags_NoHostExtendX) ? 0 : ImGuiTableColumnFlags_WidthStretch, 0.0, MyItemColumnID_Description);
            ImGui.TableSetupColumn("Hidden",       ImGuiTableColumnFlags_DefaultHide | ImGuiTableColumnFlags_NoSort);
            ImGui.TableSetupScrollFreeze(freeze_cols, freeze_rows);

            -- Sort our data if sort specs have been changednot 
            ImGuiTableSortSpecs* sorts_specs = ImGui.TableGetSortSpecs();
            if (sorts_specs and sorts_specs->SpecsDirty)
                items_need_sort = true;
            if (sorts_specs and items_need_sort and items.Size > 1)then
                MyItem.s_current_sort_specs = sorts_specs; -- Store in variable accessible by the sort function.
                qsort(&items[0], (size_t)items.Size, sizeof(items[0]), MyItem.CompareWithSortSpecs);
                MyItem.s_current_sort_specs = NULL;
                sorts_specs->SpecsDirty = false;
            end
            items_need_sort = false;

            -- Take note of whether we are currently sorting based on the Quantity field,
            -- we will use this to trigger sorting when we know the data of this column has been modified.
            const bool sorts_specs_using_quantity = (ImGui.TableGetColumnFlags(3) & ImGuiTableColumnFlags_IsSorted) ~= 0;

            -- Show headers
            if (show_headers)
                ImGui.TableHeadersRow();

            -- Show data
            -- FIXME-TABLE FIXME-NAV: How we can get decent up/down even though we have the buttons here?
            ImGui.PushButtonRepeat(true);
--if 1
            -- Demonstrate using clipper for large vertical lists
            ImGuiListClipper clipper;
            clipper.Begin(items.Size);
            while (clipper.Step())then
                for (int row_n = clipper.DisplayStart; row_n < clipper.DisplayEnd; row_n++)
--else
            -- Without clipperthen
                for (int row_n = 0; row_n < items.Size; row_n++)
--endifthen
                    MyItem* item = &items[row_n];
                    --if (not filter.PassFilter(item->Name))
                    --    continue;

                    const bool item_is_selected = selection.contains(item->ID);
                    ImGui.PushID(item->ID);
                    ImGui.TableNextRow(ImGuiTableRowFlags_None, row_min_height);

                    -- For the demo purpose we can select among different type of items submitted in the first column
                    ImGui.TableSetColumnIndex(0);
                    char label[32];
                    sprintf(label, "%04d", item->ID);
                    if (contents_type == CT_Text)
                        ImGui.TextUnformatted(label);
                    else if (contents_type == CT_Button)
                        ImGui.Button(label);
                    else if (contents_type == CT_SmallButton)
                        ImGui.SmallButton(label);
                    else if (contents_type == CT_FillButton)
                        ImGui.Button(label, ImVec2(-FLT_MIN, 0.0));
                    else if (contents_type == CT_Selectable or contents_type == CT_SelectableSpanRow)then
                        ImGuiSelectableFlags selectable_flags = (contents_type == CT_SelectableSpanRow) ? ImGuiSelectableFlags_SpanAllColumns | ImGuiSelectableFlags_AllowItemOverlap : ImGuiSelectableFlags_None;
                        if (ImGui.Selectable(label, item_is_selected, selectable_flags, ImVec2(0, row_min_height)))then
                            if (ImGui.GetIO().KeyCtrl)then
                                if (item_is_selected)
                                    selection.find_erase_unsorted(item->ID);
                                else
                                    selection.push_back(item->ID);
                            end
                            elsethen
                                selection.clear();
                                selection.push_back(item->ID);
                            end
                        end
                    end

                    if (ImGui.TableSetColumnIndex(1))
                        ImGui.TextUnformatted(item->Name);

                    -- Here we demonstrate marking our data set as needing to be sorted again if we modified a quantity,
                    -- and we are currently sorting on the column showing the Quantity.
                    -- To avoid triggering a sort while holding the button, we only trigger it when the button has been released.
                    -- You will probably need a more advanced system in your code if you want to automatically sort when a specific entry changes.
                    if (ImGui.TableSetColumnIndex(2))then
                        if (ImGui.SmallButton("Chop")) do item->Quantity += 1; end
                        if (sorts_specs_using_quantity and ImGui.IsItemDeactivated()) do items_need_sort = true; end
                        ImGui.SameLine();
                        if (ImGui.SmallButton("Eat")) do item->Quantity -= 1; end
                        if (sorts_specs_using_quantity and ImGui.IsItemDeactivated()) do items_need_sort = true; end
                    end

                    if (ImGui.TableSetColumnIndex(3))
                        ImGui.Text("%d", item->Quantity);

                    ImGui.TableSetColumnIndex(4);
                    if (show_wrapped_text)
                        ImGui.TextWrapped("Lorem ipsum dolor sit amet");
                    else
                        ImGui.Text("Lorem ipsum dolor sit amet");

                    if (ImGui.TableSetColumnIndex(5))
                        ImGui.Text("1234");

                    ImGui.PopID();
                end
            end
            ImGui.PopButtonRepeat();

            -- Store some info to display debug details below
            table_scroll_cur = ImVec2(ImGui.GetScrollX(), ImGui.GetScrollY());
            table_scroll_max = ImVec2(ImGui.GetScrollMaxX(), ImGui.GetScrollMaxY());
            table_draw_list = ImGui.GetWindowDrawList();
            ImGui.EndTable();
        end
        local show_debug_details = false;
        ImGui.Checkbox("Debug details", show_debug_details);
        if (show_debug_details and table_draw_list)then
            ImGui.SameLine(0.0, 0.0);
            const int table_draw_list_draw_cmd_count = table_draw_list->CmdBuffer.Size;
            if (table_draw_list == parent_draw_list)
                ImGui.Text(": DrawCmd: +%d (in same window)",
                    table_draw_list_draw_cmd_count - parent_draw_list_draw_cmd_count);
            else
                ImGui.Text(": DrawCmd: +%d (in child window), Scroll: (%.f/%.f) (%.f/%.f)",
                    table_draw_list_draw_cmd_count - 1, table_scroll_cur.x, table_scroll_max.x, table_scroll_cur.y, table_scroll_max.y);
        end
        ImGui.TreePop();
    end

    ImGui.PopID();

    ShowDemoWindowColumns();

    if (disable_indent)
        ImGui.PopStyleVar();
end

-- Demonstrate old/legacy Columns APInot 
-- [2020: Columns are under-featured and not maintained. Prefer using the more flexible and powerful BeginTable() APInot ]
function ShowDemoWindowColumns()
    bool open = ImGui.TreeNode("Legacy Columns API");
    ImGui.SameLine();
    HelpMarker("Columns() is an old APInot  Prefer using the more flexible and powerful BeginTable() APInot ");
    if (not open)
        return;

    -- Basic columns
    if (ImGui.TreeNode("Basic"))then
        ImGui.Text("Without border:");
        ImGui.Columns(3, "mycolumns3", false);  -- 3-ways, no border
        ImGui.Separator();
        for (int n = 0; n < 14; n++)then
            char label[32];
            sprintf(label, "Item %d", n);
            if (ImGui.Selectable(label)) do end
            --if (ImGui.Button(label, ImVec2(-FLT_MIN,0.0))) do end
            ImGui.NextColumn();
        end
        ImGui.Columns(1);
        ImGui.Separator();

        ImGui.Text("With border:");
        ImGui.Columns(4, "mycolumns"); -- 4-ways, with border
        ImGui.Separator();
        ImGui.Text("ID"); ImGui.NextColumn();
        ImGui.Text("Name"); ImGui.NextColumn();
        ImGui.Text("Path"); ImGui.NextColumn();
        ImGui.Text("Hovered"); ImGui.NextColumn();
        ImGui.Separator();
        const char* names[3] = do "One", "Two", "Three" end;
        const char* paths[3] = do "/path/one", "/path/two", "/path/three" end;
        static int selected = -1;
        for (int i = 0; i < 3; i++)then
            char label[32];
            sprintf(label, "%04d", i);
            if (ImGui.Selectable(label, selected == i, ImGuiSelectableFlags_SpanAllColumns))
                selected = i;
            bool hovered = ImGui.IsItemHovered();
            ImGui.NextColumn();
            ImGui.Text(names[i]); ImGui.NextColumn();
            ImGui.Text(paths[i]); ImGui.NextColumn();
            ImGui.Text("%d", hovered); ImGui.NextColumn();
        end
        ImGui.Columns(1);
        ImGui.Separator();
        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Borders"))then
        -- NB: Future columns API should allow automatic horizontal borders.
        local h_borders = true;
        local v_borders = true;
        static int columns_count = 4;
        const int lines_count = 3;
        ImGui.SetNextItemWidth(ImGui.GetFontSize() * 8);
        ImGui.DragInt("----columns_count", columns_count, 0.1f, 2, 10, "%d columns");
        if (columns_count < 2)
            columns_count = 2;
        ImGui.SameLine();
        ImGui.Checkbox("horizontal", h_borders);
        ImGui.SameLine();
        ImGui.Checkbox("vertical", v_borders);
        ImGui.Columns(columns_count, NULL, v_borders);
        for (int i = 0; i < columns_count * lines_count; i++)then
            if (h_borders and ImGui.GetColumnIndex() == 0)
                ImGui.Separator();
            ImGui.Text("%c%c%c", 'a' + i, 'a' + i, 'a' + i);
            ImGui.Text("Width %.2f", ImGui.GetColumnWidth());
            ImGui.Text("Avail %.2f", ImGui.GetContentRegionAvail().x);
            ImGui.Text("Offset %.2f", ImGui.GetColumnOffset());
            ImGui.Text("Long text that is likely to clip");
            ImGui.Button("Button", ImVec2(-FLT_MIN, 0.0));
            ImGui.NextColumn();
        end
        ImGui.Columns(1);
        if (h_borders)
            ImGui.Separator();
        ImGui.TreePop();
    end

    -- Create multiple items in a same cell before switching to next column
    if (ImGui.TreeNode("Mixed items"))then
        ImGui.Columns(3, "mixed");
        ImGui.Separator();

        ImGui.Text("Hello");
        ImGui.Button("Banana");
        ImGui.NextColumn();

        ImGui.Text("ImGui");
        ImGui.Button("Apple");
        static float foo = 1.0;
        ImGui.InputFloat("red", foo, 0.05f, 0, "%.3f");
        ImGui.Text("An extra line here.");
        ImGui.NextColumn();

        ImGui.Text("Sailor");
        ImGui.Button("Corniflower");
        static float bar = 1.0;
        ImGui.InputFloat("blue", bar, 0.05f, 0, "%.3f");
        ImGui.NextColumn();

        if (ImGui.CollapsingHeader("Category A")) do ImGui.Text("Blah blah blah"); end ImGui.NextColumn();
        if (ImGui.CollapsingHeader("Category B")) do ImGui.Text("Blah blah blah"); end ImGui.NextColumn();
        if (ImGui.CollapsingHeader("Category C")) do ImGui.Text("Blah blah blah"); end ImGui.NextColumn();
        ImGui.Columns(1);
        ImGui.Separator();
        ImGui.TreePop();
    end

    -- Word wrapping
    if (ImGui.TreeNode("Word-wrapping"))then
        ImGui.Columns(2, "word-wrapping");
        ImGui.Separator();
        ImGui.TextWrapped("The quick brown fox jumps over the lazy dog.");
        ImGui.TextWrapped("Hello Left");
        ImGui.NextColumn();
        ImGui.TextWrapped("The quick brown fox jumps over the lazy dog.");
        ImGui.TextWrapped("Hello Right");
        ImGui.Columns(1);
        ImGui.Separator();
        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Horizontal Scrolling"))then
        ImGui.SetNextWindowContentSize(ImVec2(1500.0, 0.0));
        ImVec2 child_size = ImVec2(0, ImGui.GetFontSize() * 20.0);
        ImGui.BeginChild("----ScrollingRegion", child_size, false, ImGuiWindowFlags_HorizontalScrollbar);
        ImGui.Columns(10);

        -- Also demonstrate using clipper for large vertical lists
        int ITEMS_COUNT = 2000;
        ImGuiListClipper clipper;
        clipper.Begin(ITEMS_COUNT);
        while (clipper.Step())then
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++)
                for (int j = 0; j < 10; j++)then
                    ImGui.Text("Line %d Column %d...", i, j);
                    ImGui.NextColumn();
                end
        end
        ImGui.Columns(1);
        ImGui.EndChild();
        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Tree"))then
        ImGui.Columns(2, "tree", true);
        for (int x = 0; x < 3; x++)then
            bool open1 = ImGui.TreeNode((void*)(intptr_t)x, "Node%d", x);
            ImGui.NextColumn();
            ImGui.Text("Node contents");
            ImGui.NextColumn();
            if (open1)then
                for (int y = 0; y < 3; y++)then
                    bool open2 = ImGui.TreeNode((void*)(intptr_t)y, "Node%d.%d", x, y);
                    ImGui.NextColumn();
                    ImGui.Text("Node contents");
                    if (open2)then
                        ImGui.Text("Even more contents");
                        if (ImGui.TreeNode("Tree in column"))then
                            ImGui.Text("The quick brown fox jumps over the lazy dog");
                            ImGui.TreePop();
                        end
                    end
                    ImGui.NextColumn();
                    if (open2)
                        ImGui.TreePop();
                end
                ImGui.TreePop();
            end
        end
        ImGui.Columns(1);
        ImGui.TreePop();
    end

    ImGui.TreePop();
end


-------------------------------------------------------------------------------
-- [SECTION] Style Editor / ShowStyleEditor()
-------------------------------------------------------------------------------
-- - ShowFontSelector()
-- - ShowStyleSelector()
-- - ShowStyleEditor()
-------------------------------------------------------------------------------

-- Forward declare ShowFontAtlas() which isn't worth putting in public API yet
namespace ImGui do IMGUI_API void ShowFontAtlas(ImFontAtlas* atlas); end

-- Demo helper function to select among loaded fonts.
-- Here we use the regular BeginCombo()/EndCombo() api which is more the more flexible one.
function ImGui.ShowFontSelector(const char* label)
    ImGuiIO& io = ImGui.GetIO();
    ImFont* font_current = ImGui.GetFont();
    if (ImGui.BeginCombo(label, font_current->GetDebugName()))then
        for (int n = 0; n < io.Fonts->Fonts.Size; n++)then
            ImFont* font = io.Fonts->Fonts[n];
            ImGui.PushID((void*)font);
            if (ImGui.Selectable(font->GetDebugName(), font == font_current))
                io.FontDefault = font;
            ImGui.PopID();
        end
        ImGui.EndCombo();
    end
    ImGui.SameLine();
    HelpMarker(
        "- Load additional fonts with io.Fonts->AddFontFromFileTTF().\n"
        "- The font atlas is built when calling io.Fonts->GetTexDataAsXXXX() or io.Fonts->Build().\n"
        "- Read FAQ and docs/FONTS.md for more details.\n"
        "- If you need to add/remove fonts at runtime (e.g. for DPI change), do it before calling NewFrame().");
end

-- Demo helper function to select among default colors. See ShowStyleEditor() for more advanced options.
-- Here we use the simplified Combo() api that packs items into a single literal string.
-- Useful for quick combo boxes where the choices are known locally.
bool ImGui.ShowStyleSelector(const char* label)
    static int style_idx = -1;
    if (ImGui.Combo(label, style_idx, "Dark\0Light\0Classic\0"))then
        switch (style_idx)then
        case 0: ImGui.StyleColorsDark(); break;
        case 1: ImGui.StyleColorsLight(); break;
        case 2: ImGui.StyleColorsClassic(); break;
        end
        return true;
    end
    return false;
end

function ImGui.ShowStyleEditor(ImGuiStyle* ref)
    -- You can pass in a reference ImGuiStyle structure to compare to, revert to and save to
    -- (without a reference style pointer, we will use one compared locally as a reference)
    ImGuiStyle& style = ImGui.GetStyle();
    static ImGuiStyle ref_saved_style;

    -- Default to using internal storage as reference
    local init = true;
    if (init and ref == NULL)
        ref_saved_style = style;
    init = false;
    if (ref == NULL)
        ref = &ref_saved_style;

    ImGui.PushItemWidth(ImGui.GetWindowWidth() * 0..0);

    if (ImGui.ShowStyleSelector("Colors----Selector"))
        ref_saved_style = style;
    ImGui.ShowFontSelector("Fonts----Selector");

    -- Simplified Settings (expose floating-pointer border sizes as boolean representing 0.0 or 1.0)
    if (ImGui.SliderFloat("FrameRounding", style.FrameRounding, 0.0, 12.0, "%.0"))
        style.GrabRounding = style.FrameRounding; -- Make GrabRounding always the same value as FrameRoundingthen bool border = (style.WindowBorderSize > 0.0); if (ImGui.Checkbox("WindowBorder", border)) do style.WindowBorderSize = border ? 1.0 : 0.0; end end
    ImGui.SameLine();then bool border = (style.FrameBorderSize > 0.0);  if (ImGui.Checkbox("FrameBorder",  &border)) do style.FrameBorderSize  = border ? 1.0 : 0.0; end end
    ImGui.SameLine();then bool border = (style.PopupBorderSize > 0.0);  if (ImGui.Checkbox("PopupBorder",  &border)) do style.PopupBorderSize  = border ? 1.0 : 0.0; end end

    -- Save/Revert button
    if (ImGui.Button("Save Ref"))
        *ref = ref_saved_style = style;
    ImGui.SameLine();
    if (ImGui.Button("Revert Ref"))
        style = *ref;
    ImGui.SameLine();
    HelpMarker(
        "Save/Revert in local non-persistent storage. Default Colors definition are not affected. "
        "Use \"Export\" below to save them somewhere.");

    ImGui.Separator();

    if (ImGui.BeginTabBar("----tabs", ImGuiTabBarFlags_None))then
        if (ImGui.BeginTabItem("Sizes"))then
            ImGui.Text("Main");
            ImGui.SliderFloat2("WindowPadding", (float*)&style.WindowPadding, 0.0, 20.0, "%.0");
            ImGui.SliderFloat2("FramePadding", (float*)&style.FramePadding, 0.0, 20.0, "%.0");
            ImGui.SliderFloat2("CellPadding", (float*)&style.CellPadding, 0.0, 20.0, "%.0");
            ImGui.SliderFloat2("ItemSpacing", (float*)&style.ItemSpacing, 0.0, 20.0, "%.0");
            ImGui.SliderFloat2("ItemInnerSpacing", (float*)&style.ItemInnerSpacing, 0.0, 20.0, "%.0");
            ImGui.SliderFloat2("TouchExtraPadding", (float*)&style.TouchExtraPadding, 0.0, 10.0, "%.0");
            ImGui.SliderFloat("IndentSpacing", style.IndentSpacing, 0.0, 30.0, "%.0");
            ImGui.SliderFloat("ScrollbarSize", style.ScrollbarSize, 1.0, 20.0, "%.0");
            ImGui.SliderFloat("GrabMinSize", style.GrabMinSize, 1.0, 20.0, "%.0");
            ImGui.Text("Borders");
            ImGui.SliderFloat("WindowBorderSize", style.WindowBorderSize, 0.0, 1.0, "%.0");
            ImGui.SliderFloat("ChildBorderSize", style.ChildBorderSize, 0.0, 1.0, "%.0");
            ImGui.SliderFloat("PopupBorderSize", style.PopupBorderSize, 0.0, 1.0, "%.0");
            ImGui.SliderFloat("FrameBorderSize", style.FrameBorderSize, 0.0, 1.0, "%.0");
            ImGui.SliderFloat("TabBorderSize", style.TabBorderSize, 0.0, 1.0, "%.0");
            ImGui.Text("Rounding");
            ImGui.SliderFloat("WindowRounding", style.WindowRounding, 0.0, 12.0, "%.0");
            ImGui.SliderFloat("ChildRounding", style.ChildRounding, 0.0, 12.0, "%.0");
            ImGui.SliderFloat("FrameRounding", style.FrameRounding, 0.0, 12.0, "%.0");
            ImGui.SliderFloat("PopupRounding", style.PopupRounding, 0.0, 12.0, "%.0");
            ImGui.SliderFloat("ScrollbarRounding", style.ScrollbarRounding, 0.0, 12.0, "%.0");
            ImGui.SliderFloat("GrabRounding", style.GrabRounding, 0.0, 12.0, "%.0");
            ImGui.SliderFloat("LogSliderDeadzone", style.LogSliderDeadzone, 0.0, 12.0, "%.0");
            ImGui.SliderFloat("TabRounding", style.TabRounding, 0.0, 12.0, "%.0");
            ImGui.Text("Alignment");
            ImGui.SliderFloat2("WindowTitleAlign", (float*)&style.WindowTitleAlign, 0.0, 1.0, "%.2f");
            int window_menu_button_position = style.WindowMenuButtonPosition + 1;
            if (ImGui.Combo("WindowMenuButtonPosition", (int*)&window_menu_button_position, "None\0Left\0Right\0"))
                style.WindowMenuButtonPosition = window_menu_button_position - 1;
            ImGui.Combo("ColorButtonPosition", (int*)&style.ColorButtonPosition, "Left\0Right\0");
            ImGui.SliderFloat2("ButtonTextAlign", (float*)&style.ButtonTextAlign, 0.0, 1.0, "%.2f");
            ImGui.SameLine(); HelpMarker("Alignment applies when a button is larger than its text content.");
            ImGui.SliderFloat2("SelectableTextAlign", (float*)&style.SelectableTextAlign, 0.0, 1.0, "%.2f");
            ImGui.SameLine(); HelpMarker("Alignment applies when a selectable is larger than its text content.");
            ImGui.Text("Safe Area Padding");
            ImGui.SameLine(); HelpMarker("Adjust if you cannot see the edges of your screen (e.g. on a TV where scaling has not been configured).");
            ImGui.SliderFloat2("DisplaySafeAreaPadding", (float*)&style.DisplaySafeAreaPadding, 0.0, 30.0, "%.0");
            ImGui.EndTabItem();
        end

        if (ImGui.BeginTabItem("Colors"))then
            static int output_dest = 0;
            local output_only_modified = true;
            if (ImGui.Button("Export"))then
                if (output_dest == 0)
                    ImGui.LogToClipboard();
                else
                    ImGui.LogToTTY();
                ImGui.LogText("ImVec4* colors = ImGui.GetStyle().Colors;" IM_NEWLINE);
                for (int i = 0; i < ImGuiCol_COUNT; i++)then
                    const ImVec4& col = style.Colors[i];
                    const char* name = ImGui.GetStyleColorName(i);
                    if (not output_only_modified or memcmp(&col, ref->Colors[i], sizeof(ImVec4)) ~= 0)
                        ImGui.LogText("colors[ImGuiCol_%s]%*s= ImVec4(%.2ff, %.2ff, %.2ff, %.2ff);" IM_NEWLINE,
                            name, 23 - (int)strlen(name), "", col.x, col.y, col.z, col.w);
                end
                ImGui.LogFinish();
            end
            ImGui.SameLine(); ImGui.SetNextItemWidth(120); ImGui.Combo("----output_type", output_dest, "To Clipboard\0To TTY\0");
            ImGui.SameLine(); ImGui.Checkbox("Only Modified Colors", output_only_modified);

            static ImGuiTextFilter filter;
            filter.Draw("Filter colors", ImGui.GetFontSize() * 16);

            static ImGuiColorEditFlags alpha_flags = 0;
            if (ImGui.RadioButton("Opaque", alpha_flags == ImGuiColorEditFlags_None))             then alpha_flags = ImGuiColorEditFlags_None; end ImGui.SameLine();
            if (ImGui.RadioButton("Alpha",  alpha_flags == ImGuiColorEditFlags_AlphaPreview))     then alpha_flags = ImGuiColorEditFlags_AlphaPreview; end ImGui.SameLine();
            if (ImGui.RadioButton("Both",   alpha_flags == ImGuiColorEditFlags_AlphaPreviewHalf)) do alpha_flags = ImGuiColorEditFlags_AlphaPreviewHalf; end ImGui.SameLine();
            HelpMarker(
                "In the color list:\n"
                "Left-click on color square to open color picker,\n"
                "Right-click to open edit options menu.");

            ImGui.BeginChild("----colors", ImVec2(0, 0), true, ImGuiWindowFlags_AlwaysVerticalScrollbar | ImGuiWindowFlags_AlwaysHorizontalScrollbar | ImGuiWindowFlags_NavFlattened);
            ImGui.PushItemWidth(-160);
            for (int i = 0; i < ImGuiCol_COUNT; i++)then
                const char* name = ImGui.GetStyleColorName(i);
                if (not filter.PassFilter(name))
                    continue;
                ImGui.PushID(i);
                ImGui.ColorEdit4("----color", (float*)&style.Colors[i], ImGuiColorEditFlags_AlphaBar | alpha_flags);
                if (memcmp(&style.Colors[i], ref->Colors[i], sizeof(ImVec4)) ~= 0)then
                    -- Tips: in a real user application, you may want to merge and use an icon font into the main font,
                    -- so instead of "Save"/"Revert" you'd use iconsnot 
                    -- Read the FAQ and docs/FONTS.md about using icon fonts. It's really easy and super convenientnot 
                    ImGui.SameLine(0.0, style.ItemInnerSpacing.x); if (ImGui.Button("Save")) do ref->Colors[i] = style.Colors[i]; end
                    ImGui.SameLine(0.0, style.ItemInnerSpacing.x); if (ImGui.Button("Revert")) do style.Colors[i] = ref->Colors[i]; end
                end
                ImGui.SameLine(0.0, style.ItemInnerSpacing.x);
                ImGui.TextUnformatted(name);
                ImGui.PopID();
            end
            ImGui.PopItemWidth();
            ImGui.EndChild();

            ImGui.EndTabItem();
        end

        if (ImGui.BeginTabItem("Fonts"))then
            ImGuiIO& io = ImGui.GetIO();
            ImFontAtlas* atlas = io.Fonts;
            HelpMarker("Read FAQ and docs/FONTS.md for details on font loading.");
            ImGui.ShowFontAtlas(atlas);

            -- Post-baking font scaling. Note that this is NOT the nice way of scaling fonts, read below.
            -- (we enforce hard clamping manually as by default DragFloat/SliderFloat allows CTRL+Click text to get out of bounds).
            const float MIN_SCALE = 0.3f;
            const float MAX_SCALE = 2.0;
            HelpMarker(
                "Those are old settings provided for convenience.\n"
                "However, the _correct_ way of scaling your UI is currently to reload your font at the designed size, "
                "rebuild the font atlas, and call style.ScaleAllSizes() on a reference ImGuiStyle structure.\n"
                "Using those settings here will give you poor quality results.");
            static float window_scale = 1.0;
            ImGui.PushItemWidth(ImGui.GetFontSize() * 8);
            if (ImGui.DragFloat("window scale", window_scale, 0.005f, MIN_SCALE, MAX_SCALE, "%.2f", ImGuiSliderFlags_AlwaysClamp)) -- Scale only this window
                ImGui.SetWindowFontScale(window_scale);
            ImGui.DragFloat("global scale", io.FontGlobalScale, 0.005f, MIN_SCALE, MAX_SCALE, "%.2f", ImGuiSliderFlags_AlwaysClamp); -- Scale everything
            ImGui.PopItemWidth();

            ImGui.EndTabItem();
        end

        if (ImGui.BeginTabItem("Rendering"))then
            ImGui.Checkbox("Anti-aliased lines", style.AntiAliasedLines);
            ImGui.SameLine();
            HelpMarker("When disabling anti-aliasing lines, you'll probably want to disable borders in your style as well.");

            ImGui.Checkbox("Anti-aliased lines use texture", style.AntiAliasedLinesUseTex);
            ImGui.SameLine();
            HelpMarker("Faster lines using texture data. Require backend to render with bilinear filtering (not point/nearest filtering).");

            ImGui.Checkbox("Anti-aliased fill", style.AntiAliasedFill);
            ImGui.PushItemWidth(ImGui.GetFontSize() * 8);
            ImGui.DragFloat("Curve Tessellation Tolerance", style.CurveTessellationTol, 0.02f, 0..0, 10.0, "%.2f");
            if (style.CurveTessellationTol < 0..0) style.CurveTessellationTol = 0..0;

            -- When editing the "Circle Segment Max Error" value, draw a preview of its effect on auto-tessellated circles.
            ImGui.DragFloat("Circle Tessellation Max Error", style.CircleTessellationMaxError , 0.005f, 0..0, 5.0, "%.2f", ImGuiSliderFlags_AlwaysClamp);
            if (ImGui.IsItemActive())then
                ImGui.SetNextWindowPos(ImGui.GetCursorScreenPos());
                ImGui.BeginTooltip();
                ImGui.TextUnformatted("(R = radius, N = number of segments)");
                ImGui.Spacing();
                ImDrawList* draw_list = ImGui.GetWindowDrawList();
                const float min_widget_width = ImGui.CalcTextSize("N: MMM\nR: MMM").x;
                for (int n = 0; n < 8; n++)then
                    const float RAD_MIN = 5.0;
                    const float RAD_MAX = 70.0;
                    const float rad = RAD_MIN + (RAD_MAX - RAD_MIN) * (float)n / (8.0 - 1.0);

                    ImGui.BeginGroup();

                    ImGui.Text("R: %.f\nN: %d", rad, draw_list->_CalcCircleAutoSegmentCount(rad));

                    const float canvas_width = IM_MAX(min_widget_width, rad * 2.0);
                    const float offset_x     = floorf(canvas_width * 0.5f);
                    const float offset_y     = floorf(RAD_MAX);

                    const ImVec2 p1 = ImGui.GetCursorScreenPos();
                    draw_list->AddCircle(ImVec2(p1.x + offset_x, p1.y + offset_y), rad, ImGui.GetColorU32(ImGuiCol_Text));
                    ImGui.Dummy(ImVec2(canvas_width, RAD_MAX * 2));

                    --
                    const ImVec2 p2 = ImGui.GetCursorScreenPos();
                    draw_list->AddCircleFilled(ImVec2(p2.x + offset_x, p2.y + offset_y), rad, ImGui.GetColorU32(ImGuiCol_Text));
                    ImGui.Dummy(ImVec2(canvas_width, RAD_MAX * 2));
                    --

                    ImGui.EndGroup();
                    ImGui.SameLine();
                end
                ImGui.EndTooltip();
            end
            ImGui.SameLine();
            HelpMarker("When drawing circle primitives with \"num_segments == 0\" tesselation will be calculated automatically.");

            ImGui.DragFloat("Global Alpha", style.Alpha, 0.005f, 0..0, 1.0, "%.2f"); -- Not exposing zero here so user doesn't "lose" the UI (zero alpha clips all widgets). But application code could have a toggle to switch between zero and non-zero.
            ImGui.DragFloat("Disabled Alpha", style.DisabledAlpha, 0.005f, 0.0, 1.0, "%.2f"); ImGui.SameLine(); HelpMarker("Additional alpha multiplier for disabled items (multiply over current value of Alpha).");
            ImGui.PopItemWidth();

            ImGui.EndTabItem();
        end

        ImGui.EndTabBar();
    end

    ImGui.PopItemWidth();
end

-------------------------------------------------------------------------------
-- [SECTION] Example App: Debug Console / ShowExampleAppConsole()
-------------------------------------------------------------------------------

-- Demonstrate creating a simple console window, with scrolling, filtering, completion and history.
-- For the console example, we are using a more C++ like approach of declaring a class to hold both data and functions.
struct ExampleAppConsole
    char                  InputBuf[256];
    ImVector<char*>       Items;
    ImVector<const char*> Commands;
    ImVector<char*>       History;
    int                   HistoryPos;    -- -1: new line, 0..History.Size-1 browsing history.
    ImGuiTextFilter       Filter;
    bool                  AutoScroll;
    bool                  ScrollToBottom;

    ExampleAppConsole()then
        ClearLog();
        memset(InputBuf, 0, sizeof(InputBuf));
        HistoryPos = -1;

        -- "CLASSIFY" is here to provide the test case where "C"+[tab] completes to "CL" and display multiple matches.
        Commands.push_back("HELP");
        Commands.push_back("HISTORY");
        Commands.push_back("CLEAR");
        Commands.push_back("CLASSIFY");
        AutoScroll = true;
        ScrollToBottom = false;
        AddLog("Welcome to Dear ImGuinot ");
    end
    ~ExampleAppConsole()then
        ClearLog();
        for (int i = 0; i < History.Size; i++)
            free(History[i]);
    end

    -- Portable helpers
    static int   Stricmp(const char* s1, const char* s2)         then int d; while ((d = toupper(*s2) - toupper(*s1)) == 0 and *s1) do s1++; s2++; end return d; end
    static int   Strnicmp(const char* s1, const char* s2, int n) do int d = 0; while (n > 0 and (d = toupper(*s2) - toupper(*s1)) == 0 and *s1) do s1++; s2++; n--; end return d; end
    static char* Strdup(const char* s)                           then IM_ASSERT(s); size_t len = strlen(s) + 1; void* buf = malloc(len); IM_ASSERT(buf); return (char*)memcpy(buf, (const void*)s, len); end
    function  Strtrim(char* s)                                then char* str_end = s + strlen(s); while (str_end > s and str_end[-1] == ' ') str_end--; *str_end = 0; end

    void    ClearLog()then
        for (int i = 0; i < Items.Size; i++)
            free(Items[i]);
        Items.clear();
    end

    void    AddLog(const char* fmt, ...) IM_FMTARGS(2)then
        -- FIXME-OPT
        char buf[1024];
        va_list args;
        va_start(args, fmt);
        vsnprintf(buf, IM_ARRAYSIZE(buf), fmt, args);
        buf[IM_ARRAYSIZE(buf)-1] = 0;
        va_end(args);
        Items.push_back(Strdup(buf));
    end

    void    Draw(const char* title, bool* p_open)then
        ImGui.SetNextWindowSize(ImVec2(520, 600), ImGuiCond_FirstUseEver);
        if (not ImGui.Begin(title, p_open))then
            ImGui.End();
            return;
        end

        -- As a specific feature guaranteed by the library, after calling Begin() the last Item represent the title bar.
        -- So e.g. IsItemHovered() will return true when hovering the title bar.
        -- Here we create a context menu only available from the title bar.
        if (ImGui.BeginPopupContextItem())then
            if (ImGui.MenuItem("Close Console"))
                *p_open = false;
            ImGui.EndPopup();
        end

        ImGui.TextWrapped(
            "This example implements a console with basic coloring, completion (TAB key) and history (Up/Down keys). A more elaborate "
            "implementation may want to store entries along with extra data such as timestamp, emitter, etc.");
        ImGui.TextWrapped("Enter 'HELP' for help.");

        -- TODO: display items starting from the bottom

        if (ImGui.SmallButton("Add Debug Text"))  do AddLog("%d some text", Items.Size); AddLog("some more text"); AddLog("display very important message herenot "); end
        ImGui.SameLine();
        if (ImGui.SmallButton("Add Debug Error")) do AddLog("[error] something went wrong"); end
        ImGui.SameLine();
        if (ImGui.SmallButton("Clear"))           then ClearLog(); end
        ImGui.SameLine();
        bool copy_to_clipboard = ImGui.SmallButton("Copy");
        --static float t = 0.0; if (ImGui.GetTime() - t > 0.02f) do t = ImGui.GetTime(); AddLog("Spam %f", t); end

        ImGui.Separator();

        -- Options menu
        if (ImGui.BeginPopup("Options"))then
            ImGui.Checkbox("Auto-scroll", AutoScroll);
            ImGui.EndPopup();
        end

        -- Options, Filter
        if (ImGui.Button("Options"))
            ImGui.OpenPopup("Options");
        ImGui.SameLine();
        Filter.Draw("Filter (\"incl,-excl\") (\"error\")", 180);
        ImGui.Separator();

        -- Reserve enough left-over height for 1 separator + 1 input text
        const float footer_height_to_reserve = ImGui.GetStyle().ItemSpacing.y + ImGui.GetFrameHeightWithSpacing();
        ImGui.BeginChild("ScrollingRegion", ImVec2(0, -footer_height_to_reserve), false, ImGuiWindowFlags_HorizontalScrollbar);
        if (ImGui.BeginPopupContextWindow())then
            if (ImGui.Selectable("Clear")) ClearLog();
            ImGui.EndPopup();
        end

        -- Display every line as a separate entry so we can change their color or add custom widgets.
        -- If you only want raw text you can use ImGui.TextUnformatted(log.begin(), log.end());
        -- NB- if you have thousands of entries this approach may be too inefficient and may require user-side clipping
        -- to only process visible items. The clipper will automatically measure the height of your first item and then
        -- "seek" to display only items in the visible area.
        -- To use the clipper we can replace your standard loop:
        --      for (int i = 0; i < Items.Size; i++)
        --   With:
        --      ImGuiListClipper clipper;
        --      clipper.Begin(Items.Size);
        --      while (clipper.Step())
        --         for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++)
        -- - That your items are evenly spaced (same height)
        -- - That you have cheap random access to your elements (you can access them given their index,
        --   without processing all the ones before)
        -- You cannot this code as-is if a filter is active because it breaks the 'cheap random-access' property.
        -- We would need random-access on the post-filtered list.
        -- A typical application wanting coarse clipping and filtering may want to pre-compute an array of indices
        -- or offsets of items that passed the filtering test, recomputing this array when user changes the filter,
        -- and appending newly elements as they are inserted. This is left as a task to the user until we can manage
        -- to improve this example codenot 
        -- If your items are of variable height:
        -- - Split them into same height items would be simpler and facilitate random-seeking into your list.
        -- - Consider using manual call to IsRectVisible() and skipping extraneous decoration from your items.
        ImGui.PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(4, 1)); -- Tighten spacing
        if (copy_to_clipboard)
            ImGui.LogToClipboard();
        for (int i = 0; i < Items.Size; i++)then
            const char* item = Items[i];
            if (not Filter.PassFilter(item))
                continue;

            -- Normally you would store more information in your item than just a string.
            -- (e.g. make Items[] an array of structure, store color/type etc.)
            ImVec4 color;
            bool has_color = false;
            if (strstr(item, "[error]"))          then color = ImVec4(1.0, 0.4f, 0.4f, 1.0); has_color = true; end
            else if (strncmp(item, "-- ", 2) == 0) do color = ImVec4(1.0, 0.8f, 0.6f, 1.0); has_color = true; end
            if (has_color)
                ImGui.PushStyleColor(ImGuiCol_Text, color);
            ImGui.TextUnformatted(item);
            if (has_color)
                ImGui.PopStyleColor();
        end
        if (copy_to_clipboard)
            ImGui.LogFinish();

        if (ScrollToBottom or (AutoScroll and ImGui.GetScrollY() >= ImGui.GetScrollMaxY()))
            ImGui.SetScrollHereY(1.0);
        ScrollToBottom = false;

        ImGui.PopStyleVar();
        ImGui.EndChild();
        ImGui.Separator();

        -- Command-line
        bool reclaim_focus = false;
        ImGuiInputTextFlags input_text_flags = ImGuiInputTextFlags_EnterReturnsTrue | ImGuiInputTextFlags_CallbackCompletion | ImGuiInputTextFlags_CallbackHistory;
        if (ImGui.InputText("Input", InputBuf, IM_ARRAYSIZE(InputBuf), input_text_flags, TextEditCallbackStub, (void*)this))then
            char* s = InputBuf;
            Strtrim(s);
            if (s[0])
                ExecCommand(s);
            strcpy(s, "");
            reclaim_focus = true;
        end

        -- Auto-focus on window apparition
        ImGui.SetItemDefaultFocus();
        if (reclaim_focus)
            ImGui.SetKeyboardFocusHere(-1); -- Auto focus previous widget

        ImGui.End();
    end

    void    ExecCommand(const char* command_line)then
        AddLog("-- %s\n", command_line);

        -- Insert into history. First find match and delete it so it can be pushed to the back.
        -- This isn't trying to be smart or optimal.
        HistoryPos = -1;
        for (int i = History.Size - 1; i >= 0; i--)
            if (Stricmp(History[i], command_line) == 0)then
                free(History[i]);
                History.erase(History.begin() + i);
                break;
            end
        History.push_back(Strdup(command_line));

        -- Process command
        if (Stricmp(command_line, "CLEAR") == 0)then
            ClearLog();
        end
        else if (Stricmp(command_line, "HELP") == 0)then
            AddLog("Commands:");
            for (int i = 0; i < Commands.Size; i++)
                AddLog("- %s", Commands[i]);
        end
        else if (Stricmp(command_line, "HISTORY") == 0)then
            int first = History.Size - 10;
            for (int i = first > 0 ? first : 0; i < History.Size; i++)
                AddLog("%3d: %s\n", i, History[i]);
        end
        elsethen
            AddLog("Unknown command: '%s'\n", command_line);
        end

        -- On command input, we scroll to bottom even if AutoScroll==false
        ScrollToBottom = true;
    end

    -- In C++11 you'd be better off using lambdas for this sort of forwarding callbacks
    static int TextEditCallbackStub(ImGuiInputTextCallbackData* data)then
        ExampleAppConsole* console = (ExampleAppConsole*)data->UserData;
        return console->TextEditCallback(data);
    end

    int     TextEditCallback(ImGuiInputTextCallbackData* data)then
        --AddLog("cursor: %d, selection: %d-%d", data->CursorPos, data->SelectionStart, data->SelectionEnd);
        switch (data->EventFlag)then
        case ImGuiInputTextFlags_CallbackCompletion:then
                -- Example of TEXT COMPLETION

                -- Locate beginning of current word
                const char* word_end = data->Buf + data->CursorPos;
                const char* word_start = word_end;
                while (word_start > data->Buf)then
                    const char c = word_start[-1];
                    if (c == ' ' or c == '\t' or c == ',' or c == ';')
                        break;
                    word_start--;
                end

                -- Build a list of candidates
                ImVector<const char*> candidates;
                for (int i = 0; i < Commands.Size; i++)
                    if (Strnicmp(Commands[i], word_start, (int)(word_end - word_start)) == 0)
                        candidates.push_back(Commands[i]);

                if (candidates.Size == 0)then
                    -- No match
                    AddLog("No match for \"%.*s\"not \n", (int)(word_end - word_start), word_start);
                end
                else if (candidates.Size == 1)then
                    -- Single match. Delete the beginning of the word and replace it entirely so we've got nice casing.
                    data->DeleteChars((int)(word_start - data->Buf), (int)(word_end - word_start));
                    data->InsertChars(data->CursorPos, candidates[0]);
                    data->InsertChars(data->CursorPos, " ");
                end
                elsethen
                    -- Multiple matches. Complete as much as we can..
                    -- So inputing "C"+Tab will complete to "CL" then display "CLEAR" and "CLASSIFY" as matches.
                    int match_len = (int)(word_end - word_start);
                    for (;;)then
                        int c = 0;
                        bool all_candidates_matches = true;
                        for (int i = 0; i < candidates.Size and all_candidates_matches; i++)
                            if (i == 0)
                                c = toupper(candidates[i][match_len]);
                            else if (c == 0 or c ~= toupper(candidates[i][match_len]))
                                all_candidates_matches = false;
                        if (not all_candidates_matches)
                            break;
                        match_len++;
                    end

                    if (match_len > 0)then
                        data->DeleteChars((int)(word_start - data->Buf), (int)(word_end - word_start));
                        data->InsertChars(data->CursorPos, candidates[0], candidates[0] + match_len);
                    end

                    -- List matches
                    AddLog("Possible matches:\n");
                    for (int i = 0; i < candidates.Size; i++)
                        AddLog("- %s\n", candidates[i]);
                end

                break;
            end
        case ImGuiInputTextFlags_CallbackHistory:then
                -- Example of HISTORY
                const int prev_history_pos = HistoryPos;
                if (data->EventKey == ImGuiKey_UpArrow)then
                    if (HistoryPos == -1)
                        HistoryPos = History.Size - 1;
                    else if (HistoryPos > 0)
                        HistoryPos--;
                end
                else if (data->EventKey == ImGuiKey_DownArrow)then
                    if (HistoryPos ~= -1)
                        if (++HistoryPos >= History.Size)
                            HistoryPos = -1;
                end

                -- A better implementation would preserve the data on the current input line along with cursor position.
                if (prev_history_pos ~= HistoryPos)then
                    const char* history_str = (HistoryPos >= 0) ? History[HistoryPos] : "";
                    data->DeleteChars(0, data->BufTextLen);
                    data->InsertChars(0, history_str);
                end
            end
        end
        return 0;
    end
end;

function ShowExampleAppConsole(bool* p_open)
    static ExampleAppConsole console;
    console.Draw("Example: Console", p_open);
end

-------------------------------------------------------------------------------
-- [SECTION] Example App: Debug Log / ShowExampleAppLog()
-------------------------------------------------------------------------------

-- Usage:
--  static ExampleAppLog my_log;
--  my_log.AddLog("Hello %d world\n", 123);
--  my_log.Draw("title");
struct ExampleAppLog
    ImGuiTextBuffer     Buf;
    ImGuiTextFilter     Filter;
    ImVector<int>       LineOffsets; -- Index to lines offset. We maintain this with AddLog() calls.
    bool                AutoScroll;  -- Keep scrolling if already at the bottom.

    ExampleAppLog()then
        AutoScroll = true;
        Clear();
    end

    void    Clear()then
        Buf.clear();
        LineOffsets.clear();
        LineOffsets.push_back(0);
    end

    void    AddLog(const char* fmt, ...) IM_FMTARGS(2)then
        int old_size = Buf.size();
        va_list args;
        va_start(args, fmt);
        Buf.appendfv(fmt, args);
        va_end(args);
        for (int new_size = Buf.size(); old_size < new_size; old_size++)
            if (Buf[old_size] == '\n')
                LineOffsets.push_back(old_size + 1);
    end

    void    Draw(const char* title, bool* p_open = NULL)then
        if (not ImGui.Begin(title, p_open))then
            ImGui.End();
            return;
        end

        -- Options menu
        if (ImGui.BeginPopup("Options"))then
            ImGui.Checkbox("Auto-scroll", AutoScroll);
            ImGui.EndPopup();
        end

        -- Main window
        if (ImGui.Button("Options"))
            ImGui.OpenPopup("Options");
        ImGui.SameLine();
        bool clear = ImGui.Button("Clear");
        ImGui.SameLine();
        bool copy = ImGui.Button("Copy");
        ImGui.SameLine();
        Filter.Draw("Filter", -100.0);

        ImGui.Separator();
        ImGui.BeginChild("scrolling", ImVec2(0, 0), false, ImGuiWindowFlags_HorizontalScrollbar);

        if (clear)
            Clear();
        if (copy)
            ImGui.LogToClipboard();

        ImGui.PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(0, 0));
        const char* buf = Buf.begin();
        const char* buf_end = Buf.end();
        if (Filter.IsActive())then
            -- In this example we don't use the clipper when Filter is enabled.
            -- This is because we don't have a random access on the result on our filter.
            -- A real application processing logs with ten of thousands of entries may want to store the result of
            -- search/filter.. especially if the filtering function is not trivial (e.g. reg-exp).
            for (int line_no = 0; line_no < LineOffsets.Size; line_no++)then
                const char* line_start = buf + LineOffsets[line_no];
                const char* line_end = (line_no + 1 < LineOffsets.Size) ? (buf + LineOffsets[line_no + 1] - 1) : buf_end;
                if (Filter.PassFilter(line_start, line_end))
                    ImGui.TextUnformatted(line_start, line_end);
            end
        end
        elsethen
            -- The simplest and easy way to display the entire buffer:
            --   ImGui.TextUnformatted(buf_begin, buf_end);
            -- And it'll just work. TextUnformatted() has specialization for large blob of text and will fast-forward
            -- to skip non-visible lines. Here we instead demonstrate using the clipper to only process lines that are
            -- within the visible area.
            -- If you have tens of thousands of items and their processing cost is non-negligible, coarse clipping them
            -- on your side is recommended. Using ImGuiListClipper requires
            -- - A) random access into your data
            -- - B) items all being the  same height,
            -- both of which we can handle since we an array pointing to the beginning of each line of text.
            -- When using the filter (in the block of code above) we don't have random access into the data to display
            -- anymore, which is why we don't use the clipper. Storing or skimming through the search result would make
            -- it possible (and would be recommended if you want to search through tens of thousands of entries).
            ImGuiListClipper clipper;
            clipper.Begin(LineOffsets.Size);
            while (clipper.Step())then
                for (int line_no = clipper.DisplayStart; line_no < clipper.DisplayEnd; line_no++)then
                    const char* line_start = buf + LineOffsets[line_no];
                    const char* line_end = (line_no + 1 < LineOffsets.Size) ? (buf + LineOffsets[line_no + 1] - 1) : buf_end;
                    ImGui.TextUnformatted(line_start, line_end);
                end
            end
            clipper.End();
        end
        ImGui.PopStyleVar();

        if (AutoScroll and ImGui.GetScrollY() >= ImGui.GetScrollMaxY())
            ImGui.SetScrollHereY(1.0);

        ImGui.EndChild();
        ImGui.End();
    end
end;

-- Demonstrate creating a simple log window with basic filtering.
function ShowExampleAppLog(bool* p_open)
    static ExampleAppLog log;

    -- For the demo: add a debug button _BEFORE_ the normal log window contents
    -- We take advantage of a rarely used feature: multiple calls to Begin()/End() are appending to the _same_ window.
    -- Most of the contents of the window will be added by the log.Draw() call.
    ImGui.SetNextWindowSize(ImVec2(500, 400), ImGuiCond_FirstUseEver);
    ImGui.Begin("Example: Log", p_open);
    if (ImGui.SmallButton("[Debug] Add 5 entries"))then
        static int counter = 0;
        const char* categories[3] = do "info", "warn", "error" end;
        const char* words[] = do "Bumfuzzled", "Cattywampus", "Snickersnee", "Abibliophobia", "Absquatulate", "Nincompoop", "Pauciloquent" end;
        for (int n = 0; n < 5; n++)then
            const char* category = categories[counter % IM_ARRAYSIZE(categories)];
            const char* word = words[counter % IM_ARRAYSIZE(words)];
            log.AddLog("[%05d] [%s] Hello, current time is %.1f, here's a word: '%s'\n",
                ImGui.GetFrameCount(), category, ImGui.GetTime(), word);
            counter++;
        end
    end
    ImGui.End();

    -- Actually call in the regular Log helper (which will Begin() into the same window as we just did)
    log.Draw("Example: Log", p_open);
end

-------------------------------------------------------------------------------
-- [SECTION] Example App: Simple Layout / ShowExampleAppLayout()
-------------------------------------------------------------------------------

-- Demonstrate create a window with multiple child windows.
function ShowExampleAppLayout(bool* p_open)
    ImGui.SetNextWindowSize(ImVec2(500, 440), ImGuiCond_FirstUseEver);
    if (ImGui.Begin("Example: Simple layout", p_open, ImGuiWindowFlags_MenuBar))then
        if (ImGui.BeginMenuBar())then
            if (ImGui.BeginMenu("File"))then
                if (ImGui.MenuItem("Close")) *p_open = false;
                ImGui.EndMenu();
            end
            ImGui.EndMenuBar();
        end

        -- Left
        static int selected = 0;then
            ImGui.BeginChild("left pane", ImVec2(150, 0), true);
            for (int i = 0; i < 100; i++)then
                -- FIXME: Good candidate to use ImGuiSelectableFlags_SelectOnNav
                char label[128];
                sprintf(label, "MyObject %d", i);
                if (ImGui.Selectable(label, selected == i))
                    selected = i;
            end
            ImGui.EndChild();
        end
        ImGui.SameLine();

        -- Rightthen
            ImGui.BeginGroup();
            ImGui.BeginChild("item view", ImVec2(0, -ImGui.GetFrameHeightWithSpacing())); -- Leave room for 1 line below us
            ImGui.Text("MyObject: %d", selected);
            ImGui.Separator();
            if (ImGui.BeginTabBar("----Tabs", ImGuiTabBarFlags_None))then
                if (ImGui.BeginTabItem("Description"))then
                    ImGui.TextWrapped("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ");
                    ImGui.EndTabItem();
                end
                if (ImGui.BeginTabItem("Details"))then
                    ImGui.Text("ID: 0123456789");
                    ImGui.EndTabItem();
                end
                ImGui.EndTabBar();
            end
            ImGui.EndChild();
            if (ImGui.Button("Revert")) do end
            ImGui.SameLine();
            if (ImGui.Button("Save")) do end
            ImGui.EndGroup();
        end
    end
    ImGui.End();
end

-------------------------------------------------------------------------------
-- [SECTION] Example App: Property Editor / ShowExampleAppPropertyEditor()
-------------------------------------------------------------------------------

function ShowPlaceholderObject(const char* prefix, int uid)
    -- Use object uid as identifier. Most commonly you could also use the object pointer as a base ID.
    ImGui.PushID(uid);

    -- Text and Tree nodes are less high than framed widgets, using AlignTextToFramePadding() we add vertical spacing to make the tree lines equal high.
    ImGui.TableNextRow();
    ImGui.TableSetColumnIndex(0);
    ImGui.AlignTextToFramePadding();
    bool node_open = ImGui.TreeNode("Object", "%s_%u", prefix, uid);
    ImGui.TableSetColumnIndex(1);
    ImGui.Text("my sailor is rich");

    if (node_open)then
        static float placeholder_members[8] = do 0.0, 0.0, 1.0, 3.1416f, 100.0, 999.0 end;
        for (int i = 0; i < 8; i++)then
            ImGui.PushID(i); -- Use field index as identifier.
            if (i < 2)then
                ShowPlaceholderObject("Child", 424242);
            end
            elsethen
                -- Here we use a TreeNode to highlight on hover (we could use e.g. Selectable as well)
                ImGui.TableNextRow();
                ImGui.TableSetColumnIndex(0);
                ImGui.AlignTextToFramePadding();
                ImGuiTreeNodeFlags flags = ImGuiTreeNodeFlags_Leaf | ImGuiTreeNodeFlags_NoTreePushOnOpen | ImGuiTreeNodeFlags_Bullet;
                ImGui.TreeNodeEx("Field", flags, "Field_%d", i);

                ImGui.TableSetColumnIndex(1);
                ImGui.SetNextItemWidth(-FLT_MIN);
                if (i >= 5)
                    ImGui.InputFloat("----value", placeholder_members[i], 1.0);
                else
                    ImGui.DragFloat("----value", placeholder_members[i], 0.01f);
                ImGui.NextColumn();
            end
            ImGui.PopID();
        end
        ImGui.TreePop();
    end
    ImGui.PopID();
end

-- Demonstrate create a simple property editor.
function ShowExampleAppPropertyEditor(bool* p_open)
    ImGui.SetNextWindowSize(ImVec2(430, 450), ImGuiCond_FirstUseEver);
    if (not ImGui.Begin("Example: Property editor", p_open))then
        ImGui.End();
        return;
    end

    HelpMarker(
        "This example shows how you may implement a property editor using two columns.\n"
        "All objects/fields data are dummies here.\n"
        "Remember that in many simple cases, you can use ImGui.SameLine(xxx) to position\n"
        "your cursor horizontally instead of using the Columns() API.");

    ImGui.PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(2, 2));
    if (ImGui.BeginTable("split", 2, ImGuiTableFlags_BordersOuter | ImGuiTableFlags_Resizable))then
        -- Iterate placeholder objects (all the same data)
        for (int obj_i = 0; obj_i < 4; obj_i++)then
            ShowPlaceholderObject("Object", obj_i);
            --ImGui.Separator();
        end
        ImGui.EndTable();
    end
    ImGui.PopStyleVar();
    ImGui.End();
end

-------------------------------------------------------------------------------
-- [SECTION] Example App: Long Text / ShowExampleAppLongText()
-------------------------------------------------------------------------------

-- Demonstrate/test rendering huge amount of text, and the incidence of clipping.
function ShowExampleAppLongText(bool* p_open)
    ImGui.SetNextWindowSize(ImVec2(520, 600), ImGuiCond_FirstUseEver);
    if (not ImGui.Begin("Example: Long text display", p_open))then
        ImGui.End();
        return;
    end

    static int test_type = 0;
    static ImGuiTextBuffer log;
    static int lines = 0;
    ImGui.Text("Printing unusually long amount of text.");
    ImGui.Combo("Test type", test_type,
        "Single call to TextUnformatted()\0"
        "Multiple calls to Text(), clipped\0"
        "Multiple calls to Text(), not clipped (slow)\0");
    ImGui.Text("Buffer contents: %d lines, %d bytes", lines, log.size());
    if (ImGui.Button("Clear")) do log.clear(); lines = 0; end
    ImGui.SameLine();
    if (ImGui.Button("Add 1000 lines"))then
        for (int i = 0; i < 1000; i++)
            log.appendf("%i The quick brown fox jumps over the lazy dog\n", lines + i);
        lines += 1000;
    end
    ImGui.BeginChild("Log");
    switch (test_type)then
    case 0:
        -- Single call to TextUnformatted() with a big buffer
        ImGui.TextUnformatted(log.begin(), log.end());
        break;
    case 1:then
            -- Multiple calls to Text(), manually coarsely clipped - demonstrate how to use the ImGuiListClipper helper.
            ImGui.PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(0, 0));
            ImGuiListClipper clipper;
            clipper.Begin(lines);
            while (clipper.Step())
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++)
                    ImGui.Text("%i The quick brown fox jumps over the lazy dog", i);
            ImGui.PopStyleVar();
            break;
        end
    case 2:
        -- Multiple calls to Text(), not clipped (slow)
        ImGui.PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(0, 0));
        for (int i = 0; i < lines; i++)
            ImGui.Text("%i The quick brown fox jumps over the lazy dog", i);
        ImGui.PopStyleVar();
        break;
    end
    ImGui.EndChild();
    ImGui.End();
end

-------------------------------------------------------------------------------
-- [SECTION] Example App: Auto Resize / ShowExampleAppAutoResize()
-------------------------------------------------------------------------------

-- Demonstrate creating a window which gets auto-resized according to its content.
function ShowExampleAppAutoResize(bool* p_open)
    if (not ImGui.Begin("Example: Auto-resizing window", p_open, ImGuiWindowFlags_AlwaysAutoResize))then
        ImGui.End();
        return;
    end

    static int lines = 10;
    ImGui.TextUnformatted(
        "Window will resize every-frame to the size of its content.\n"
        "Note that you probably don't want to query the window size to\n"
        "output your content because that would create a feedback loop.");
    ImGui.SliderInt("Number of lines", lines, 1, 20);
    for (int i = 0; i < lines; i++)
        ImGui.Text("%*sThis is line %d", i * 4, "", i); -- Pad with space to extend size horizontally
    ImGui.End();
end

-------------------------------------------------------------------------------
-- [SECTION] Example App: Constrained Resize / ShowExampleAppConstrainedResize()
-------------------------------------------------------------------------------

-- Demonstrate creating a window with custom resize constraints.
function ShowExampleAppConstrainedResize(bool* p_open)
    struct CustomConstraintsthen
        -- Helper functions to demonstrate programmatic constraints
        function Square(ImGuiSizeCallbackData* data) do data->DesiredSize.x = data->DesiredSize.y = IM_MAX(data->DesiredSize.x, data->DesiredSize.y); end
        function Step(ImGuiSizeCallbackData* data)   do float step = (float)(int)(intptr_t)data->UserData; data->DesiredSize = ImVec2((int)(data->DesiredSize.x / step + 0.5f) * step, (int)(data->DesiredSize.y / step + 0.5f) * step); end
    end;

    const char* test_desc[] =then
        "Resize vertical only",
        "Resize horizontal only",
        "Width > 100, Height > 100",
        "Width 400-500",
        "Height 400-500",
        "Custom: Always Square",
        "Custom: Fixed Steps (100)",
    end;

    local auto_resize = false;
    static int type = 0;
    static int display_lines = 10;
    if (type == 0) ImGui.SetNextWindowSizeConstraints(ImVec2(-1, 0),    ImVec2(-1, FLT_MAX));      -- Vertical only
    if (type == 1) ImGui.SetNextWindowSizeConstraints(ImVec2(0, -1),    ImVec2(FLT_MAX, -1));      -- Horizontal only
    if (type == 2) ImGui.SetNextWindowSizeConstraints(ImVec2(100, 100), ImVec2(FLT_MAX, FLT_MAX)); -- Width > 100, Height > 100
    if (type == 3) ImGui.SetNextWindowSizeConstraints(ImVec2(400, -1),  ImVec2(500, -1));          -- Width 400-500
    if (type == 4) ImGui.SetNextWindowSizeConstraints(ImVec2(-1, 400),  ImVec2(-1, 500));          -- Height 400-500
    if (type == 5) ImGui.SetNextWindowSizeConstraints(ImVec2(0, 0),     ImVec2(FLT_MAX, FLT_MAX), CustomConstraints.Square);                     -- Always Square
    if (type == 6) ImGui.SetNextWindowSizeConstraints(ImVec2(0, 0),     ImVec2(FLT_MAX, FLT_MAX), CustomConstraints.Step, (void*)(intptr_t)100); -- Fixed Step

    ImGuiWindowFlags flags = auto_resize ? ImGuiWindowFlags_AlwaysAutoResize : 0;
    if (ImGui.Begin("Example: Constrained Resize", p_open, flags))then
        if (ImGui.IsWindowDocked())
            ImGui.Text("Warning: Sizing Constraints won't work if the window is dockednot ");
        if (ImGui.Button("200x200")) do ImGui.SetWindowSize(ImVec2(200, 200)); end ImGui.SameLine();
        if (ImGui.Button("500x500")) do ImGui.SetWindowSize(ImVec2(500, 500)); end ImGui.SameLine();
        if (ImGui.Button("800x200")) do ImGui.SetWindowSize(ImVec2(800, 200)); end
        ImGui.SetNextItemWidth(200);
        ImGui.Combo("Constraint", type, test_desc, IM_ARRAYSIZE(test_desc));
        ImGui.SetNextItemWidth(200);
        ImGui.DragInt("Lines", display_lines, 0.2f, 1, 100);
        ImGui.Checkbox("Auto-resize", auto_resize);
        for (int i = 0; i < display_lines; i++)
            ImGui.Text("%*sHello, sailornot  Making this line long enough for the example.", i * 4, "");
    end
    ImGui.End();
end

-------------------------------------------------------------------------------
-- [SECTION] Example App: Simple overlay / ShowExampleAppSimpleOverlay()
-------------------------------------------------------------------------------

-- Demonstrate creating a simple static window with no decoration
-- + a context-menu to choose which corner of the screen to use.
function ShowExampleAppSimpleOverlay(bool* p_open)
    static int corner = 0;
    ImGuiIO& io = ImGui.GetIO();
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoDocking | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoNav;
    if (corner ~= -1)then
        const float PAD = 10.0;
        const ImGuiViewport* viewport = ImGui.GetMainViewport();
        ImVec2 work_pos = viewport->WorkPos; -- Use work area to avoid menu-bar/task-bar, if anynot 
        ImVec2 work_size = viewport->WorkSize;
        ImVec2 window_pos, window_pos_pivot;
        window_pos.x = (corner & 1) ? (work_pos.x + work_size.x - PAD) : (work_pos.x + PAD);
        window_pos.y = (corner & 2) ? (work_pos.y + work_size.y - PAD) : (work_pos.y + PAD);
        window_pos_pivot.x = (corner & 1) ? 1.0 : 0.0;
        window_pos_pivot.y = (corner & 2) ? 1.0 : 0.0;
        ImGui.SetNextWindowPos(window_pos, ImGuiCond_Always, window_pos_pivot);
        ImGui.SetNextWindowViewport(viewport->ID);
        window_flags |= ImGuiWindowFlags_NoMove;
    end
    ImGui.SetNextWindowBgAlpha(0.35f); -- Transparent background
    if (ImGui.Begin("Example: Simple overlay", p_open, window_flags))then
        ImGui.Text("Simple overlay\n" "in the corner of the screen.\n" "(right-click to change position)");
        ImGui.Separator();
        if (ImGui.IsMousePosValid())
            ImGui.Text("Mouse Position: (%.1f,%.1f)", io.MousePos.x, io.MousePos.y);
        else
            ImGui.Text("Mouse Position: <invalid>");
        if (ImGui.BeginPopupContextWindow())then
            if (ImGui.MenuItem("Custom",       NULL, corner == -1)) corner = -1;
            if (ImGui.MenuItem("Top-left",     NULL, corner == 0)) corner = 0;
            if (ImGui.MenuItem("Top-right",    NULL, corner == 1)) corner = 1;
            if (ImGui.MenuItem("Bottom-left",  NULL, corner == 2)) corner = 2;
            if (ImGui.MenuItem("Bottom-right", NULL, corner == 3)) corner = 3;
            if (p_open and ImGui.MenuItem("Close")) *p_open = false;
            ImGui.EndPopup();
        end
    end
    ImGui.End();
end

-------------------------------------------------------------------------------
-- [SECTION] Example App: Fullscreen window / ShowExampleAppFullscreen()
-------------------------------------------------------------------------------

-- Demonstrate creating a window covering the entire screen/viewport
function ShowExampleAppFullscreen(bool* p_open)
    local use_work_area = true;
    static ImGuiWindowFlags flags = ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoSavedSettings;

    -- We demonstrate using the full viewport area or the work area (without menu-bars, task-bars etc.)
    -- Based on your use case you may want one of the other.
    const ImGuiViewport* viewport = ImGui.GetMainViewport();
    ImGui.SetNextWindowPos(use_work_area ? viewport->WorkPos : viewport->Pos);
    ImGui.SetNextWindowSize(use_work_area ? viewport->WorkSize : viewport->Size);

    if (ImGui.Begin("Example: Fullscreen window", p_open, flags))then
        ImGui.Checkbox("Use work area instead of main area", use_work_area);
        ImGui.SameLine();
        HelpMarker("Main Area = entire viewport,\nWork Area = entire viewport minus sections used by the main menu bars, task bars etc.\n\nEnable the main-menu bar in Examples menu to see the difference.");

        ImGui.CheckboxFlags("ImGuiWindowFlags_NoBackground", flags, ImGuiWindowFlags_NoBackground);
        ImGui.CheckboxFlags("ImGuiWindowFlags_NoDecoration", flags, ImGuiWindowFlags_NoDecoration);
        ImGui.Indent();
        ImGui.CheckboxFlags("ImGuiWindowFlags_NoTitleBar", flags, ImGuiWindowFlags_NoTitleBar);
        ImGui.CheckboxFlags("ImGuiWindowFlags_NoCollapse", flags, ImGuiWindowFlags_NoCollapse);
        ImGui.CheckboxFlags("ImGuiWindowFlags_NoScrollbar", flags, ImGuiWindowFlags_NoScrollbar);
        ImGui.Unindent();

        if (p_open and ImGui.Button("Close this window"))
            *p_open = false;
    end
    ImGui.End();
end

-------------------------------------------------------------------------------
-- [SECTION] Example App: Manipulating Window Titles / ShowExampleAppWindowTitles()
-------------------------------------------------------------------------------

-- Demonstrate using "----" and "------" in identifiers to manipulate ID generation.
-- This apply to all regular items as well.
-- Read FAQ section "How can I have multiple widgets with the same label?" for details.
function ShowExampleAppWindowTitles(bool*)
    const ImGuiViewport* viewport = ImGui.GetMainViewport();
    const ImVec2 base_pos = viewport->Pos;

    -- By default, Windows are uniquely identified by their title.
    -- You can use the "----" and "------" markers to manipulate the display/ID.

    -- Using "----" to display same title but have unique identifier.
    ImGui.SetNextWindowPos(ImVec2(base_pos.x + 100, base_pos.y + 100), ImGuiCond_FirstUseEver);
    ImGui.Begin("Same title as another window----1");
    ImGui.Text("This is window 1.\nMy title is the same as window 2, but my identifier is unique.");
    ImGui.End();

    ImGui.SetNextWindowPos(ImVec2(base_pos.x + 100, base_pos.y + 200), ImGuiCond_FirstUseEver);
    ImGui.Begin("Same title as another window----2");
    ImGui.Text("This is window 2.\nMy title is the same as window 1, but my identifier is unique.");
    ImGui.End();

    -- Using "------" to display a changing title but keep a static identifier "AnimatedTitle"
    char buf[128];
    sprintf(buf, "Animated title %c %d------AnimatedTitle", "|/-\\"[(int)(ImGui.GetTime() / 0.25f) & 3], ImGui.GetFrameCount());
    ImGui.SetNextWindowPos(ImVec2(base_pos.x + 100, base_pos.y + 300), ImGuiCond_FirstUseEver);
    ImGui.Begin(buf);
    ImGui.Text("This window has a changing title.");
    ImGui.End();
end

-------------------------------------------------------------------------------
-- [SECTION] Example App: Custom Rendering using ImDrawList API / ShowExampleAppCustomRendering()
-------------------------------------------------------------------------------

-- Demonstrate using the low-level ImDrawList to draw custom shapes.
function ShowExampleAppCustomRendering(bool* p_open)
    if (not ImGui.Begin("Example: Custom rendering", p_open))then
        ImGui.End();
        return;
    end

    -- Tip: If you do a lot of custom rendering, you probably want to use your own geometrical types and benefit of
    -- overloaded operators, etc. Define IM_VEC2_CLASS_EXTRA in imconfig.h to create implicit conversions between your
    -- types and ImVec2/ImVec4. Dear ImGui defines overloaded operators but they are internal to imgui.cpp and not
    -- exposed outside (to avoid messing with your types) In this example we are not using the maths operatorsnot 

    if (ImGui.BeginTabBar("----TabBar"))then
        if (ImGui.BeginTabItem("Primitives"))then
            ImGui.PushItemWidth(-ImGui.GetFontSize() * 15);
            ImDrawList* draw_list = ImGui.GetWindowDrawList();

            -- Draw gradients
            -- (note that those are currently exacerbating our sRGB/Linear issues)
            -- Calling ImGui.GetColorU32() multiplies the given colors by the current Style Alpha, but you may pass the IM_COL32() directly as well..
            ImGui.Text("Gradients");
            ImVec2 gradient_size = ImVec2(ImGui.CalcItemWidth(), ImGui.GetFrameHeight());then
                ImVec2 p0 = ImGui.GetCursorScreenPos();
                ImVec2 p1 = ImVec2(p0.x + gradient_size.x, p0.y + gradient_size.y);
                ImU32 col_a = ImGui.GetColorU32(IM_COL32(0, 0, 0, 255));
                ImU32 col_b = ImGui.GetColorU32(IM_COL32(255, 255, 255, 255));
                draw_list->AddRectFilledMultiColor(p0, p1, col_a, col_b, col_b, col_a);
                ImGui.InvisibleButton("----gradient1", gradient_size);
            endthen
                ImVec2 p0 = ImGui.GetCursorScreenPos();
                ImVec2 p1 = ImVec2(p0.x + gradient_size.x, p0.y + gradient_size.y);
                ImU32 col_a = ImGui.GetColorU32(IM_COL32(0, 255, 0, 255));
                ImU32 col_b = ImGui.GetColorU32(IM_COL32(255, 0, 0, 255));
                draw_list->AddRectFilledMultiColor(p0, p1, col_a, col_b, col_b, col_a);
                ImGui.InvisibleButton("----gradient2", gradient_size);
            end

            -- Draw a bunch of primitives
            ImGui.Text("All primitives");
            static float sz = 36.0;
            static float thickness = 3.0;
            static int ngon_sides = 6;
            local circle_segments_override = false;
            static int circle_segments_override_v = 12;
            local curve_segments_override = false;
            static int curve_segments_override_v = 8;
            static ImVec4 colf = ImVec4(1.0, 1.0, 0.4f, 1.0);
            ImGui.DragFloat("Size", sz, 0.2f, 2.0, 100.0, "%.0");
            ImGui.DragFloat("Thickness", thickness, 0.05f, 1.0, 8.0, "%.02f");
            ImGui.SliderInt("N-gon sides", ngon_sides, 3, 12);
            ImGui.Checkbox("----circlesegmentoverride", circle_segments_override);
            ImGui.SameLine(0.0, ImGui.GetStyle().ItemInnerSpacing.x);
            circle_segments_override |= ImGui.SliderInt("Circle segments override", circle_segments_override_v, 3, 40);
            ImGui.Checkbox("----curvessegmentoverride", curve_segments_override);
            ImGui.SameLine(0.0, ImGui.GetStyle().ItemInnerSpacing.x);
            curve_segments_override |= ImGui.SliderInt("Curves segments override", curve_segments_override_v, 3, 40);
            ImGui.ColorEdit4("Color", colf.x);

            const ImVec2 p = ImGui.GetCursorScreenPos();
            const ImU32 col = ImColor(colf);
            const float spacing = 10.0;
            const ImDrawFlags corners_tl_br = ImDrawFlags_RoundCornersTopLeft | ImDrawFlags_RoundCornersBottomRight;
            const float rounding = sz / 5.0;
            const int circle_segments = circle_segments_override ? circle_segments_override_v : 0;
            const int curve_segments = curve_segments_override ? curve_segments_override_v : 0;
            float x = p.x + 4.0;
            float y = p.y + 4.0;
            for (int n = 0; n < 2; n++)then
                -- First line uses a thickness of 1.0, second line uses the configurable thickness
                float th = (n == 0) ? 1.0 : thickness;
                draw_list->AddNgon(ImVec2(x + sz*0.5f, y + sz*0.5f), sz*0.5f, col, ngon_sides, th);                 x += sz + spacing;  -- N-gon
                draw_list->AddCircle(ImVec2(x + sz*0.5f, y + sz*0.5f), sz*0.5f, col, circle_segments, th);          x += sz + spacing;  -- Circle
                draw_list->AddRect(ImVec2(x, y), ImVec2(x + sz, y + sz), col, 0.0, ImDrawFlags_None, th);          x += sz + spacing;  -- Square
                draw_list->AddRect(ImVec2(x, y), ImVec2(x + sz, y + sz), col, rounding, ImDrawFlags_None, th);      x += sz + spacing;  -- Square with all rounded corners
                draw_list->AddRect(ImVec2(x, y), ImVec2(x + sz, y + sz), col, rounding, corners_tl_br, th);         x += sz + spacing;  -- Square with two rounded corners
                draw_list->AddTriangle(ImVec2(x+sz*0.5f,y), ImVec2(x+sz, y+sz-0.5f), ImVec2(x, y+sz-0.5f), col, th);x += sz + spacing;  -- Triangle
                --draw_list->AddTriangle(ImVec2(x+sz*0.2f,y), ImVec2(x, y+sz-0.5f), ImVec2(x+sz*0.4f, y+sz-0.5f), col, th);x+= sz*0.4f + spacing; -- Thin triangle
                draw_list->AddLine(ImVec2(x, y), ImVec2(x + sz, y), col, th);                                       x += sz + spacing;  -- Horizontal line (note: drawing a filled rectangle will be fasternot )
                draw_list->AddLine(ImVec2(x, y), ImVec2(x, y + sz), col, th);                                       x += spacing;       -- Vertical line (note: drawing a filled rectangle will be fasternot )
                draw_list->AddLine(ImVec2(x, y), ImVec2(x + sz, y + sz), col, th);                                  x += sz + spacing;  -- Diagonal line

                -- Quadratic Bezier Curve (3 control points)
                ImVec2 cp3[3] = do ImVec2(x, y + sz * 0.6f), ImVec2(x + sz * 0.5f, y - sz * 0.4f), ImVec2(x + sz, y + sz) end;
                draw_list->AddBezierQuadratic(cp3[0], cp3[1], cp3[2], col, th, curve_segments); x += sz + spacing;

                -- Cubic Bezier Curve (4 control points)
                ImVec2 cp4[4] = do ImVec2(x, y), ImVec2(x + sz * 1.3f, y + sz * 0.3f), ImVec2(x + sz - sz * 1.3f, y + sz - sz * 0.3f), ImVec2(x + sz, y + sz) end;
                draw_list->AddBezierCubic(cp4[0], cp4[1], cp4[2], cp4[3], col, th, curve_segments);

                x = p.x + 4;
                y += sz + spacing;
            end
            draw_list->AddNgonFilled(ImVec2(x + sz * 0.5f, y + sz * 0.5f), sz*0.5f, col, ngon_sides);               x += sz + spacing;  -- N-gon
            draw_list->AddCircleFilled(ImVec2(x + sz*0.5f, y + sz*0.5f), sz*0.5f, col, circle_segments);            x += sz + spacing;  -- Circle
            draw_list->AddRectFilled(ImVec2(x, y), ImVec2(x + sz, y + sz), col);                                    x += sz + spacing;  -- Square
            draw_list->AddRectFilled(ImVec2(x, y), ImVec2(x + sz, y + sz), col, 10.0);                             x += sz + spacing;  -- Square with all rounded corners
            draw_list->AddRectFilled(ImVec2(x, y), ImVec2(x + sz, y + sz), col, 10.0, corners_tl_br);              x += sz + spacing;  -- Square with two rounded corners
            draw_list->AddTriangleFilled(ImVec2(x+sz*0.5f,y), ImVec2(x+sz, y+sz-0.5f), ImVec2(x, y+sz-0.5f), col);  x += sz + spacing;  -- Triangle
            --draw_list->AddTriangleFilled(ImVec2(x+sz*0.2f,y), ImVec2(x, y+sz-0.5f), ImVec2(x+sz*0.4f, y+sz-0.5f), col); x += sz*0.4f + spacing; -- Thin triangle
            draw_list->AddRectFilled(ImVec2(x, y), ImVec2(x + sz, y + thickness), col);                             x += sz + spacing;  -- Horizontal line (faster than AddLine, but only handle integer thickness)
            draw_list->AddRectFilled(ImVec2(x, y), ImVec2(x + thickness, y + sz), col);                             x += spacing * 2.0;-- Vertical line (faster than AddLine, but only handle integer thickness)
            draw_list->AddRectFilled(ImVec2(x, y), ImVec2(x + 1, y + 1), col);                                      x += sz;            -- Pixel (faster than AddLine)
            draw_list->AddRectFilledMultiColor(ImVec2(x, y), ImVec2(x + sz, y + sz), IM_COL32(0, 0, 0, 255), IM_COL32(255, 0, 0, 255), IM_COL32(255, 255, 0, 255), IM_COL32(0, 255, 0, 255));

            ImGui.Dummy(ImVec2((sz + spacing) * 10.2f, (sz + spacing) * 3.0));
            ImGui.PopItemWidth();
            ImGui.EndTabItem();
        end

        if (ImGui.BeginTabItem("Canvas"))then
            static ImVector<ImVec2> points;
            static ImVec2 scrolling(0.0, 0.0);
            local opt_enable_grid = true;
            local opt_enable_context_menu = true;
            local adding_line = false;

            ImGui.Checkbox("Enable grid", opt_enable_grid);
            ImGui.Checkbox("Enable context menu", opt_enable_context_menu);
            ImGui.Text("Mouse Left: drag to add lines,\nMouse Right: drag to scroll, click for context menu.");

            -- Typically you would use a BeginChild()/EndChild() pair to benefit from a clipping region + own scrolling.
            -- Here we demonstrate that this can be replaced by simple offsetting + custom drawing + PushClipRect/PopClipRect() calls.
            -- To use a child window instead we could use, e.g:
            --      ImGui.PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0, 0));      -- Disable padding
            --      ImGui.PushStyleColor(ImGuiCol_ChildBg, IM_COL32(50, 50, 50, 255));  -- Set a background color
            --      ImGui.BeginChild("canvas", ImVec2(0.0, 0.0), true, ImGuiWindowFlags_NoMove);
            --      ImGui.PopStyleColor();
            --      ImGui.PopStyleVar();
            --      [...]
            --      ImGui.EndChild();

            -- Using InvisibleButton() as a convenience 1) it will advance the layout cursor and 2) allows us to use IsItemHovered()/IsItemActive()
            ImVec2 canvas_p0 = ImGui.GetCursorScreenPos();      -- ImDrawList API uses screen coordinatesnot 
            ImVec2 canvas_sz = ImGui.GetContentRegionAvail();   -- Resize canvas to what's available
            if (canvas_sz.x < 50.0) canvas_sz.x = 50.0;
            if (canvas_sz.y < 50.0) canvas_sz.y = 50.0;
            ImVec2 canvas_p1 = ImVec2(canvas_p0.x + canvas_sz.x, canvas_p0.y + canvas_sz.y);

            -- Draw border and background color
            ImGuiIO& io = ImGui.GetIO();
            ImDrawList* draw_list = ImGui.GetWindowDrawList();
            draw_list->AddRectFilled(canvas_p0, canvas_p1, IM_COL32(50, 50, 50, 255));
            draw_list->AddRect(canvas_p0, canvas_p1, IM_COL32(255, 255, 255, 255));

            -- This will catch our interactions
            ImGui.InvisibleButton("canvas", canvas_sz, ImGuiButtonFlags_MouseButtonLeft | ImGuiButtonFlags_MouseButtonRight);
            const bool is_hovered = ImGui.IsItemHovered(); -- Hovered
            const bool is_active = ImGui.IsItemActive();   -- Held
            const ImVec2 origin(canvas_p0.x + scrolling.x, canvas_p0.y + scrolling.y); -- Lock scrolled origin
            const ImVec2 mouse_pos_in_canvas(io.MousePos.x - origin.x, io.MousePos.y - origin.y);

            -- Add first and second point
            if (is_hovered and not adding_line and ImGui.IsMouseClicked(ImGuiMouseButton_Left))then
                points.push_back(mouse_pos_in_canvas);
                points.push_back(mouse_pos_in_canvas);
                adding_line = true;
            end
            if (adding_line)then
                points.back() = mouse_pos_in_canvas;
                if (not ImGui.IsMouseDown(ImGuiMouseButton_Left))
                    adding_line = false;
            end

            -- Pan (we use a zero mouse threshold when there's no context menu)
            -- You may decide to make that threshold dynamic based on whether the mouse is hovering something etc.
            const float mouse_threshold_for_pan = opt_enable_context_menu ? -1.0 : 0.0;
            if (is_active and ImGui.IsMouseDragging(ImGuiMouseButton_Right, mouse_threshold_for_pan))then
                scrolling.x += io.MouseDelta.x;
                scrolling.y += io.MouseDelta.y;
            end

            -- Context menu (under default mouse threshold)
            ImVec2 drag_delta = ImGui.GetMouseDragDelta(ImGuiMouseButton_Right);
            if (opt_enable_context_menu and ImGui.IsMouseReleased(ImGuiMouseButton_Right) and drag_delta.x == 0.0 and drag_delta.y == 0.0)
                ImGui.OpenPopupOnItemClick("context");
            if (ImGui.BeginPopup("context"))then
                if (adding_line)
                    points.resize(points.size() - 2);
                adding_line = false;
                if (ImGui.MenuItem("Remove one", NULL, false, points.Size > 0)) do points.resize(points.size() - 2); end
                if (ImGui.MenuItem("Remove all", NULL, false, points.Size > 0)) do points.clear(); end
                ImGui.EndPopup();
            end

            -- Draw grid + all lines in the canvas
            draw_list->PushClipRect(canvas_p0, canvas_p1, true);
            if (opt_enable_grid)then
                const float GRID_STEP = 64.0;
                for (float x = fmodf(scrolling.x, GRID_STEP); x < canvas_sz.x; x += GRID_STEP)
                    draw_list->AddLine(ImVec2(canvas_p0.x + x, canvas_p0.y), ImVec2(canvas_p0.x + x, canvas_p1.y), IM_COL32(200, 200, 200, 40));
                for (float y = fmodf(scrolling.y, GRID_STEP); y < canvas_sz.y; y += GRID_STEP)
                    draw_list->AddLine(ImVec2(canvas_p0.x, canvas_p0.y + y), ImVec2(canvas_p1.x, canvas_p0.y + y), IM_COL32(200, 200, 200, 40));
            end
            for (int n = 0; n < points.Size; n += 2)
                draw_list->AddLine(ImVec2(origin.x + points[n].x, origin.y + points[n].y), ImVec2(origin.x + points[n + 1].x, origin.y + points[n + 1].y), IM_COL32(255, 255, 0, 255), 2.0);
            draw_list->PopClipRect();

            ImGui.EndTabItem();
        end

        if (ImGui.BeginTabItem("BG/FG draw lists"))then
            local draw_bg = true;
            local draw_fg = true;
            ImGui.Checkbox("Draw in Background draw list", draw_bg);
            ImGui.SameLine(); HelpMarker("The Background draw list will be rendered below every Dear ImGui windows.");
            ImGui.Checkbox("Draw in Foreground draw list", draw_fg);
            ImGui.SameLine(); HelpMarker("The Foreground draw list will be rendered over every Dear ImGui windows.");
            ImVec2 window_pos = ImGui.GetWindowPos();
            ImVec2 window_size = ImGui.GetWindowSize();
            ImVec2 window_center = ImVec2(window_pos.x + window_size.x * 0.5f, window_pos.y + window_size.y * 0.5f);
            if (draw_bg)
                ImGui.GetBackgroundDrawList()->AddCircle(window_center, window_size.x * 0.6f, IM_COL32(255, 0, 0, 200), 0, 10 + 4);
            if (draw_fg)
                ImGui.GetForegroundDrawList()->AddCircle(window_center, window_size.y * 0.6f, IM_COL32(0, 255, 0, 200), 0, 10);
            ImGui.EndTabItem();
        end

        ImGui.EndTabBar();
    end

    ImGui.End();
end

-------------------------------------------------------------------------------
-- [SECTION] Example App: Docking, DockSpace / ShowExampleAppDockSpace()
-------------------------------------------------------------------------------

-- Demonstrate using DockSpace() to create an explicit docking node within an existing window.
-- Note: You can use most Docking facilities without calling any API. You DO NOT need to call DockSpace() to use Dockingnot 
-- - Drag from window title bar or their tab to dock/undock. Hold SHIFT to disable docking.
-- - Drag from window menu button (upper-left button) to undock an entire node (all windows).
-- About dockspaces:
-- - Use DockSpace() to create an explicit dock node _within_ an existing window.
-- - Use DockSpaceOverViewport() to create an explicit dock node covering the screen or a specific viewport.
--   This is often used with ImGuiDockNodeFlags_PassthruCentralNode.
-- - Important: Dockspaces need to be submitted _before_ any window they can host. Submit it early in your framenot  (*)
-- - Important: Dockspaces need to be kept alive if hidden, otherwise windows docked into it will be undocked.
--   e.g. if you have multiple tabs with a dockspace inside each tab: submit the non-visible dockspaces with ImGuiDockNodeFlags_KeepAliveOnly.
-- (*) because of this constraint, the implicit \"Debug\" window can not be docked into an explicit DockSpace() node,
-- because that window is submitted as part of the part of the NewFrame() call. An easy workaround is that you can create
-- your own implicit "Debug----2" window after calling DockSpace() and leave it in the window stack for anyone to use.
function ShowExampleAppDockSpace(bool* p_open)
    -- If you strip some features of, this demo is pretty much equivalent to calling DockSpaceOverViewport()not 
    -- In most cases you should be able to just call DockSpaceOverViewport() and ignore all the code belownot 
    -- In this specific demo, we are not using DockSpaceOverViewport() because:
    -- - we allow the host window to be floating/moveable instead of filling the viewport (when opt_fullscreen == false)
    -- - we allow the host window to have padding (when opt_padding == true)
    -- - we have a local menu bar in the host window (vs. you could use BeginMainMenuBar() + DockSpaceOverViewport() in your codenot )
    -- TL;DR; this demo is more complicated than what you would normally use.
    -- If we removed all the options we are showcasing, this demo would become:
    --     void ShowExampleAppDockSpace()
    --     then
    --         ImGui.DockSpaceOverViewport(ImGui.GetMainViewport());
    --     end

    local opt_fullscreen = true;
    local opt_padding = false;
    static ImGuiDockNodeFlags dockspace_flags = ImGuiDockNodeFlags_None;

    -- We are using the ImGuiWindowFlags_NoDocking flag to make the parent window not dockable into,
    -- because it would be confusing to have two docking targets within each others.
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_MenuBar | ImGuiWindowFlags_NoDocking;
    if (opt_fullscreen)then
        const ImGuiViewport* viewport = ImGui.GetMainViewport();
        ImGui.SetNextWindowPos(viewport->WorkPos);
        ImGui.SetNextWindowSize(viewport->WorkSize);
        ImGui.SetNextWindowViewport(viewport->ID);
        ImGui.PushStyleVar(ImGuiStyleVar_WindowRounding, 0.0);
        ImGui.PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0);
        window_flags |= ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove;
        window_flags |= ImGuiWindowFlags_NoBringToFrontOnFocus | ImGuiWindowFlags_NoNavFocus;
    end
    elsethenthenckspace_flags &= ~ImGuiDockNodeFlags_PassthruCentralNode;
    end

    -- When using ImGuiDockNodeFlags_PassthruCentralNode, DockSpace() will render our background
    -- and handle the pass-thru hole, so we ask Begin() to not render a background.
    if (dockspace_flags & ImGuiDockNodeFlags_PassthruCentralNode)
        window_flags |= ImGuiWindowFlags_NoBackground;

    -- Important: note that we proceed even if Begin() returns false (aka window is collapsed).
    -- This is because we want to keep our DockSpace() active. If a DockSpace() is inactive,
    -- all active windows docked into it will lose their parent and become undocked.
    -- We cannot preserve the docking relationship between an active window and an inactive docking, otherwise
    -- any change of dockspace/settings would lead to windows being stuck in limbo and never being visible.
    if (not opt_padding)
        ImGui.PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0.0, 0.0));
    ImGui.Begin("DockSpace Demo", p_open, window_flags);
    if (not opt_padding)
        ImGui.PopStyleVar();

    if (opt_fullscreen)
        ImGui.PopStyleVar(2);

    -- Submit the DockSpace
    ImGuiIO& io = ImGui.GetIO();
    if (io.ConfigFlags & ImGuiConfigFlags_DockingEnable)then
        ImGuiID dockspace_id = ImGui.GetID("MyDockSpace");
        ImGui.DockSpace(dockspace_id, ImVec2(0.0, 0.0), dockspace_flags);
    end
    elsethen
        ShowDockingDisabledMessage();
    end

    if (ImGui.BeginMenuBar())then
        if (ImGui.BeginMenu("Options"))then
            -- Disabling fullscreen would allow the window to be moved to the front of other windows,
            -- which we can't undo at the moment without finer window depth/z control.
            ImGui.MenuItem("Fullscreen", NULL, opt_fullscreen);
            ImGui.MenuItem("Padding", NULL, opt_padding);
            ImGui.Separator();

            if (ImGui.MenuItem("Flag: NoSplit",                "", (dockspace_flags & ImGuiDockNodeFlags_NoSplit) ~= 0))                 then dockspace_flags ^= ImGuiDockNodeFlags_NoSplit; end
            if (ImGui.MenuItem("Flag: NoResize",               "", (dockspace_flags & ImGuiDockNodeFlags_NoResize) ~= 0))                then dockspace_flags ^= ImGuiDockNodeFlags_NoResize; end
            if (ImGui.MenuItem("Flag: NoDockingInCentralNode", "", (dockspace_flags & ImGuiDockNodeFlags_NoDockingInCentralNode) ~= 0))  do dockspace_flags ^= ImGuiDockNodeFlags_NoDockingInCentralNode; end
            if (ImGui.MenuItem("Flag: AutoHideTabBar",         "", (dockspace_flags & ImGuiDockNodeFlags_AutoHideTabBar) ~= 0))          then dockspace_flags ^= ImGuiDockNodeFlags_AutoHideTabBar; end
            if (ImGui.MenuItem("Flag: PassthruCentralNode",    "", (dockspace_flags & ImGuiDockNodeFlags_PassthruCentralNode) ~= 0, opt_fullscreen)) do dockspace_flags ^= ImGuiDockNodeFlags_PassthruCentralNode; end
            ImGui.Separator();

            if (ImGui.MenuItem("Close", NULL, false, p_open ~= NULL))
                *p_open = false;
            ImGui.EndMenu();
        end
        HelpMarker(
            "When docking is enabled, you can ALWAYS dock MOST window into anothernot  Try it nownot " "\n"
            "- Drag from window title bar or their tab to dock/undock." "\n"
            "- Drag from window menu button (upper-left button) to undock an entire node (all windows)." "\n"
            "- Hold SHIFT to disable docking." "\n"
            "This demo app has nothing to do with itnot " "\n\n"
            "This demo app only demonstrate the use of ImGui.DockSpace() which allows you to manually create a docking node _within_ another window." "\n\n"
            "Read comments in ShowExampleAppDockSpace() for more details.");

        ImGui.EndMenuBar();
    end

    ImGui.End();
end

-------------------------------------------------------------------------------
-- [SECTION] Example App: Documents Handling / ShowExampleAppDocuments()
-------------------------------------------------------------------------------

-- Simplified structure to mimic a Document model
struct MyDocument
    const char* Name;       -- Document title
    bool        Open;       -- Set when open (we keep an array of all available documents to simplify demo codenot )
    bool        OpenPrev;   -- Copy of Open from last update.
    bool        Dirty;      -- Set when the document has been modified
    bool        WantClose;  -- Set when the document
    ImVec4      Color;      -- An arbitrary variable associated to the document

    MyDocument(const char* name, bool open = true, const ImVec4& color = ImVec4(1.0, 1.0, 1.0, 1.0))then
        Name = name;
        Open = OpenPrev = open;
        Dirty = false;
        WantClose = false;
        Color = color;
    end
    void DoOpen()       then Open = true; end
    void DoQueueClose() do WantClose = true; end
    void DoForceClose() do Open = false; Dirty = false; end
    void DoSave()       then Dirty = false; end

    -- Display placeholder contents for the Document
    function DisplayContents(MyDocument* doc)then
        ImGui.PushID(doc);
        ImGui.Text("Document \"%s\"", doc->Name);
        ImGui.PushStyleColor(ImGuiCol_Text, doc->Color);
        ImGui.TextWrapped("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.");
        ImGui.PopStyleColor();
        if (ImGui.Button("Modify", ImVec2(100, 0)))thenc->Dirty = true;
        ImGui.SameLine();
        if (ImGui.Button("Save", ImVec2(100, 0)))thenc->DoSave();
        ImGui.ColorEdit3("color", doc->Color.x);  -- Useful to test drag and drop and hold-dragged-to-open-tab behavior.
        ImGui.PopID();
    end

    -- Display context menu for the Document
    function DisplayContextMenu(MyDocument* doc)then
        if (not ImGui.BeginPopupContextItem())
            return;

        char buf[256];
        sprintf(buf, "Save %s", doc->Name);
        if (ImGui.MenuItem(buf, "CTRL+S", false, doc->Open))thenc->DoSave();
        if (ImGui.MenuItem("Close", "CTRL+W", false, doc->Open))thenc->DoQueueClose();
        ImGui.EndPopup();
    end
end;

struct ExampleAppDocuments
    ImVector<MyDocument> Documents;

    ExampleAppDocuments()thenthencuments.push_back(MyDocument("Lettuce",             true,  ImVec4(0.4f, 0.8f, 0.4f, 1.0)));thencuments.push_back(MyDocument("Eggplant",            true,  ImVec4(0.8f, 0.5f, 1.0, 1.0)));thencuments.push_back(MyDocument("Carrot",              true,  ImVec4(1.0, 0.8f, 0.5f, 1.0)));thencuments.push_back(MyDocument("Tomato",              false, ImVec4(1.0, 0.3f, 0.4f, 1.0)));thencuments.push_back(MyDocument("A Rather Long Title", false));thencuments.push_back(MyDocument("Some Document",       false));
    end
end;

-- [Optional] Notify the system of Tabs/Windows closure that happened outside the regular tab interface.
-- If a tab has been closed programmatically (aka closed from another source such as the Checkbox() in the demo,
-- as opposed to clicking on the regular tab closing button) and stops being submitted, it will take a frame for
-- the tab bar to notice its absence. During this frame there will be a gap in the tab bar, and if the tab that has
-- disappeared was the selected one, the tab bar will report no selected tab during the frame. This will effectively
-- give the impression of a flicker for one frame.
-- We call SetTabItemClosed() to manually notify the Tab Bar or Docking system of removed tabs to avoid this glitch.
-- Note that this completely optional, and only affect tab bars with the ImGuiTabBarFlags_Reorderable flag.
function NotifyOfDocumentsClosedElsewhere(ExampleAppDocuments& app)
    for (int doc_n = 0; doc_n < app.Documents.Size; doc_n++)then
        MyDocument* doc = &app.Documents[doc_n];
        if (not doc->Open and doc->OpenPrev)
            ImGui.SetTabItemClosed(doc->Name);thenc->OpenPrev = doc->Open;
    end
end

function ShowExampleAppDocuments(bool* p_open)
    static ExampleAppDocuments app;

    -- Options
    enum Targetthen
        Target_None,
        Target_Tab,                 -- Create documents as local tab into a local tab bar
        Target_DockSpaceAndWindow   -- Create documents as regular windows, and create an embedded dockspace
    end;
    static Target opt_target = Target_Tab;
    local opt_reorderable = true;
    static ImGuiTabBarFlags opt_fitting_flags = ImGuiTabBarFlags_FittingPolicyDefault_;

    -- When (opt_target == Target_DockSpaceAndWindow) there is the possibily that one of our child Document window (e.g. "Eggplant")
    -- that we emit gets docked into the same spot as the parent window ("Example: Documents").
    -- This would create a problematic feedback loop because selecting the "Eggplant" tab would make the "Example: Documents" tab
    -- not visible, which in turn would stop submitting the "Eggplant" window.
    -- We avoid this problem by submitting our documents window even if our parent window is not currently visible.
    -- Another solution may be to make the "Example: Documents" window use the ImGuiWindowFlags_NoDocking.

    bool window_contents_visible = ImGui.Begin("Example: Documents", p_open, ImGuiWindowFlags_MenuBar);
    if (not window_contents_visible and opt_target ~= Target_DockSpaceAndWindow)then
        ImGui.End();
        return;
    end

    -- Menu
    if (ImGui.BeginMenuBar())then
        if (ImGui.BeginMenu("File"))then
            int open_count = 0;
            for (int doc_n = 0; doc_n < app.Documents.Size; doc_n++)
                open_count += app.Documents[doc_n].Open ? 1 : 0;

            if (ImGui.BeginMenu("Open", open_count < app.Documents.Size))then
                for (int doc_n = 0; doc_n < app.Documents.Size; doc_n++)then
                    MyDocument* doc = &app.Documents[doc_n];
                    if (not doc->Open)
                        if (ImGui.MenuItem(doc->Name))thenc->DoOpen();
                end
                ImGui.EndMenu();
            end
            if (ImGui.MenuItem("Close All Documents", NULL, false, open_count > 0))
                for (int doc_n = 0; doc_n < app.Documents.Size; doc_n++)
                    app.Documents[doc_n].DoQueueClose();
            if (ImGui.MenuItem("Exit", "Alt+F4")) do end
            ImGui.EndMenu();
        end
        ImGui.EndMenuBar();
    end

    -- [Debug] List documents with one checkbox for each
    for (int doc_n = 0; doc_n < app.Documents.Size; doc_n++)then
        MyDocument* doc = &app.Documents[doc_n];
        if (doc_n > 0)
            ImGui.SameLine();
        ImGui.PushID(doc);
        if (ImGui.Checkbox(doc->Name, doc->Open))
            if (not doc->Open)thenc->DoForceClose();
        ImGui.PopID();
    end
    ImGui.PushItemWidth(ImGui.GetFontSize() * 12);
    ImGui.Combo("Output", (int*)&opt_target, "None\0TabBar+Tabs\0DockSpace+Window\0");
    ImGui.PopItemWidth();
    bool redock_all = false;
    if (opt_target == Target_Tab)                then ImGui.SameLine(); ImGui.Checkbox("Reorderable Tabs", opt_reorderable); end
    if (opt_target == Target_DockSpaceAndWindow) do ImGui.SameLine(); redock_all = ImGui.Button("Redock all"); end

    ImGui.Separator();

    -- About the ImGuiWindowFlags_UnsavedDocument / ImGuiTabItemFlags_UnsavedDocument flags.
    -- They have multiple effects:
    -- - Display a dot next to the title.
    -- - Tab is selected when clicking the X close button.
    -- - Closure is not assumed (will wait for user to stop submitting the tab).
    --   Otherwise closure is assumed when pressing the X, so if you keep submitting the tab may reappear at end of tab bar.
    --   We need to assume closure by default otherwise waiting for "lack of submission" on the next frame would leave an empty
    --   hole for one-frame, both in the tab-bar and in tab-contents when closing a tab/window.
    --   The rarely used SetTabItemClosed() function is a way to notify of programmatic closure to avoid the one-frame hole.

    -- Tabs
    if (opt_target == Target_Tab)then
        ImGuiTabBarFlags tab_bar_flags = (opt_fitting_flags) | (opt_reorderable ? ImGuiTabBarFlags_Reorderable : 0);
        if (ImGui.BeginTabBar("----tabs", tab_bar_flags))then
            if (opt_reorderable)
                NotifyOfDocumentsClosedElsewhere(app);

            -- [DEBUG] Stress tests
            --if ((ImGui.GetFrameCount() % 30) == 0) docs[1].Open ^= 1;            -- [DEBUG] Automatically show/hide a tab. Test various interactions e.g. dragging with this on.
            --if (ImGui.GetIO().KeyCtrl) ImGui.SetTabItemSelected(docs[1].Name);  -- [DEBUG] Test SetTabItemSelected(), probably not very useful as-is anyway..

            -- Submit Tabs
            for (int doc_n = 0; doc_n < app.Documents.Size; doc_n++)then
                MyDocument* doc = &app.Documents[doc_n];
                if (not doc->Open)
                    continue;

                ImGuiTabItemFlags tab_flags = (doc->Dirty ? ImGuiTabItemFlags_UnsavedDocument : 0);
                bool visible = ImGui.BeginTabItem(doc->Name, doc->Open, tab_flags);

                -- Cancel attempt to close when unsaved add to save queue so we can display a popup.
                if (not doc->Open and doc->Dirty)thenthenc->Open = true;thenc->DoQueueClose();
                end

                MyDocument.DisplayContextMenu(doc);
                if (visible)then
                    MyDocument.DisplayContents(doc);
                    ImGui.EndTabItem();
                end
            end

            ImGui.EndTabBar();
        end
    end
    else if (opt_target == Target_DockSpaceAndWindow)then
        if (ImGui.GetIO().ConfigFlags & ImGuiConfigFlags_DockingEnable)then
            NotifyOfDocumentsClosedElsewhere(app);

            -- Create a DockSpace node where any window can be docked
            ImGuiID dockspace_id = ImGui.GetID("MyDockSpace");
            ImGui.DockSpace(dockspace_id);

            -- Create Windows
            for (int doc_n = 0; doc_n < app.Documents.Size; doc_n++)then
                MyDocument* doc = &app.Documents[doc_n];
                if (not doc->Open)
                    continue;

                ImGui.SetNextWindowDockID(dockspace_id, redock_all ? ImGuiCond_Always : ImGuiCond_FirstUseEver);
                ImGuiWindowFlags window_flags = (doc->Dirty ? ImGuiWindowFlags_UnsavedDocument : 0);
                bool visible = ImGui.Begin(doc->Name, doc->Open, window_flags);

                -- Cancel attempt to close when unsaved add to save queue so we can display a popup.
                if (not doc->Open and doc->Dirty)thenthenc->Open = true;thenc->DoQueueClose();
                end

                MyDocument.DisplayContextMenu(doc);
                if (visible)
                    MyDocument.DisplayContents(doc);

                ImGui.End();
            end
        end
        elsethen
            ShowDockingDisabledMessage();
        end
    end

    -- Early out other contents
    if (not window_contents_visible)then
        ImGui.End();
        return;
    end

    -- Update closing queue
    static ImVector<MyDocument*> close_queue;
    if (close_queue.empty())then
        -- Close queue is locked once we started a popup
        for (int doc_n = 0; doc_n < app.Documents.Size; doc_n++)then
            MyDocument* doc = &app.Documents[doc_n];
            if (doc->WantClose)thenthenc->WantClose = false;
                close_queue.push_back(doc);
            end
        end
    end

    -- Display closing confirmation UI
    if (not close_queue.empty())then
        int close_queue_unsaved_documents = 0;
        for (int n = 0; n < close_queue.Size; n++)
            if (close_queue[n]->Dirty)
                close_queue_unsaved_documents++;

        if (close_queue_unsaved_documents == 0)then
            -- Close documents when all are unsaved
            for (int n = 0; n < close_queue.Size; n++)
                close_queue[n]->DoForceClose();
            close_queue.clear();
        end
        elsethen
            if (not ImGui.IsPopupOpen("Save?"))
                ImGui.OpenPopup("Save?");
            if (ImGui.BeginPopupModal("Save?", NULL, ImGuiWindowFlags_AlwaysAutoResize))then
                ImGui.Text("Save change to the following items?");
                float item_height = ImGui.GetTextLineHeightWithSpacing();
                if (ImGui.BeginChildFrame(ImGui.GetID("frame"), ImVec2(-FLT_MIN, 6.25f * item_height)))then
                    for (int n = 0; n < close_queue.Size; n++)
                        if (close_queue[n]->Dirty)
                            ImGui.Text("%s", close_queue[n]->Name);
                    ImGui.EndChildFrame();
                end

                ImVec2 button_size(ImGui.GetFontSize() * 7.0, 0.0);
                if (ImGui.Button("Yes", button_size))then
                    for (int n = 0; n < close_queue.Size; n++)then
                        if (close_queue[n]->Dirty)
                            close_queue[n]->DoSave();
                        close_queue[n]->DoForceClose();
                    end
                    close_queue.clear();
                    ImGui.CloseCurrentPopup();
                end
                ImGui.SameLine();
                if (ImGui.Button("No", button_size))then
                    for (int n = 0; n < close_queue.Size; n++)
                        close_queue[n]->DoForceClose();
                    close_queue.clear();
                    ImGui.CloseCurrentPopup();
                end
                ImGui.SameLine();
                if (ImGui.Button("Cancel", button_size))then
                    close_queue.clear();
                    ImGui.CloseCurrentPopup();
                end
                ImGui.EndPopup();
            end
        end
    end

    ImGui.End();
end
