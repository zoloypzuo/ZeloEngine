-- This exists solely to make serializing the ground creep from the map sane, as opposed to
-- insane special case code that lives god knows where

local GroundCreep = Class(function(self, inst)
    self.inst = inst
end)

function GroundCreep:OnSave()
	local data = nil
	if self.inst.GroundCreep then
		data = self.inst.GroundCreep:GetAsString()
	end
	return data
end

function GroundCreep:OnLoad(data)
	if data ~= nil and self.inst.GroundCreep then
		self.inst.GroundCreep:SetFromString(data)
	end
end

return GroundCreep

