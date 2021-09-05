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
    items = {"AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "GGGG", "HHHH", "IIIIIII", "JJJJ", "KKKKKKK"};
    item_current = ImGui.Combo("combo", item_current, items, #items);
    ImGui.SameLine()
    ImGui.HelpMarker(
        "Using the simplified one-liner Combo API here.\n" ..
        'Refer to the "Combo" section below for an explanation of how to use the more flexible and general BeginCombo/EndCombo API.'
    )

    -- To wire InputText() with std.string or any other custom string type,
    -- see the "Text Input > Resize Callback" section of this demo, and the misc/cpp/imgui_stdlib.h file.
    str0 = ImGui.InputText("input text", str0, 256);
    ImGui.SameLine(); ImGui.HelpMarker(
        "USER:\n" ..
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
    ImGui.SameLine(); ImGui.HelpMarker(
        "You can apply arithmetic operators +,*,/ on numerical values.\n" ..
        "  e.g. [ 100 ], input \'*2\', result becomes [ 200 ]\n" ..
        "Use +- to subtract.");

    f0 = ImGui.InputFloat("input float", f0, 0.01, 1.0, "%.3f");

    d0 = ImGui.InputDouble("input double", d0, 0.01, 1.0, "%.8f");

    f1 = ImGui.InputFloat("input scientific", f1, 0.0, 0.0, "%e");
    ImGui.SameLine(); ImGui.HelpMarker(
        "You can input value using the scientific notation,\n" ..
        "  e.g. \"1e+8\" becomes \"100000000\".");

    vec4a = ImGui.InputFloat3("input float3", vec4a);

    ImGui.TreePop()
end

function ImGui.ShowDemoWindowWidgets()
    if (not ImGui.CollapsingHeader("Widgets")) then
        return
    end

    -- local disable_all = false -- The Checkbox for that is inside the "Disabled" section at the bottom
    -- if (disable_all) then
    --     ImGui.BeginDisabled()
    -- end

    Basic()
end
