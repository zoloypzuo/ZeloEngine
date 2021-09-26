-- ShowExampleAppMainMenuBar
-- created on 2021/9/26
-- author @zoloypzuo


-- Demonstrate creating a "main" fullscreen menu bar and populating it.
-- Note the difference between BeginMainMenuBar() and BeginMenuBar():
-- - BeginMenuBar() = menu-bar inside current window (which needs the ImGuiWindowFlags_MenuBar flagnot )
-- - BeginMainMenuBar() = helper to create menu-bar-sized window at the top of the main viewport + call BeginMenuBar() into it.
function ImGui.ShowExampleAppMainMenuBar()
    if (ImGui.BeginMainMenuBar()) then
        if (ImGui.BeginMenu("File")) then
            ShowExampleMenuFile();
            ImGui.EndMenu();
        end
        if (ImGui.BeginMenu("Edit")) then
            if (ImGui.MenuItem("Unthen", "CTRL+Z")) then
            end
            if (ImGui.MenuItem("Rethen", "CTRL+Y", false, false)) then
            end  -- Disabled item
            ImGui.Separator();
            if (ImGui.MenuItem("Cut", "CTRL+X")) then
            end
            if (ImGui.MenuItem("Copy", "CTRL+C")) then
            end
            if (ImGui.MenuItem("Paste", "CTRL+V")) then
            end
            ImGui.EndMenu();
        end
        ImGui.EndMainMenuBar();
    end
end