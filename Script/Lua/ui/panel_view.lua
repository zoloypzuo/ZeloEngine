-- panel_view
-- created on 2021/9/30
-- author @zoloypzuo
local PanelWindow = require("ui.panel_window")

local PanelView = Class(PanelWindow, function(self, name, opened, panelSettings)
    PanelWindow._ctor(self, name, opened, panelSettings)

    self:CreateWidget(Image)
end)

function PanelView:Update()
    ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 0,0)
    PanelWindow.Update(self)
    ImGui.PopStyleVar()
end

