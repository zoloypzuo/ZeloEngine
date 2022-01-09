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

local function ToFloat3(o)
    return {o.x, o.y, o.z}
end

local function ToVec3(o)
    return vec3.new(unpack(o))
end

function DragFloat3:_UpdateImpl()
    if self.getter then
        self.value = self.getter()
    end
    local label = self.label .. self.id
    local value, used = ImGui.DragFloat3(label, ToFloat3(self.value), self.speed, self.min, self.max, "%.3f")

    if used then
        self.value = ToVec3(value)

        if self.setter then
            self.setter(self.value)
        end

        self.ValueChangedEvent:HandleEvent(self.value)
    end

    self.value = value
end

return DragFloat3