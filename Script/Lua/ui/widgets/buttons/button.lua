-- button
-- created on 2021/8/22
-- author @zoloypzuo
require("framework.events")
local widget = require("ui.widget")

local AButton = Class(widget.AWidget, function(self)
    self.on_click = EventProcessor()
end)

function AButton:AddOnClickHandler(fn)
    return self.on_click:AddEventHandler("on_click", fn)
end

function AButton:_OnClick()
    self.on_click:HandleEvent("on_click")
end

local Button = Class(function(self)
    self.label = ""
    self.size = {}
    self.
end)

return { AButton = AButton; Button = Button; }