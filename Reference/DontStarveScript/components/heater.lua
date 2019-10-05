local Heater = Class(function(self, inst)
    self.inst = inst
    self.heat = 0
    self.heatfn = nil
	self.equippedheat = 0
	self.equippedheatfn = nil
	self.carriedheat = 0
	self.carriedheatfn = nil
	self.iscooler = false
	self.inst.entity:AddTag("HASHEATER")
end)


function Heater:GetHeat(observer)
	if self.heatfn then
		return self.heatfn(self.inst, observer)
	end
	return self.heat
end

function Heater:GetEquippedHeat(observer)
	if self.equippedheatfn then
		return self.equippedheatfn(self.inst, observer)
	end
	return self.equippedheat
end

function Heater:GetCarriedHeat(observer)
	if self.carriedheatfn then
		return self.carriedheatfn(self.inst, observer)
	end
	return self.carriedheat
end

return Heater
