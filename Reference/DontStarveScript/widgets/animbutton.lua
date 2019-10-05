local Widget = require "widgets/widget"
local Button = require "widgets/button"
local UIAnim = require "widgets/uianim"

local AnimButton = Class(Button, function(self, animname)
    Button._ctor(self, "AnimButton")
    self.anim = self:AddChild(UIAnim())
    self.anim:MoveToBack() 
    self.anim:GetAnimState():SetBuild(animname)
    self.anim:GetAnimState():SetBank(animname)
    self.anim:GetAnimState():PlayAnimation("idle")
    self.anim:GetAnimState():SetRayTestOnBB(true);
end)

function AnimButton:OnGainFocus()
	AnimButton._base.OnGainFocus(self)

    if self:IsEnabled() then
		self.anim:GetAnimState():PlayAnimation("over")
	end
end

function AnimButton:OnLoseFocus()
	AnimButton._base.OnLoseFocus(self)

	if self:IsEnabled() then
		self.anim:GetAnimState():PlayAnimation("idle")
    end
end


function AnimButton:Enable()
	AnimButton._base.Enable(self)
	self.anim:GetAnimState():PlayAnimation("idle")
	--self.text:SetColour(1,1,1,1)
end

function AnimButton:Disable()
	AnimButton._base.Disable(self)
	self.anim:GetAnimState():PlayAnimation("disabled")
	--self.text:SetColour(.7,.7,.7,1)
end

return AnimButton