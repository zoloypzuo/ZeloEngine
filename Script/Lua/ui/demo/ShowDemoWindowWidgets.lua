-- ShowDemoWindowWidgets
-- created on 2021/9/4
-- author @zoloypzuo
require("ui.demo.demo_util")

function ImGui.ShowDemoWindowWidgets()
    if (not ImGui.CollapsingHeader("Widgets")) then
        return
    end

    local disable_all = false; -- The Checkbox for that is inside the "Disabled" section at the bottom
    if (disable_all) then
        ImGui.BeginDisabled();
    end

    if (ImGui.TreeNode("Basic"))then
        local clicked = 0;
        if (ImGui.Button("Button")) then
            clicked = clicked + 1
        end
        -- if (clicked & 1)then
        -- ImGui.SameLine();
        -- ImGui.Text("Thanks for clicking menot ");
        -- end

        local check = true;
        ImGui.Checkbox("checkbox", check);

        local e = 0;
        ImGui.RadioButton("radio a", e, 0); ImGui.SameLine();
        ImGui.RadioButton("radio b", e, 1); ImGui.SameLine();
        ImGui.RadioButton("radio c", e, 2);

        -- Color buttons, demonstrate using PushID() to add unique identifier in the ID stack, and changing style.
        for i = 0, 6 do
            if (i > 0) then
                ImGui.SameLine();
            end
            ImGui.PushID(i);
            -- TODO
            -- ImGui.PushStyleColor(ImGuiCol_Button, (ImVec4)ImColor.HSV(i / 7.0, 0.6f, 0.6f));
            -- ImGui.PushStyleColor(ImGuiCol_ButtonHovered, (ImVec4)ImColor.HSV(i / 7.0, 0.7f, 0.7f));
            -- ImGui.PushStyleColor(ImGuiCol_ButtonActive, (ImVec4)ImColor.HSV(i / 7.0, 0.8f, 0.8f));
            ImGui.Button("Click");
            ImGui.PopStyleColor(3);
            ImGui.PopID();
        end

        -- Use AlignTextToFramePadding() to align text baseline to the baseline of framed widgets elements
        -- (otherwise a Text+SameLine+Button sequence will have the text a little too high by defaultnot )
        -- See 'Demo->Layout->Text Baseline Alignment' for details.
        ImGui.AlignTextToFramePadding();
        ImGui.Text("Hold to repeat:");
        ImGui.SameLine();

        -- Arrow buttons with Repeater
        local counter = 0;
        local spacing = ImGui.GetStyle().ItemInnerSpacing.x;
        ImGui.PushButtonRepeat(true);
        if (ImGui.ArrowButton("----left", ImGuiDir_Left)) then
            counter = counter - 1;
        end
        ImGui.SameLine(0.0, spacing);
        if (ImGui.ArrowButton("----right", ImGuiDir_Right)) then
            counter = counter + 1;
        end
        ImGui.PopButtonRepeat();
        ImGui.SameLine();
        ImGui.Text("%d", counter);

        ImGui.Text("Hover over me");
        if (ImGui.IsItemHovered()) then
            ImGui.SetTooltip("I am a tooltip");
        end
        ImGui.SameLine();
        ImGui.Text("- or me");
        if (ImGui.IsItemHovered())then
            ImGui.BeginTooltip();
            ImGui.Text("I am a fancy tooltip");
            -- static float arr[] = do 0.6f, 0.1f, 1.0, 0.5f, 0.92f, 0.1f, 0.2f end;
            -- ImGui.PlotLines("Curve", arr, IM_ARRAYSIZE(arr));
            ImGui.EndTooltip();
        end

        ImGui.Separator();

        ImGui.LabelText("label", "Value")
        -- Using the _simplified_ one-liner Combo() api here
        -- See "Combo" section for examples of how to use the more flexible BeginCombo()/EndCombo() api.
        -- const char* items[] = do "AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "GGGG", "HHHH", "IIIIIII", "JJJJ", "KKKKKKK" end;
        -- static int item_current = 0;
        -- ImGui.Combo("combo", item_current, items, IM_ARRAYSIZE(items));
        ImGui.SameLine(); ImGui.HelpMarker([[
Using the simplified one-liner Combo API here.
Refer to the \"Combo\" section below for an explanation of how to use the more flexible and general BeginCombo/EndCombo API.
        ]]);


        ImGui.TreePop();
    end
end