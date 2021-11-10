-- combobox
-- created on 2021/8/26
-- author @zoloypzuo
local AWidget = require("ui.widget")

local ComboBox = Class(AWidget, function(self, parent, choices, currentChoice)
    AWidget._ctor(self, parent)
    self.choices = choices or {}
    self.currentChoice = currentChoice or next(self.choices)

    self.getter = nil
    self.setter = nil

    local processor = EventProcessor()
    self.ValueChangedEvent = EventWrapper(processor, "ValueChangedEvent")
end)

function ComboBox:_UpdateImpl()
    if self.getter then
       self.currentChoice = self.getter()
    end

    local currentChoice = self.currentChoice

    if ImGui.BeginCombo(self.id, self.choices[self.currentChoice]) then
        for key, value in pairs(self.choices) do
            local selected = key == self.currentChoice

            if ImGui.Selectable(value, selected) then
                if not selected then
                    ImGui.SetItemDefaultFocus()
                    self.currentChoice = key
                end
            end
        end
        ImGui.EndCombo()
    end

    if currentChoice ~= self.currentChoice then
       if self.currentChoice then
           self.setter(self.currentChoice)
           self.ValueChangedEvent:HandleEvent(value)
       end
    end
end

return ComboBox