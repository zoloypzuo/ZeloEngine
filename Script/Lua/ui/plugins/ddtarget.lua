-- ddtarget
-- created on 2021/8/25
-- author @zoloypzuo
local DDTarget = Class(function(self, id_)
    self.id = id_
    self.DataReceivedEvent = nil
    self.HoverStartEvent = nil
    self.HoverEndEvent = nil

    self.showYellowRect = true

    -- private
    self.m_isHovered = false
end)

function DDTarget:Execute()
    if ImGui.BeginDragDropTarget() then
        if not self.m_isHovered then
            self.HoverStartEvent:HandleEvent()
        end
        self.m_isHovered =   true

        local flags = 0
        if not self.showYellowRect then
            target_flags = bit.bor(target_flags, ImGuiDragDropFlags.AcceptNoDrawDefaultRect)
        end
        local payload = ImGui.AcceptDragDropPayload(self.id, flags)
        if payload then
            self.DataReceivedEvent:HandleEvent(payload)
        end
        ImGui.EndDragDropTarget()
    else
        if self.m_isHovered then
            self.HoverEndEvent:HandleEvent()
        end
        self.m_isHovered = false
    end
end