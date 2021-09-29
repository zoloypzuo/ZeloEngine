-- button_arrow
-- created on 2021/9/29
-- author @zoloypzuo
local AButton = require("ui.widgets.abutton")

local ButtonArrow = Class(AButton, function(self, direction)
    AButton._ctor(self)
    self.direction = direction or ImGuiDir.None
end)

function ButtonArrow:_UpdateImpl()
    if ImGui.ArrowButton(self.label .. self.id, self.direction) then
        self:_OnClick()
    end
end

return ButtonArrow