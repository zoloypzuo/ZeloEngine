local ButterflySpawner = Class(function(self, inst)
    self.inst = inst
    self.inst:StartUpdatingComponent(self)
    self.butterflys = {}
    self.timetospawn = 10
    self.butterflycap = 4
    self.numbutterflys = 0
end)

function ButterflySpawner:SetButterfly(butterfly)
    self.prefab = butterfly
end

function ButterflySpawner:GetSpawnPoint(player)
	local rad = 25
	local player = GetPlayer()
	local x,y,z = player.Transform:GetWorldPosition()
	local nearby_ents = TheSim:FindEntities(x,y,z, rad, {'flower'})
	local mindistance = 36
	local validflowers = {}
	for k,flower in ipairs(nearby_ents) do
		if flower and
		player:GetDistanceSqToInst(flower) > mindistance then
			table.insert(validflowers, flower)			
		end
	end

	if #validflowers > 0 then
		local f = validflowers[math.random(1, #validflowers)]
		return f
	else
		return nil
	end
end

function ButterflySpawner:StartTracking(inst)
    inst.persists = false
    if not inst.components.homeseeker then
	    inst:AddComponent("homeseeker")
	end

	self.butterflys[inst] = function()
	    if self.butterflys[inst] then
	        inst:Remove()
	    end
	end

	self.inst:ListenForEvent("entitysleep", self.butterflys[inst], inst)
	
	self.numbutterflys = self.numbutterflys + 1
end

function ButterflySpawner:StopTracking(inst)
    inst.persists = true
	inst:RemoveComponent("homeseeker")
	if self.butterflys[inst] then
		self.inst:RemoveEventCallback("entitysleep", self.butterflys[inst], inst)
		self.butterflys[inst] = nil
		self.numbutterflys = self.numbutterflys - 1
	end
end

function ButterflySpawner:OnUpdate( dt )
	local maincharacter = GetPlayer()
    local day = GetClock():IsDay()
    if maincharacter then
	    
		if self.timetospawn > 0 then
			self.timetospawn = self.timetospawn - dt
		end
	    
		if maincharacter and day and GetWorld().components.seasonmanager:IsSummer() and self.prefab then
			if self.timetospawn <= 0 then
				local spawnFlower = self:GetSpawnPoint(maincharacter)
				if spawnFlower and self.numbutterflys < self.butterflycap then
					local butterfly = SpawnPrefab(self.prefab)
					local spawn_point = Vector3(spawnFlower.Transform:GetWorldPosition() )
					butterfly.Physics:Teleport(spawn_point.x,spawn_point.y,spawn_point.z)
					butterfly.components.pollinator:Pollinate(spawnFlower)
					self:StartTracking(butterfly)
					butterfly.components.homeseeker:SetHome(spawnFlower)
				end
				self.timetospawn = 10 + math.random()*10
			end
		end
	end
    
end

function ButterflySpawner:GetDebugString()
	return "Next spawn: "..tostring(self.timetospawn)
end

function ButterflySpawner:OnSave()
	return 
	{
		timetospawn = self.timetospawn,
    	butterflycap = self.butterflycap,
	}
end

function ButterflySpawner:OnLoad(data)
	self.timetospawn = data.timetospawn or 10
	self.butterflycap = data.butterflycap or 4
	if self.butterflycap <= 0 then
		self.inst:StopUpdatingComponent(self)
	end
end

function ButterflySpawner:SpawnModeNever()
	self.timetospawn = -1
    self.butterflycap = 0
    self.inst:StopUpdatingComponent(self)
end

function ButterflySpawner:SpawnModeHeavy()
	self.timetospawn = 3
    self.butterflycap = 10
end

function ButterflySpawner:SpawnModeMed()
	self.timetospawn = 6
    self.butterflycap = 7
end

function ButterflySpawner:SpawnModeLight()
	self.timetospawn = 20
    self.butterflycap = 2
end

return ButterflySpawner
