-- button_small
-- created on 2021/9/29
-- author @zoloypzuo
local AButton = require("ui.widgets.abutton")

local ButtonSmall = Class(AButton, function(self, parent, label)
    AButton._ctor(self, parent)
    self.label = label
end)

function ButtonSmall:_UpdateImpl()
    if ImGui.SmallButton(self.label .. self.id) then
        self._OnClick()
    end
end

return ButtonSmall