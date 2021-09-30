-- panel_view
-- created on 2021/9/30
-- author @zoloypzuo
local PanelWindow = require("ui.panel_window")
local Image = require("ui.widgets.image")

local PanelView = Class(PanelWindow, function(self, name, opened, panelSettings)
    PanelWindow._ctor(self, name, opened, panelSettings)

    self.panelSettings.NoScrollWithMouse = true
    self.panelSettings.NoScrollbar = true

    local size_x, size_y = 800, 600
    self.m_fbo = Framebuffer.new(size_x, size_y)
    self.m_image = self:CreateWidget(Image, self.m_fbo:GetRenderTextureID(), Vector2(size_x, size_y))
end)

function PanelView:Update()
    ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 0, 0)
    PanelWindow.Update(self)
    ImGui.PopStyleVar()
end

function PanelView:_UpdateImpl()
    PanelWindow._UpdateImpl(self)
    local size_x, size_y = unpack(self.m_windowSize)
    if size_x ~= 0 and size_y ~= 0 then
        self.m_image.size = Vector2(size_x, size_y)
        self.m_fbo:Resize(size_x, size_y)
    end
end

return PanelView