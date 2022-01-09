-- imgui_manager.lua
-- created on 2021/12/16
-- author @zoloypzuo
function ImGuiManager.Initialize()
    UI = ImGuiManager.GetSingletonPtr()

    UI:UseFont(LoadResource("Ruda-Bold.ttf"))

    -- hook debug
    ENABLE_HOOK_DEBUG_IMGUI = false
    if ENABLE_HOOK_DEBUG_IMGUI then
        local _ImGui = {}
        for name, fn in pairs(ImGui) do
            _ImGui[name] = function(...)
                print("ImGui." .. name, ...)
                return fn(...)
            end
        end

        ImGui = _ImGui
    end

    require("editor.editor_actions")

    local MenuBarPanel = require("editor.panels.menu_bar_panel.menu_bar_panel")
    TheFrontEnd:LoadPanel(MenuBarPanel, "", true)

    local HierarchyPanel = require("editor.panels.hierarchy_panel.hierarchy_panel")
    TheFrontEnd:LoadPanel(HierarchyPanel, "Hierarchy", true)
    local InspectorPanel = require("editor.panels.inspector_panel.inspector_panel")
    TheFrontEnd:LoadPanel(InspectorPanel, "Inspector", true)

    local ProjectSettingPanel = require("editor.panels.project_setting_panel.project_setting_panel")
    TheFrontEnd:LoadPanel(ProjectSettingPanel, "Project Setting", false)

    local ConsolePanel = require("editor.panels.console_panel.console_panel")
    TheFrontEnd:LoadPanel(ConsolePanel, "Console", true)

    -- local GameViewPanel = require("editor.panels.game_view_panel.game_view_panel")
    -- TheFrontEnd:LoadPanel(GameViewPanel, "Game View", true)

    local DemoPanel = require("editor.panels.demo_panel")
    TheFrontEnd:LoadPanel(DemoPanel, "Demo", false)

    local MaterialEditor = require("editor.panels.material_editor_panel.material_editor_panel")
    TheFrontEnd:LoadPanel(MaterialEditor, "Material Editor", false)

    UI:ResetLayout()
    UI.enable_docking = false

    -- TODO load scene
    --LoadAvatar()
    --SpawnPrefab("bistro")
end

function ImGuiManager.Update()
    TheFrontEnd:Update()
end
