-- spacing
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")

local Spacing = Class(AWidget, function(self, parent, spaces)
    AWidget._ctor(self, parent)
    self.spaces = spaces or 1
end)

function Spacing:_UpdateImpl()
    for i = 1, self.spaces do
        ImGui.Spacing()

        if i + 1 <= self.spaces then
            ImGui.SameLine()
        end
    end
end

return Spacing