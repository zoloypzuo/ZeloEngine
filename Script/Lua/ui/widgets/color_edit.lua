-- color_edit
-- created on 2021/10/1
-- author @zoloypzuo
local AWidget = require("ui.widget")

local ColorEdit = Class(AWidget, function(self, parent, enableAlpha, defaultColor)
    AWidget._ctor(self, parent)
    self.enableAlpha = enableAlpha or false
    self.color = defaultColor or { 0, 0, 0 }
    self.ColorChangedEvent = EventWrapper(EventProcessor(), "ColorChangedEvent")

    self.getter = nil
    self.setter = nil
end)

function ColorEdit:_UpdateImpl()
    if self.getter then
        self.color = self.getter()
    end

    local flags = 0
    if not self.enableAlpha then
        flags = ImGuiColorEditFlags.NoAlpha
    end

    local widgetFn = self.enableAlpha and ImGui.ColorEdit4 or ImGui.ColorEdit3

    local color, used = widgetFn(self.id, self.color, flags)

    if used then
        self.color = color

        if self.setter then
            self.setter(color)
        end

        self.ColorChangedEvent:HandleEvent(color)
    end

    self.color = color
end

return ColorEdit