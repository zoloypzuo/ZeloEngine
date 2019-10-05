local FrogRain = Class(function(self, inst)
    self.inst = inst
    self.timetospawn = 0
	self.frogs = {}
	self.frog_count = 0
    self.frogcap = TUNING.FROG_RAIN_MAX
    self.spawntime = TUNING.FROG_RAIN_DELAY
	self.local_rain_max = TUNING.FROG_RAIN_LOCAL_MAX

	inst:ListenForEvent("rainstart", function() self.local_rain_max = math.random(10, TUNING.FROG_RAIN_LOCAL_MAX) end)
    self.inst:StartUpdatingComponent(self)
end)

function FrogRain:GetDebugString()
--    return string.format("Frograin: %d/%d, next in %ds", GetTableSize(self.frogs), self.frogcap, self.timetospawn)
    return string.format("Frograin: %d/%d, next in %ds min: %2.2f max:%2.2f", self.frog_count, self.frogcap, self.timetospawn, self.spawntime.min, self.spawntime.max)
end

function FrogRain:OnSave()
	local save = {
			timetospawn = 	self.timetospawn,
			frog_count = 	self.frog_count,
		    frogcap = 		self.frogcap,
		   	spawntime =  	self.spawntime,
		}
	--save.frogs = {}


    return save
  end

function FrogRain:OnLoad(data)
	if data ~= nil then
		self.timetospawn = data.timetospawn or self.timetospawn
		self.frog_count = data.frog_count or self.frog_count
		self.frogcap = data.frogcap or self.frogcap
		self.spawntime = data.spawntime or self.spawntime
	end
end

function FrogRain:SetSpawnTimes(times)
    self.spawntime = times
end

function FrogRain:SetMaxFrogs(max)
    self.frogcap = max
end

function FrogRain:StartTracking(inst)
	self.frog_count = self.frog_count + 1
 --    inst.persists = false

 --    self.frogs[inst] = {}

	-- self.frogs[inst].sleep = function()
	--     if self.frogs[inst] then
	-- 		if #self.frogs > self.frogcap then
	-- 			inst:Remove()
	-- 		end
	--     end
	-- end

	-- self.frogs[inst].remove = function()
	--     if self.frogs[inst] then
	-- 		self:StopTracking(inst)
	--     end
	-- end

	-- self.inst:ListenForEvent("entitysleep", self.frogs[inst].sleep, inst)
	-- self.inst:ListenForEvent("onremove", self.frogs[inst].remove, inst)
	
end

function FrogRain:StopTracking(inst)
	self.frog_count = self.frog_count - 1
  --   inst.persists = true
  --   if self.frogs[inst] then
		-- self.inst:RemoveEventCallback("entitysleep", self.frogs[inst].sleep, inst)
		-- self.inst:RemoveEventCallback("onremove", self.frogs[inst].remove, inst)
		-- self.frogs[inst] = nil
  --   end
end

function FrogRain:GetSpawnPoint(pt)

    local theta = math.random() * 2 * PI
    local radius = math.random()*TUNING.FROG_RAIN_SPAWN_RADIUS
    
	-- we have to special case this one because birds can't land on creep
	local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
		local ground = GetWorld()
        local spawn_point = pt + offset
        if not (ground.Map and ground.Map:GetTileAtPoint(spawn_point.x, spawn_point.y, spawn_point.z) == GROUND.IMPASSABLE) then
			return true
        end
		return false
    end)

	if result_offset then
		return pt+result_offset
	end
end

function FrogRain:SpawnFrog(spawn_point)
    local prefab = "frog"
	if prefab then
	    local frog = SpawnPrefab(prefab)
	    if math.random() < .5 then
		    frog.Transform:SetRotation(180)
	    end
		spawn_point.y = 35

		frog.sg:GoToState("fall")
    	
	    frog.Physics:Teleport(spawn_point.x,spawn_point.y,spawn_point.z)
	    return frog
	end
end

function FrogRain:OnUpdate( dt )
	local maincharacter = GetPlayer()

    if maincharacter then

		if self.timetospawn > 0 then
			self.timetospawn = self.timetospawn - dt
		end

		

		--if self.timetospawn <= 0 and GetTableSize(self.frogs) < self.frogcap then
		if self.timetospawn <= 0 and self.frog_count < self.frogcap then
			--print("Upd",  GetSeasonManager():IsRaining(), GetSeasonManager():GetPrecipitationRate() > TUNING.FROG_RAIN_PRECIPITATION, TUNING.FROG_RAIN_PRECIPITATION,
			--			GetSeasonManager():GetMoistureLimit() > TUNING.FROG_RAIN_MOISTURE, TUNING.FROG_RAIN_MOISTURE)
			if SaveGameIndex:GetCurrentMode() == "adventure" and 
					GetSeasonManager():IsRaining() and
					GetSeasonManager():GetPrecipitationRate() > TUNING.FROG_RAIN_PRECIPITATION and
					GetSeasonManager():GetMoistureLimit() > TUNING.FROG_RAIN_MOISTURE then
				local char_pos = Vector3(maincharacter.Transform:GetWorldPosition())
				local spawn_point = self:GetSpawnPoint(char_pos)
				local nearbyfrogs = TheSim:FindEntities(char_pos.x, char_pos.y, char_pos.z, TUNING.FROG_RAIN_MAX_RADIUS, {"frog"})
				if spawn_point and #nearbyfrogs < self.local_rain_max then
					local frog = self:SpawnFrog(spawn_point)
					if frog then
						self:StartTracking(frog)
					end
				end

				if self.spawntime and self.spawntime.min and self.spawntime.max then
					self.timetospawn = GetRandomMinMax(self.spawntime.min, self.spawntime.max)
				end
			end
		end
	end
    
end

return FrogRain
