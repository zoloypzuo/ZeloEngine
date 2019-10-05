local BirdSpawner = Class(function(self, inst)
    self.inst = inst
    self.inst:StartUpdatingComponent(self)
    self.birds = {}
    self.timetospawn = 0
    self.birdcap = 4
    self.spawntime = TUNING.BIRD_SPAWN_DELAY
    
	self.birdtypes = -- Note: in winter, 'robin' is replaced with 'robin_winter' automatically
	{
		--[GROUND.IMPASSABLE] = {bird = ""},
		--[GROUND.ROAD] = {"crow"},
		[GROUND.ROCKY] = {"crow"},
		[GROUND.DIRT] = {"crow"},
		[GROUND.SAVANNA] = {"robin","crow"},
		[GROUND.GRASS] = {"robin"},
		[GROUND.FOREST] = {"robin","crow"},
		[GROUND.MARSH] = {"crow"},
	}
	
end)

function BirdSpawner:GetDebugString()
    return string.format("Birds: %d/%d", GetTableSize(self.birds), self.birdcap)
end

function BirdSpawner:SetSpawnTimes(times)
    self.spawntime = times
end

function BirdSpawner:SetMaxBirds(max)
    self.birdcap = max
end

function BirdSpawner:StartTracking(inst)
    inst.persists = false

    self.birds[inst] = function()
	    if self.birds[inst] then
	        inst:Remove()
	    end
	end

	self.inst:ListenForEvent("entitysleep", self.birds[inst], inst)
	
end

function BirdSpawner:StopTracking(inst)
    inst.persists = true
    if self.birds[inst] then
		self.inst:RemoveEventCallback("entitysleep", self.birds[inst], inst)
		self.birds[inst] = nil
    end
end

function BirdSpawner:GetSpawnPoint(pt)

    local theta = math.random() * 2 * PI
    local radius = 6+math.random()*6
    
	-- we have to special case this one because birds can't land on creep
	local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
		local ground = GetWorld()
        local spawn_point = pt + offset
        if not (ground.Map and ground.Map:GetTileAtPoint(spawn_point.x, spawn_point.y, spawn_point.z) == GROUND.IMPASSABLE)
           and not ground.GroundCreep:OnCreep(spawn_point.x, spawn_point.y, spawn_point.z) then
			return true
        end
		return false
    end)

	if result_offset then
		return pt+result_offset
	end
end

function BirdSpawner:PickBird(spawn_point)
    local ground = GetWorld()
    if ground and ground.Map then
        local tile = ground.Map:GetTileAtPoint(spawn_point.x, spawn_point.y, spawn_point.z)
		local bird = GetRandomItem(self.birdtypes[tile] or {"crow"})
		if ground.components.seasonmanager:IsWinter() and bird == "robin" then
			bird = "robin_winter"
		end
        return bird
    end
end

function BirdSpawner:DangerNearby(pt)
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 8, {"scarytoprey"})
    return next(ents) ~= nil
end

function BirdSpawner:SpawnBird(spawn_point, ignore_bait)
    local prefab = self:PickBird(spawn_point)
	if prefab then
	    local bird = SpawnPrefab(prefab)
	    if math.random() < .5 then
		    bird.Transform:SetRotation(180)
	    end
    	
	    if bird:HasTag("bird") then
	        spawn_point.y = 15
	    end
	    --see if there's bait nearby that we might spawn into
	    if bird.components.eater and not ignore_bait then
	        local bait = TheSim:FindEntities(spawn_point.x, 0, spawn_point.z, 15)
	        for k,v in pairs(bait) do
		        if bird.components.eater:CanEat(v)
		           and v.components.bait
		           and not (v.components.inventoryitem and v.components.inventoryitem:IsHeld())
		           and not self:DangerNearby(Vector3(v.Transform:GetWorldPosition() ) ) then
			        local target_pos = Vector3(v.Transform:GetWorldPosition() )
			        spawn_point = Vector3(target_pos.x, spawn_point.y, target_pos.z)
			        bird.bufferedaction = BufferedAction(bird, v, ACTIONS.EAT)
			        break
		        elseif v.components.trap
		               and v.components.trap.isset
		               and (not v.components.trap.targettag or bird:HasTag(v.components.trap.targettag) )
		               and not v.components.trap.issprung
		               and math.random() < TUNING.BIRD_TRAP_CHANCE
					   and not self:DangerNearby(Vector3(v.Transform:GetWorldPosition() ) ) then
			        local target_pos = Vector3(v.Transform:GetWorldPosition() )
			        spawn_point = Vector3(target_pos.x, spawn_point.y, target_pos.z)
			        break
		        end
	        end
	    end

	    bird.Physics:Teleport(spawn_point.x,spawn_point.y,spawn_point.z)
	    return bird
	end
end

function BirdSpawner:OnUpdate( dt )
	local maincharacter = GetPlayer()
    local night = GetClock():IsNight()
    if maincharacter then
	    
		if self.timetospawn > 0 then
			if GetSeasonManager():IsRaining() then
				self.timetospawn = self.timetospawn - dt*TUNING.BIRD_RAIN_FACTOR
			else
				self.timetospawn = self.timetospawn - dt
			end
		end
	    
		if maincharacter and not night then
			if self.timetospawn <= 0 and GetTableSize(self.birds) < self.birdcap then
	            local char_pos = Vector3(maincharacter.Transform:GetWorldPosition())
				local spawn_point = self:GetSpawnPoint(char_pos)
				if spawn_point then
	                local bird = self:SpawnBird(spawn_point)
	                if bird then
	                    self:StartTracking(bird)
					end
					if self.spawntime and self.spawntime.min and self.spawntime.max then
					    self.timetospawn = GetRandomMinMax(self.spawntime.min, self.spawntime.max)
					end
				end
			end
		end
	end    
end

function BirdSpawner:OnSave()
	return 
	{
		timetospawn = self.timetospawn,
    	birdcap = self.birdcap,
	}
end

function BirdSpawner:OnLoad(data)
	self.timetospawn = data.timetospawn or 10
	self.birdcap = data.birdcap or 4
	if self.birdcap <= 0 then
		self.inst:StopUpdatingComponent(self)
	end
end

function BirdSpawner:SpawnModeNever()
	self.timetospawn = -1
    self.birdcap = 0
    self.inst:StopUpdatingComponent(self)
end

function BirdSpawner:SpawnModeHeavy()
	self.timetospawn = 3
    self.birdcap = 10
end

function BirdSpawner:SpawnModeMed()
	self.timetospawn = 6
    self.birdcap = 7
end

function BirdSpawner:SpawnModeLight()
	self.timetospawn = 20
    self.birdcap = 2
end

return BirdSpawner
