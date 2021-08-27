-- panel
-- created on 2021/8/21
-- author @zoloypzuo
require("common.table_util")

local PanelTransformable = require("ui.panel_transformable")

local DefaultPanelWindowSettings = {
    closable = false;
    resizable = true;
    movable = true;
    dockable = true;
    scrollable = true;
    hideBackground = false;
    forceHorizontalScrollbar = false;
    forceVerticalScrollbar = false;
    allowHorizontalScrollbar = false;
    bringToFrontOnFocus = true;
    collapsable = false;
    allowInputs = true;
    titleBar = true;
    autoSize = false;
}

local function GenFlagFromPaneSetting(panelSettings)
	local closable = panelSettings.closable
	local resizable = panelSettings.resizable
	local movable = panelSettings.movable
	local dockable = panelSettings.dockable
	local scrollable = panelSettings.scrollable
	local hideBackground = panelSettings.hideBackground
	local forceHorizontalScrollbar = panelSettings.forceHorizontalScrollbar
	local forceVerticalScrollbar = panelSettings.forceVerticalScrollbar
	local allowHorizontalScrollbar = panelSettings.allowHorizontalScrollbar
	local bringToFrontOnFocus = panelSettings.bringToFrontOnFocus
	local collapsable = panelSettings.collapsable
	local allowInputs = panelSettings.allowInputs
	local titleBar = panelSettings.titleBar
	local autoSize = panelSettings.autoSize
	
	local windowFlags = 0
    -- @formatter:off
    if not resizable then windowFlags = bit.bor(windowFlags, ImGuiWindowFlags.NoResize) end
    if not movable then windowFlags = bit.bor(windowFlags, ImGuiWindowFlags.NoMove) end
    if not dockable then windowFlags = bit.bor(windowFlags, ImGuiWindowFlags.NoDocking) end
    if hideBackground then windowFlags = bit.bor(windowFlags, ImGuiWindowFlags.NoBackground) end
    if forceHorizontalScrollbar then windowFlags = bit.bor(windowFlags, ImGuiWindowFlags.AlwaysHorizontalScrollbar) end
    if forceVerticalScrollbar then windowFlags = bit.bor(windowFlags, ImGuiWindowFlags.AlwaysVerticalScrollbar) end
    if allowHorizontalScrollbar then windowFlags = bit.bor(windowFlags, ImGuiWindowFlags.HorizontalScrollbar) end
    if not bringToFrontOnFocus then windowFlags = bit.bor(windowFlags, ImGuiWindowFlags.NoBringToFrontOnFocus) end
    if not collapsable then windowFlags = bit.bor(windowFlags, ImGuiWindowFlags.NoCollapse) end
    if not allowInputs then windowFlags = bit.bor(windowFlags, ImGuiWindowFlags.NoInputs) end
    if not scrollable then windowFlags = bit.bor(windowFlags, ImGuiWindowFlags.NoScrollWithMouse, ImGuiWindowFlags.NoScrollbar) end
    if not titleBar then windowFlags = bit.bor(windowFlags, ImGuiWindowFlags.NoTitleBar) end
    -- @formatter:on
    return windowFlags
end

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
    panelSettings = panelSettings or DefaultPanelWindowSettings
    self.closable = panelSettings.closable;
    self.resizable = panelSettings.resizable;
    self.movable = panelSettings.movable;
    self.dockable = panelSettings.dockable;
    self.scrollable = panelSettings.scrollable;
    self.hideBackground = panelSettings.hideBackground;
    self.forceHorizontalScrollbar = panelSettings.forceHorizontalScrollbar;
    self.forceVerticalScrollbar = panelSettings.forceVerticalScrollbar;
    self.allowHorizontalScrollbar = panelSettings.allowHorizontalScrollbar;
    self.bringToFrontOnFocus = panelSettings.bringToFrontOnFocus;
    self.collapsable = panelSettings.collapsable;
    self.allowInputs = panelSettings.allowInputs;
    self.titleBar = panelSettings.titleBar;
    self.autoSize = panelSettings.autoSize;

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
    local windowFlags = GenFlagFromPaneSetting(self)

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

    --if (ImGui::Begin((name + m_panelID).c_str(), closable ? &m_opened : nullptr, windowFlags)) {
    local shouldDraw = ImGui.Begin(self.name, self.opened, windowFlags)
    if  shouldDraw then
        self.hovered = ImGui.IsWindowHovered()
        self.focused = ImGui.IsWindowFocused()

        local scrollY = ImGui.GetScrollY()
        self.m_scrolledToBottom = scrollY == ImGui.GetScrollMaxY()
        self.m_scrolledToTop = scrollY == 0

        if not shouldDraw then
            self.CloseEvent:HandleEvent()
        end

        self:UpdateTransform()

        if self.m_mustScrollToBottom  then
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