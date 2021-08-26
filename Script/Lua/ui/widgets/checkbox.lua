-- check_box
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")

local CheckBox = Class(AWidget, function(self, parent, value, label)
    AWidget._ctor(self, parent)
    self.value = value or false
    self.label = label or ""

    self.getter = nil
    self.setter = nil

    local processor = EventProcessor()
    self.ValueChangedEvent = EventWrapper(processor, "ValueChangedEvent")
end)

function CheckBox:_UpdateImpl()
    if self.getter then
        self.value = self.getter()
    end

    local value, _ = ImGui.Checkbox(self.label, self.value)

    if value ~= self.value then
        self.value = value

        if self.setter then
            self.setter(value)
        end

        self.ValueChangedEvent:HandleEvent(value)
    end

    self.value = value
end

return CheckBox