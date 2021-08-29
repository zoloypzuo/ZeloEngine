-- column
-- created on 2021/8/22
-- author @zoloypzuo
local Group = require("ui.layouts.group")

local GroupCollapsable = Class(Group, function(self, parent, name)
    Group._ctor(self, parent)
    self.name = name or ""
    self.opened = true

    local processor = EventProcessor()
    self.CloseEvent = EventWrapper(processor, "CloseEvent")
    self.OpenEvent = EventWrapper(processor, "OpenEvent")
end)

function GroupCollapsable:_UpdateImpl()
    local open, notCollapsed = ImGui.CollapsingHeader(self.name .. self.id, self.opened)
    if notCollapsed then
        Group._UpdateImpl(self)
    end

    if open ~= self.opened then
        if open then
            self.OpenEvent:HandleEvent()
        else
            self.CloseEvent:HandleEvent()
        end
    end

    self.opened = open
end

return GroupCollapsable