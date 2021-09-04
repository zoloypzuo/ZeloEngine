-- ShowExampleMenuFile
-- created on 2021/9/4
-- author @zoloypzuo
local b = true;
local f = 0.5;
local n = 0;
-- Note that shortcuts are currently provided for display only
-- (future version will add explicit flags to BeginMenu() to request processing shortcuts)
function ShowExampleMenuFile()
    ImGui.MenuItem("(demo menu)");
    if (ImGui.MenuItem("New")) then
    end
    if (ImGui.MenuItem("Open", "Ctrl+O")) then
    end
    if (ImGui.BeginMenu("Open Recent")) then
        ImGui.MenuItem("fish_hat.c");
        ImGui.MenuItem("fish_hat.inl");
        ImGui.MenuItem("fish_hat.h");
        if (ImGui.BeginMenu("More..")) then
            ImGui.MenuItem("Hello");
            ImGui.MenuItem("Sailor");
            if (ImGui.BeginMenu("Recurse..")) then
                ShowExampleMenuFile();
                ImGui.EndMenu();
            end
            ImGui.EndMenu();
        end
        ImGui.EndMenu();
    end
    if (ImGui.MenuItem("Save", "Ctrl+S")) then
    end
    if (ImGui.MenuItem("Save As..")) then
    end

    ImGui.Separator();
    if (ImGui.BeginMenu("Options")) then
        local enabled = true;
        ImGui.MenuItem("Enabled", "", enabled);
        ImGui.BeginChild("child", 0, 60, true);
        -- for (int i = 0; i < 10; i++)
        -- ImGui.Text("Scrolling Text %d", i);
        ImGui.EndChild();

        ImGui.SliderFloat("Value", f, 0.0, 1.0);
        ImGui.InputFloat("Input", f, 0.1);
        ImGui.Combo("Combo", n, "Yes\0No\0Maybe\0\0");
        ImGui.EndMenu();
    end

    if (ImGui.BeginMenu("Colors")) then
        local sz = ImGui.GetTextLineHeight();
        for i = 0, ImGuiCol.COUNT - 1 do
            local name = ImGui.GetStyleColorName(i)
            local x, y = ImGui.GetCursorScreenPos();
            --ImGui.GetWinthenwDrawList()->AddRectFilled(p, ImVec2(p.x + sz, p.y + sz), ImGui.GetColorU32((ImGuiCol)i));
            --ImGui.Dummy(ImVec2(sz, sz));
            --ImGui.SameLine();
            --ImGui.MenuItem(name);
        end
        ImGui.EndMenu();
    end

    -- Here we demonstrate appending again to the "Options" menu (which we already created above)
    -- Of course in this demo it is a little bit silly that this function calls BeginMenu("Options") twice.
    -- In a real code-base using it would make senses to use this feature from very different code locations.
    if (ImGui.BeginMenu("Options")) then
        -- <-- Appendnot then
        ImGui.Checkbox("SomeOption", b);
        ImGui.EndMenu();
    end

    if (ImGui.BeginMenu("Disabled", false)) then
        assert(false)
    end
    if (ImGui.MenuItem("Checked")) then
    end
    if (ImGui.MenuItem("Quit", "Alt+F4")) then
    end
end

return ShowExampleMenuFile