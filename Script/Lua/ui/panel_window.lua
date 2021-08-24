-- panel
-- created on 2021/8/21
-- author @zoloypzuo
require("common.table_util")

local PanelTransformable = require("ui.panel_transformable")

local DefaultPanelWindowSettings = {
    closable = false;
    resizable = true;
    movable = true;
    dockable = false;
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
    local windowFlags = 0
    -- @formatter:off
    if not resizable then windowFlags = bits.bor(windowFlags, ImGuiWindowFlags.NoResize) end
    if not movable then windowFlags = bits.bor(windowFlags, ImGuiWindowFlags.NoMove) end
    if not dockable then windowFlags = bits.bor(windowFlags, ImGuiWindowFlags.NoDocking) end
    if hideBackground then windowFlags = bits.bor(windowFlags, ImGuiWindowFlags.NoBackground) end
    if forceHorizontalScrollbar then windowFlags = bits.bor(windowFlags, ImGuiWindowFlags.AlwaysHorizontalScrollbar) end
    if forceVerticalScrollbar then windowFlags = bits.bor(windowFlags, ImGuiWindowFlags.AlwaysVerticalScrollbar) end
    if allowHorizontalScrollbar then windowFlags = bits.bor(windowFlags, ImGuiWindowFlags.HorizontalScrollbar) end
    if not bringToFrontOnFocus then windowFlags = bits.bor(windowFlags, ImGuiWindowFlags.NoBringToFrontOnFocus) end
    if not collapsable then windowFlags = bits.bor(windowFlags, ImGuiWindowFlags.NoCollapse) end
    if not allowInputs then windowFlags = bits.bor(windowFlags, ImGuiWindowFlags.NoInputs) end
    if not scrollable then windowFlags = bits.bor(windowFlags, ImGuiWindowFlags.NoScrollWithMouse, ImGuiWindowFlags.NoScrollbar) end
    if not titleBar then windowFlags = bits.bor(windowFlags, ImGuiWindowFlags.NoTitleBar) end
    -- @formatter:on
    return windowFlags
end

local PanelWindow = Class(PanelTransformable, function(self, name, opened, panelSettings)
    --const std::string &name = "",
    --bool opened = true,
    --const Settings::PanelWindowSettings &panelSettings = Settings::PanelWindowSettings{}
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

    --
    --ImVec2 minSizeConstraint = Internal::Converter::ToImVec2(minSize);
    --ImVec2 maxSizeConstraint = Internal::Converter::ToImVec2(maxSize);
    --
    --if (minSizeConstraint.x <= 0.f || minSizeConstraint.y <= 0.f)
    --    minSizeConstraint = {0.0f, 0.0f};
    --
    --if (maxSizeConstraint.x <= 0.f || maxSizeConstraint.y <= 0.f)
    --    maxSizeConstraint = {10000.f, 10000.f};
    --
    --ImGui::SetNextWindowSizeConstraints(minSizeConstraint, maxSizeConstraint);
    --
    --if (ImGui::Begin((name + m_panelID).c_str(), closable ? &m_opened : nullptr, windowFlags)) {
    --    m_hovered = ImGui::IsWindowHovered();
    --    m_focused = ImGui::IsWindowFocused();
    --
    --    auto scrollY = ImGui::GetScrollY();
    --
    --    m_scrolledToBottom = scrollY == ImGui::GetScrollMaxY();
    --    m_scrolledToTop = scrollY == 0.0f;
    --
    --    if (!m_opened)
    --        CloseEvent.Invoke();
    --
    --    Update();
    --
    --    if (m_mustScrollToBottom) {
    --        ImGui::SetScrollY(ImGui::GetScrollMaxY());
    --        m_mustScrollToBottom = false;
    --    }
    --
    --    if (m_mustScrollToTop) {
    --        ImGui::SetScrollY(0.0f);
    --        m_mustScrollToTop = false;
    --    }
    --
    --    DrawWidgets();
    --}
    --
    --ImGui::End();
end

return PanelWindow