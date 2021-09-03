local demo_util = {}

function demo_util.HelpMarker(desc)
    -- Helper to display a little (?) mark which shows a tooltip when hovered.
    -- In your own code you may want to display an actual icon if you are using a merged icon fonts (see docs/FONTS.md)
    ImGui.TextDisabled("(?)")
    if (ImGui.IsItemHovered()) then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 35.0)
        ImGui.TextUnformatted(desc)
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end

function demo_util.ShowDockingDisabledMessage()
    -- TODO IO
    -- ImGuiIO& io = ImGui.GetIO();
    ImGui.Text("ERROR: Docking is not enabled! See Demo > Configuration.");
    ImGui.Text("Set io.ConfigFlags |= ImGuiConfigFlags_DockingEnable in your code, or ");
    ImGui.SameLine(0.0, 0.0);
    -- if (ImGui.SmallButton("click here"))
        -- io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
end

function demo_util.ShowUserGuide()
    -- ImGuiIO& io = ImGui.GetIO();
    ImGui.BulletText("Double-click on title bar to collapse window.");
    ImGui.BulletText(
        "Click and drag on lower corner to resize window\n"
        "(double-click to auto fit window to its contents).");
    ImGui.BulletText("CTRL+Click on a slider or drag box to input value as text.");
    ImGui.BulletText("TAB/SHIFT+TAB to cycle through keyboard editable fields.");
    -- if (io.FontAllowUserScaling)
        -- ImGui.BulletText("CTRL+Mouse Wheel to zoom window contents.");
    ImGui.BulletText("While inputing text:\n");
    ImGui.Indent();
    ImGui.BulletText("CTRL+Left/Right to word jump.");
    ImGui.BulletText("CTRL+A or double-click to select all.");
    ImGui.BulletText("CTRL+X/C/V to use clipboard cut/copy/paste.");
    ImGui.BulletText("CTRL+Z,CTRL+Y to undo/redo.");
    ImGui.BulletText("ESCAPE to revert.");
    ImGui.BulletText("You can apply arithmetic operators +,*,/ on numerical values.\nUse +- to subtract.");
    ImGui.Unindent();
    ImGui.BulletText("With keyboard navigation enabled:");
    ImGui.Indent();
    ImGui.BulletText("Arrow keys to navigate.");
    ImGui.BulletText("Space to activate a widget.");
    ImGui.BulletText("Return to input text into a widget.");
    ImGui.BulletText("Escape to deactivate a widget, close popup, exit child window.");
    ImGui.BulletText("Alt to jump to the menu layer of a window.");
    ImGui.BulletText("CTRL+Tab to select a window.");
    ImGui.Unindent();
end

return demo_util