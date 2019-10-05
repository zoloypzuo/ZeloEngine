local quakelevels =
{
	level1={
		prequake = 7, 																								--the warning before the quake
		quaketime = function() return math.random(5, 10) + 5 end, 													--how long the quake lasts
		debrispersecond = function() return math.random(5, 6) end, 													--how much debris falls every second
		nextquake = function() return TUNING.TOTAL_DAY_TIME * 0.5 + math.random() * TUNING.TOTAL_DAY_TIME end 	--how long until the next quake
	},

	level2={
		prequake = 6,
		quaketime = function() return math.random(7, 12) + 5 end, 
		debrispersecond = function() return math.random(6, 7) end, 
		nextquake =  function() return TUNING.TOTAL_DAY_TIME * 2 + math.random() * TUNING.TOTAL_DAY_TIME * 1 end
	},

	level3={
		prequake = 5, 
		quaketime = function() return math.random(10, 15) + 5 end, 
		debrispersecond = function() return math.random(7, 8) end, 
		nextquake =  function() return TUNING.TOTAL_DAY_TIME * 1 + math.random() * TUNING.TOTAL_DAY_TIME * 1 end
	},

	level4={
		prequake = 4, 
		quaketime = function() return math.random(12, 17) + 5 end, 
		debrispersecond = function() return math.random(8, 9) end, 
		nextquake =  function() return TUNING.TOTAL_DAY_TIME * 1 + math.random() * TUNING.TOTAL_DAY_TIME * 0.5 end
	},

	level5=
	{
		prequake = 3, 
		quaketime = function() return math.random(15, 20) + 5 end, 
		debrispersecond = function() return math.random(9, 10) end, 
		nextquake =  function() return TUNING.TOTAL_DAY_TIME * 0.5 + math.random() * TUNING.TOTAL_DAY_TIME end
	},

	tentacleQuake=
    { -- quake during tentacle pillar death throes
		prequake = -3,                                                           --the warning before the quake
		quaketime = function() return GetRandomWithVariance(3,.5) end, 	        --how long the quake lasts
		debrispersecond = function() return GetRandomWithVariance(20,.5) end, 	--how much debris falls every second
		nextquake = function() return TUNING.TOTAL_DAY_TIME * 100 end, 	        --how long until the next quake
	},
}

local Quaker = Class(function(self,inst)
	self.inst = inst
	self.timetospawn = 0
	self.spawntime = 0.5
	self.quake = false
	self.inst:StartUpdatingComponent(self)
	self.emittingsound = false
	self.quakelevel = quakelevels["level1"]
	self.prequake = self.quakelevel.prequake
	self.quaketime = self.quakelevel.quaketime()
	self.debrispersecond = self.quakelevel.debrispersecond()
	self.nextquake = self.quakelevel.nextquake()

	self.inst:ListenForEvent("explosion", function(inst, data)
		if not self.quake and self.nextquake > self.prequake + 1 then
			self.nextquake = self.nextquake - data.damage

			if self.nextquake < self.prequake then
				self.nextquake = self.prequake + 1
			end
		end
	 end)
end)

local debris =
{
	common = 
	{
		"rocks",
		"flint"
	},
	rare = 
	{
		"goldnugget",
		"nitre"
	},
	veryrare =
	{
		"redgem",
		"bluegem",
		"marble",
	},
}



function Quaker:OnSave()
	if not self.noserial then
        if self.quakeold then
            self.quakelevel = self.quakeold
            self.quakeold = nil
            self.prequake = self.quakelevel.prequake
            self.quaketime = self.quakelevel.quaketime()
            self.debrispersecond = self.quakelevel.debrispersecond()
            self.nextquake = self.quakelevel.nextquake()
        end
		return
		{
			prequake = self.prequake,
			quaketime = self.quaketime,
			debrispersecond = self.debrispersecond,
			nextquake = self.nextquake,
		}
	end
	self.noserial = false
end

function Quaker:OnLoad(data)
	self.prequake = data.prequake or self.quakelevel.prequake
	self.quaketime = data.quaketime or self.quakelevel.quaketime()
	self.debrispersecond = data.debrispersecond or self.quakelevel.debrispersecond()
	self.nextquake = data.nextquake or self.quakelevel.nextquake()
end

function Quaker:OnProgress()
	self.noserial = true
end

function Quaker:GetDebugString()
	if self.nextquake > 0 then
		return string.format("Next quake in %2.2f. There will be a %2.2f second warning. %2.2f debris will drop every second. It will last for %2.2f seconds",
		self.nextquake, self.prequake, self.debrispersecond, self.quaketime)
	else
		return string.format("QUAKING")
	end
end

function Quaker:SetNextQuake()
	self.prequake = self.quakelevel.prequake
	self.quaketime = self.quakelevel.quaketime()
	self.debrispersecond = self.quakelevel.debrispersecond()
	self.nextquake = self.quakelevel.nextquake()
end

function Quaker:GetTimeForNextDebris()
	return 1/self.debrispersecond
end

function Quaker:SetQuakeLevel(level)
 	self.quakelevel = quakelevels[level]
    self.levelname = level
	self:SetNextQuake()
end

function Quaker:GetSpawnPoint(pt, rad)

    local theta = math.random() * 2 * PI
    local radius = math.random()*(rad or TUNING.FROG_RAIN_SPAWN_RADIUS)
    	
	local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
		local ground = GetWorld()
        local spawn_point = pt + offset
        if not (ground.Map and ground.Map:GetTileAtPoint(spawn_point.x, spawn_point.y, spawn_point.z) == GROUND.IMPASSABLE or ground.Map:GetTileAtPoint(spawn_point.x, spawn_point.y, spawn_point.z) > GROUND.UNDERGROUND ) then
			return true
        end
		return false
    end)

	if result_offset then
		return pt+result_offset
	end

end

function Quaker:WarnQuake()
	self.inst:DoTaskInTime(1, function()
		GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_QUAKE"))
		self.inst:PushEvent("warnquake")
	end)
	self.emittingsound = true
	TheCamera:Shake("FULL", self.prequake + 3, 0.02, .2, 40)
	self.inst.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "earthquake")
	self.inst.SoundEmitter:SetParameter("earthquake", "intensity", 0.08)
end

function Quaker:StartQuake()
	self.inst.SoundEmitter:SetParameter("earthquake", "intensity", 1)
	self.quake = true
	self.inst:PushEvent("startquake")
end

function Quaker:EndQuake()
    if self.quakeold then
 	    self.quakelevel = self.quakeold
 	    self.quakeold = nil
        self.prequake = self.quakelevel.prequake
        self.quaketime = self.quakelevel.quaketime()
        self.debrispersecond = self.quakelevel.debrispersecond()
        self.nextquake = self.quakelevel.nextquake()
    end
	self.quake = false
	self.inst:PushEvent("endquake")
	self.emittingsound = false
	self.inst.SoundEmitter:KillSound("earthquake")
	self:SetNextQuake()
end

-- Immediately start the current or a specified quake
-- If a new quake type is forced, save current quake type and restore it once quake has finished
function Quaker:ForceQuake(level)

	if self.quake then return false end  

    if level and quakelevels[level] then
 	    self.quakeold = self.quakelevel
 	    self.quakelevel = quakelevels[level]
        self.prequake = self.quakelevel.prequake
        self.quaketime = self.quakelevel.quaketime()
        self.debrispersecond = self.quakelevel.debrispersecond()
        self.nextquake = self.quakelevel.nextquake()
    end
	self.nextquake = self.prequake

    return true
end

local function UpdateShadowSize(inst, height)
	if inst.shadow then
		local scaleFactor = Lerp(0.5, 1.5, height/35)
		inst.shadow.Transform:SetScale(scaleFactor, scaleFactor, scaleFactor)
	end
end

local function GiveDebrisShadow(inst)
	local pt = Vector3(inst.Transform:GetWorldPosition())
	inst.shadow = SpawnPrefab("warningshadow")
	UpdateShadowSize(inst, 35)
	inst.shadow.Transform:SetPosition(pt.x, 0, pt.z)
end

function Quaker:GetDebris()
	local rng = math.random()
	local todrop = nil
	if rng < 0.75 then
		todrop = debris.common[math.random(1, #debris.common)]
	elseif rng >= 0.75 and rng < 0.95 then
		todrop = debris.rare[math.random(1, #debris.rare)]
	else
		todrop = debris.veryrare[math.random(1, #debris.veryrare)]
	end
	return todrop
end

function Quaker:SpawnDebris(spawn_point)
    local prefab = self:GetDebris()
	if prefab then
	    local db = SpawnPrefab(prefab)
	    if math.random() < .5 then
		    db.Transform:SetRotation(180)
	    end
		spawn_point.y = 35


	    db.Physics:Teleport(spawn_point.x,spawn_point.y,spawn_point.z)

	    return db
	end
end

function PlayFallingSound(inst, volume)
	volume = volume or 1	
    local sound = inst.SoundEmitter
    if sound then
        local tile, tileinfo = inst:GetCurrentTileType()        
        if tile and tileinfo then
			local x, y, z = inst.Transform:GetWorldPosition()			
			local size_affix = "_small"			
			sound:PlaySound(tileinfo.walksound .. size_affix, nil, volume)
        end
    end
end

local function grounddetection_update(inst)
	local pt = Point(inst.Transform:GetWorldPosition())
	
	if not inst.shadow then
		GiveDebrisShadow(inst)
	else
		UpdateShadowSize(inst, pt.y)
	end

	if pt.y < 2 then
		inst.Physics:SetMotorVel(0,0,0)
    end

	if pt.y <= .2 then
		PlayFallingSound(inst)
		if inst.shadow then
			inst.shadow:Remove()
		end

		local ents = TheSim:FindEntities(pt.x, 0, pt.z, 2, nil, {'smashable'})
	    for k,v in pairs(ents) do
	    	if v and v.components.combat then  -- quakes shouldn't break the set dressing
	    		v.components.combat:GetAttacked(inst, 20, nil)
	    	end
	   	end
	   	--play hit ground sound


	   	inst.Physics:SetDamping(0.9)	   	

	    if inst.updatetask then
			inst.updatetask:Cancel()
			inst.updatetask = nil
		end

		if math.random() < 0.75 then
			--spawn break effect
			inst.SoundEmitter:PlaySound("dontstarve/common/stone_drop")
			local pt = Vector3(inst.Transform:GetWorldPosition())
			local breaking = SpawnPrefab("ground_chunks_breaking")
			breaking.Transform:SetPosition(pt.x, 0, pt.z)
			inst:Remove()
		end
	end
end

local function start_grounddetection(inst)
	inst.updatetask = inst:DoPeriodicTask(0.1, grounddetection_update, 0.05)
end


function Quaker:MiniQuake(rad, num, duration, target)

	self.inst.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "miniearthquake")
	self.inst.SoundEmitter:SetParameter("miniearthquake", "intensity", 1)

    local time = 0
    for i=1,num do

    	self.inst:DoTaskInTime(time, function()    		
			local char_pos = Vector3(target.Transform:GetWorldPosition())
			local spawn_point = self:GetSpawnPoint(char_pos, rad)								
			if spawn_point then
				local db = self:SpawnDebris(spawn_point)	
				start_grounddetection(db)
			end
		end)

		time = time + duration/num
    end

    self.inst:DoTaskInTime(duration, function() self.inst.SoundEmitter:KillSound("miniearthquake") end)
end

function Quaker:OnUpdate( dt )

	if self.nextquake > 0 then
		self.nextquake = self.nextquake - dt

		if self.nextquake < self.prequake and not self.emittingsound then
			self:WarnQuake()
		end

	elseif self.nextquake <= 0 and not self.quake then		
		self:StartQuake()
	end


	if self.quake then
		if self.quaketime > 0 then
			self.quaketime = self.quaketime - dt

			local maincharacter = GetPlayer()

		    if maincharacter then
				if self.timetospawn > 0 then
					self.timetospawn = self.timetospawn - dt
				end

				if self.timetospawn <= 0 then				
					local char_pos = Vector3(maincharacter.Transform:GetWorldPosition())
					local spawn_point = self:GetSpawnPoint(char_pos)								
					if spawn_point then
						local db = self:SpawnDebris(spawn_point)	
				    	TheCamera:Shake("FULL", 0.7, 0.02, .75, 40)
						start_grounddetection(db)
						if self.spawntime then
							self.timetospawn = self:GetTimeForNextDebris()
						end
					end
				end
			end
		else
			self:EndQuake()
		end
	end    
end

return Quaker
