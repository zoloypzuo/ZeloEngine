-- button
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")

local AButton = Class(AWidget, function(self, parent)
    AWidget._ctor(self, parent)
    self.on_click = EventProcessor()
end)

function AButton:AddOnClickHandler(fn)
    return self.on_click:AddEventHandler("on_click", fn)
end

function AButton:_OnClick()
    self.on_click:HandleEvent("on_click")
end

return AButton