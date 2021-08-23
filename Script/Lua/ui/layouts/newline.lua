-- dummy
-- created on 2021/8/23
-- author @zoloypzuo
local AWidget = require("ui.widget")

local NewLine = Class(AWidget, function(self, parent)
    AWidget._ctor(self, parent)
end)

function NewLine:_UpdateImpl()
    ImGui.NewLine()
end

return NewLine