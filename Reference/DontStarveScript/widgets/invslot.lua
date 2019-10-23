local ItemSlot = require "widgets/itemslot"

local InvSlot = Class(ItemSlot, function(self, num, atlas, bgim, owner, container)
    ItemSlot._ctor(self, atlas, bgim, owner)
    self.owner = owner
    self.container = container
    self.num = num
end)

function InvSlot:GetSlotNum()
    if self.tile and self.tile.item then
        return self.tile.item.components.inventoryitem:GetSlotNum()
    end
end

function InvSlot:OnControl(control, down)
    if InvSlot._base.OnControl(self, control, down) then
        return true
    end
    if down then
        if control == CONTROL_ACCEPT then
            --generic click, with possible modifiers
            if TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) then
                self:Inspect()
            else
                if TheInput:IsControlPressed(CONTROL_FORCE_TRADE) then
                    self:TradeItem(TheInput:IsControlPressed(CONTROL_FORCE_STACK))
                else
                    self:Click(TheInput:IsControlPressed(CONTROL_FORCE_STACK))
                end
            end

        elseif control == CONTROL_SECONDARY and self.tile and self.tile.item then
            --alt use (usually RMB)
            GetPlayer().components.inventory:UseItemFromInvTile(self.tile.item)

            --  the rest are explicit control presses for controllers
        elseif control == CONTROL_SPLITSTACK then
            self:Click(true)
        elseif control == CONTROL_TRADEITEM then
            self:TradeItem(false)
        elseif control == CONTROL_TRADESTACK then
            self:TradeItem(true)
        elseif control == CONTROL_INSPECT then
            self:Inspect()
        else
            return false
        end
        return true
    end


end

function InvSlot:Click(stack_mod)
    local character = GetPlayer()
    local active_item = GetPlayer().components.inventory:GetActiveItem()
    local slot_number = self.num
    local container = self.container
    local inventory = character.components.inventory
    local container_item = container:GetItemInSlot(slot_number)

    local can_take_active_item = active_item and (not container.CanTakeItemInSlot or container:CanTakeItemInSlot(active_item, slot_number))
    if active_item and not container_item then

        if can_take_active_item then

            if active_item.components.stackable and active_item.components.stackable:StackSize() > 1 and (stack_mod or not container.acceptsstacks) then
                container:GiveItem(active_item.components.stackable:Get(), slot_number, nil, true)
            else
                inventory:RemoveItem(active_item, true)
                container:GiveItem(active_item, slot_number, nil, true, true)
            end

            character.SoundEmitter:PlaySound("dontstarve/HUD/click_object")

        else
            character.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
        end

    elseif container_item and not active_item then

        if stack_mod and container_item.components.stackable and container_item.components.stackable:StackSize() > 1 then
            inventory:GiveActiveItem(container_item.components.stackable:Get(math.floor(container_item.components.stackable:StackSize() / 2)))
        else
            container:RemoveItemBySlot(slot_number)
            inventory:GiveActiveItem(container_item)
        end

        character.SoundEmitter:PlaySound("dontstarve/HUD/click_object")

    elseif container_item and active_item then
        if can_take_active_item then
            local same_prefab = container_item and active_item and container_item.prefab == active_item.prefab
            local stacked = same_prefab and container_item.components.stackable and container.acceptsstacks
            if stacked then
                if stack_mod and active_item.components.stackable.stacksize > 1 and not container_item.components.stackable:IsFull() then
                    container_item.components.stackable:Put(active_item.components.stackable:Get())
                else
                    local leftovers = container_item.components.stackable:Put(active_item)
                    inventory:SetActiveItem(leftovers)
                end
            else
                local cant_trade_stack = not container.acceptsstacks and (active_item.components.stackable and active_item.components.stackable:StackSize() > 1)

                if not cant_trade_stack then
                    inventory:RemoveItem(active_item, true)
                    container:RemoveItemBySlot(slot_number)
                    inventory:GiveActiveItem(container_item)
                    container:GiveItem(active_item, slot_number, nil, true, true)
                end
            end

            character.SoundEmitter:PlaySound("dontstarve/HUD/click_object")

        else
            character.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
        end
    end
end


--moves items between open containers
function InvSlot:TradeItem(stack_mod)
    local character = GetPlayer()
    local active_item = GetPlayer().components.inventory:GetActiveItem()
    local slot_number = self.num
    local container = self.container
    local inventory = character.components.inventory
    local container_item = container:GetItemInSlot(slot_number)

    if character and inventory and container_item then
        --find our destination container
        local dest_inst = container ~= inventory and character or nil
        for k, v in pairs(inventory.opencontainers) do
            if k ~= container.inst and (not dest_inst or not k.components.equippable) then
                local dest = k.components.inventory or k.components.container
                if dest then
                    if dest:CanTakeItemInSlot(container_item) then
                        if dest:IsFull() and dest.acceptsstacks then
                            --check the container to see if an item of that type is in it already and can be put in.
                            for c, v in pairs(dest.slots) do
                                if v.prefab == container_item.prefab then
                                    dest_inst = k
                                end
                            end
                        else
                            dest_inst = k
                        end
                    end
                end
            end
        end


        --if a destination container/inv is found...
        if dest_inst then
            local dest = dest_inst.components.inventory or dest_inst.components.container
            if dest then
                local item = nil

                --take either the item or half of its stack
                if container_item.components.stackable and stack_mod then
                    item = container_item.components.stackable:Get(math.floor(container_item.components.stackable:StackSize() / 2))
                    if item.components.stackable.stacksize < 1 then
                        item = nil
                        return
                    end
                else
                    item = container:RemoveItemBySlot(slot_number)
                end

                --and give it to the dest object
                item.prevcontainer = nil
                if not dest:GiveItem(item) then
                    container:GiveItem(item, slot_number, nil, true)
                end
                return
            end
        end
    end
end

return InvSlot
