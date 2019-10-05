local Widget = require "widgets/widget"
local SanityBadge = require "widgets/sanitybadge"
local HealthBadge = require "widgets/healthbadge"
local HungerBadge = require "widgets/hungerbadge"


local StatusDisplays = Class(Widget, function(self, owner)
    Widget._ctor(self, "Status")
    self.owner = owner

    self.brain = self:AddChild(SanityBadge(owner))
    --self.brain:SetPosition(0,35,0)
    self.brain:SetPosition(0,-40,0)
    self.brain:SetPercent(self.owner.components.sanity:GetPercent(), self.owner.components.sanity.max, self.owner.components.sanity:GetPenaltyPercent())

    self.stomach = self:AddChild(HungerBadge(owner))
    --self.stomach:SetPosition(-38,-32,0)
    self.stomach:SetPosition(-40,20,0)
    self.stomach:SetPercent(self.owner.components.hunger:GetPercent(), self.owner.components.hunger.max)

    self.heart = self:AddChild(HealthBadge(owner))
    --self.heart:SetPosition(38,-32,0)
    self.heart:SetPosition(40,20,0)
    
    self.heart:SetPercent(self.owner.components.health:GetPercent(), self.owner.components.health.maxhealth, self.owner.components.health:GetPenaltyPercent())
    
    self.inst:ListenForEvent("healthdelta", function(inst, data)  self:HealthDelta(data) end, self.owner)
    self.inst:ListenForEvent("hungerdelta", function(inst, data) self:HungerDelta(data) end, self.owner)
    self.inst:ListenForEvent("sanitydelta", function(inst, data) self:SanityDelta(data) end, self.owner)
end)

function StatusDisplays:HealthDelta(data)
	self.heart:SetPercent(data.newpercent, self.owner.components.health.maxhealth,self.owner.components.health:GetPenaltyPercent()) 
	
	if data.oldpercent > .33 and data.newpercent <= .33 then
		self.heart:StartWarning()
	else
		self.heart:StopWarning()
	end
	
	if not data.overtime then
		if data.newpercent > data.oldpercent then
			self.heart:PulseGreen()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_up")
		elseif data.newpercent < data.oldpercent then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_down")
			self.heart:PulseRed()
		end
	end
end

function StatusDisplays:HungerDelta(data)
	self.stomach:SetPercent(data.newpercent, self.owner.components.hunger.max)

	if data.newpercent <= 0 then
		self.stomach:StartWarning()
	else
		self.stomach:StopWarning()
	end
	
	if not data.overtime then
		if data.newpercent > data.oldpercent then
			self.stomach:PulseGreen()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/hunger_up")
		elseif data.newpercent < data.oldpercent then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/hunger_down")
			self.stomach:PulseRed()
		end
	end
	
end

function StatusDisplays:SanityDelta(data)
	self.brain:SetPercent(data.newpercent, self.owner.components.sanity.max, self.owner.components.sanity:GetPenaltyPercent())
	
	
	if self.owner.components.sanity:IsCrazy() then
		self.brain:StartWarning()
	else
		self.brain:StopWarning()
	end
	
	if not data.overtime then
		if data.newpercent > data.oldpercent then
			self.brain:PulseGreen()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_up")
		elseif data.newpercent < data.oldpercent then
			self.brain:PulseRed()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_down")
		end
	end
	
end

return StatusDisplays
