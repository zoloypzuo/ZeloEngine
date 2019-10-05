local Perishable = Class(function(self, inst)
    self.inst = inst
    self.perishfn = nil
    self.perishtime = nil
    
    self.targettime = nil
    self.perishremainingtime = nil
    self.updatetask = nil
    self.dt = nil
    self.onperishreplacement = nil
end)



local function Update(inst, dt)
    if inst.components.perishable then
		
		local modifier = 1
		local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner or nil
		if owner then
			if owner:HasTag("fridge") then
				modifier = TUNING.PERISH_FRIDGE_MULT 
			elseif owner:HasTag("spoiler") then
				modifier = TUNING.PERISH_GROUND_MULT 
			end
		else
			modifier = TUNING.PERISH_GROUND_MULT 
		end
		
		if GetSeasonManager() and GetSeasonManager():GetCurrentTemperature() < 0 then
			modifier = modifier * TUNING.PERISH_WINTER_MULT
		end

		modifier = modifier * TUNING.PERISH_GLOBAL_MULT
		
		local old_val = inst.components.perishable.perishremainingtime
		inst.components.perishable.perishremainingtime = inst.components.perishable.perishremainingtime - dt*modifier
        if math.floor(old_val*100) ~= math.floor(inst.components.perishable.perishremainingtime*100) then
	        inst:PushEvent("perishchange", {percent = inst.components.perishable:GetPercent()})
	    end
        
        --trigger the next callback
        if inst.components.perishable.perishremainingtime <= 0 then
			inst.components.perishable:Perish()
        end
    end
end


function Perishable:IsFresh()
	return self:GetPercent() >= .5 
end

function Perishable:IsStale()
	return self:GetPercent() < .5 and self:GetPercent() > .2
end


function Perishable:IsSpoiled()
	return self:GetPercent() <= .2 
end

function Perishable:GetAdjective()
	if self.inst.components.edible then
		if self:IsStale() then
			return STRINGS.UI.HUD.STALE
		elseif self:IsSpoiled() then
			return STRINGS.UI.HUD.SPOILED
		end
	end
end

function Perishable:Dilute(number, timeleft)
	if self.inst.components.stackable then
		self.perishremainingtime = (self.inst.components.stackable.stacksize * self.perishremainingtime + number * timeleft) / ( number + self.inst.components.stackable.stacksize )
		self.inst:PushEvent("perishchange", {percent = self:GetPercent()})
	end
end


function Perishable:SetPerishTime(time)
	self.perishtime = time
	self.perishremainingtime = time
end

function Perishable:SetOnPerishFn(fn)
	self.perishfn = fn
end

function Perishable:GetPercent()
	if self.perishremainingtime and self.perishtime and self.perishtime > 0 then
		return math.min(1, self.perishremainingtime / self.perishtime)
	else
		return 0
	end
end

function Perishable:SetPercent(percent)
	if percent < 0 then percent = 0 end
	if percent > 1 then percent = 1 end
	self.perishremainingtime = percent*self.perishtime
end

function Perishable:ReducePercent(amount)
	local cur = self:GetPercent()
	self:SetPercent(cur - amount)
end

function Perishable:GetDebugString()
	if self.perishremainingtime and  self.perishremainingtime > 0 then
		return string.format("%s %2.2fs", self.updatetask and "Perishing" or "Paused", self.perishremainingtime)
	else
		return "perished"
	end
end


function Perishable:LongUpdate(dt)
	Update(self.inst, dt)
end

function Perishable:StartPerishing()
    
	if self.updatetask then
		self.updatetask:Cancel()
		self.updatetask = nil
	end

    local dt = 10 + math.random()*FRAMES*8--math.max( 4, math.min( self.perishtime / 100, 10)) + ( math.random()* FRAMES * 8)

    if dt > 0 then
        self.updatetask = self.inst:DoPeriodicTask(dt, Update, math.random()*2, dt)
    else
        Update(self.inst, 0)
    end
end

function Perishable:Perish()
    
	if self.updatetask then
		self.updatetask:Cancel()
		self.updatetask = nil
	end
    
    if self.perishfn then
        self.perishfn(self.inst)
    end
    
    if self.onperishreplacement then
		local goop = SpawnPrefab(self.onperishreplacement)
		if goop then
			local owner = self.inst.components.inventoryitem and self.inst.components.inventoryitem.owner or nil
			local pt = Vector3(self.inst.Transform:GetWorldPosition())
			local holder = owner and ( owner.components.inventory or owner.components.container) 
			local slot = holder and holder:GetItemSlot(self.inst)			
			self.inst:Remove()
			if holder then
				holder:GiveItem(goop, slot)
			else
				goop.Transform:SetPosition(pt:Get())
			end
			
			if goop.components.stackable and self.inst.components.stackable then
				goop.components.stackable:SetStackSize(self.inst.components.stackable.stacksize)
			end
		end
    end
end

function Perishable:StopPerishing()
	if self.updatetask then
		self.updatetask:Cancel()
		self.updatetask = nil
	end
end


function Perishable:OnSave()
    local data = {}

    data.paused = self.updatetask == nil
    data.time = self.perishremainingtime

    return data
end   
      
function Perishable:OnLoad(data)

    if data and data.time then
		self.perishremainingtime = data.time
		if not data.paused then
			self:StartPerishing()
		end
    end
end

return Perishable
