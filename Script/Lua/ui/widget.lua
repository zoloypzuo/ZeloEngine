-- widget
-- created on 2021/8/21
-- author @zoloypzuo
local PluginableMixin = require("ui.pluginable_mixin")

local __WIDGET_ID_INCREMENT = 0
local function GenWidgetID()
    __WIDGET_ID_INCREMENT = __WIDGET_ID_INCREMENT + 1
    return __WIDGET_ID_INCREMENT
end

local AWidget = Class(function(self, parent)
    PluginableMixin.included(self)
    assert(type(parent) == "table", "A class derived from AWidget must pass parent to base ctor")
    self.parent = parent
    self.id = "##" .. GenWidgetID()
    self.enabled = true
    self.lineBreak = true;
    self.m_autoExecutePlugins = true
end):include(PluginableMixin)

function AWidget:Update()
    if self.enabled then
        self:_UpdateImpl()

        if self.m_autoExecutePlugins then
            -- ExecutePlugins  TODO public Plugins::Pluginable
        end

        if not self.lineBreak then
            ImGui.SameLine()
        end
    end
end

return AWidget