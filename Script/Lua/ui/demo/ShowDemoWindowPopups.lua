-- ShowDemoWindowPopups
-- created on 2021/9/4
-- author @zoloypzuo
require("ui.demo.demo_util")

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
    --   bool my_tool_is_active = false; if (ImGui.Button("Open")) my_tool_is_active = true; [...] if (my_tool_is_active) Begin("My Tool", my_tool_is_active) do [...] end End();
    -- Typical use for popups:
    --   if (ImGui.Button("Open")) ImGui.OpenPopup("MyPopup"); if (ImGui.BeginPopup("MyPopup") do [...] EndPopup(); end

    -- With popups we have to go through a library call (here OpenPopup) to manipulate the visibility state.
    -- This may be a bit confusing at first but it should quickly make sense. Follow on the examples below.

end