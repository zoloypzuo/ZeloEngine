function ImGui.HelpMarker(desc)
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

function ImGui.ShowDockingDisabledMessage()
    -- TODO IO
    -- ImGuiIO& io = ImGui.GetIO();
    ImGui.Text("ERROR: Docking is not enabled! See Demo > Configuration.");
    ImGui.Text("Set io.ConfigFlags |= ImGuiConfigFlags_DockingEnable in your code, or ");
    ImGui.SameLine(0.0, 0.0);
    -- if (ImGui.SmallButton("click here"))
    -- io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
end
