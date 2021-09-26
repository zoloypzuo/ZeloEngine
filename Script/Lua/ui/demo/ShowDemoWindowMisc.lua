-- ShowDemoWindowMisc
-- created on 2021/9/26
-- author @zoloypzuo

local lines = { "aaa1.c", "bbb1.c", "ccc1.c", "aaa2.cpp", "bbb2.cpp", "ccc2.cpp", "abc.h", "hello, world" }

local function Filtering()
    -- TODO Filtering
    --    if (ImGui.CollapsingHeader("Filtering")) then
    --        -- Helper class to easy setup a text filter.
    --        -- You may want to implement a more feature-full filtering scheme in your own application.
    --        static ImGuiTextFilter filter;
    --        ImGui.Text("Filter usage:\n" ..
    --                    "  \"\"         display all lines\n" ..
    --                    "  \"xxx\"      display lines containing \"xxx\"\n" ..
    --                    "  \"xxx,yyy\"  display lines containing \"xxx\" or \"yyy\"\n" ..
    --                    "  \"-xxx\"     hide lines containing \"xxx\"");
    --        filter.Draw();
    --        for (i = 1, #lines)
    --            if (filter.PassFilter(lines[i])) then
    --                ImGui.BulletText(string.format("%s", lines[i]));
    --            end
    --    end
end

local function InputsNavigationFocus()
    
end

function ImGui.ShowDemoWindowMisc()
    Filtering()
    InputsNavigationFocus()
end