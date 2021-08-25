-- button
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")

local TextColored = Class(AWidget, function(self, parent, content, color)
    AWidget._ctor(self, parent)
    self.content = content or ""
    self.color = color or RGBA(1, 1, 1, 1)
end)

function TextColored:_UpdateImpl()
    ImGui.TextColored(self.color.r, self.color.g, self.color.b, self.color.a, self.content)
end

return TextColored