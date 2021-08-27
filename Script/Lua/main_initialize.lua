-- main_initialize.lua
-- created on 2021/8/18
-- author @zoloypzuo

--collectgarbage("stop") -- fix gc

-- singleton
TheSim = Game.GetSingletonPtr()
UI = UIManager.GetSingletonPtr()

-- add our print loggers
--AddPrintLogger(function(...)
--    TheSim:LuaPrint(...)
--end)

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

-- UI
--UI.enable_docking = false;
UI:ApplyStyle(EStyle.DUNE_DARK)
UI:UseFont(LoadResource("Ruda-Bold.ttf"))

-- hook debug
ENABLE_HOOK_DEBUG_IMGUI = false
if ENABLE_HOOK_DEBUG_IMGUI then
    local _ImGui = {}
    for name, fn in pairs(ImGui) do
    	_ImGui[name] = function (...)
    		print("ImGui.", name, ...)
    		return fn(...)
    	end
    end

    ImGui = _ImGui
end

require("editor.editor_actions")

local project_hub_panel = require("editor.panels.project_hub_panel")
local HierarchyPanel = require("editor.panels.hierarchy_panel.hierarchy_panel")
local hierarchyPanel = TheFrontEnd:LoadPanel(HierarchyPanel, "Hierarchy Panel", true)
local InspectorPanel = require("editor.panels.inspector_panel")
TheFrontEnd:LoadPanel(InspectorPanel, "Inspector Panel", true)

-- scene
require("scenes.scene01")

hierarchyPanel:LoadScene()