require "class"

local Container = Class(function(self, inst)
    self.inst = inst
    self.slots = {}
    self.numslots = 0
    self.canbeopened = true
    self.acceptsstacks = true
    self.side_widget = false
    self.type = "chest"
end)


function Container:NumItems()
    local num = 0
    for k,v in pairs(self.slots) do
        num = num + 1
    end
    
    return num
end

function Container:OnRemoveEntity()
	if self.open then
		local old_opener = self.opener
		if self.opener and self.opener.HUD then
			local opener = self.opener
			self.opener = nil
			opener.HUD:CloseContainer(self.inst)
		end
		self:OnClose(old_opener)
	end
end


function Container:IsFull()
	local items = 0
	for k,v in pairs(self.slots) do
		items = items + 1
end
	
	return items >= self.numslots

end

function Container:IsEmpty()
	for k,v in pairs(self.slots) do
		return false
	end
	
	return true
end


function Container:SetNumSlots(numslots)
    assert(numslots >= self.numslots)
    self.numslots = numslots
end


function Container:DropEverything()
    
    for k = 1,self.numslots do
		local item = self:RemoveItemBySlot(k)
        if item then
			local pos = Vector3(self.inst.Transform:GetWorldPosition())
			item.Transform:SetPosition(pos:Get())
			if item.components.inventoryitem then
				item.components.inventoryitem:OnDropped(true)
			end
			self.inst:PushEvent("dropitem", {item = item})
        end
    end
end

function Container:DropItem(itemtodrop)
    local item = self:RemoveItem(itemtodrop)
    if item then 
        local pos = Vector3(self.inst.Transform:GetWorldPosition())
        item.Transform:SetPosition(pos:Get())
        if item.components.inventoryitem then
            item.components.inventoryitem:OnDropped(true)
        end
        self.inst:PushEvent("dropitem", {item = item})                  
    end
end

function Container:CanTakeItemInSlot(item, slot)
	if not (item and item.components.inventoryitem and item.components.inventoryitem.cangoincontainer) then
		return false
	end
	
	if self.itemtestfn then
		return self.itemtestfn(self.inst, item, slot)
	end

	return true
end

function Container:DestroyContents()
	for k = 1,self.numslots do
		local item = self:RemoveItemBySlot(k)
		if item then
			item:Remove()
		end		
	end
end

function Container:GiveItem(item, slot, src_pos, drop_on_fail, skipsound)
    drop_on_fail = drop_on_fail == nil and true or drop_on_fail
    --print("Container:GiveItem", item.prefab)
    if item and item.components.inventoryitem and self:CanTakeItemInSlot(item, slot) then
		
		--try to burn off stacks if we're just dumping it in there
		if item.components.stackable and slot == nil and self.acceptsstacks then
            for k = 1,self.numslots do
				local other_item = self.slots[k]
				if other_item and other_item.prefab == item.prefab and not other_item.components.stackable:IsFull() then
					
					if self.inst.components.inventoryitem and self.inst.components.inventoryitem.owner and not skipsound then
						self.inst.components.inventoryitem.owner:PushEvent("containergotitem", {item = item, src_pos = src_pos})
					end
					
		            item = other_item.components.stackable:Put(item, src_pos)
		            if not item then
						return true
		            end
				end
            end
		end
		
        local use_slot = slot and slot <= self.numslots and not self.slots[slot]
        local in_slot = nil
        if use_slot then
            in_slot = slot
        elseif self.numslots > 0 then
            for k = 1,self.numslots do
                if not self.slots[k] then
                    in_slot = k
                    break
                end
            end
        end
        
        if in_slot then

			--weird case where we are trying to force a stack into a non-stacking container. this should probably have been handled earlier, but this is a failsafe        
			if item.components.stackable and item.components.stackable:StackSize() > 1 and not self.acceptsstacks then
				item = item.components.stackable:Get()
				self.slots[in_slot] = item
				item.components.inventoryitem:OnPutInInventory(self.inst)
				self.inst:PushEvent("itemget", {slot = in_slot, item = item, src_pos = src_pos})	
				return false
			end
			
			self.slots[in_slot] = item
			item.components.inventoryitem:OnPutInInventory(self.inst)
			self.inst:PushEvent("itemget", {slot = in_slot, item = item, src_pos = src_pos})
			
			if self.inst.components.inventoryitem and self.inst.components.inventoryitem.owner and not skipsound then
				self.inst.components.inventoryitem.owner:PushEvent("containergotitem", {item = item, src_pos = src_pos})
			end
			
			return true
        else
            if drop_on_fail then
				item.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
				if item.components.inventoryitem then
	                item.components.inventoryitem:OnDropped(true)
				end
			end				
            return false
        end
        
    end
end


function Container:RemoveItemBySlot(slot)
    if slot and self.slots[slot] then
        local item = self.slots[slot]
        if item then
			self.slots[slot] = nil
			if item.components.inventoryitem then
				item.components.inventoryitem:OnRemoved()
			end
			
			self.inst:PushEvent("itemlose", {slot = slot})
		end
        item.prevcontainer = self
        item.prevslot = slot
        return item
        
    end
end

function Container:GetNumSlots()
    return self.numslots
end

function Container:GetItemInSlot(slot)
    if slot and self.slots[slot] then
        return self.slots[slot]
    end
end

function Container:GetItemSlot(item)
    for k,v in pairs(self.slots) do
        if item == v then
            return k
        end
    end
end


function Container:Close()
	
	if self.open then
		local old_opener = self.opener
		if self.opener and self.opener.HUD then
			local opener = self.opener
			self.opener = nil
			opener.HUD:CloseContainer(self.inst)
		end
		self:OnClose(old_opener)
	end
end

function Container:Open(doer)
	self.opener = doer
	if not self.open then
		if doer and doer.HUD then
			doer.HUD:OpenContainer(self.inst, self.side_widget)
		end

		self:OnOpen()
	end
end

function Container:OnOpen()
    self.open = true
    
	if self.opener and self.opener.components.inventory then
		self.opener.components.inventory.opencontainers[self.inst] = true
	end
    
    self.inst:PushEvent("onopen", {doer = self.opener})    
    if self.onopenfn then
        self.onopenfn(self.inst)
    end
end

function Container:IsOpen()
	return self.open
end

function Container:OnClose(old_opener)
   	if old_opener and old_opener.components.inventory then
   		old_opener.components.inventory.opencontainers[self.inst] = nil
   	end
        
    if self.open then
        self.open = false
        if self.onclosefn then
            self.onclosefn(self.inst)
        end

        self.inst:PushEvent("onclose")
    end
end

function Container:CollectSceneActions(doer, actions, right)
    if self.inst:HasTag("bundle") then
        if right and self:IsOpenedBy(doer) then
	        table.insert(actions, ACTIONS.WRAPBUNDLE)
		end
	elseif doer.components.inventory and self.canbeopened then
        table.insert(actions, ACTIONS.RUMMAGE)
    end
end

function Container:CollectInventoryActions(doer, actions)
    if doer.components.inventory and self.canbeopened then
        if not (self.side_widget and TheInput:ControllerAttached()) then
            table.insert(actions, ACTIONS.RUMMAGE)
        end
    end
end

function Container:FindItem(fn)
    for k,v in pairs(self.slots) do
        if fn(v) then
            return v
        end
    end
end

function Container:FindItems(fn)
    local items = {}
    
    for k,v in pairs(self.slots) do
        if fn(v) then
            table.insert(items, v)
        end
    end

    return items
end

function Container:Has(item, amount)
    local num_found = 0
    for k,v in pairs(self.slots) do
        if v and v.prefab == item then
        	if v.components.stackable ~= nil then
        		num_found = num_found + v.components.stackable:StackSize()
        	else
            	num_found = num_found + 1
            end
        end
    end
    
    return num_found >= amount, num_found
end



function Container:ConsumeByName(item, amount)
    
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
    

    for k,v in pairs(self.slots) do
        total_num_found = total_num_found + tryconsume(v)
        
        if total_num_found >= amount then
            break
        end
    end
end

function Container:OnSave()
    local data = {items= {}}
    for k,v in pairs(self.slots) do
        if v:IsValid() then --only save the valid items
			data.items[k] = v:GetSaveRecord()
		end
    end
    
    return data
end   

function Container:OnLoad(data, newents)
    if data.items then
        for k,v in pairs(data.items) do
            local inst = SpawnSaveRecord(v, newents)
            if inst then
                self:GiveItem(inst, k)
            end
        end
    end
end



function Container:RemoveItem(item, wholestack)
    local dec_stack = not wholestack and item and item.components.stackable and item.components.stackable:IsStack() and item.components.stackable:StackSize() > 1
	local slot = self:GetItemSlot(item)
    if dec_stack then
        local dec = item.components.stackable:Get()
        dec.prevslot = slot
        dec.prevcontainer = self
        return dec
    else
        for k,v in pairs(self.slots) do
            if v == item then
                self.slots[k] = nil
                self.inst:PushEvent("itemlose", {slot = k})
                
                if item.components.inventoryitem then
                    item.components.inventoryitem:OnRemoved()
                end
                
		        item.prevslot = slot
		        item.prevcontainer = self
                return item
            end
        end
    end
    
    return item

end

function Container:IsOpenedBy(guy)
    return self.opener == guy
end


return Container

