local Brush = Class(function(self, inst)
    self.inst = inst
end)

function Brush:CollectUseActions(doer, target, actions, right)
    if not right and target:HasTag("brushable") then
        table.insert(actions, ACTIONS.BRUSH)
    end	    
end

function Brush:CollectEquippedActions(doer, target, actions)
    if target:HasTag("brushable") then
        table.insert(actions, ACTIONS.BRUSH)
    end	    	
end

return Brush
