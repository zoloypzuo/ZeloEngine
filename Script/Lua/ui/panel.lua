-- panel
-- created on 2021/8/21
-- author @zoloypzuo
require("common.table_util")
require("framework.guid")
local WidgetContainerMixin = require("ui.widget_container_mixin")

local __PANEL_ID_Manager = IdManager()

local APanel = Class(function(self)
    WidgetContainerMixin.included(self)
    self.id = "##" .. __PANEL_ID_Manager:GenID()
    self.enabled = true
end):include(WidgetContainerMixin)

function APanel:Update()
    if self.enabled then
        self:_UpdateImpl()
    end
end

function APanel:_UpdateImpl()
    error("implemented by derived class")
end

return APanel