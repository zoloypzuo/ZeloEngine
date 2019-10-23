local Stackable = Class(function(self, inst)
    self.inst = inst
    self.stacksize = 1 -- Its a stack of one (ie the first item)
    self.maxsize = TUNING.STACK_SIZE_MEDITEM
end)

function Stackable:IsStack()
    return self.stacksize > 1
end

function Stackable:StackSize()
    return self.stacksize
end

function Stackable:IsFull()
    return self.stacksize < self.maxsize
end

function Stackable:OnSave()
    if self.stacksize ~= 1 then
        return { stack = self.stacksize }
    end
end

function Stackable:OnLoad(data)
    self.stacksize = data.stack or self.stacksize
    self.inst:PushEvent("stacksizechange", { stacksize = self.stacksize, oldstacksize = 1 })

    --CLEARS BROKEN STACKS
    if self.stacksize < 1 then
        print("CAUTION: Found a stack size < 1 and removed it.")
        self.inst:Remove()
    end
end

function Stackable:SetOnDeStack(fn)
    self.ondestack = fn
end

function Stackable:SetStackSize(sz)
    local old_size = self.stacksize
    self.stacksize = sz
    self.inst:PushEvent("stacksizechange", { stacksize = sz, oldstacksize = old_size })
end

function Stackable:Get(num)
    local num_to_get = num or 1
    -- If we have more than one item in the stack
    if self.stacksize > num_to_get then
        local instance = SpawnPrefab(self.inst.prefab)

        self:SetStackSize(self.stacksize - num_to_get)
        instance.components.stackable:SetStackSize(num_to_get)

        if self.ondestack then
            self.ondestack(instance)
        end

        if instance.components.perishable then
            instance.components.perishable.perishremainingtime = self.inst.components.perishable.perishremainingtime
        end

        return instance
    end

    return self.inst
end

function Stackable:RoomLeft()
    return self.maxsize - self.stacksize
end

function Stackable:IsFull()
    return self.stacksize >= self.maxsize
end

function Stackable:Put(item, source_pos)
    assert(item ~= self, "cant stack on self")
    local ret
    if item.prefab == self.inst.prefab then

        local num_to_add = item.components.stackable.stacksize
        local newtotal = self.stacksize + num_to_add

        local oldsize = self.stacksize
        local newsize = math.min(self.maxsize, newtotal)
        local numberadded = newsize - oldsize
        if self.maxsize >= newtotal then
            if self.inst.components.perishable then
                self.inst.components.perishable:Dilute(numberadded, item.components.perishable.perishremainingtime)
            end
            item:Remove()
        else
            if self.inst.components.perishable then
                self.inst.components.perishable:Dilute(numberadded, item.components.perishable.perishremainingtime)
            end
            item.components.stackable.stacksize = newtotal - self.maxsize
            item:PushEvent("stacksizechange", { stacksize = item.components.stackable.stacksize, oldstacksize = num_to_add, src_pos = source_pos })
            ret = item
        end

        self.stacksize = newsize
        self.inst:PushEvent("stacksizechange", { stacksize = self.stacksize, oldstacksize = oldsize, src_pos = source_pos })
    end
    return ret
end

function Stackable:CollectUseActions(doer, target, actions)
    if target and target.components.inventoryitem and not target.components.inventoryitem:IsHeld() and target.components.stackable
            and not target.components.stackable:IsFull() and target.prefab == self.inst.prefab and target.components.inventoryitem.canbepickedup then
        table.insert(actions, ACTIONS.COMBINESTACK)
    end
end

return Stackable