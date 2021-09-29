-- column
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")
local WidgetContainerMixin = require("ui.mixins.widget_container_mixin")

local Group = Class(AWidget, function(self, parent)
    AWidget._ctor(self, parent)
    WidgetContainerMixin.included(self)
end):include(WidgetContainerMixin)

function Group:_UpdateImpl()
    self:UpdateWidgets()
end

return Group