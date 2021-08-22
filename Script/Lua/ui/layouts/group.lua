-- column
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")

local Group = Class(AWidget, function(self, parent)
    AWidget._ctor(self, parent)
    self.widgets = {}
end)

function Group:_UpdateImpl()
    for _, widget in ipairs(self.widgets) do
        widget:Update()
    end
end

function Group:CreateWidget(type_, ...)
    inst = type_(self, ...)
    self.widgets[#self.widgets + 1] = inst
    return inst
end

function Group:RemoveWidget(widget)
    RemoveByValue(self.widgets, widget)
end

function Group:Clear()
    self.widgets = {}
end

return Group