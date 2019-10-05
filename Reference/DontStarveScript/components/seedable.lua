local Seedable = Class(function(self, inst)
    self.inst = inst
    self.growtime = 120
    self.product = nil
    self.minlevel = 1
end)



function Seedable:CollectUseActions(doer, target, actions)
    if target.components.breeder and target.components.breeder:IsEmpty() and not target.components.breeder.seeded then
		if target:HasTag("fishfarm") then
			if self.inst:HasTag("roe") then
				table.insert(actions, ACTIONS.PLANT)
			end
		end		
	end
end


return Seedable
