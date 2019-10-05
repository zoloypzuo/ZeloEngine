local function DoDry(inst)
    local dryer = inst.components.dryer
    if dryer then
	    dryer.task = nil
    	
	    if dryer.ondonecooking then
		    dryer.ondonecooking(inst, dryer.product)
	    end	    
	    dryer.ingredient = nil
    end
end

local Dryer = Class(function(self, inst)
    self.inst = inst
    self.targettime = nil
    self.ingredient = nil
    self.product = nil
    self.onstartcooking = nil
    self.oncontinuecooking = nil
    self.ondonecooking = nil
    self.oncontinuedone = nil
    self.onharvest = nil
end)

function Dryer:SetStartDryingFn(fn)
    self.onstartcooking = fn
end

function Dryer:SetContinueDryingFn(fn)
    self.oncontinuecooking = fn
end

function Dryer:SetDoneDryingFn(fn)
    self.ondonecooking = fn
end

function Dryer:SetContinueDoneFn(fn)
    self.oncontinuedone = fn
end

function Dryer:SetOnHarvestFn(fn)
    self.onharvest = fn
end

function Dryer:GetTimeToDry()
	if self.targettime then
		return self.targettime - GetTime()
	end
	return 0
end

function Dryer:IsDrying()
    return self.targettime and self:GetTimeToDry() > 0
end

function Dryer:IsDone()
    return self.product and self.targettime and self:GetTimeToDry() < 0
end

function Dryer:CanDry(dryable)
    return not self:IsDone() and not self:IsDrying()
           and dryable.components.dryable and dryable.components.dryable:GetProduct() and dryable.components.dryable:GetDryingTime()
end

function Dryer:StartDrying(dryable)
	if self:CanDry(dryable) then
	    self.ingredient = dryable.prefab
	    if self.onstartcooking then
		    self.onstartcooking(self.inst, dryable.prefab)
	    end
	    local cooktime = dryable.components.dryable:GetDryingTime()
	    self.product = dryable.components.dryable:GetProduct()
	    self.targettime = GetTime() + cooktime
	    self.task = self.inst:DoTaskInTime(cooktime, DoDry)
	    dryable:Remove()
		return true
	end
end

function Dryer:OnSave()
    
    if self:IsDrying() then
		local data = {}
		data.cooking = true
		data.ingredient = self.ingredient
		data.product = self.product
		data.time = self:GetTimeToDry()
		return data
    elseif self:IsDone() then
		local data = {}
		data.product = self.product
		data.done = true
		return data		
    end
end

function Dryer:OnLoad(data)
    --self.produce = data.produce
    if data.cooking then
		self.product = data.product
		self.ingredient = data.ingredient
		if self.oncontinuecooking then
			self.oncontinuecooking(self.inst, self.ingredient)
			self.targettime = GetTime() + data.time
			self.task = self.inst:DoTaskInTime(data.time, DoDry)
		end
    elseif data.done then
		self.targettime = GetTime() - 1
		self.product = data.product
		if self.oncontinuedone then
			self.oncontinuedone(self.inst, self.product)
		end
    end
end

function Dryer:GetDebugString()
    local str = nil
    
	if self:IsDrying() then 
		str = "COOKING" 
	elseif self:IsDone() then
		str = "FULL"
	else
		str = "EMPTY"
	end
    if self.targettime then
        str = str.." ("..tostring(self.targettime - GetTime())..")"
    end
    
    if self.product then
		str = str.. " ".. self.product
    end
    
	return str
end

function Dryer:CollectSceneActions(doer, actions)
    if self:IsDone() then
        table.insert(actions, ACTIONS.HARVEST)
    end
end


function Dryer:Harvest( harvester )
	if self:IsDone() then
		if self.onharvest then
			self.onharvest(self.inst)
		end
		if self.product then
			if harvester and harvester.components.inventory then
				local loot = SpawnPrefab(self.product)
				if loot then
					if loot and loot.components.perishable then
					    loot.components.perishable:SetPercent(1) --always full perishable
					end
					harvester.components.inventory:GiveItem(loot, nil, Vector3(TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition())))
				end
			end
			self.product = nil
		end
		self.ingredient = nil
		return true
	end
end


function Dryer:LongUpdate(dt)
	if self:IsDrying() then
		if self.task then
			self.task:Cancel()
			self.task = nil
		end

		local time_to_wait = self.targettime - GetTime() - dt
		if time_to_wait <= 0 then
			self.targettime = GetTime()
			DoDry(self.inst)
		else
			self.targettime = GetTime() + time_to_wait
			self.task = self.inst:DoTaskInTime(time_to_wait, DoDry)
		end


	end
end


return Dryer
