-- spawner in unique from childspawner in that it manages a single persistant entity 
-- (eg. a specific named pigman with a specific hat)
-- whereas childspawner creates and destroys one or more generic entities as they enter 
-- and leave the spawner (eg. spiders). it can manage more than one, but can not maintain
-- individual properties of each entity

local trace = function() end
-- local trace = function(inst, ...)
--     print(inst, ...)
-- end

local function ReleaseChild(inst)
    local spawner = inst.components.spawner
    if spawner then
        if not spawner.spawnoffscreen or inst:IsAsleep() then
            spawner:ReleaseChild()
        end
    end
end

local function OnEntitySleep(inst)
    local spawner = inst.components.spawner
    if spawner and spawner.spawnoffscreen and spawner.nextspawntime and GetTime() > spawner.nextspawntime then
        spawner:ReleaseChild()
    end
end

local Spawner = Class(function(self, inst)
	self.inst = inst
	self.child = nil
    self.delay = 0
    self.onoccupied = nil
    self.onvacate = nil
    self.spawnsleft = nil
    self.spawnoffscreen = false
    
    self.task = nil
    self.nextspawntime = nil
end)

function Spawner:GetDebugString()
    local str = "child: "..tostring(self.child)
    if self:IsOccupied() then
        str = str.." occupied"
    end
    if self.task and self.nextspawntime then
        str = str..string.format(" spawn in %2.2fs", self.nextspawntime - GetTime() )
    end
    
    if self.spawnsleft then
		str = str .. " left:".. self.spawnsleft
    end
    
    return str
end

function Spawner:SetOnOccupiedFn(fn)
    self.onoccupied = fn
end

function Spawner:SetOnVacateFn(fn)
    self.onvacate = fn
end

function Spawner:SetOnlySpawnOffscreen(offscreen)
    self.spawnoffscreen = offscreen
    if self.spawnoffscreen then
	    self.inst:ListenForEvent("entitysleep", OnEntitySleep)
	else
	    self.inst:RemoveEventCallback("entitysleep", OnEntitySleep)
	end
end

function Spawner:Configure( childname, delay, startdelay)
    self.childname = childname
    self.delay = delay
    
    self:SpawnWithDelay(startdelay or 0)
end

function Spawner:SetReleaseRadius(rad, attempts)
    self.release_radius = rad
    self.release_attempts = attempts
end

function Spawner:SpawnWithDelay(delay)
    delay = math.max(0, delay)
    self.nextspawntime = GetTime() + delay
    self.task = self.inst:DoTaskInTime(delay, ReleaseChild)
end

function Spawner:CancelSpawning()
    if self.task then
        self.task:Cancel()
        self.task = nil
        self.nextspawntime = nil
    end
end


function Spawner:OnSave()
    local data = {}

    if self.child and self:IsOccupied() then
        data.child = self.child:GetSaveRecord()
    elseif self.child and self.child.components.health and not self.child.components.health:IsDead() then
        data.childid = self.child.GUID
    elseif self.nextspawntime then
        data.startdelay = self.nextspawntime - GetTime()
    end
    
    data.spawnsleft = self.spawnsleft
    
    local refs = nil
    if data.childid then
		refs = {data.childid}
    end
    return data, refs
end   
   

function Spawner:OnLoad(data, newents)
    
    self:CancelSpawning()
    
    if data.child then
        local child = SpawnSaveRecord(data.child, newents)
        self:TakeOwnership(child)
        self:GoHome(child)
    end
    if data.startdelay then
        self:SpawnWithDelay(data.startdelay)
    end
    
    --[[if data.spawnsleft then
		self.spawnsleft = data.spawnsleft
		if data.spawnsleft and data.spawnsleft == 0 and self.onoutofspawns then
			self.onoutofspawns(self.inst)
		end
    end
    --]]
end

function Spawner:TakeOwnership(child)
    if self.child ~= child then
        child:ListenForEvent( "ontrapped", function() self:OnChildKilled( child ) end, child )
        child:ListenForEvent( "death", function() self:OnChildKilled( child ) end, child )
        if child.components.knownlocations then
            child.components.knownlocations:RememberLocation("home", Vector3(self.inst.Transform:GetWorldPosition()))
        end
    end
    child:AddComponent("homeseeker")
    child.components.homeseeker:SetHome(self.inst)
    self.child = child
end

function Spawner:LoadPostPass(newents, savedata)
    if savedata.childid then
        local child = newents[savedata.childid]
        if child then
            child = child.entity
            self:TakeOwnership(child)
        end
    end
end

function Spawner:IsOccupied()
    return self.child and self.child.parent == self.inst
end

function Spawner:ReleaseChild()

    if self.spawnsleft and self.spawnsleft == 0 then
		return
    end
    
    self:CancelSpawning()    
    local child = self.child
    if not child then
        
        local childname = self.childname
        if self.childfn then
			childname = self.childfn(self.inst)
        end
        
        local child = SpawnPrefab(childname)
        self:TakeOwnership(child)
        self:GoHome(child)
    end
    
    if self:IsOccupied() then
        self.inst:RemoveChild(self.child)
        self.child:ReturnToScene()
    
        local rad = self.release_radius or 0.5
        if self.inst.Physics then
	        local prad = self.inst.Physics:GetRadius() or 0
            rad = rad + prad
        end
        
        if self.child.Physics then
	        local prad = self.child.Physics:GetRadius() or 0
            rad = rad + prad
        end
        
        local pos = Vector3(self.inst.Transform:GetWorldPosition())
        local start_angle = math.random()*2*PI

        local offset = FindWalkableOffset(pos, start_angle, rad, self.release_attempts or 8, false)
        if offset == nil then
            -- well it's gotta go somewhere!
            trace(self.inst, "Spawner:ReleaseChild() no good place to spawn child: ", self.child)
            pos = pos + Vector3(rad*math.cos(start_angle), 0, rad*math.sin(start_angle))
        else
            trace(self.inst, "Spawner:ReleaseChild() safe spawn of: ", self.child)
            pos = pos + offset
        end
    
        self:TakeOwnership(self.child)
        if self.child.Physics then
            self.child.Physics:Teleport(pos:Get() )
        else
            self.child.Transform:SetPosition(pos:Get())
        end
        
        if self.onvacate then
            self.onvacate(self.inst, self.child)
        end
        return true
	end
end

function Spawner:GoHome( child )
    if self.child == child and not self:IsOccupied() then
        self.inst:AddChild(child)
        child:RemoveFromScene()
        
        if child.components.locomotor then
			child.components.locomotor:Stop()
        end
        
        if child.components.burnable and child.components.burnable:IsBurning() then
            child.components.burnable:Extinguish()
        end
        
        if child.components.health and child.components.health:IsHurt() then
        end
        
        child:RemoveComponent("homeseeker")
        if self.onoccupied then
            self.onoccupied(self.inst, child)
        end
        return true
    end

end


function Spawner:OnChildKilled( child )

	if self.spawnsleft and self.spawnsleft > 0 then
		self.spawnsleft = self.spawnsleft - 1
		if self.spawnsleft == 0 then
			if self.onoutofspawns then
				self.onoutofspawns(self.inst)
			end
		end
	end
	
	if not self.spawnsleft or self.spawnsleft > 0 then
		if not self:IsOccupied() then
			self.child = nil
			self:SpawnWithDelay(self.delay)
		end
	end
	
	
end

return Spawner

