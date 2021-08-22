-- button
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")
local AButton = require("ui.widgets.abutton")

local Button = Class(AButton, function(self, parent, label, size, disabled)
    AButton._ctor(self)
    self.parent = parent
    self.label = label or ""
    self.size = size or Vector2()
    self.disabled = disabled or false

    self.idleBackgroundColor = nil;
    self.hoveredBackgroundColor = nil;
    self.clickedBackgroundColor = nil;
    self.textColor = nil;
end)

function Button:_UpdateImpl()
    local push_counter = 0
    if self.idleBackgroundColor then
        push_counter  = push_counter + 1
        ImGui.PushStyleColor(ImGuiCol.Button,
                self.idleBackgroundColor.r,
                self.idleBackgroundColor.g,
                self.idleBackgroundColor.b,
                self.idleBackgroundColor.a
        )
    end
    if self.hoveredBackgroundColor then
        push_counter  = push_counter + 1
        ImGui.PushStyleColor(ImGuiCol.ButtonHovered,
                self.hoveredBackgroundColor.r,
                self.hoveredBackgroundColor.g,
                self.hoveredBackgroundColor.b,
                self.hoveredBackgroundColor.a
        )
    end
    if self.clickedBackgroundColor then
        push_counter  = push_counter + 1
        ImGui.PushStyleColor(ImGuiCol.ButtonActive,
                self.clickedBackgroundColor.r,
                self.clickedBackgroundColor.g,
                self.clickedBackgroundColor.b,
                self.clickedBackgroundColor.a
        )
    end
    if self.textColor then
        push_counter  = push_counter + 1
        ImGui.PushStyleColor(ImGuiCol.Text,
                self.textColor.r,
                self.textColor.g,
                self.textColor.b,
                self.textColor.a
        )
    end
    if ImGui.Button(self.label, self.size.x, self.size.y) then
        self:_OnClick()
    end
    if push_counter then
        ImGui.PopStyleColor(push_counter)
    end
end

return Button