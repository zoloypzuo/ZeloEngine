-- button_small
-- created on 2021/9/29
-- author @zoloypzuo
local AButton = require("ui.widgets.abutton")

local ButtonSmall = Class(AButton, function (self, label)
    AButton._ctor(self)
    self.label = label
end)

function ButtonSmall:_UpdateImpl()
    if ImGui.SmallButton(self.label .. self.id) then
        self._OnClick()
    end
end 