-- separator
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")

local Separator = Class(AWidget, function(self, parent)
    AWidget._ctor(self, parent)
end)

function Separator:_UpdateImpl()
    ImGui.Separator()
end

return Separator