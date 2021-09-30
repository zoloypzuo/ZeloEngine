-- image
-- created on 2021/9/30
-- author @zoloypzuo
local AWidget = require("ui.widget")

local Image = Class(AWidget, function(self, parent, textureId, size)
    AWidget._ctor(self, parent)
    self.textureId = textureId
    self.size = size
end)

function Image:_UpdateImpl()
    ImGui.Image(self.textureId, self.size.x, self.size.y, 0, 1, 1, 0)
end

return Image