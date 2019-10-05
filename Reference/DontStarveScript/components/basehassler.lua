local BaseHassler = Class(function(self, inst)
    self.inst = inst
	self.warning = false
	self.timetoattack = nil
	self.warnduration = 60
	self.timetonextwarningsound = 0
	self.announcewarningsoundinterval = 4
	self.hasslerprefab = "deerclops"
	self.warningsound = "dontstarve/creatures/deerclops/distant"
	
	self.attacksperwinter = 1
	self.attackduringsummer = false
	self.attackdelay = nil
	self.attackrandom = nil
	
	self.inst:ListenForEvent("snowcoverchange", function(inst)
		local snow_cover = GetSeasonManager() and GetSeasonManager():GetSnowPercent() or 0

	    if snow_cover >= 0.2 then 
	        if not self.timetoattack then
	            self:StartAttacks()
	        end
	    elseif snow_cover <= 0 and self.attackduringsummer and not self.timetoattack then
            self:StartAttacks()
        else
            self:CeaseAttacks()
	    end
	end, GetWorld() )
end)

local HASSLER_SPAWN_DIST = 40
local WANDER_AWAY_DIST = 100

function BaseHassler:SetHasslerPrefab(prefab)
    self.hasslerprefab = prefab
end

function BaseHassler:SetWarningSound(sound)
    self.warningsound = sound
end

function BaseHassler:SetAttacksPerWinter(attacks)
    self.attacksperwinter = attacks
end

function BaseHassler:SetAttackDuringSummer(attack)
    self.attackduringsummer = attack
end

function BaseHassler:OnSave()
	if not self.noserial then
		return 
		{
			warning = self.warning,
			timetoattack = self.timetoattack,
			attackdelay = self.attackdelay,
			attackrandom = self.attackrandom,
		}
	end
	self.noserial = false
end

function BaseHassler:OnLoad(data)
	self.warning = data.warning or false
	self.timetoattack = data.timetoattack
	self.attackdelay = data.attackdelay
	self.attackrandom = data.attackrandom

	if self.timetoattack then
    	self.inst:StartUpdatingComponent(self)
    end
end


function BaseHassler:OnProgress()
	self.noserial = true
end


function BaseHassler:GetDebugString()
	if not self.timetoattack then
	    return "DORMANT"
	elseif self.timetoattack > 0 then
		return string.format("%s Deerclops is coming in %2.2f", self.warning and "WARNING" or "WAITING", self.timetoattack)
	else
		return string.format("ATTACKING!!!")
	end
end


function BaseHassler:LongUpdate(dt)
	self:OnUpdate(dt)
end

function BaseHassler:OnUpdate(dt)
    if not self.timetoattack then
        self:CeaseAttacks()
        return
    end
    
	self.timetoattack = self.timetoattack - dt
	if self.timetoattack <= 0 then
		self.warning = false
	    self:ReleaseHassler()
		self:CeaseAttacks()
	else
		if not self.warning and self.timetoattack < self.warnduration then
			self.warning = true
			self.timetonextwarningsound = 0
		end
	end
	
	if self.warning then
		self.timetonextwarningsound	= self.timetonextwarningsound - dt
		
		if self.timetonextwarningsound <= 0 then
		
			self.announcewarningsoundinterval = self.announcewarningsoundinterval - 1
			if self.announcewarningsoundinterval <= 0 then
				self.announcewarningsoundinterval = 10 + math.random(5)
					GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_DEERCLOPS"))
			end
		
			local inst = CreateEntity()
			inst.entity:AddTransform()
			inst.entity:AddSoundEmitter()
			inst.persists = false
			local theta = math.random() * 2 * PI

			local radius = 5
			self.timetonextwarningsound = 15 + math.random(4)
			
			if self.timetoattack < 30 then
				self.timetonextwarningsound = 10 + math.random(1)
				radius = radius
			elseif self.timetoattack < 60 then
				radius = radius + 10
			elseif self.timetoattack < 90 then
				radius = radius + 15
			else
				radius = radius + 20
			end

			local offset = Vector3(GetPlayer().Transform:GetWorldPosition()) +  Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
			
			inst.Transform:SetPosition(offset.x,offset.y,offset.z)
			inst.SoundEmitter:PlaySound(self.warningsound)
			inst:DoTaskInTime(1.5, function() inst:Remove() end)
		end
	end
end

function BaseHassler:StartAttacks()
    local timeLeftInSeason = GetSeasonManager():GetDaysLeftInSeason() * TUNING.TOTAL_DAY_TIME
	if self.attacksperwinter > 0 then
	    if self.attacksperwinter < 1 then
	        --special case: plan attack for NEXT season
	        local summersToSkip = math.floor( (1 / self.attacksperwinter) - 1 )
	        local wintersToSkip = math.max(0, summersToSkip-1)
	        self.attackdelay = 0.5*timeLeftInSeason + TUNING.TOTAL_DAY_TIME*(summersToSkip*GetSeasonManager().summerlength + wintersToSkip*GetSeasonManager().winterlength)
            self.attackrandom = 0.25*timeLeftInSeason
        else
            self.attackdelay = timeLeftInSeason / self.attacksperwinter
            self.attackrandom = 0.25*self.attackdelay
	    end
	    self:PlanNextAttack()
        self.inst:StartUpdatingComponent(self)
	end
	
end

function BaseHassler:PlanNextAttack()
    if (not GetSeasonManager():IsWinter() and not self.attackduringsummer) or not self.attackdelay then
        self:CeaseAttacks()
        return
    end
	
	self.timetoattack = GetRandomWithVariance(self.attackdelay, self.attackrandom or 0)
end

function BaseHassler:CeaseAttacks()
    self.timetoattack = nil
    self.warning = false
    self.inst:StopUpdatingComponent(self)
end

function BaseHassler:GetSpawnPoint(pt)
    local theta = math.random() * 2 * PI
    local radius = HASSLER_SPAWN_DIST

	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	if offset then
		return pt+offset
	end
end

function BaseHassler:GetWanderAwayPoint(pt)
    local theta = math.random() * 2 * PI
    local radius = WANDER_AWAY_DIST
    
    local ground = GetWorld()
    
    -- Walk the circle trying to find a valid spawn point
    local steps = 12
    for i = 1, 12 do
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        local wander_point = pt + offset
        
        if ground.Map and ground.Map:GetTileAtPoint(wander_point.x, wander_point.y, wander_point.z) ~= GROUND.IMPASSABLE
           and ground.Pathfinder:IsClear(pt.x, pt.y, pt.z, wander_point.x, wander_point.y, wander_point.z, {ignorewalls = true} ) then
            return wander_point
        end
        theta = theta - (2 * PI / steps)
    end
end

function BaseHassler:ReleaseHassler()
	local pt = Vector3(GetPlayer().Transform:GetWorldPosition())
	
    local spawn_pt = self:GetSpawnPoint(pt)
	
    if spawn_pt then
	    local hassler = TheSim:FindFirstEntityWithTag(self.hasslerprefab)
	    if not hassler then
	        hassler = SpawnPrefab(self.hasslerprefab)
	    end
        if hassler then
            hassler.Physics:Teleport(spawn_pt:Get())
            local target = GetClosestInstWithTag("structure", GetPlayer(), 40)
            if target then
                local targetPos = Vector3(target.Transform:GetWorldPosition() )
		        hassler.components.knownlocations:RememberLocation("targetbase", targetPos)
                local wanderAwayPoint = self:GetWanderAwayPoint(targetPos)
                if wanderAwayPoint then
                    hassler.components.knownlocations:RememberLocation("home", wanderAwayPoint)
                end
		    else
		        hassler.components.combat:SetTarget(GetPlayer())
		    end
		end
	end
end

function BaseHassler:OverrideAttacksPerSeason(name, num)
	if name == "DEERCLOPS" then
		self.attacksperwinter = num
	end
end

function BaseHassler:OverrideAttackDuringOffSeason(name, bool)
	if name == "DEERCLOPS" then
		self.attackduringsummer = bool
	end
end


return BaseHassler
