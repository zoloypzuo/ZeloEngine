local Dapperness = Class(function(self, inst)
    self.inst = inst
    self.dapperness = 0
end)

function Dapperness:GetDapperness(owner)
	if self.dapperfn then
		return self.dapperfn(self.inst,owner)
	end
	return self.dapperness
end

return Dapperness
