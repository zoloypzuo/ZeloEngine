-- project_hub_panel
-- created on 2021/8/21
-- author @zoloypzuo
local panel = require("ui.panel")
local button = require("ui.widgets.buttons.button")
local ProjectHubPanel = Class(panel.APanel, function(self)
    panel.APanel._ctor(self)
    local openProjectButton = self:CreateWidget(button.Button, "Open Project")
	openProjectButton:AddOnClickHandler(function ()
	print("button clicked")
	end)
end)

return ProjectHubPanel