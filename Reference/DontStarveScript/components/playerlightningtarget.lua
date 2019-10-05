local PlayerLightningTarget = Class(function(self, inst)
    self.inst = inst
end)

function PlayerLightningTarget:CanBeHit()

    for k,v in pairs (self.inst.components.inventory.equipslots) do
        if v.components.dapperness and v.components.dapperness.mitigates_rain then
            return false
        end     
    end

    return true
end

return PlayerLightningTarget