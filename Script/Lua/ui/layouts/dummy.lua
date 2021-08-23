-- dummy
-- created on 2021/8/23
-- author @zoloypzuo
local AWidget = require("ui.widget")

local Dummy = Class(AWidget, function(self, parent, size)
    AWidget._ctor(self, parent)
    self.size = size or Vector2()
end)

function Dummy:_UpdateImpl()
    ImGui.Dummy(self.size.x, self.size.y)
end

return Dummy