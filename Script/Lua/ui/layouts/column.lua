-- column
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")

local Column = Class(AWidget, function(self, parent, size)
    AWidget._ctor(self, parent)

    self.size = size or 1
    self.widths = {}
    for i = 1, size do
        self.widths[i] = -1
    end

    self.widgets = {}
end)

function Column:_UpdateImpl()
    ImGui.Columns(self.size, self.id, false)

    local idx = 1
    local counter = 1
    while idx <= #self.widgets do
        widget = self.widgets[idx]
        widget:Update()

        idx = idx + 1
        if idx <= #self.widgets then
            if self.widths[counter] ~= -1 then
                ImGui.SetColumnWidth(counter - 1, self.widths[counter])
            end
            ImGui.NextColumn()
        end

        counter = counter + 1
        if counter == self.size then
            counter = 1
        end
    end

    ImGui.Columns(1)
end

function Column:CreateWidget(type_, ...)
    inst = type_(self, ...)
    self.widgets[#self.widgets + 1] = inst
    return inst
end

function Column:RemoveWidget(widget)
    RemoveByValue(self.widgets, widget)
end

function Column:Clear()
    self.widgets = {}
end

return Column