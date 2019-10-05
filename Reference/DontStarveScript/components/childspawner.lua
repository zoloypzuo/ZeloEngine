local trace = function() end
-- local trace = function(inst, ...)
-- 	if inst.prefab == "beebox" then
-- 		print(inst, ...)
-- 	end
-- end

--- Spawns and tracks child entities in the world
-- For setup the following params should be set
-- @param childname The prefab name of the default child to be spawned. This can be overridden in the SpawnChild method
-- @param delay The time between spawning children when the spawner is actively spawning. If nil, only manual spawning works.
-- @param newchilddelay The time it takes for a killed/captured child to be regenerated in the childspawner. If nil, dead children aren't regenerated.
-- It's also a good idea to call SetMaxChildren as part of the childspawner setup.
local ChildSpawner = Class(function(self, inst)
	self.inst = inst
	self.childrenoutside = {}
	self.childreninside = 1
	self.numchildrenoutside = 0
	self.maxchildren = 0
	
	self.childname = ""
	self.rarechild = nil
	self.rarechildchance = 0.1

    self.onvacate = nil
    self.onoccupied = nil
    self.onspawned = nil
    self.ongohome = nil

	self.spawning = false
	self.timetonextspawn = 0
	self.spawnperiod = 20
	self.spawnvariance = 2
    
    self.regening = true
    self.timetonextregen = 0
    self.regenperiod = 20
	self.regenvariance = 2
    self.spawnoffscreen = false
end)

function ChildSpawner:StartRegen()
	self.regening = true
	
	if self.numchildrenoutside + self.childreninside < self.maxchildren then
		self.timetonextregen = self.regenperiod + (math.random()*2-1)*self.regenvariance
		self:StartUpdate(6)
	end
end

function ChildSpawner:SetRareChild(childname, chance)
	self.rarechild = childname
	self.rarechildchance = chance
end

function ChildSpawner:StopRegen()
	self.regening = false
end

function ChildSpawner:SetSpawnPeriod(period, variance)
	self.spawnperiod = period
	self.spawnvariance = variance or period * 0.1
end

function ChildSpawner:SetRegenPeriod(period, variance)
	self.regenperiod = period
	self.regenvariance = variance or period * 0.1
end

function ChildSpawner:OnUpdate(dt)
	
	if self.regening then
		if self.numchildrenoutside + self.childreninside < self.maxchildren then
			self.timetonextregen = self.timetonextregen - dt
			if self.timetonextregen < 0 then
				self.timetonextregen = self.regenperiod + (math.random()*2-1)*self.regenvariance
				self:AddChildrenInside(1)
			end
		else
			self.timetonextregen = self.regenperiod + (math.random()*2-1)*self.regenvariance
		end
	end
	
	
	if self.spawning then
		if self.childreninside > 0 then
			self.timetonextspawn = self.timetonextspawn - dt
			if self.timetonextspawn < 0 then
				self.timetonextspawn = self.spawnperiod + (math.random()*2-1)*self.spawnvariance
				self:SpawnChild()
			end
		else
			self.timetonextspawn = 0
		end
	end
	
	local need_to_continue_spawning = self.spawning and self.childreninside > 0
	local need_to_continue_regening = self.regening and self.numchildrenoutside + self.childreninside < self.maxchildren
	
	
	if not need_to_continue_spawning and not need_to_continue_regening then
		if self.task then
			self.task:Cancel()
			self.task = nil
		end
		--self.inst:StopUpdatingComponent(self)
	end
end

function ChildSpawner:StartUpdate(dt)
	if not self.task then
		local dt = 5 + math.random()*5 
		self.task = self.inst:DoPeriodicTask(dt, function() self:OnUpdate(dt) end)
	end
end

function ChildSpawner:StartSpawning()
	trace(self.inst, "ChildSpawner:StartSpawning()")
	self.spawning = true
	self.timetonextspawn = 0
	self:StartUpdate(6)
	
end

function ChildSpawner:StopSpawning()
	self.spawning = false
end

function ChildSpawner:SetOccupiedFn(fn)
    self.onoccupied = fn
end

function ChildSpawner:SetSpawnedFn(fn)
    self.onspawned = fn
end

function ChildSpawner:SetGoHomeFn(fn)
    self.ongohome = fn
end

function ChildSpawner:SetVacateFn(fn)
    self.onvacate = fn
end

function ChildSpawner:CountChildrenOutside(fn)
    local vacantchildren = 0
    for k,v in pairs(self.childrenoutside) do
        if v and v:IsValid() and (not fn or fn(v) ) then
            vacantchildren = vacantchildren + 1
        end
    end
    return vacantchildren
end

function ChildSpawner:SetMaxChildren(max)
    self.childreninside = max - self:CountChildrenOutside()
    self.maxchildren = max
    if self.childreninside < 0 then self.childreninside = 0 end
end


function ChildSpawner:OnSave()
    local data = {}
	local references = {}

    for k,v in pairs(self.childrenoutside) do
        if not data.childrenoutside then
            data.childrenoutside = {v.GUID}
            
        else
            table.insert(data.childrenoutside, v.GUID)
        end
        
        table.insert(references, v.GUID)
    end
    data.childreninside = self.childreninside

	data.spawning = self.spawning
	data.regening = self.regening
	data.timetonextregen = math.floor(self.timetonextregen)
	data.timetonextspawn = math.floor(self.timetonextspawn)
	
    return data, references
end

function ChildSpawner:GetDebugString()
    local str = string.format("%s - %d in, %d out", self.childname, self.childreninside, self.numchildrenoutside )
	
	local num_children = self.numchildrenoutside + self.childreninside
	if num_children < self.maxchildren and self.regening then
		str = str..string.format(" Regen in %2.2f ", self.timetonextregen )
	end
	
	if self.childreninside > 0 and self.spawning then
		str = str..string.format(" Spawn in %2.2f ", self.timetonextspawn )
	end
	
	if self.spawning then
		str = str.."S"
	end

	if self.regening then
		str = str.."R"
	end
	
	return str
end

function ChildSpawner:OnLoad(data)
	trace(self.inst, "ChildSpawner:OnLoad")
    
    --convert previous data
    if data.occupied then
        data.childreninside = 1
    end
    if data.childid then
        data.childrenoutside = {data.childid}
    end
    
    if data.childreninside then
        self.childreninside = 0
        self:AddChildrenInside(data.childreninside)
        if self.childreninside > 0 and self.onoccupied then
            self.onoccupied(self.inst)
        elseif self.childreninside == 0 and self.onvacate then
            self.onvacate(self.inst)
        end
    end
    
    
	self.spawning = data.spawning or  self.spawning
	self.regening = data.regening or self.regening
	self.timetonextregen = data.timetonextregen or self.timetonextregen
	self.timetonextspawn = data.timetonextspawn or self.timetonextspawn
	
	if self.spawning or self.regening then
		self:StartUpdate(6)
	end
	
end

function ChildSpawner:TakeOwnership(child)
    if child.components.knownlocations then
        child.components.knownlocations:RememberLocation("home", Vector3(self.inst.Transform:GetWorldPosition()))
    end
    child:AddComponent("homeseeker")
    child.components.homeseeker:SetHome(self.inst)
	self.inst:ListenForEvent( "ontrapped", function() self:OnChildKilled( child ) end, child )
	self.inst:ListenForEvent( "death", function() self:OnChildKilled( child ) end, child )
	
	self.childrenoutside[child] = child
	self.numchildrenoutside = self.numchildrenoutside + 1
	
end

function ChildSpawner:LoadPostPass(newents, savedata)
	trace(self.inst, "ChildSpawner:LoadPostPass")
    if savedata.childrenoutside then
        for k,v in pairs(savedata.childrenoutside) do
            local child = newents[v]
            if child then
                child = child.entity
                self:TakeOwnership(child)
            end
        end
    end
end

function ChildSpawner:SpawnChild(target, prefab, radius)
    if not self:CanSpawn() then
        return
    end

	trace(self.inst, "ChildSpawner:SpawnChild")

	local pos = Vector3(self.inst.Transform:GetWorldPosition())
	local start_angle = math.random()*PI*2
	local rad = radius or 0.5
	if self.inst.Physics then
		rad = rad + self.inst.Physics:GetRadius()
	end
	local offset = FindWalkableOffset(pos, start_angle, rad, 8, false)
	if offset == nil then
		return
	end

	pos = pos + offset

	local childtospawn = prefab or self.childname

	if self.rarechild and math.random() < self.rarechildchance then
		childtospawn = self.rarechild
	end
	
    local child = SpawnPrefab(childtospawn)
    
    if child ~= nil then
        
        child.Transform:SetPosition(pos:Get())
        self:TakeOwnership(child)
        if target and child.components.combat then
            child.components.combat:SetTarget(target)
        end
        
        if self.onspawned then
            self.onspawned(self.inst, child)
        end
		
		if self.childreninside == 1 and self.onvacate then
            self.onvacate(self.inst)
	    end
	    self.childreninside = self.childreninside - 1
	    
		
	end
	return child
end

function ChildSpawner:GoHome( child )
    if self.childrenoutside[child] then
        self.inst:PushEvent("childgoinghome", {child = child})
        child:PushEvent("goinghome", {home = self.inst})
        if self.ongohome then
            self.ongohome(self.inst, child)
        end
        child:Remove()
        self.childrenoutside[child] = nil

        self.numchildrenoutside = self.numchildrenoutside - 1
        self:AddChildrenInside(1)
        return true
    end
end


function ChildSpawner:CanSpawn()
    if self.childreninside <= 0 then
        return false
    end
    
    if self.inst:IsAsleep() and not self.spawnoffscreen then
		return false
    end
    
    if not self.inst:IsValid() then
        return false
    end
    
    if self.inst.components.health and self.inst.components.health:IsDead() then
        return false
    end
    
    return true
end


function ChildSpawner:OnChildKilled( child )
    if self.childrenoutside[child] then
        self.childrenoutside[child] = nil
        self.numchildrenoutside = self.numchildrenoutside - 1
        
        if self.regening then
			self:StartUpdate(6)
        end
    end
end

function ChildSpawner:ReleaseAllChildren(target, prefab)
    while self:CanSpawn() do
        self:SpawnChild(target, prefab)
    end
end

function ChildSpawner:AddChildrenInside(count)
    if self.childreninside == 0 and self.onoccupied then
        self.onoccupied(self.inst)
    end
    self.childreninside = self.childreninside + count
    if self.maxchildren then
        self.childreninside = math.min(self.maxchildren, self.childreninside)
    end
end

function ChildSpawner:LongUpdate(dt)
	if self.spawning then
		self:OnUpdate(dt)
	end
end


return ChildSpawner

