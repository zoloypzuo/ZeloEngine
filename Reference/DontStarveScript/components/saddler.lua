--Update inventoryitem_replica constructor if any more properties are added

local function onspeedmult(self, speedmult)
    if self.inst.replica.inventoryitem ~= nil then
        --This network optimization hack is shared by equippable component,
        --so a prefab must not have both components at the same time.
        self.inst.replica.inventoryitem:SetWalkSpeedMult(speedmult)
    end
end

local Saddler = Class(function(self, inst)
    self.inst = inst
    self.swapsymbol = nil
    self.swapbuild = nil

    self.bonusdamage = nil
    self.speedmult = nil
    self.onspeedmult = onspeedmult
end)

function Saddler:CollectUseActions(doer, target, actions, right)
    if target:HasTag("saddleable") then
        table.insert(actions, ACTIONS.SADDLE)
    end
end
    

function Saddler:SetSwaps(build, symbol)
    self.swapbuild = build
    self.swapsymbol = symbol
end

function Saddler:SetBonusDamage(damage)
    self.bonusdamage = damage
end

function Saddler:SetBonusSpeedMult(mult)
    self.speedmult = mult
end

function Saddler:GetBonusDamage(target)
    return self.bonusdamage or 0
end

function Saddler:GetBonusSpeedMult()
    return self.speedmult or 1
end

function Saddler:SetDiscardedCallback(cb)
    self.discardedcb = cb
end

return Saddler
