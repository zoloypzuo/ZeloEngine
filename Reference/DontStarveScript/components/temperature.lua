local easing = require("easing")

local Temperature = Class(function(self, inst)
    self.inst = inst
	self.settemp = nil
	self.rate = 0
	self.current = 30
	self.maxtemp = 40
	self.mintemp = -20
	self.hurtrate = TUNING.WILSON_HEALTH / TUNING.FREEZING_KILL_TIME
	self.inherentinsulation = 0
	self:OnUpdate(0)

	self.last_real_delta = 0
	
	self.inst:StartUpdatingComponent(self)
end)

function Temperature:GetCurrent()
	return self.current 
end

function Temperature:OnSave()
	return { current = self.current }
			 
end

function Temperature:SetTemp(temp)
	if temp then
		self.settemp = temp
		local old = self.current 
		self.current = temp
		self.inst:PushEvent("temperaturedelta", {last = old, new = self.current})		
	else
		self.settemp = nil
	end
end

function Temperature:OnProgress()
	self.current = 30
end


function Temperature:OnLoad(data)

	self.current = data.current or self.current
	self:OnUpdate(0)
	
end

function Temperature:SetTemperature(value)
	self.current = value
end

function Temperature:GetDebugString()
    return string.format("%2.2fC at %2.2f (delta: %2.2f)", self:GetCurrent(), self.rate, self.last_real_delta)
end

function Temperature:IsFreezing()
	return self.current < 0
end

function Temperature:OnUpdate(dt, applyhealthdelta)
	
	if self.settemp then return end


	if applyhealthdelta == nil then
		applyhealthdelta = true
	end
	
	if (self.inst.components.health and self.inst.components.health.invincible == true) or self.inst.is_teleporting == true then
		return
	end

    local last = self.current

	local ambient_delta = GetSeasonManager() and (GetSeasonManager():GetCurrentTemperature() - self.current) or 30

	--figure out our insulation
	local total_insulation = 0

	total_insulation = total_insulation + self.inherentinsulation

	if self.inst.components.inventory then
		for k,v in pairs (self.inst.components.inventory.equipslots) do
			if v.components.heater then
				local heat = v.components.heater:GetEquippedHeat()
				if heat > self.current and not v.components.heater.iscooler then
					ambient_delta = ambient_delta + (heat - self.current)
				elseif heat < self.current and v.components.heater.iscooler then
					ambient_delta = ambient_delta + (heat - self.current)
				end
			end
			
			if v.components.insulator then
				total_insulation = total_insulation + v.components.insulator.insulation
			end
		end
		for k,v in pairs(self.inst.components.inventory.itemslots) do
			if v.components.heater then
				local heat = v.components.heater:GetCarriedHeat()
				if heat > self.current and not v.components.heater.iscooler then
					ambient_delta = ambient_delta + (heat - self.current)
				elseif heat < self.current and v.components.heater.iscooler then
					ambient_delta = ambient_delta + (heat - self.current)
				end
			end
		end

		if self.inst.components.inventory.overflow and self.inst.components.inventory.overflow.components.container then
			for k,v in pairs(self.inst.components.inventory.overflow.components.container.slots) do
				if v.components.heater then
					local heat = v.components.heater:GetCarriedHeat()
					if heat > self.current and not v.components.heater.iscooler then
						ambient_delta = ambient_delta + (heat - self.current)
					elseif heat < self.current and v.components.heater.iscooler then
						ambient_delta = ambient_delta + (heat - self.current)
					end
				end
			end
		end
		

	end
	
	if self.inst.components.beard then
		total_insulation = total_insulation + self.inst.components.beard:GetInsulation()
	end

	--now figure out the temperature where we are standing
	local x,y,z = self.inst.Transform:GetWorldPosition()
	
	local ZERO_DISTANCE = 10
	local ZERO_DISTSQ = ZERO_DISTANCE*ZERO_DISTANCE

	local ents = TheSim:FindEntities(x,y,z, ZERO_DISTANCE, {"HASHEATER"})
    for k,v in pairs(ents) do 
		if v.components.heater and v ~= self.inst and not v:IsInLimbo() then
			local heat = v.components.heater:GetHeat(self.inst)
			local distsq = self.inst:GetDistanceSqToInst(v)

			-- This produces a gentle falloff from 1 to zero.
			local heatfactor = ((-1/ZERO_DISTSQ)*distsq) + 1

			if heat*heatfactor > self.current then
				ambient_delta = ambient_delta + (heat*heatfactor - self.current)
			end
		end
    end	

	local delta = ambient_delta
	self.last_real_delta = delta
	local freeze_time = TUNING.SEG_TIME + total_insulation
	local WARM_DEGREES_PER_SECOND = 1
	local THAW_DEGREES_PER_SECOND = 5
	
	if delta < 0 then
		self.rate = math.max(delta, -30 / freeze_time)
	elseif delta > 0 then
		
		self.rate = math.min(delta, self.current <= 0 and THAW_DEGREES_PER_SECOND or WARM_DEGREES_PER_SECOND)
	else
		self.rate = 0
	end
	
	
    self.current = math.max( math.min( self.current + self.rate*dt, self.maxtemp), self.mintemp)
	
    if (self.current < 0) ~= (last < 0)  then
    	if self.current < 0 then
    		self.inst:PushEvent("startfreezing")
    	else
    		self.inst:PushEvent("stopfreezing")
    	end
    end

	self.inst:PushEvent("temperaturedelta")
	
	if applyhealthdelta and self.current < 0 and self.inst.components.health then
		self.inst.components.health:DoDelta(-self.hurtrate*dt, true, "cold") 
	end
	
end

return Temperature
