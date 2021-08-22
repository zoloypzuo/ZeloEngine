-- ui_root
-- created on 2021/8/21
-- author @zoloypzuo
UIRoot = Class(function(self)
    self.panels = {}
end)

function UIRoot:Update()
    for _, panel in ipairs(self.panels) do
        panel:Update()
    end
end

function UIRoot:LoadPanel(name, ...)
    local panel_cls = require("panels." .. name)
    local panel = panel_cls(...)
    self.panels[panel.id] = panel
end
