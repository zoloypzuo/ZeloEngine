-- menu_item
-- created on 2021/8/25
-- author @zoloypzuo
local AWidget = require("ui.widget")
local MenuItem = Class(AWidget, function(self, parent, name, shortcut, checkable, checked)
    AWidget._ctor(self, parent)
    self.name = name
    self.shortcut = shortcut or ""
    self.checkable = checkable or false
    self.checked = checked or false

    local processor = EventProcessor()
    self.ClickedEvent = EventWrapper(processor, "ClickedEvent")
    self.ValueChangedEvent = EventWrapper(processor, "ValueChangedEvent")
end)

function MenuItem:_UpdateImpl()
    local selected, activated = ImGui.MenuItem(self.name, self.shortcut, self.checked, self.enabled)
    if activated then
        self.ClickedEvent:HandleEvent()
    end

    if selected ~= self.checked then
        self.ValueChangedEvent:HandleEvent(selected)
        self.checked = selected
    end
end

return MenuItem