-- ui_root
-- created on 2021/8/21
-- author @zoloypzuo
UIRoot = Class(function(self)
    self.panels = {}
end)

function UIRoot:Update()
    for _, panel in pairs(self.panels) do
        panel:Update()
    end
end

function UIRoot:LoadPanel(type_, ...)
    assert(type(type_) == "table", "should load a panel")
    local panel = type_(...)
    self.panels[panel.id] = panel
    return panel
end

function UIRoot:GetPanel(type_)
    for _, panel in pairs(self.panels) do
        if panel.is_a(type_) then
            return panel
        end
    end
    return nil
end