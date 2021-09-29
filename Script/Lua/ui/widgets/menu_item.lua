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

    if self.checkable == false then
        self.checked = false
    end
end)

function MenuItem:_UpdateImpl()
    local checked, activated = ImGui.MenuItem(self.name, self.shortcut, self.checked, self.enabled)
    if activated then
        self.ClickedEvent:HandleEvent()
    end

    if self.checkable and checked ~= self.checked then
        self.ValueChangedEvent:HandleEvent(checked)
        self.checked = checked
    end
end

return MenuItem