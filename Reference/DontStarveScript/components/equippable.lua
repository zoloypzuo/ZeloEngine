local Equippable = Class(function(self, inst)
    self.inst = inst
    self.isequipped = false
    self.equipslot = EQUIPSLOTS.HANDS
    self.onequipfn = nil
    self.onunequipfn = nil
    self.onpocketfn = nil
    self.equipstack = false
end)

function Equippable:SetOnEquip(fn)
    self.onequipfn = fn
end

function Equippable:SetOnPocket(fn)
    self.onpocketfn = fn
end

function Equippable:SetOnUnequip(fn)
    self.onunequipfn = fn
end

function Equippable:IsEquipped()
    return self.isequipped
end

function Equippable:Equip(owner, slot)
    self.isequipped = true
    
    if self.onequipfn then
        self.onequipfn(self.inst, owner)
    end
    self.inst:PushEvent("equipped", {owner=owner, slot=slot})
    self.owner = owner
end

function Equippable:ToPocket(owner)
    if self.onpocketfn then
        self.onpocketfn(self.inst, owner)
    end

end

function Equippable:Unequip(owner, slot)
    self.isequipped = false
    
    if self.onunequipfn then
        self.onunequipfn(self.inst, owner)
    end
    
    self.inst:PushEvent("unequipped", {owner=owner, slot=slot})
    self.owner = nil
end

function Equippable:GetWalkSpeedMult()
	return self.walkspeedmult or 1.0
end

function Equippable:CollectInventoryActions(doer, actions)
    if not self.isequipped then
        table.insert(actions, ACTIONS.EQUIP)
    else
        table.insert(actions, ACTIONS.UNEQUIP)
    end
end

return Equippable