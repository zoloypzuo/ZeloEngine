local Dryable = Class(function(self, inst)
    self.inst = inst
    self.product = nil
    self.drytime = nil
end)

function Dryable:SetProduct(product)
    self.product = product
end

function Dryable:GetProduct()
    return self.product
end

function Dryable:GetDryingTime()
    return self.drytime
end

function Dryable:SetDryTime(time)
    self.drytime = time
end

function Dryable:CollectUseActions(doer, target, actions)
    if target.components.dryer and target.components.dryer:CanDry(self.inst) then
        table.insert(actions, ACTIONS.DRY)
    end
end

return Dryable