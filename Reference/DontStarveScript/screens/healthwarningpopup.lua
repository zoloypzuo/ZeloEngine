local Screen = require "widgets/screen"
local Button = require "widgets/button"
local ImageButton = require "widgets/imagebutton"

local HealthWarningPopup = Class(Screen, function(self)
	Screen._ctor(self, "HealthWarningPopup")
	
	self.bg = self:AddChild(ImageButton("images/rail.xml", "health_warning.tex"))
	self.bg.image:SetVRegPoint(ANCHOR_MIDDLE)
	self.bg.image:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg.image:SetVAnchor(ANCHOR_MIDDLE)
	self.bg.image:SetHAnchor(ANCHOR_MIDDLE)
	self.bg.image:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.bg:SetOnClick(function() --[[ eat the click ]] end)

	self.inst:DoTaskInTime(7.75, function()
		TheFrontEnd:Fade(false, 0.25, function()
			TheFrontEnd:PopScreen()
			TheFrontEnd:Fade(true, 0.25)
		end)
	end)
end)

return HealthWarningPopup