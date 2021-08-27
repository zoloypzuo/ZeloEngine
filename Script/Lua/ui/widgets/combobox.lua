-- combobox
-- created on 2021/8/26
-- author @zoloypzuo
local AWidget = require("ui.widget")

local ComboBox = Class(AWidget, function(self, parent, currentChoice)
    AWidget._ctor(self, parent)
    self.choices = {}  -- int => string
    self.currentChoice = currentChoice or 0

    self.getter = nil
    self.setter = nil

    local processor = EventProcessor()
    self.ValueChangedEvent = EventWrapper(processor, "ValueChangedEvent")
end)

function ComboBox:_UpdateImpl()
    --if self.getter then
    --    self.value = self.getter()
    --end

    if ImGui.BeginCombo(self.id, self.choices[self.currentChoice]) then
        for key, value  in pairs(self.choices) do
            local selected = key == self.currentChoice

            if ImGui.Selectable(value, selected) then
                if not selected then
                    ImGui.SetItemDefaultFocus()
                    self.currentChoice = key
                    self.ValueChangedEvent:HandleEvent(value)
                end
            end
        end
        ImGui.EndCombo()
    end

    --if value ~= self.value then
    --    self.value = value
    --
    --    if self.setter then
    --        self.setter(value)
    --    end
    --
    --end
end

return ComboBox