local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local easing = require "easing"
local Widget = require "widgets/widget"

local Badge = Class(Widget, function(self, anim, owner)
    
    Widget._ctor(self, "Badge")
	self.owner = owner
    
    --self:SetHAnchor(ANCHOR_RIGHT)
    --self:SetVAnchor(ANCHOR_TOP)
    self.percent = 1
    self:SetScale(1,1,1)
    
    
    self.pulse = self:AddChild(UIAnim())
    self.pulse:GetAnimState():SetBank("pulse")
    self.pulse:GetAnimState():SetBuild("hunger_health_pulse")

    self.warning = self:AddChild(UIAnim())
    self.warning:GetAnimState():SetBank("pulse")
    self.warning:GetAnimState():SetBuild("hunger_health_pulse")
    self.warning:Hide()

    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank(anim)
    self.anim:GetAnimState():SetBuild(anim)
    self.anim:GetAnimState():PlayAnimation("anim")
    
    self.underNumber = self:AddChild(Widget("undernumber"))
    
    self.num = self:AddChild(Text(BODYTEXTFONT, 33))
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetPosition(5, 0, 0)
    self.num:Hide()
    
end)

function Badge:OnGainFocus()
    Badge._base.OnGainFocus(self)
    self.num:Show()
end

function Badge:OnLoseFocus()
    Badge._base.OnLoseFocus(self)
    self.num:Hide()
end

function Badge:SetPercent(val, max)
    val = val or self.percent
    max = max or 100

    self.anim:GetAnimState():SetPercent("anim", 1 - val)
    self.num:SetString(tostring(math.ceil(val*max)))
            
    self.percent = val
end

function Badge:PulseGreen()
    self.pulse:GetAnimState():SetMultColour(0,1,0,1)
	self.pulse:GetAnimState():PlayAnimation("pulse")
end

function Badge:PulseRed()
    self.pulse:GetAnimState():SetMultColour(1,0,0,1)
	self.pulse:GetAnimState():PlayAnimation("pulse")
end

function Badge:StopWarning()
	if self.warning.shown then
		self.warning:Hide()
	end
end

function Badge:StartWarning()
	if not self.warning.shown then
		self.warning:Show()
		self.warning:GetAnimState():SetMultColour(1,0,0,1)
		self.warning:GetAnimState():PlayAnimation("pulse", true)
	end
end

return Badge