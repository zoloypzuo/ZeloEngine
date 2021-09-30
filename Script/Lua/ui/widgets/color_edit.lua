-- color_edit
-- created on 2021/10/1
-- author @zoloypzuo
local AWidget = require("ui.widget")

local ColorEdit = Class(AWidget, function(self, parent, enableAlpha, defaultColor)
    AWidget._ctor(self, parent)
    self.enableAlpha = enableAlpha or false
    self.color = defaultColor or {}
    self.ColorChangedEvent = EventWrapper(EventProcessor(), "ColorChangedEvent")
end)

function ColorEdit:_UpdateImpl()
    local flags = 0
    if not self.enableAlpha then
        flags = ImGuiColorEditFlags.NoAlpha
    end
    local widgetFn = self.enableAlpha and ImGui.ColorEdit4 or ImGui.ColorEdit3
    local valueChanged = widgetFn(self.id, self.color, flags)
    if valueChanged then
        self.ColorChangedEvent:HandleEvent(self.color)
    end
end