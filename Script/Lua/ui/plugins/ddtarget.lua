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
        end
    end