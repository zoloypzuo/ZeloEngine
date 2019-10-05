local TransparentOnSanity = Class(function(self, inst)
    self.inst = inst
	self.inst:StartUpdatingComponent(self)
	self.offset = math.random()
	self.osc_speed = .25 + math.random()*2
	self.alpha = .4
	self.most_alpha = .4
end)

function TransparentOnSanity:GetPercent()
	return self.alpha / self.most_alpha
end

function TransparentOnSanity:OnUpdate(dt)
	local player = GetPlayer()
	if player then
		
		
		local alpha = self.most_alpha
		local sanity = player.components.sanity:GetPercent()
		
		local fullvis = 0
		if sanity < fullvis then
			alpha = self.most_alpha
		else
			alpha =  (1 - (sanity - fullvis) / (1-fullvis))*self.most_alpha
		end
	
		
		alpha = alpha* (math.max(.5, math.sin( (GetTime() + self.offset)*self.osc_speed)))
		
		if self.inst.components.combat and self.inst.components.combat.target then
			alpha = self.most_alpha
		end
		
		self.inst.AnimState:SetMultColour(1,1,1,alpha)
		self.alpha = alpha
	end
	
end

return TransparentOnSanity
