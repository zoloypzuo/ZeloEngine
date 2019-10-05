local Plantable = Class(function(self, inst)
    self.inst = inst
    self.growtime = 120
    self.product = nil
    self.minlevel = 1
end)



function Plantable:CollectUseActions(doer, target, actions)
    if target.components.grower and target.components.grower:IsEmpty() and target.components.grower:IsFertile() and target.components.grower.level >= self.minlevel then		
		table.insert(actions, ACTIONS.PLANT)		
    elseif target.components.growable and target.components.growable:GetCurrentStageData().name == "plantable" then
		table.insert(actions, ACTIONS.PLANTONGROWABLE)
	end
end


return Plantable
