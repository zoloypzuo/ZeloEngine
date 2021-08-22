-- widget
-- created on 2021/8/21
-- author @zoloypzuo
local __WIDGET_ID_INCREMENT = 0
local function GenWidgetID()
    __WIDGET_ID_INCREMENT = __WIDGET_ID_INCREMENT + 1
    return __WIDGET_ID_INCREMENT
end

local AWidget = Class(function(self, parent)
    self.id = "##" .. GenWidgetID()
    self.enabled = true
    self.line_break = true;
    self.auto_execute_plugins = true

    self.parent = parent
end)

function AWidget:Update()
    if self.enabled then
        self:_UpdateImpl()

        if self.auto_execute_plugins then
            -- ExecutePlugins  TODO public Plugins::Pluginable
        end

        if not self.line_break then
            ImGui.SameLine()
        end
    end
end

return AWidget