-- plugins.lua
-- created on 2021/12/16
-- author @zoloypzuo
-- plugin
local plugins = {
    --"TemplatePlugin",
    "ImGuiManager",
}

global("PluginInstances")
PluginInstances = {}

for _, v in ipairs(plugins) do
    local plugin = _G[v].new()
    PluginInstances[v] = plugin
    install(plugin)
end

require("plugins.imgui_manager")
