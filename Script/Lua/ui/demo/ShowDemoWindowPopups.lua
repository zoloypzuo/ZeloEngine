-- ShowDemoWindowPopups
-- created on 2021/9/4
-- author @zoloypzuo
require("ui.demo.demo_util")


local selected_fish = -1;
local names = { "Bream", "Haddock", "Mackerel", "Pollock", "Tilefish" }
local toggles = { true, false, false, false, false };

function ImGui.ShowDemoWindowPopups()
    if (not ImGui.CollapsingHeader("Popups & Modal windows")) then
        return ;
    end

    -- The properties of popups windows are:
    -- - They block normal mouse hovering detection outside them. (*)
    -- - Unless modal, they can be closed by clicking anywhere outside them, or by pressing ESCAPE.
    -- - Their visibility state (~bool) is held internally by Dear ImGui instead of being held by the programmer as
    --   we are used to with regular Begin() calls. User can manipulate the visibility state by calling OpenPopup().
    -- (*) One can use IsItemHovered(ImGuiHoveredFlags_AllowWhenBlockedByPopup) to bypass it and detect hovering even
    --     when normally blocked by a popup.
    -- Those three properties are connected. The library needs to hold their visibility state BECAUSE it can close
    -- popups at any time.

    -- Typical use for regular windows:
    -- bool my_tool_is_active = false;
    -- if (ImGui.Button("Open")) my_tool_is_active = true;
    -- [...]
    -- if (my_tool_is_active) Begin("My Tool", my_tool_is_active) do [...] end End();
    -- Typical use for popups:
    -- if (ImGui.Button("Open")) ImGui.OpenPopup("MyPopup");
    -- if (ImGui.BeginPopup("MyPopup") do [...] EndPopup(); end

    -- With popups we have to go through a library call (here OpenPopup) to manipulate the visibility state.
    -- This may be a bit confusing at first but it should quickly make sense. Follow on the examples below.
    if (ImGui.TreeNode("Popups")) then
        ImGui.TextWrapped("When a popup is active, it inhibits interacting with windows that are behind the popup. " ..
                "Clicking outside the popup closes it.");

        -- Simple selection popup (if you want to show the current selection inside the Button itself,
        -- you may want to build a string using the "------" operator to preserve a constant ID with a variable label)
        if (ImGui.Button("Select..")) then
            ImGui.OpenPopup("my_select_popup");
        end
        ImGui.SameLine();
        ImGui.TextUnformatted(selected_fish == -1 and "<None>" or names[selected_fish]);
        if (ImGui.BeginPopup("my_select_popup")) then
            ImGui.Text("Aquarium");
            ImGui.Separator();
            for i = 1, #names do
                if (ImGui.Selectable(names[i])) then
                    selected_fish = i;
                end
            end
            ImGui.EndPopup();
        end

        -- Showing a menu with toggles
        if (ImGui.Button("Toggle..")) then
            ImGui.OpenPopup("my_toggle_popup");
        end
        if (ImGui.BeginPopup("my_toggle_popup")) then
            for i = 1, #names do
                ImGui.MenuItem(names[i], "", toggles[i]);
            end
            if (ImGui.BeginMenu("Sub-menu")) then
                ImGui.MenuItem("Click me");
                ImGui.EndMenu();
            end

            ImGui.Separator();
            ImGui.Text("Tooltip here");
            if (ImGui.IsItemHovered()) then
                ImGui.SetTooltip("I am a tooltip over a popup");
            end

            if (ImGui.Button("Stacked Popup")) then
                ImGui.OpenPopup("another popup");
            end
            if (ImGui.BeginPopup("another popup")) then
                for i = 1, #names do
                    ImGui.MenuItem(names[i], "", toggles[i]);
                end
                if (ImGui.BeginMenu("Sub-menu")) then
                    ImGui.MenuItem("Click me");
                    if (ImGui.Button("Stacked Popup")) then
                        ImGui.OpenPopup("another popup");
                    end
                    if (ImGui.BeginPopup("another popup")) then
                        ImGui.Text("I am the last one here.");
                        ImGui.EndPopup();
                    end
                    ImGui.EndMenu();
                end
                ImGui.EndPopup();
            end
            ImGui.EndPopup();
        end

        -- Call the more complete ShowExampleMenuFile which we use in various places of this demo
        if (ImGui.Button("File Menu..")) then
            ImGui.OpenPopup("my_file_popup");
            if (ImGui.BeginPopup("my_file_popup")) then
                ShowExampleMenuFile();
                ImGui.EndPopup();
            end

            ImGui.TreePop();
        end

        ImGui.TreePop();
    end
end