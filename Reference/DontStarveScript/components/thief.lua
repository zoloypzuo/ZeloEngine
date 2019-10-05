local Thief = Class(function(self, inst)
    self.inst = inst
    self.stolenitems = {}
    self.onstolen--[[inst, victim, item]] = nil
end)

function Thief:SetOnStolenFn(fn)
    self.onstolen = fn
end

function Thief:StealItem(victim, itemtosteal, attack)
    if victim.components.inventory and not victim.components.inventory.nosteal then
        local item = itemtosteal or victim.components.inventory:FindItem(function(item) return not item:HasTag("nosteal") end)

        if attack then
            self.inst.components.combat:DoAttack(victim)
        end
      
        if item then
            local direction = Vector3(self.inst.Transform:GetWorldPosition()) - Vector3(victim.Transform:GetWorldPosition() )
            victim.components.inventory:DropItem(item, false, direction:GetNormalized())
            table.insert(self.stolenitems, item)
            if self.onstolen then
                self.onstolen(self.inst, victim, item)
            end
        end
    elseif victim.components.container then
        local item = itemtosteal or victim.components.container:FindItem(function(item) return not item:HasTag("nosteal") end)

        if attack then
            if victim.components.equippable and victim.components.inventoryitem and victim.components.inventoryitem.owner  then 
                self.inst.components.combat:DoAttack(victim.components.inventoryitem.owner)
            end
        end

        victim.components.container:DropItem(item)
        table.insert(self.stolenitems, item)
        if self.onstolen then
            self.onstolen(self.inst, victim, item)
        end
    end
end

return Thief