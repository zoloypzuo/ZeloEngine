local Tradable = Class(function(self, inst)
    self.inst = inst
    self.goldvalue = 0
end)

function Tradable:CollectUseActions(doer, target, actions)
    if not doer.components.rider or not doer.components.rider:IsRiding() then
        if target.components.trader and target.components.trader.enabled then
            table.insert(actions, ACTIONS.GIVE)
        end
    end
end

return Tradable