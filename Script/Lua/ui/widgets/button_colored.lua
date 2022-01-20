-- button_colored
-- created on 2021/9/29
-- author @zoloypzuo
local AButton = require("ui.widgets.abutton")

local ButtonColored = Class(AButton, function(self, parent, label, color, size, enableAlpha)
    AButton._ctor(self, parent)
    self.label = label
    self.color = color
    self.size = size
    self.enableAlpha = enableAlpha
end)

function ButtonColored:_UpdateImpl()
    local flag = 0
    if not self.enableAlpha then
        flag = ImGuiColorEditFlags.NoAlpha
    end
    if ImGui.ColorButton(self.label .. self.id, self.color, flag, self.size.x, self.size.y) then
        self._OnClick()
    end
end

return ButtonColored