-- ShowDemoWindowWidgets
-- created on 2021/9/4
-- author @zoloypzuo
require("ui.demo.demo_util")

local clicked = 0
local check = true
local e = 0
local counter = 0
local item_current = 0;
local str0 = "Hello, worldnot ";
local str1 = ""
local i0 = 123
local f0 = 0.001
local d0 = 999999.00000001
local f1 = 1e0
local vec4a = { 0.10, 0.20, 0.30, 0.44 }
local i1, i2 = 50, 42;
local f1, f2 = 1.0, 0.0067;
local i1 = 0;
local f1, f2 = 0.123, 0.0;
local angle = 0.0;
local col1 = { 1.0, 0.0, 0.2 };
local col2 = { 0.4, 0.7, 0.0, 0.5 };
local list_item_current = 1;

local function Basic()
    if not (ImGui.TreeNode("Basic")) then
        return
    end

    if (ImGui.Button("Button")) then
        clicked = clicked + 1
    end
    if bit.band(clicked, 1) ~= 0 then
        ImGui.SameLine()
        ImGui.Text("Thanks for clicking menot ")
    end

    check = ImGui.Checkbox("checkbox", check)

    e = ImGui.RadioButton("radio a", e, 0)
    ImGui.SameLine()
    e = ImGui.RadioButton("radio b", e, 1)
    ImGui.SameLine()
    e = ImGui.RadioButton("radio c", e, 2)

    -- Color buttons, demonstrate using PushID() to add unique identifier in the ID stack, and changing style.
    for i = 0, 6 do
        if (i > 0) then
            ImGui.SameLine()
        end
        ImGui.PushID(i)
        ImGui.PushStyleColor(ImGuiCol.Button, i / 7.0, 0.6, 0.6, 1);
        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, i / 7.0, 0.7, 0.7, 1);
        ImGui.PushStyleColor(ImGuiCol.ButtonActive, i / 7.0, 0.8, 0.8, 1);
        ImGui.Button("Click")
        ImGui.PopStyleColor(3)
        ImGui.PopID()
    end

    -- BREAK POINT HERE
    -- Use AlignTextToFramePadding() to align text baseline to the baseline of framed widgets elements
    -- (otherwise a Text+SameLine+Button sequence will have the text a little too high by defaultnot )
    -- See 'Demo->Layout->Text Baseline Alignment' for details.
    ImGui.AlignTextToFramePadding()
    ImGui.Text("Hold to repeat:")
    ImGui.SameLine()

    -- Arrow buttons with Repeater
    ImGui.PushButtonRepeat(true)
    if (ImGui.ArrowButton("----left", ImGuiDir.Left)) then
        counter = counter - 1
    end
    ImGui.SameLine()
    if (ImGui.ArrowButton("----right", ImGuiDir.Right)) then
        counter = counter + 1
    end
    ImGui.PopButtonRepeat()
    ImGui.SameLine()
    ImGui.Text(string.format("%s", counter))

    ImGui.Text("Hover over me")
    if (ImGui.IsItemHovered()) then
        ImGui.SetTooltip("I am a tooltip")
    end
    ImGui.SameLine()
    ImGui.Text("- or me")
    if (ImGui.IsItemHovered()) then
        ImGui.BeginTooltip()
        ImGui.Text("I am a fancy tooltip")
        -- static float arr[] = do 0.6f, 0.1f, 1.0, 0.5f, 0.92f, 0.1f, 0.2f end;
        -- ImGui.PlotLines("Curve", arr, IM_ARRAYSIZE(arr));
        ImGui.EndTooltip()
    end

    ImGui.Separator()

    ImGui.LabelText("label", "Value")
    -- Using the _simplified_ one-liner Combo() api here
    -- See "Combo" section for examples of how to use the more flexible BeginCombo()/EndCombo() api.
    items = { "AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "GGGG", "HHHH", "IIIIIII", "JJJJ", "KKKKKKK" };
    item_current = ImGui.Combo("combo", item_current, items, #items);
    ImGui.SameLine()
    ImGui.HelpMarker("Using the simplified one-liner Combo API here.\n" ..
            'Refer to the "Combo" section below for an explanation of how to use the more flexible and general BeginCombo/EndCombo API.'
    )

    -- To wire InputText() with std.string or any other custom string type,
    -- see the "Text Input > Resize Callback" section of this demo, and the misc/cpp/imgui_stdlib.h file.
    str0 = ImGui.InputText("input text", str0, 256);
    ImGui.SameLine();
    ImGui.HelpMarker("USER:\n" ..
            "Hold SHIFT or use mouse to select text.\n" ..
            "CTRL+Left/Right to word jump.\n" ..
            "CTRL+A or double-click to select all.\n" ..
            "CTRL+X,CTRL+C,CTRL+V clipboard.\n" ..
            "CTRL+Z,CTRL+Y undo/redo.\n" ..
            "ESCAPE to revert.\n\n" ..
            "PROGRAMMER:\n" ..
            "You can use the ImGuiInputTextFlags_CallbackResize facility if you need to wire InputText() " ..
            "to a dynamic string type. See misc/cpp/imgui_stdlib.h for an example (this is not demonstrated " ..
            "in imgui_demo.cpp).");

    str1 = ImGui.InputTextWithHint("input text (w/ hint)", "enter text here", str1, 256);

    i0 = ImGui.InputInt("input int", i0);
    ImGui.SameLine();
    ImGui.HelpMarker("You can apply arithmetic operators +,*,/ on numerical values.\n" ..
            "  e.g. [ 100 ], input \'*2\', result becomes [ 200 ]\n" ..
            "Use +- to subtract.");

    f0 = ImGui.InputFloat("input float", f0, 0.01, 1.0, "%.3f");

    d0 = ImGui.InputDouble("input double", d0, 0.01, 1.0, "%.8f");

    f1 = ImGui.InputFloat("input scientific", f1, 0.0, 0.0, "%e");
    ImGui.SameLine();
    ImGui.HelpMarker(
            "You can input value using the scientific notation,\n" ..
                    "  e.g. \"1e+8\" becomes \"100000000\".");

    vec4a = ImGui.InputFloat3("input float3", vec4a);

    i1 = ImGui.DragInt("drag int", i1, 1);
    ImGui.SameLine();
    ImGui.HelpMarker(
            "Click and drag to edit value.\n" ..
                    "Hold SHIFT/ALT for faster/slower edit.\n" ..
                    "Double-click or CTRL+click to input value.");

    i2 = ImGui.DragInt("drag int 0..100", i2, 1, 0, 100, "%d%%") -- TODO , ImGuiSliderFlags.AlwaysClamp);

    f1 = ImGui.DragFloat("drag float", f1, 0.005);
    f2 = ImGui.DragFloat("drag small float", f2, 0.0001, 0.0, 0.0, "%.06f ns");

    i1 = ImGui.SliderInt("slider int", i1, -1, 3);
    ImGui.SameLine();
    ImGui.HelpMarker("CTRL+click to input value.");

    f1 = ImGui.SliderFloat("slider float", f1, 0.0, 1.0, "ratio = %.3f");
    f2 = ImGui.SliderFloat("slider float (log)", f2, -10.0, 10.0, "%.4f") -- TODO , ImGuiSliderFlags.Logarithmic);

    angle = ImGui.SliderAngle("slider angle", angle);

    -- Using the format string to display a name instead of an integer.
    -- Here we completely omit '%d' from the format string, so it'll only display a name.
    -- This technique can also be used with DragInt().
    --enum Element do Element_Fire, Element_Earth, Element_Air, Element_Water, Element_COUNT end;
    --local elem = Element_Fire;
    --const char* elems_names[Element_COUNT] = do "Fire", "Earth", "Air", "Water" end;
    --const char* elem_name = (elem >= 0 and elem < Element_COUNT) ? elems_names[elem] : "Unknown";
    --ImGui.SliderInt("slider enum", elem, 0, Element_COUNT - 1, elem_name);
    --ImGui.SameLine(); ImGui.HelpMarker("Using the format string parameter to display a name instead of the underlying integer.");


    ImGui.ColorEdit3("color 1", col1);
    ImGui.SameLine();
    ImGui.HelpMarker(
            "Click on the color square to open a color picker.\n" ..
                    "Click and hold to use drag and drop.\n" ..
                    "Right-click on the color square to show options.\n" ..
                    "CTRL+click on individual component to input value.");

    ImGui.ColorEdit4("color 2", col2);

    -- Using the _simplified_ one-liner ListBox() api here
    -- See "List boxes" section for examples of how to use the more flexible BeginListBox()/EndListBox() api.
    local items = { "Apple", "Banana", "Cherry", "Kiwi", "Mango", "Orange", "Pineapple", "Strawberry", "Watermelon" };
    list_item_current = ImGui.ListBox("listbox", list_item_current, items, #items, 4);
    ImGui.SameLine();
    ImGui.HelpMarker(
            "Using the simplified one-liner ListBox API here.\n" ..
                    "Refer to the \"List boxes\" section below for an explanation of how to use the more flexible and general BeginListBox/EndListBox API.");

    ImGui.TreePop()
end

local base_flags = bit.bor(
        ImGuiTreeNodeFlags.OpenOnArrow,
        ImGuiTreeNodeFlags.OpenOnDoubleClick,
        ImGuiTreeNodeFlags.SpanAvailWidth)
local align_label_with_current_x_position = false;
local test_drag_and_drop = false;
local selection_mask = bit.lshift(1, 2);

local function Trees()
    if not ImGui.TreeNode("Trees") then
        return
    end
    if (ImGui.TreeNode("Basic trees")) then
        for i = 0, 4 do
            -- Use SetNextItemOpen() so set the default state of a node to be open. We could
            -- also use TreeNodeEx() with the ImGuiTreeNodeFlags_DefaultOpen flag to achieve the same thingnot
            if (i == 0) then
                ImGui.SetNextItemOpen(true, ImGuiCond.Once);
            end

            if (ImGui.TreeNode("##" .. i, string.format("Child %d", i))) then
                ImGui.Text("blah blah");
                ImGui.SameLine();
                if (ImGui.SmallButton("button")) then
                end
                ImGui.TreePop();
            end
        end
        ImGui.TreePop();
    end

    if (ImGui.TreeNode("Advanced, with Selectable nodes")) then
        ImGui.HelpMarker("This is a more typical looking tree with selectable nodes.\n" ..
                "Click to select, CTRL+Click to toggle, click on arrows or double-click to open.");

        -- TODO CheckboxFlags
        --        ImGui.CheckboxFlags("ImGuiTreeNodeFlags_OpenOnArrow",       &base_flags, ImGuiTreeNodeFlags_OpenOnArrow);
        --        ImGui.CheckboxFlags("ImGuiTreeNodeFlags_OpenOnDoubleClick", base_flags, ImGuiTreeNodeFlags_OpenOnDoubleClick);
        --        ImGui.CheckboxFlags("ImGuiTreeNodeFlags_SpanAvailWidth",    &base_flags, ImGuiTreeNodeFlags_SpanAvailWidth); ImGui.SameLine(); HelpMarker("Extend hit area to all available width instead of allowing more items to be laid out after the node.");
        --        ImGui.CheckboxFlags("ImGuiTreeNodeFlags_SpanFullWidth",     &base_flags, ImGuiTreeNodeFlags_SpanFullWidth);
        align_label_with_current_x_position = ImGui.Checkbox("Align label with current X position", align_label_with_current_x_position);
        test_drag_and_drop = ImGui.Checkbox("Test tree node as drag source", test_drag_and_drop);
        ImGui.Text("Hellonot ");
        if (align_label_with_current_x_position) then
            ImGui.Unindent(ImGui.GetTreeNodeToLabelSpacing());
        end
        -- 'selection_mask' is dumb representation of what may be user-side selection state.
        --  You may retain selection state inside or outside your objects in whatever format you see fit.
        -- 'node_clicked' is temporary storage of what node we have clicked to process selection at the end
        --/ of the loop. May be a pointer to your own node type, etc.
        local node_clicked = -1;
        for i = 0, 5 do
            -- Disable the default "open on single-click behavior" + set Selected flag according to our selection.
            local node_flags = base_flags
            local is_selected = (bit.band(selection_mask, bit.lshift(1, i)) ~= 0)
            if is_selected then
                node_flags = bit.bor(node_flags, ImGuiTreeNodeFlags.Selected)
            end
            if (i < 3) then
                -- Items 0..2 are Tree Node
                local node_open = ImGui.TreeNodeEx("##" .. i, node_flags, string.format("Selectable Node %d", i))
                if (ImGui.IsItemClicked()) then
                    node_clicked = i;
                end
                -- TODO BeginDragDropSource
                --if (test_drag_and_drop and ImGui.BeginDragDropSource()) then
                --    ImGui.SetDragDropPayload("_TREENODE", NULL, 0);
                --    ImGui.Text("This is a drag and drop source");
                --    ImGui.EndDragDropSource();
                --end
                if (node_open) then
                    ImGui.BulletText("Blah blah\nBlah Blah");
                    ImGui.TreePop();
                end
            else
                -- Items 3..5 are Tree Leaves
                -- The only reason we use TreeNode at all is to allow selection of the leaf. Otherwise we can
                -- use BulletText() or advance the cursor by GetTreeNodeToLabelSpacing() and call Text().
                node_flags = bit.bor(node_flags, ImGuiTreeNodeFlags.Leaf, ImGuiTreeNodeFlags.NoTreePushOnOpen)
                ImGui.TreeNodeEx("##" .. i, node_flags, string.format("Selectable Node %d", i))
                if (ImGui.IsItemClicked()) then
                    node_clicked = i;
                end
                if (test_drag_and_drop and ImGui.BeginDragDropSource()) then
                    ImGui.SetDragDropPayload("_TREENODE", NULL, 0);
                    ImGui.Text("This is a drag and drop source");
                    ImGui.EndDragDropSource();
                end
            end
        end

        if (node_clicked ~= -1) then
            -- Update selection state
            -- (process outside of tree loop to avoid visual inconsistencies during the clicking frame)
            -- TODO GetIO
            --if (ImGui.GetIO().KeyCtrl) then
            if false then
                selection_mask = bit.bxor(1, node_clicked) -- CTRL+click to toggle
            else
                --if (not (selection_mask & (1 << node_clicked))) -- Depending on selection behavior you want, may want to preserve selection when clicking on item that is part of the selection
                selection_mask = bit.lshift(1, node_clicked); -- Click to single-select
            end
        end
        if (align_label_with_current_x_position) then
            ImGui.Indent(ImGui.GetTreeNodeToLabelSpacing());
        end
        ImGui.TreePop();
    end

    ImGui.TreePop();
end

local closable_group = true;

local function CollapsingHeaders()
    if (ImGui.TreeNode("Collapsing Headers")) then
        closable_group = ImGui.Checkbox("Show 2nd header", closable_group);
        if (ImGui.CollapsingHeader("Header", ImGuiTreeNodeFlags.None)) then
            ImGui.Text(string.format("IsItemHovered: %s", tostring(ImGui.IsItemHovered())));
            for i = 1, 5 do
                ImGui.Text(string.format("Some content " .. i));
            end
        end
        if (ImGui.CollapsingHeader("Header with a close button", closable_group)) then
            ImGui.Text(string.format("IsItemHovered: %s", tostring(ImGui.IsItemHovered())));
            for i = 1, 5 do
                ImGui.Text("More content " .. i);
            end
        end
        --if (ImGui.CollapsingHeader("Header with a bullet", ImGuiTreeNodeFlags.Bullet)) then
        --    ImGui.Text(string.format("IsItemHovered: %s", tostring(ImGui.IsItemHovered())));
        --end
        ImGui.TreePop();
    end
end

local function Bullets()
    if (ImGui.TreeNode("Bullets")) then
        ImGui.BulletText("Bullet point 1");
        ImGui.BulletText("Bullet point 2\nOn multiple lines");
        if (ImGui.TreeNode("Tree node")) then
            ImGui.BulletText("Another bullet point");
            ImGui.TreePop();
        end
        ImGui.Bullet();
        ImGui.Text("Bullet point 3 (two calls)");
        ImGui.Bullet();
        ImGui.SmallButton("Button");
        ImGui.TreePop();
    end

end

local wrap_width = 200.0;

local function Text()

    if (ImGui.TreeNode("Text")) then
        if (ImGui.TreeNode("Colorful Text")) then
            -- Using shortcut. You can use PushStyleColor()/PopStyleColor() for more flexibility.
            ImGui.TextColored(1.0, 0.0, 1.0, 1.0, "Pink");
            ImGui.TextColored(1.0, 1.0, 0.0, 1.0, "Yellow");
            ImGui.TextDisabled("Disabled");
            ImGui.SameLine();
            ImGui.HelpMarker("The TextDisabled color is stored in ImGuiStyle.");
            ImGui.TreePop();
        end

        if (ImGui.TreeNode("Word Wrapping")) then
            -- Using shortcut. You can use PushTextWrapPos()/PopTextWrapPos() for more flexibility.
            ImGui.TextWrapped(
                    "This text should automatically wrap on the edge of the window. The current implementation " ..
                            "for text wrapping follows simple rules suitable for English and possibly other languages.");
            ImGui.Spacing();

            wrap_width = ImGui.SliderFloat("Wrap width", wrap_width, -20, 600, "%.0");

            -- TODO ImDrawList
            --ImDrawList* draw_list = ImGui.GetWindowDrawList();
            for n = 0, 1 do
                ImGui.Text("Test paragraph %d:", n);
                --ImVec2 pos = ImGui.GetCursorScreenPos();
                --ImVec2 marker_min = ImVec2(pos.x + wrap_width, pos.y);
                --ImVec2 marker_max = ImVec2(pos.x + wrap_width + 10, pos.y + ImGui.GetTextLineHeight());
                local x, y = ImGui.GetCursorPos()
                ImGui.PushTextWrapPos(x + wrap_width);
                if (n == 0) then
                    ImGui.Text("The lazy dog is a good dog. This paragraph should fit within %.0 pixels. Testing a 1 character word. The quick brown fox jumps over the lazy dog.", wrap_width);
                else
                    ImGui.Text("aaaaaaaa bbbbbbbb, c cccccccc,dddddddd. d eeeeeeee   ffffffff. ggggggggnot hhhhhhhh");
                end
                -- Draw actual text bounding box, following by marker of our expected limit (should not overlapnot )
                --draw_list->AddRect(ImGui.GetItemRectMin(), ImGui.GetItemRectMax(), IM_COL32(255, 255, 0, 255));
                --draw_list->AddRectFilled(marker_min, marker_max, IM_COL32(255, 0, 255, 255));
                ImGui.PopTextWrapPos();
            end

            ImGui.TreePop();
        end

        if (ImGui.TreeNode("UTF-8 Text")) then
            -- UTF-8 test with Japanese characters
            -- (Needs a suitable font? Try "Google Noto" or "Arial Unicode". See docs/FONTS.md for details.)
            -- - From C++11 you can use the u8"my text" syntax to encode literal strings as UTF-8
            -- - For earlier compiler, you may be able to encode your sources as UTF-8 (e.g. in Visual Studio, you
            --   can save your source files as 'UTF-8 without signature').
            -- - FOR THIS DEMO FILE ONLY, BECAUSE WE WANT TO SUPPORT OLD COMPILERS, WE ARE *NOT* INCLUDING RAW UTF-8
            --   CHARACTERS IN THIS SOURCE FILE. Instead we are encoding a few strings with hexadecimal constants.
            --   Don't do this in your applicationnot  Please use u8"text in any language" in your applicationnot
            -- Note that characters values are preserved even by InputText() if the font cannot be displayed,
            -- so you can safely copy & paste garbled characters into another application.
            ImGui.TextWrapped("CJK text will only appears if the font was loaded with the appropriate CJK character ranges. " ..
                    "Call io.Fonts->AddFontFromFileTTF() manually to load extra character ranges. " ..
                    "Read docs/FONTS.md for details.");
            ImGui.Text("Hiragana: \xe3\x81\x8b\xe3\x81\x8d\xe3\x81\x8f\xe3\x81\x91\xe3\x81\x93 (kakikukeko)"); -- Normally we would use u8"blah blah" with the proper characters directly in the string.
            ImGui.Text("Kanjis: \xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e (nihongo)");
            -- TODO input
            --static char buf[32] = "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e";
            --static char buf[32] = u8"NIHONGO"; -- <- this is how you would write it with C++11, using real kanjis
            --ImGui.InputText("UTF-8 input", buf, IM_ARRAYSIZE(buf));
            ImGui.TreePop();
        end
        ImGui.TreePop();
    end
end

local function Images()

end

local function Combo()

end

local function ListBoxes()

end

local function Selectables()

end

local function TextInput()

end

local function Tabs()

end

function ImGui.ShowDemoWindowWidgets()
    if (not ImGui.CollapsingHeader("Widgets")) then
        return
    end

    -- TODO BeginDisabled
    -- local disable_all = false -- The Checkbox for that is inside the "Disabled" section at the bottom
    -- if (disable_all) then
    --     ImGui.BeginDisabled()
    -- end

    Basic()
    Trees()
    CollapsingHeaders()
    Bullets()
    Text()


    -- EndDisabled
    -- Demonstrate BeginDisabled/EndDisabled using a checkbox located at the bottom of the section (which is a bit odd:
    -- logically we'd have this checkbox at the top of the section, but we don't want this feature to steal that space)
    -- if (disable_all)
    --     ImGui.EndDisabled();

    -- if (ImGui.TreeNode("Disable block"))then
    --     ImGui.Checkbox("Disable entire section above", disable_all);
    --     ImGui.SameLine(); HelpMarker("Demonstrate using BeginDisabled()/EndDisabled() across this section.");
    --     ImGui.TreePop();
    -- end
end
