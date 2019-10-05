local Widget = require "widgets/widget"
local Image = require "widgets/image"


local LivingArtifactOver = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "LivingArtifactOver")
	self:SetClickable(false)

	self.img = self:AddChild(Image("images/fx6.xml", "living_artifact.tex"))
    self.img:SetHAnchor(ANCHOR_MIDDLE)
    self.img:SetVAnchor(ANCHOR_MIDDLE)
    self.img:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.img:SetVRegPoint(ANCHOR_MIDDLE)
    self.img:SetHRegPoint(ANCHOR_MIDDLE)

    self.currentalpha = 0
    self.alphabaseline = 0
    self.time = 2
    self.dist = 0
    self:Hide() 
    self:UpdateState()
end)

function LivingArtifactOver:UpdateState()
    local player = GetPlayer()
	if player.livingartifact then
		self:TurnOn()
	else
		self:TurnOff()
	end
end

function LivingArtifactOver:TurnOn()
	self.time = 1
	self.alphabaseline = 0.3
	self.dist = 0.3
	self:Show()
    self:StartUpdating()
end

function LivingArtifactOver:TurnOff()
	self.time = 0.3
	self.alphabaseline = 0
    self.dist = 0.3
    self:OnUpdate(0)
end

function LivingArtifactOver:OnUpdate(dt)
	
	local dir = 0
	local target = self.alphabaseline
	if self.alphaspike then
		target = self.alphaspike
	end
	if self.currentalpha ~= target then
		dir = target - self.currentalpha
	end
	if dir > 0 then
		self.currentalpha = math.min(self.currentalpha + (self.dist/(30*self.time)),target)
	else
		self.currentalpha = math.max(self.currentalpha - (self.dist/(30*self.time)),target)
	end
	if self.alphaspike and self.currentalpha == self.alphaspike then
		self.alphaspike = nil
	end

	local r,g,b = 1,1,1

	local player = GetPlayer()
	if player.livingartifact then
		local la = player.livingartifact
		g = Remap(la.timeremaining, la.timemax, 0, 1, 0.1)
		b = Remap(la.timeremaining, la.timemax, 0, 1, 0)
	end
	self.img:SetTint(r,g,b, self.currentalpha)
	if self.currentalpha <= 0 then
		self:Hide()
	else
		self:Show()
	end
end

function LivingArtifactOver:Flash(data)
	self.time = data  and data.time or 0.2
	self.alphaspike = data and data.goal or 0.5   	
	self.dist = math.abs(self.currentalpha - self.alphaspike)	
end

return LivingArtifactOver