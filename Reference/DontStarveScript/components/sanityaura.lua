local SanityAura = Class(function(self, inst)
    self.inst = inst
    self.aura = 0
    self.aurafn = nil
    self.penalty = nil
end)

function SanityAura:GetAura(observer)
	if self.aurafn then
		return self.aurafn(self.inst, observer)
	end
	return self.aura
end

return SanityAura
