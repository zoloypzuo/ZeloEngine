-- menu_list
-- created on 2021/8/25
-- author @zoloypzuo
local Group = require("ui.layouts.group")
local MenuList = Class(Group, function(self, parent, name, locked)
    Group._ctor(self, parent)
    self.name = name or ""
    self.locked = locked or false
    self.ClickedEvent = EventWrapper(EventProcessor(), "ClickedEvent")

    -- private
    self.m_opened = false
end)

function MenuList:_UpdateImpl()
    if ImGui.BeginMenu(self.name, not self.locked) then
        if not self.m_opened then
            self.ClickedEvent:HandleEvent()
            self.m_opened = true
        end

        self:UpdateWidgets()
        ImGui.EndMenu()
    else
        self.m_opened = false
    end
end

return MenuList