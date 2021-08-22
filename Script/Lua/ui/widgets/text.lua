-- button
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")

local Text = Class(AWidget, function(self, parent, content)
    AWidget._ctor(self, parent)
    self.content = content or ""
end)

function Text:_UpdateImpl()
    ImGui.Text(self.content)
end

return Text