local Shaver = Class(function(self, inst)
    self.inst = inst
    
end)

function Shaver:CollectInventoryActions(doer, actions)
    if doer.components.beard then
        table.insert(actions, ACTIONS.SHAVE)
    end
end

function Shaver:CollectUseActions(doer, target, actions)
	if not doer.components.rider or not doer.components.rider:IsRiding() then
	    if target.components.beard or target.shaveable then
	        table.insert(actions, ACTIONS.SHAVE)
	    end
	end
end

return Shaver
