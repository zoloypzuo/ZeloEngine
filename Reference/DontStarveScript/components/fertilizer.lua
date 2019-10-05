local Fertilizer = Class(function(self, inst)
    self.inst = inst
    self.fertilizervalue = 1
    self.soil_cycles = 1
end)

function Fertilizer:CollectUseActions(doer, target, actions)
    if target.components.crop and not target.components.crop:IsReadyForHarvest() then
        table.insert(actions, ACTIONS.FERTILIZE)
    elseif target.components.grower and target.components.grower:IsEmpty() and not target.components.grower:IsFullFertile() then
        table.insert(actions, ACTIONS.FERTILIZE)
    elseif target.components.pickable and target.components.pickable:CanBeFertilized() then
        table.insert(actions, ACTIONS.FERTILIZE)
    end
    
end


return Fertilizer