local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local easing = require("easing")

local FireOver = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "FireOver")
	self.anim = self:AddChild(UIAnim())
    self:SetScaleMode(SCALEMODE_FIXEDPROPORTIONAL)
	
	self:SetClickable(false)
    self.anim:GetAnimState():SetBank("fire_over")
    self.anim:GetAnimState():SetBuild("fire_over")
    self.anim:GetAnimState():PlayAnimation("anim", true)
    self:SetHAnchor(ANCHOR_LEFT)
    self:SetVAnchor(ANCHOR_TOP)
    self.targetalpha = 0
    self.startalpha = 0
    self.alpha = 0
    self:Hide()
    self.ease_time = .4
    self.t = 0
	self.anim:GetAnimState():SetMultColour(1,1,1,0)
	
    self.inst:ListenForEvent("startfiredamage", function(inst, data) self:TurnOn() end, self.owner)
    self.inst:ListenForEvent("stopfiredamage", function(inst, data) self:TurnOff() end, self.owner)
	
end)


function FireOver:TurnOn()
	self.targetalpha = 1
	self.ease_time = 2
	self.startalpha = 0
	self.t = 0
	self.alpha = 0
	self:StartUpdating()
end

function FireOver:TurnOff()
	self.targetalpha = 0
	self.ease_time = 1
	self.startalpha = 1
	self.t = 0
	self.alpha = 1
end

function FireOver:OnUpdate(dt)
	self.t = self.t + dt
	self.alpha = easing.outCubic( self.t, self.startalpha, self.targetalpha-self.startalpha, self.ease_time ) 
	self.anim:GetAnimState():SetMultColour(1,1,1,self.alpha)
	if self.alpha <= 0 then
		self:Hide()	
		self:StopUpdating()
	else
		self:Show()

	end
end

return FireOver
