-- panel
-- created on 2021/8/21
-- author @zoloypzuo
require("common.table_util")
require("ui.ui_util")

local PanelTransformable = require("ui.panel_transformable")

local DefaultPanelWindowSettings = {
    NoResize = false;
    NoMove = false;
    NoDocking = false;
    NoBackground = false;
    AlwaysHorizontalScrollbar = false;
    AlwaysVerticalScrollbar = forceVerticalScrollbar;
    HorizontalScrollbar = allowHorizontalScrollbar;
    NoBringToFrontOnFocus = false;
    NoCollapse = false;
    NoInputs = false;
    NoScrollWithMouse = false;
    NoScrollbar = false;
    NoTitleBar = false;
}

local PanelWindow = Class(PanelTransformable, function(self, name, opened, panelSettings)
    PanelTransformable._ctor(self)
    self.name = name
    self.opened = opened
    self.hovered = false
    self.focused = false

    self.minSize = Vector2()
    self.maxSize = Vector2()

    local processor = EventProcessor()
    self.OpenEvent = EventWrapper(processor, "OpenEvent")
    self.CloseEvent = EventWrapper(processor, "CloseEvent")

    -- panelSettings
    self.panelSettings = panelSettings or DefaultPanelWindowSettings

    --private:
    self.m_mustScrollToBottom = false;
    self.m_mustScrollToTop = false;
    self.m_scrolledToBottom = false;
    self.m_scrolledToTop = false;
end)

function PanelWindow:_UpdateImpl()
    if not self.opened then
        return
    end
    local windowFlags = GenFlagFromTable(ImGuiWindowFlags, self.panelSettings, DefaultPanelWindowSettings)

    local minSizeConstraint = Vector2(self.minSize.x, self.minSize.y)
    local maxSizeConstraint = Vector2(self.maxSize.x, self.maxSize.y)

    -- clamp
    if minSizeConstraint.x <= 0 or minSizeConstraint.y <= 0 then
        minSizeConstraint = Vector2()
    end

    if maxSizeConstraint.x <= 0 or maxSizeConstraint <= 0 then
        maxSizeConstraint = Vector2(10000, 10000)
    end

    ImGui.SetNextWindowSizeConstraints(minSizeConstraint.x, minSizeConstraint.y,
            maxSizeConstraint.x, maxSizeConstraint.y)

    local shouldDraw
    self.opened, shouldDraw = ImGui.Begin(self.name .. self.id, self.opened, windowFlags)
    if shouldDraw then
        self.hovered = ImGui.IsWindowHovered()
        self.focused = ImGui.IsWindowFocused()

        local scrollY = ImGui.GetScrollY()
        self.m_scrolledToBottom = scrollY == ImGui.GetScrollMaxY()
        self.m_scrolledToTop = scrollY == 0

        if not shouldDraw then
            self.CloseEvent:HandleEvent()
        end

        self:UpdateTransform()

        if self.m_mustScrollToBottom then
            ImGui.SetScrollY(ImGui.GetScrollMaxY())
            self.m_mustScrollToBottom = false
        end

        if self.m_scrolledToTop then
            ImGui.SetScrollY(0)
            self.m_mustScrollToTop = false
        end

        self:UpdateWidgets()

        ImGui.End()
    end
end

return PanelWindow