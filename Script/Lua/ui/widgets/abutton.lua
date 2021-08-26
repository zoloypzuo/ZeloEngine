-- button
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")

local AButton = Class(AWidget, function(self, parent)
    AWidget._ctor(self, parent)
    self.ClickedEvent = EventWrapper(EventProcessor(), "ClickedEvent")
end)

function AButton:AddOnClickHandler(fn)
    return self.ClickedEvent:AddEventHandler(fn)
end

function AButton:_OnClick()
    self.ClickedEvent:HandleEvent()
end

return AButton