local Unsaddler = Class(function(self, inst)
    -- this is just a marker component
end)

function Unsaddler:CollectUseActions(doer, target, actions, right)
    if not right and target:HasTag("saddled") then
        table.insert(actions, ACTIONS.UNSADDLE)
    end
end

function Unsaddler:CollectEquippedActions(doer, target, actions, right)
    if target:HasTag("saddled") and not right then
        table.insert(actions, ACTIONS.UNSADDLE)
    end	
end

return Unsaddler
