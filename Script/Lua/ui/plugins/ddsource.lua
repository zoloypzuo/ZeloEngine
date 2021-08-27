-- ddtarget
-- created on 2021/8/25
-- author @zoloypzuo
local DDSource = Class(function(self, id_, tooltip, data)
    self.id = id_
    self.tooltip = tooltip or ""
    self.data = data or nil
    self.hasTooltip = true -- Hide the tooltip

    local processor = EventProcessor()
    self.DragStartEvent = EventWrapper(processor, "DragStartEvent")
    self.DragStopEvent = EventWrapper(processor, "DragStopEvent")

    self.isDragged = false
end)

function DDSource:Execute()
    --	// Keep the source displayed as hovered
    --	// Because our dragging is local, we disable the feature of opening foreign treenodes/tabs while dragging
    local src_flags = bit.bor(ImGuiDragDropFlags.SourceNoDisableHover, ImGuiDragDropFlags.SourceNoHoldToOpenOthers)

    if not self.hasTooltip then
        src_flags = bit.bor(src_flags, ImGuiDragDropFlags.SourceNoPreviewTooltip)
    end

    if ImGui.BeginDragDropSource(src_flags) then
        if not self.isDragged then
            self.DragStartEvent:HandleEvent()
            self.isDragged = true
        end

        if bit.band(src_flags, ImGuiDragDropFlags.SourceNoPreviewTooltip) ~= 0 then
            ImGui.Text(self.tooltip)
        end
        --				ImGui::SetDragDropPayload(identifier.c_str(), &data, sizeof(data));
        -- TODO userdata
        ImGui.SetDragDropPayload(self.id, self.data)
    else
        if self.isDragged then
            self.DragStopEvent:HandleEvent()
        end
        self.isDragged = false
    end
end

return DDSource