-- plugins.lua
-- created on 2021/12/16
-- author @zoloypzuo
-- plugin
--postEffectPlugin = EdgePipelinePlugin.new()
--postEffectPlugin = BlurPipelinePlugin.new()
--postEffectPlugin = BloomPipelinePlugin.new()
--postEffectPlugin = ShadowMapPipelinePlugin.new()

local plugins = {
    --"TemplatePlugin",
    --"CraftPlugin",
    --"Ch5MeshRendererPlugin",
    --"Ch6PBRPlugin",
    --"Ch7LargeScenePlugin",
    --"Ch10FinalPlugin",
    --"ImGuiManager",
}

global("PluginInstances")
PluginInstances = {}

for _, v in ipairs(plugins) do
    local plugin = _G[v].new()
    PluginInstances[v] = plugin
    install(plugin)
end

require("plugins.imgui_manager")
