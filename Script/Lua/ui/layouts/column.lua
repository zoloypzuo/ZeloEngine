-- column
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")
local WidgetContainerMixin = require("ui.mixins.widget_container_mixin")

local Column = Class(AWidget, function(self, parent, size)
    AWidget._ctor(self, parent)
    WidgetContainerMixin.included(self)

    self.size = size or 1
    self.widths = {}
    for i = 1, size do
        self.widths[i] = -1
    end

end):include(WidgetContainerMixin)

function Column:_UpdateImpl()
    ImGui.Columns(self.size, self.id, false)

    local idx = 1
    local counter = 1
    while idx <= #self.widgets do
        local widget = self.widgets[idx]
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

return Column