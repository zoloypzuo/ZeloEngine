-- drag_float3
-- created on 2021/8/28
-- author @zoloypzuo
local AWidget = require("ui.widget")

local DragFloat3 = Class(AWidget, function(self, parent, min, max, speed, label)
    AWidget._ctor(self, parent)
    self.value = {}
    self.label = label or ""
    self.min = min or 0
    self.max = max or 0
    self.speed = speed or 0

    self.getter = nil
    self.setter = nil

    local processor = EventProcessor()
    self.ValueChangedEvent = EventWrapper(processor, "ValueChangedEvent")
end)

function DragFloat3:_UpdateImpl()
    if self.getter then
        self.value = self.getter()
    end
    local label = self.label .. self.id
    local value, used = ImGui.DragFloat3(label, self.value, self.speed, self.min, self.max, "%.3f")

    if used then
        self.value = value

        if self.setter then
            self.setter(value)
        end

        self.ValueChangedEvent:HandleEvent(value)
    end

    self.value = value
end

return DragFloat3