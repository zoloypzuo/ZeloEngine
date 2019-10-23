local MAXSLOTS = 15

local Inventory = Class(function(self, inst)
    self.inst = inst

    self.itemslots = {}
    self.maxslots = MAXSLOTS

    self.recipes = {}
    self.recipe_count = 0

    self.equipslots = {}
    self.dropondeath = true
    inst:ListenForEvent("death", function()
        if self.dropondeath then
            self:DropEverything(true)
        end
    end)

    self.activeitem = nil
    self.acceptsstacks = true
    self.ignorescangoincontainer = false
    self.opencontainers = {}

end)

function Inventory:NumItems()
    local num = 0
    for k, v in pairs(self.itemslots) do
        num = num + 1
    end

    return num
end

function Inventory:GuaranteeItems(items)

    self.inst:DoTaskInTime(0, function()


        for k, v in pairs(items) do
            local item = v

            local equipped = false
            for k, v in pairs(self.equipslots) do
                if v and v.prefab == item then
                    equipped = true
                end
            end

            if equipped or self:Has(item, 1) then
                for k, v in pairs(Ents) do
                    if v.prefab == item and v.components.inventoryitem:GetGrandOwner() ~= GetPlayer() then
                        v:Remove()
                    end
                end
            else
                for k, v in pairs(Ents) do
                    if v.prefab == item then
                        item = nil
                        break
                    end
                end
                if item then
                    self:GiveItem(SpawnPrefab(item))
                end
            end
        end
    end)

end

function Inventory:OnSave()
    local data = { items = {}, equip = {} }

    for k, v in pairs(self.itemslots) do
        if v.persists then
            data.items[k] = v:GetSaveRecord()
        end
    end

    for k, v in pairs(self.equipslots) do
        if v.persists then
            data.equip[k] = v:GetSaveRecord()
        end
    end

    if self.activeitem and not (self.activeitem.components.equippable and self.equipslots[self.activeitem.components.equippable.equipslot] == self.activeitem) then
        data.activeitem = self.activeitem:GetSaveRecord()
    end

    return data
end

function Inventory:CanTakeItemInSlot(item, slot)

    if not (item and item.components.inventoryitem and (item.components.inventoryitem.cangoincontainer or self.ignorescangoincontainer)) then
        return false
    end

    return item and item.components.inventoryitem ~= nil
end

function Inventory:OnLoad(data, newents)
    if data.items then
        for k, v in pairs(data.items) do
            local inst = SpawnSaveRecord(v, newents)
            if inst then
                self:GiveItem(inst, k)
            end
        end
    end

    if data.equip then
        for k, v in pairs(data.equip) do
            local inst = SpawnSaveRecord(v, newents)
            if inst then
                self:Equip(inst)
            end
        end
    end

    if data.activeitem then
        local inst = SpawnSaveRecord(data.activeitem, newents)
        if inst then
            self:GiveItem(inst)
        end
    end

end

function Inventory:DropActiveItem()
    if self.activeitem then
        self:DropItem(self.activeitem)
        self:SetActiveItem(nil)
    end

end

function Inventory:IsWearingArmor()
    for k, v in pairs(self.equipslots) do
        if v.components.armor then
            return true
        end
    end
end

function Inventory:ArmorHasTag(tag)
    for k, v in pairs(self.equipslots) do
        if v.components.armor and v:HasTag(tag) then
            return true
        end
    end
end

function Inventory:ApplyDamage(damage, attacker, weapon)
    --check resistance
    for k, v in pairs(self.equipslots) do
        if v.components.resistance and v.components.resistance:HasResistance(attacker, weapon) then
            return 0
        end
    end
    --check specialised armor
    for k, v in pairs(self.equipslots) do
        if v.components.armor and v.components.armor.tags then
            damage = v.components.armor:TakeDamage(damage, attacker, weapon)
            if damage <= 0 then
                return 0
            end
        end
    end
    --check general armor
    for k, v in pairs(self.equipslots) do
        if v.components.armor then
            damage = v.components.armor:TakeDamage(damage, attacker, weapon)
            if damage <= 0 then
                return 0
            end
        end
    end

    return damage
end

function Inventory:GetActiveItem()
    return self.activeitem
end

function Inventory:IsItemEquipped(item)
    for k, v in pairs(self.equipslots) do
        if v == item then
            return k
        end
    end
end

function Inventory:SelectActiveItemFromEquipSlot(slot)
    if self.equipslots[slot] then
        local olditem = self.activeitem
        local newitem = self:Unequip(slot)
        self:SetActiveItem(newitem)

        if olditem and not self:IsItemEquipped(olditem) then
            self:GiveItem(olditem)
        end
    end

    return self.activeitem
end

function Inventory:CombineActiveStackWithSlot(slot, stack_mod)
    if not self.itemslots[slot] and not self.equipslots[slot] then
        return
    end

    local handitem = self.activeitem
    local invitem = self.itemslots[slot] or self.equipslots[slot]

    if handitem and invitem and handitem.prefab == invitem.prefab and handitem.components.stackable then

        if stack_mod and handitem.components.stackable.stacksize > 1 then
            handitem.components.stackable:SetStackSize(handitem.components.stackable.stacksize - 1)
            invitem.components.stackable:SetStackSize(invitem.components.stackable.stacksize + 1)
        else
            local leftovers = invitem.components.stackable:Put(handitem)
            self:SetActiveItem(leftovers)
        end
    end
end

function Inventory:SelectActiveItemFromSlot(slot)
    if not self.itemslots[slot] then
        return
    end

    local olditem = self.activeitem
    local newitem = self.itemslots[slot]
    self.itemslots[slot] = nil
    self.inst:PushEvent("itemlose", { slot = slot })

    self:SetActiveItem(newitem)

    if olditem then
        self:GiveItem(olditem, slot)
    end

    return self.activeitem
end

function Inventory:ReturnActiveItem(slot, stack_mod)
    if self.activeitem then
        if stack_mod and self.activeitem.components.stackable and self.activeitem.components.stackable.stacksize > 1 then
            local item = self.activeitem.components.stackable:Get()
            if not self:GiveItem(item, slot) then
                self:DropItem(item)
            end
        else
            if not self:GiveItem(self.activeitem, slot) then
                self:DropItem(self.activeitem)
            end

            self:SetActiveItem(nil)
        end
    end
end

function Inventory:GetNumSlots()
    return self.maxslots
end

function Inventory:GetItemSlot(item)
    for k, v in pairs(self.itemslots) do
        if item == v then
            return k
        end
    end
end

function Inventory:FindItem(fn)
    for k, v in pairs(self.itemslots) do
        if fn(v) then
            return v
        end
    end

    if self.activeitem and fn(self.activeitem) then
        return self.activeitem
    end

    if self.overflow then
        return self.overflow.components.container:FindItem(fn)
    end
end

function Inventory:FindItems(fn)
    local items = {}

    for k, v in pairs(self.itemslots) do
        if fn(v) then
            table.insert(items, v)
        end
    end

    if self.activeitem and fn(self.activeitem) then
        table.insert(items, self.activeitem)
    end

    local overflow_items = {}

    if self.overflow then
        overflow_items = self.overflow.components.container:FindItems(fn)
    end

    if #overflow_items > 0 then
        for k, v in pairs(overflow_items) do
            table.insert(items, v)
        end
    end

    return items
end

function Inventory:RemoveItemBySlot(slot)
    if slot and self.itemslots[slot] then
        local item = self.itemslots[slot]
        self:RemoveItem(item, true)
        return item
    end
end

function Inventory:DropItem(item, wholestack, randomdir, pos)
    if not item or not item.components.inventoryitem then
        return
    end

    local dropped = item.components.inventoryitem:RemoveFromOwner(wholestack) or item

    if dropped then
        pos = pos or Vector3(self.inst.Transform:GetWorldPosition())
        --print("Inventory:DropItem", item, pos)
        dropped.Transform:SetPosition(pos:Get())

        if dropped.components.inventoryitem then
            dropped.components.inventoryitem:OnDropped(randomdir)
        end

        self.inst:PushEvent("dropitem", { item = dropped })
    end

    return dropped
end

function Inventory:GetEquippedItem(eslot)
    return self.equipslots[eslot]
end

function Inventory:GetItemInSlot(slot)
    return self.itemslots[slot]
end

function Inventory:IsFull()
    for k = 1, self.maxslots do
        if not self.itemslots[k] then
            return false
        end
    end

    return true
end

function Inventory:SetOverflow(over)
    self.overflow = over
    self.inst:PushEvent("setoverflow", { overflow = over })
end

---Returns the slot, and the container where the slot is (self.itemslots, self.equipslots or self.overflow)
function Inventory:GetNextAvailableSlot(item)

    local prefabname = nil
    if item.components.stackable ~= nil then
        prefabname = item.prefab

        --check for stacks that aren't full
        for k, v in pairs(self.equipslots) do
            if v.prefab == prefabname and v.components.equippable.equipstack and v.components.stackable and not v.components.stackable:IsFull() then
                return k, self.equipslots
            end
        end
        for k, v in pairs(self.itemslots) do
            if v.prefab == prefabname and v.components.stackable and not v.components.stackable:IsFull() then
                return k, self.itemslots
            end
        end
        if self.overflow and self.overflow.components.container then
            for k, v in pairs(self.overflow.components.container.slots) do
                if v.prefab == prefabname and v.components.stackable and not v.components.stackable:IsFull() then
                    return k, self.overflow
                end
            end
        end
    end

    --check for empty space in the container
    local empty = nil
    for k = 1, self.maxslots do
        if self:CanTakeItemInSlot(item, k) and not self.itemslots[k] then
            if prefabname ~= nil then
                if empty == nil then
                    empty = k
                end
            else
                return k, self.itemslots
            end
        end
    end
    return empty, self.itemslots
end

function Inventory:GiveActiveItem(inst)
    if inst and inst:IsValid() then
        self:ReturnActiveItem()
        assert(inst.components.inventoryitem, inst.entity:GetPrefabName() .. " in inventory is lacking inventoryitem component")
        if not inst.components.inventoryitem:OnPickup(self.inst) then
            inst.components.inventoryitem:OnPutInInventory(self.inst)

            self:SetActiveItem(inst)
            self.inst:PushEvent("itemget", { item = inst, slot = nil })

            if inst.components.equippable then
                inst.components.equippable:ToPocket()
            end
        end
    end
end

function Inventory:GiveItem(inst, slot, screen_src_pos, skipsound)
    --print("Inventory:GiveItem", inst, slot, screen_src_pos)

    if not inst.components.inventoryitem or not inst:IsValid() then
        return
    end

    local eslot = self:IsItemEquipped(inst)

    if eslot then
        self:Unequip(eslot)
    end

    local new_item = inst ~= self.activeitem
    if new_item then
        for k, v in pairs(self.equipslots) do
            if v == inst then
                new_item = false
                break
            end
        end
    end

    if inst.components.inventoryitem.owner and inst.components.inventoryitem.owner ~= self.inst then
        inst.components.inventoryitem:RemoveFromOwner(true)
    end

    local objectDestroyed = inst.components.inventoryitem:OnPickup(self.inst)
    if objectDestroyed then
        return
    end

    local can_use_suggested_slot = false

    if not slot and inst.prevslot and not inst.prevcontainer then
        slot = inst.prevslot
    end

    if not slot and inst.prevslot and inst.prevcontainer then
        if inst.prevcontainer.inst.components.inventoryitem and inst.prevcontainer.inst.components.inventoryitem.owner == self.inst and inst.prevcontainer:IsOpen() and inst.prevcontainer:GetItemInSlot(inst.prevslot) == nil then
            if inst.prevcontainer:GiveItem(inst, inst.prevslot, false) then
                return true
            else
                inst.prevcontainer = nil
                inst.prevslot = nil
                slot = nil
            end
        end
    end

    if slot then
        local olditem = self:GetItemInSlot(slot)
        can_use_suggested_slot = slot ~= nil and slot <= self.maxslots and (olditem == nil or (olditem and olditem.components.stackable and olditem.prefab == inst.prefab)) and self:CanTakeItemInSlot(inst, slot)
    end

    local container = self.itemslots
    if not can_use_suggested_slot then
        slot, container = self:GetNextAvailableSlot(inst)
    end

    if slot then
        if new_item and not skipsound then
            self.inst:PushEvent("gotnewitem", { item = inst, slot = slot })
        end

        local leftovers = nil
        if container == self.overflow and self.overflow and self.overflow.components.container then
            local itemInSlot = self.overflow.components.container:GetItemInSlot(slot)
            if itemInSlot then
                leftovers = itemInSlot.components.stackable:Put(inst, screen_src_pos)
            end
        elseif container == self.equipslots then
            if self.equipslots[slot] then
                leftovers = self.equipslots[slot].components.stackable:Put(inst, screen_src_pos)
            end
        else
            if self.itemslots[slot] ~= nil then
                if self.itemslots[slot].components.stackable:IsFull() then
                    leftovers = inst
                    inst.prevslot = nil
                else
                    leftovers = self.itemslots[slot].components.stackable:Put(inst, screen_src_pos)
                end
            else
                inst.components.inventoryitem:OnPutInInventory(self.inst)
                self.itemslots[slot] = inst
                self.inst:PushEvent("itemget", { item = inst, slot = slot, src_pos = screen_src_pos })
            end

            if inst.components.equippable then
                inst.components.equippable:ToPocket()
            end
        end

        if leftovers then
            self:GiveItem(leftovers)
        end

        return slot
    elseif self.overflow and self.overflow.components.container then
        if self.overflow.components.container:GiveItem(inst, nil, screen_src_pos) then
            return true
        end
    end
    self.inst:PushEvent("inventoryfull", { item = inst })

    --can't hold it!    
    if not self.activeitem and not TheInput:ControllerAttached() then
        --print("not activeitem")
        inst.components.inventoryitem:OnPutInInventory(self.inst)
        self:SetActiveItem(inst)
        return true
    else
        --print("yes activeitem")
        self:DropItem(inst, true, true)
    end

end

function Inventory:Unequip(equipslot)
    local item = self.equipslots[equipslot]
    --print("Inventory:Unequip", item)
    if item and item.components.equippable then
        item.components.equippable:Unequip(self.inst)
    end
    self.equipslots[equipslot] = nil
    self.inst:PushEvent("unequip", { item = item, eslot = equipslot })
    return item
end

function Inventory:SetActiveItem(item)
    if item and item.components.inventoryitem.cangoincontainer or item == nil then
        self.activeitem = item
        self.inst:PushEvent("newactiveitem", { item = item })

        if item and item.components.inventoryitem and item.components.inventoryitem.onactiveitemfn then
            item.components.inventoryitem.onactiveitemfn(item, self.inst)
        end
    else
        self:DropItem(item, true, true)
    end
end

function Inventory:Equip(item, old_to_active)
    if not item or not item.components.equippable or not item:IsValid() then
        return
    end

    -----
    item.prevslot = self:GetItemSlot(item)

    if item.prevslot == nil
            and item.components.inventoryitem.owner
            and item.components.inventoryitem.owner.components.container
            and item.components.inventoryitem.owner.components.inventoryitem then
        item.prevcontainer = item.components.inventoryitem.owner.components.container
        item.prevslot = item.components.inventoryitem.owner.components.container:GetItemSlot(item)
    end
    -----

    if item.components.inventoryitem then
        item = item.components.inventoryitem:RemoveFromOwner(item.components.equippable.equipstack) or item
    else
        item = self:RemoveItem(item, item.components.equippable.equipstack) or item
    end

    local leftovers = nil
    if item == self.activeitem then
        leftovers = self.activeitem
        self:SetActiveItem(nil)
    end

    local eslot = item.components.equippable.equipslot
    if self.equipslots[eslot] ~= item then
        local olditem = self.equipslots[eslot]
        if leftovers then
            if old_to_active then
                self:GiveActiveItem(leftovers)
            else
                self:GiveItem(leftovers)
            end
        end
        if olditem then
            self:Unequip(eslot)
            olditem.components.equippable:ToPocket()
            if olditem.components.inventoryitem and not olditem.components.inventoryitem.cangoincontainer and not self.ignorescangoincontainer then
                olditem.components.inventoryitem:OnRemoved()
                self:DropItem(olditem)
            else
                if old_to_active then
                    self:GiveActiveItem(olditem)
                else
                    self:GiveItem(olditem)
                end
            end
        end

        item.components.inventoryitem:OnPutInInventory(self.inst)
        item.components.equippable:Equip(self.inst)
        self.equipslots[eslot] = item
        self.inst:PushEvent("equip", { item = item, eslot = eslot })
        if METRICS_ENABLED and item.prefab then
            ProfileStatsAdd("equip_" .. item.prefab)
            FightStat_Equip(item.prefab, eslot)
        end
        return true
    end

end

function Inventory:RemoveItem(item, wholestack)

    local dec_stack = not wholestack and item and item.components.stackable and item.components.stackable:IsStack() and item.components.stackable:StackSize() > 1

    local prevslot = item.components.inventoryitem:GetSlotNum()

    if dec_stack then
        local dec = item.components.stackable:Get()
        dec.prevslot = prevslot
        return dec
    else
        for k, v in pairs(self.itemslots) do
            if v == item then
                self.itemslots[k] = nil
                self.inst:PushEvent("itemlose", { slot = k })

                if item.components.inventoryitem then
                    item.components.inventoryitem:OnRemoved()
                end

                item.prevslot = prevslot
                return item

            end
        end

        local ret = nil
        if item == self.activeitem then
            self:SetActiveItem(nil)
            ret = item
            self.inst:PushEvent("itemlose", { activeitem = true })
        end

        for k, v in pairs(self.equipslots) do
            if v == item then
                self:Unequip(k)
                ret = v
            end
        end

        if ret then
            if ret.components.inventoryitem and ret.components.inventoryitem.OnRemoved then
                ret.components.inventoryitem:OnRemoved()
                ret.prevslot = prevslot
                return ret
            end
        else
            if self.overflow then
                local item = self.overflow.components.container:RemoveItem(item, wholestack)
                item.prevslot = prevslot
                item.prevcontainer = self.overflow.components.container
                return item
            end
        end

    end

    return item

end

function Inventory:Has(item, amount)
    local num_found = 0
    for k, v in pairs(self.itemslots) do
        if v and v.prefab == item then
            if v.components.stackable ~= nil then
                num_found = num_found + v.components.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    if self.activeitem and self.activeitem.prefab == item then
        if self.activeitem.components.stackable ~= nil then
            num_found = num_found + self.activeitem.components.stackable:StackSize()
        else
            num_found = num_found + 1
        end
    end

    if self.overflow then
        local overflow_enough, overflow_found = self.overflow.components.container:Has(item, amount)
        num_found = num_found + overflow_found
    end

    return num_found >= amount, num_found
end

function Inventory:ConsumeByName(item, amount)

    local total_num_found = 0

    local function tryconsume(v)
        local num_found = 0
        if v and v.prefab == item then
            local num_left_to_find = amount - total_num_found

            if v.components.stackable then
                if v.components.stackable.stacksize > num_left_to_find then
                    v.components.stackable:SetStackSize(v.components.stackable.stacksize - num_left_to_find)
                    num_found = amount
                else
                    num_found = num_found + v.components.stackable.stacksize
                    self:RemoveItem(v, true):Remove()
                end
            else
                num_found = num_found + 1
                self:RemoveItem(v):Remove()
            end
        end
        return num_found
    end

    for k = 1, self.maxslots do
        local v = self.itemslots[k]
        total_num_found = total_num_found + tryconsume(v)

        if total_num_found >= amount then
            break
        end
    end

    if self.activeitem and self.activeitem.prefab == item and total_num_found < amount then
        total_num_found = total_num_found + tryconsume(self.activeitem)
    end

    if self.overflow and total_num_found < amount then
        self.overflow.components.container:ConsumeByName(item, (amount - total_num_found))
    end

end

function Inventory:DropEverything(ondeath, keepequip)
    if self.activeitem then
        self:DropItem(self.activeitem)
        self:SetActiveItem(nil)
    end

    for k = 1, self.maxslots do
        local v = self.itemslots[k]
        if v then
            self:DropItem(v, true, true)
        end
    end

    if not keepequip then
        for k, v in pairs(self.equipslots) do
            if not ondeath or not v.components.inventoryitem.keepondeath then
                self:DropItem(v, true, true)
            end
        end
    end
end

function Inventory:BurnNonpotatableInContainer(container)
    for j = 1, container.numslots do
        if container.slots[j] and container.slots[j]:HasTag("nonpotatable") then
            local olditem = container:RemoveItem(container.slots[j], true)
            local itemash = SpawnPrefab("ash")
            itemash.components.named:SetName(olditem.name)
            container:GiveItem(itemash, j)
            olditem:Remove()
        end
    end
end

function Inventory:OnProgress()

    if SaveGameIndex:GetCurrentMode(Settings.save_slot) == "adventure" then
        local teleportato = TheSim:FindFirstEntityWithTag("teleportato")
        if teleportato and teleportato.components.container then
            self:DropEverything()
            for k, v in pairs(teleportato.components.container.slots) do
                local item = teleportato.components.container:RemoveItemBySlot(k)
                self:GiveItem(item)
            end
        end
    else
        for i = 1, self:GetNumSlots() do
            if self.itemslots[i] and self.itemslots[i]:HasTag("nonpotatable") then
                local olditem = self:RemoveItem(self.itemslots[i], true)
                local itemash = SpawnPrefab("ash")
                itemash.components.named:SetName(olditem.name)
                self:GiveItem(itemash, i)
                olditem:Remove()
            elseif self.itemslots[i] and self.itemslots[i].components.container then
                local container = self.itemslots[i].components.container
                self:BurnNonpotatableInContainer(container)
            end
        end
        for k, item in pairs(self.equipslots) do
            if item and item.components.container then
                local container = item.components.container
                self:BurnNonpotatableInContainer(container)
            end
        end
    end
end

function Inventory:GetDebugString()
    local s = ""
    local count = 0
    for k, item in pairs(self.itemslots) do
        count = count + 1
        s = s .. ", " .. (item.prefab or "prefab")
        if item.components.stackable and item.components.stackable.stacksize > 1 then
            s = s .. " x" .. tostring(item.components.stackable.stacksize)
        end
    end

    s = count .. ": " .. s

    return s
end

function Inventory:UseItemFromInvTile(item)
    --local item = self:GetItemInSlot(slot)
    if self.inst.sg:HasStateTag("busy") then
        return
    end

    if item and self.inst.components.playeractionpicker then
        if self:GetActiveItem() then
            --use the active item on the inventory item
            local actions = self.inst.components.playeractionpicker:GetUseItemActions(item, self:GetActiveItem(), true)
            if actions then
                self.inst.components.locomotor:PushAction(actions[1], true)
            end
        else
            --just use the inventory item
            local actions = self.inst.components.playeractionpicker:GetInventoryActions(item)
            if actions then
                self.inst.components.locomotor:PushAction(actions[1], true)
            end
        end
    end
end

function Inventory:EquipHasTag(tag)
    for k, v in pairs(self.equipslots) do
        if v:HasTag(tag) then
            return true
        end
    end
end

return Inventory
