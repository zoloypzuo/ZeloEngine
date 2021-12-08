-- game_view_panel
-- created on 2021/9/30
-- author @zoloypzuo
local PanelView = require("ui.panel_view")

local GameViewPanel = Class(PanelView, function (self, name, opened, panelSettings)
    PanelView._ctor(self, name, opened, panelSettings)
end )

function GameViewPanel:_UpdateImpl()
    self.m_fbo:Bind()
    local renderSystem = RenderSystem.GetSingletonPtr()
    renderSystem:PushView(self.m_fbo)
    renderSystem:Update()
    renderSystem:PopView()
    self.m_fbo:UnBind()
    PanelView._UpdateImpl(self)
end

return GameViewPanel