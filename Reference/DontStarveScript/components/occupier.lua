local Occupier = Class(function(self, inst)
    self.inst = inst
end)


function Occupier:CollectUseActions(doer, target, actions)
    if target.components.occupiable and target.components.occupiable:CanOccupy(self.inst) then
        table.insert(actions, ACTIONS.STORE)
    end
end


return Occupier
