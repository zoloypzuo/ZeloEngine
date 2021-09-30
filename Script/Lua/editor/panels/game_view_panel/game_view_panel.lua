-- game_view_panel
-- created on 2021/9/30
-- author @zoloypzuo
local PanelView = require("ui.panel_view")

local GameViewPanel = Class(PanelView, function (self, name, opened, panelSettings)
    PanelView._ctor(self, name, opened, panelSettings)
end )

return GameViewPanel