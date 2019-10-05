local Sewing = Class(function(self, inst)
    self.inst = inst
    self.repair_value = 1
end)


function Sewing:DoSewing(target, doer)
	
    if target.components.fueled and target.components.fueled.fueltype == "USAGE" and target.components.fueled:GetPercent() < 1 then	
		
		target.components.fueled:DoDelta(self.repair_value)
		
		if self.inst.components.finiteuses then
			self.inst.components.finiteuses:Use(1)
		end
		
		if self.onsewn then
			self.onsewn(self.inst, target, doer)
		end
		
		return true
	end
	
end

function Sewing:CollectUseActions(doer, target, actions, right)
	--this... should be redone without using the fueled component... it's kind of weird.
    if not target:HasTag("no_sewing") and target.components.fueled and target.components.fueled.fueltype == "USAGE" and target.components.fueled:GetPercent() < 1 then
        table.insert(actions, ACTIONS.SEW)
    end
end

return Sewing
