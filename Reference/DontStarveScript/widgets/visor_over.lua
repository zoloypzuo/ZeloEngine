local Widget = require "widgets/widget"
local Image = require "widgets/image"


local VisorOver = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "VisorOver")
	self:SetClickable(false)

	self.img = self:AddChild(Image("images/fx2.xml", "reduced_over.tex"))
    self.img:SetHAnchor(ANCHOR_MIDDLE)
    self.img:SetVAnchor(ANCHOR_MIDDLE)
    self.img:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.img:SetVRegPoint(ANCHOR_BOTTOM)
    self.img:SetHRegPoint(ANCHOR_MIDDLE)

    self:Hide()    
end)

function VisorOver:UpdateState(data)
	print("TESTING")
	local hat = self.owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
	if hat then
		print(hat.prefab)
	end
	if hat and hat:HasTag("visorvision") then
		print("SHOW")
		self:Show()
	else
		print("HIDE")
		self:Hide()
	end		
end

return VisorOver