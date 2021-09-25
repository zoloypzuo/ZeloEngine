-- ShowDemoWindowPopups
-- created on 2021/9/4
-- author @zoloypzuo
require("ui.demo.demo_util")

FLT_MIN = 1.175494351e-38

local selected_fish = -1;
local names = { "Bream", "Haddock", "Mackerel", "Pollock", "Tilefish" }
local toggles = { true, false, false, false, false }

local function Popups()
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

local label_names = { "Label1", "Label2", "Label3", "Label4", "Label5" }
local value = 0.5

local function ContextMenus()
    if (ImGui.TreeNode("Context menus")) then
        ImGui.HelpMarker("\"Context\" functions are simple helpers to associate a Popup to a given Item or Window identifier.");

        -- BeginPopupContextItem() is a helper to provide common/simple popup behavior of essentially doing:
        --     if (id == 0)
        --         id = GetItemID(); -- Use last item id
        --     if (IsItemHovered() and IsMouseReleased(ImGuiMouseButton_Right))
        --         OpenPopup(id);
        --     return BeginPopup(id);
        -- For advanced advanced uses you may want to replicate and customize this code.
        -- See more details in BeginPopupContextItem().

        -- Example 1
        -- When used after an item that has an ID (e.g. Button), we can skip providing an ID to BeginPopupContextItem(),
        -- and BeginPopupContextItem() will use the last item ID as the popup ID.then
        for n = 1, #label_names do
            ImGui.Selectable(label_names[n]);
            if (ImGui.BeginPopupContextItem()) then
                -- <-- use last item id as popup id
                ImGui.Text(string.format("This a popup for \"%s\"", label_names[n]));
                if (ImGui.Button("Close")) then
                    ImGui.CloseCurrentPopup();
                end
                ImGui.EndPopup();
            end
            if (ImGui.IsItemHovered()) then
                ImGui.SetTooltip("Right-click to open popup");
            end
        end

        -- Example 2
        -- Popup on a Text() element which doesn't have an identifier: we need to provide an identifier to BeginPopupContextItem().
        -- Using an explicit identifier is also convenient if you want to activate the popups from different locations.then
        ImGui.HelpMarker("Text() elements don't have stable identifiers so we need to provide one.");
        ImGui.Text("Value = %.3f <-- (1) right-click this value", value);
        if (ImGui.BeginPopupContextItem("my popup")) then
            if (ImGui.Selectable("Set to zero")) then
                value = 0.0
            end ;
            if (ImGui.Selectable("Set to PI")) then
                value = 3.1415
            end ;
            ImGui.SetNextItemWidth(-FLT_MIN);
            value = ImGui.DragFloat("----Value", value, 0.1, 0.0, 0.0);
            ImGui.EndPopup();
        end

        -- We can also use OpenPopupOnItemClick() to toggle the visibility of a given popup.
        -- Here we make it that right-clicking this other text element opens the same popup as above.
        -- The popup itself will be submitted by the code above.
        -- TODO OpenPopupOnItemClick
        --ImGui.Text("(2) Or right-click this text");
        --ImGui.OpenPopupOnItemClick("my popup", ImGuiPopupFlags_MouseButtonRight);

        -- Back to square one: manually open the same popup.
        if (ImGui.Button("(3) Or click this button")) then
            ImGui.OpenPopup("my popup");
        end

        -- Example 3
        -- When using BeginPopupContextItem() with an implicit identifier (NULL == use last item ID),
        -- we need to make sure your item identifier is stable.
        -- In this example we showcase altering the item label while preserving its identifier, using the ------ operator (see FAQ).then
        ImGui.HelpMarker("Showcase using a popup ID linked to item ID, with the item having a changing label + stable ID using the ------ operator.");

        local name = "Label"
        ImGui.Button(string.format("Button: %s------Button", name))
        ------ operator override ID ignoring the preceding label
        if (ImGui.BeginPopupContextItem()) then
            ImGui.Text("Edit name:");
            ImGui.InputText("----edit", name, #name);
            if (ImGui.Button("Close")) then
                ImGui.CloseCurrentPopup();
                ImGui.EndPopup();
            end
            ImGui.SameLine();
            ImGui.Text("(<-- right-click here)");
            ImGui.TreePop()
        end

        ImGui.TreePop()
    end
end

local dont_ask_me_next_time = false;
local item = 1;
local color = { 0.4, 0.7, 0.0, 0.5 }
local unused_open = true;

local function Modals()
    if (ImGui.TreeNode("Modals")) then
        ImGui.TextWrapped("Modal windows are like popups but the user cannot close them by clicking outside.");

        if (ImGui.Button("Delete..")) then
            ImGui.OpenPopup("Delete?");
        end

        -- Always center this window when appearing
        -- TODO GetMainViewport
        --ImVec2 center = ImGui.GetMainViewport()->GetCenter();
        --ImGui.SetNextWindowPos(center, ImGuiCond_Appearing, ImVec2(0.5f, 0.5f));

        if (ImGui.BeginPopupModal("Delete?", true, ImGuiWindowFlags.AlwaysAutoResize)) then
            ImGui.Text("All those beautiful files will be deleted.\nThis operation cannot be undonenot \n\n");
            ImGui.Separator();

            --static int unused_i = 0;
            --ImGui.Combo("Combo", unused_i, "Delete\0Delete harder\0");

            ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0);
            ImGui.Checkbox("Don't ask me next time", dont_ask_me_next_time);
            ImGui.PopStyleVar();

            if (ImGui.Button("OK", 120, 0)) then
                ImGui.CloseCurrentPopup();
            end
            ImGui.SetItemDefaultFocus();
            ImGui.SameLine();
            if (ImGui.Button("Cancel", 120, 0)) then
                ImGui.CloseCurrentPopup();
            end
            ImGui.EndPopup();
        end

        if (ImGui.Button("Stacked modals..")) then
            ImGui.OpenPopup("Stacked 1");
        end
        if (ImGui.BeginPopupModal("Stacked 1", true, ImGuiWindowFlags.MenuBar)) then
            if (ImGui.BeginMenuBar()) then
                if (ImGui.BeginMenu("File")) then
                    if (ImGui.MenuItem("Some menu item")) then
                    end
                    ImGui.EndMenu();
                end
                ImGui.EndMenuBar();
            end
            ImGui.Text("Hello from Stacked The First\nUsing style.Colors[ImGuiCol_ModalWindowDimBg] behind it.");

            -- Testing behavior of widgets stacking their own regular popups over the modal.

            ImGui.Combo("Combo", item, "aaaa\0bbbb\0cccc\0dddd\0eeee\0\0");
            ImGui.ColorEdit4("color", color);

            if (ImGui.Button("Add another modal..")) then
                ImGui.OpenPopup("Stacked 2");
            end

            -- Also demonstrate passing a bool* to BeginPopupModal(), this will create a regular close button which
            -- will close the popup. Note that the visibility state of popups is owned by imgui, so the input value
            -- of the bool actually doesn't matter here.
            if (ImGui.BeginPopupModal("Stacked 2", unused_open)) then
                ImGui.Text("Hello from Stacked The Secondnot ");
                if (ImGui.Button("Close")) then
                    ImGui.CloseCurrentPopup();
                end
                ImGui.EndPopup();
            end

            if (ImGui.Button("Close")) then
                ImGui.CloseCurrentPopup();
            end
            ImGui.EndPopup();
        end

        ImGui.TreePop();
    end
end

local function MenusInsideARegularWindow()
    if (ImGui.TreeNode("Menus inside a regular window"))then
        ImGui.TextWrapped("Below we are testing adding menu items to a regular window. It's rather unusual but should worknot ");
        ImGui.Separator();

        -- Note: As a quirk in this very specific example, we want to differentiate the parent of this menu from the
        -- parent of the various popup menus above. To do so we are encloding the items in a PushID()/PopID() block
        -- to make them two different menusets. If we don't, opening any popup above and hovering our menu here would
        -- open it. This is because once a menu is active, we allow to switch to a sibling menu by just hovering on it,
        -- which is the desired behavior for regular menus.
        ImGui.PushID("foo");
        ImGui.MenuItem("Menu item", "CTRL+M");
        if (ImGui.BeginMenu("Menu inside a regular window"))then
            ImGui.ShowExampleMenuFile();
            ImGui.EndMenu();
        end
        ImGui.PopID();
        ImGui.Separator();
        ImGui.TreePop();
    end
end

function ImGui.ShowDemoWindowPopups()
    if (not ImGui.CollapsingHeader("Popups & Modal windows")) then
        return ;
    end

    Popups()
    ContextMenus()
    Modals()
    MenusInsideARegularWindow()
end