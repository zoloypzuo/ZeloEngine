-- panel_view
-- created on 2021/9/30
-- author @zoloypzuo
local PanelWindow = require("ui.panel_window")
local Image = require("ui.widgets.image")

local PanelView = Class(PanelWindow, function(self, name, opened, panelSettings)
    PanelWindow._ctor(self, name, opened, panelSettings)

    self.panelSettings.NoScrollWithMouse = true
    self.panelSettings.NoScrollbar = true

    local size_x, size_y = 1280, 720
    self.m_fbo = Framebuffer.new(size_x, size_y)
    self.m_image = self:CreateWidget(Image, self.m_fbo:GetRenderTextureID(), Vector2(size_x, size_y))
end)

function PanelView:Update()
    ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 0,0)
    PanelWindow.Update(self)
    ImGui.PopStyleVar()
end

return PanelView