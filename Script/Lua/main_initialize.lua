-- main_initialize.lua
-- created on 2021/8/18
-- author @zoloypzuo

--collectgarbage("stop") -- fix gc

-- singleton
TheSim = Game.GetSingletonPtr()

-- resource
table.insert(package.loaders, 1, ResourceMetaDataLoader)

RegisterResourceLoader("MESH", function(name, data)
    local loader = MeshLoader.new(name, data.mesh_index)
    return Mesh.new(loader)
end)

RegisterResourceLoader("MESH_GEN", function(name, _)
    return Mesh.new(MeshGenerators[name].new())
end)

RegisterResourceLoader("TEX", function(name, _)
    return Texture.new(name);
end)

RegisterResourceLoader("FONT", function(name, data)
    return Font.new(name, data.font_size)
end)

RegisterResourceLoader("MATERIAL", function(name, data)
    local tex_diffuse = LoadResource(data.diffuse)
    local tex_normal = LoadResource(data.normal)
    local tex_specular = LoadResource(data.specular)
    return Material.new(tex_diffuse, tex_normal, tex_specular)
end)

-- plugin
--postEffectPlugin = EdgePipelinePlugin.new()
--postEffectPlugin = BlurPipelinePlugin.new()
--postEffectPlugin = BloomPipelinePlugin.new()
--postEffectPlugin = ShadowMapPipelinePlugin.new()

local plugins = {
    --"TemplatePlugin",
    --"CraftPlugin",
    --"Ch5MeshRendererPlugin",
    --"Ch7PBRPlugin",
    "Ch7LargeScenePlugin",
    --"ImGuiManager",
}

global("PluginInstances")
PluginInstances = {}

for _, v in ipairs(plugins) do
    local plugin = _G[v].new()
    PluginInstances[v] = plugin
    install(plugin)
end

function ImGuiManager.Initialize()
    UI = ImGuiManager.GetSingletonPtr()

    UI:UseFont(LoadResource("Ruda-Bold.ttf"))

    -- hook debug
    -- ENABLE_HOOK_DEBUG_IMGUI = false
    -- if ENABLE_HOOK_DEBUG_IMGUI then
    --     local _ImGui = {}
    --     for name, fn in pairs(ImGui) do
    --         _ImGui[name] = function(...)
    --             print("ImGui.", name, ...)
    --             return fn(...)
    --         end
    --     end

    --     ImGui = _ImGui
    -- end

    require("editor.editor_actions")

    local MenuBarPanel = require("editor.panels.menu_bar_panel.menu_bar_panel")
    TheFrontEnd:LoadPanel(MenuBarPanel, "", true)

    local SHOW_ALL_PANEL_AT_INIT = false

    --local ProjectHubPanel = require("editor.panels.project_hub_panel.project_hub_panel")
    --TheFrontEnd:LoadPanel(ProjectHubPanel, "Project Hub", false)

    local HierarchyPanel = require("editor.panels.hierarchy_panel.hierarchy_panel")
    TheFrontEnd:LoadPanel(HierarchyPanel, "Hierarchy", SHOW_ALL_PANEL_AT_INIT)
    local InspectorPanel = require("editor.panels.inspector_panel.inspector_panel")
    TheFrontEnd:LoadPanel(InspectorPanel, "Inspector", SHOW_ALL_PANEL_AT_INIT)

    local ProjectSettingPanel = require("editor.panels.project_setting_panel.project_setting_panel")
    TheFrontEnd:LoadPanel(ProjectSettingPanel, "Project Setting", SHOW_ALL_PANEL_AT_INIT)

    local ConsolePanel = require("editor.panels.console_panel.console_panel")
    TheFrontEnd:LoadPanel(ConsolePanel, "Console", SHOW_ALL_PANEL_AT_INIT)

    local GameViewPanel = require("editor.panels.game_view_panel.game_view_panel")
    TheFrontEnd:LoadPanel(GameViewPanel, "Game View", SHOW_ALL_PANEL_AT_INIT)

    local DemoPanel = require("editor.panels.demo_panel")
    TheFrontEnd:LoadPanel(DemoPanel, "Demo", SHOW_ALL_PANEL_AT_INIT)

    local MaterialEditor = require("editor.panels.material_editor_panel.material_editor_panel")
    TheFrontEnd:LoadPanel(MaterialEditor, "Material Editor", SHOW_ALL_PANEL_AT_INIT)

    UI:ResetLayout()
end

-- scene
require("scenes.scene01")
