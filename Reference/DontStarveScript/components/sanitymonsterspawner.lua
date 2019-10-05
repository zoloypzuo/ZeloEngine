local SanityMonsterSpawner = Class(function(self, inst)
    self.inst = inst
    self.inst:StartUpdatingComponent(self)
    self.monsters = {}
    self.shadowhands = {}

	self.popchangetimer = nil
	self.currenttargetpop = 0
	self.currentpop = 0
	self.spawntimer = nil
	
	
	self.num_creepy_eyes = 0
	self.num_watchers = 0
	self.num_skitters = 0
	self.nowatchertime = 10*math.random()
	self.noeyestime = 20*math.random()
	self.noskittersstime = 20*math.random()
	self.creepyhandtimer = TUNING.SEG_TIME*20
end)



function SanityMonsterSpawner:OnSave()
    if self.noserial then return end
    
    local refs = {}
    local data = {
		monsters={},
		shadowhands = {},
		currenttargetpop = self.currenttargetpop,
		popchangetimer = self.popchangetimer,
		spawntimer = self.spawntimer,
		creepyhandtimer = self.creepyhandtimer
	}

    for k,v in pairs(self.monsters) do
		table.insert(data.monsters, v.GUID)
		table.insert(refs, v.GUID)
    end

    for k,v in pairs(self.shadowhands) do
		table.insert(data.shadowhands, v.GUID)
		table.insert(refs, v.GUID)
    end
	
    return data, refs
end


function SanityMonsterSpawner:OnLoad(data)
	self.popchangetimer = data.popchangetimer
	self.currenttargetpop = data.currenttargetpop or 0
	self.spawntimer = data.spawntimer
	self.creepyhandtimer = data.creepyhandtimer or self.creepyhandtimer
end



function SanityMonsterSpawner:OnMonsterRemoved(monster)
	for k,v in pairs(self.monsters) do
		if monster == v then
			table.remove(self.monsters, k)
			self.currentpop = self.currentpop - 1
			return
		end
	end
end

function SanityMonsterSpawner:OnProgress()
	self.noserial = true
end



function SanityMonsterSpawner:LoadPostPass(newents, savedata)
    local num = 0
    if savedata.monsters then
        for k,v in pairs(savedata.monsters) do
            local child = newents[v]
            if child and child.entity:HasTag("shadowcreature") then
				num = num + 1
				child = child.entity
				table.insert(self.monsters, child)
				child:ListenForEvent( "onremove", function() self:OnMonsterRemoved( child ) end, child )	
            end
        end
    end
    
    if savedata.shadowhands then
        for k,v in pairs(savedata.shadowhands) do
            local child = newents[v]
            if child and child.entity:HasTag("shadowhand") then
				child = child.entity
				table.insert(self.shadowhands, child)
				child:ListenForEvent( "onremove", function() self:ShadowHandRemoved( child ) end, child )	
            end
        end
    end
    
    self.currentpop = num
end

function SanityMonsterSpawner:GetDebugString()
	return string.format("%d/%d monsters, (%2.2fs, %2.2f) eyes:%d,%2.2f, hands:%d,%2.2f", self.currentpop, self.currenttargetpop, self.popchangetimer or 0, self.spawntimer or 0, self.num_creepy_eyes, self.noeyestime or 0, #self.shadowhands, self.creepyhandtimer)
end

function SanityMonsterSpawner:AddMonsterOfType(monstername, spawnPos)
	self.currentpop = self.currentpop + 1
	local monster = SpawnPrefab(monstername)		
	monster.Transform:SetPosition(spawnPos:Get() )
	table.insert(self.monsters, monster)
	monster:ListenForEvent( "onremove", function() self:OnMonsterRemoved( monster ) end, monster )	
	
	self.spawntimer = math.random()*10 + 5
	return true
end

function SanityMonsterSpawner:FindHandSpawnPoint()
    local fire = FindEntity(self.inst, 60, function(ent)
        return ent.components.burnable
               and ent.components.burnable:IsBurning()
               and ent.components.fueled
               and not ent.components.equippable
    end)
    
    if fire then
        local theta = math.random() * 2 * PI
        local radius = fire.components.burnable:GetLargestLightRadius()
		local firePos = Vector3(fire.Transform:GetWorldPosition() )
        firePos.y = 0

        if not radius then return end

		local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
			local ground = GetWorld()
			local check_point = firePos + offset
            if TheSim:GetLightAtPoint(check_point:Get()) <= TUNING.DARK_SPAWNCUTOFF 
				and ground.Map:GetTileAtPoint(check_point:Get()) ~= GROUND.IMPASSABLE then
				return true
			end
			return false
		end)

		if result_offset then
			return firePos+result_offset
		end
    end
end

function SanityMonsterSpawner:FindSpawnPoint()
	local radius = 15
	local theta = math.random()*2*PI
	local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ) )
	local spawnPos = Vector3(self.inst.Transform:GetWorldPosition()) + offset  
	return spawnPos
end

function SanityMonsterSpawner:FindCreepyEyeSpawnPoint()
	local radius = 5 + math.random()*10
	local theta = math.random()*2*PI
	local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ) )
	local spawnPos = Vector3(self.inst.Transform:GetWorldPosition()) + offset  
	
	local lightLevel = TheSim:GetLightAtPoint(spawnPos:Get() )
	if lightLevel <= .05 then
		return spawnPos
    end
	
end

function SanityMonsterSpawner:FindWatcherSpawnPoint()
    local fire = FindEntity(self.inst, 60, function(ent)
        return ent.components.burnable
               and ent.components.burnable:IsBurning()
               and ent.components.fueled
               and not ent.components.equippable
    end)
    
    if fire then
		local angle = math.random() * 360
        local radius = 27
		local firePos = Vector3(fire.Transform:GetWorldPosition() )
        firePos.y = 0

		local result_offset = FindValidPositionByFan(angle, radius, 12, function(offset)
			local ground = GetWorld()
			local check_point = firePos + offset
            if TheSim:GetLightAtPoint(check_point:Get()) <= TUNING.DARK_SPAWNCUTOFF then
				return true
			end
			return false
		end)

		if result_offset then
			return firePos+result_offset
		end

    end
	
end



function SanityMonsterSpawner:RemoveRandomMonster()
	
	if self.currentpop > 0 then
		
		local idx = math.random(self.currentpop)
		local monster = self.monsters[idx]
		if monster then
			monster.persists = false
			if monster.sg then
				monster.sg:GoToState("disappear")
			else
				monster:Remove()
			end
			table.remove(self.monsters, idx)
			self.currentpop = self.currentpop - 1
		end
		
	end
end



function SanityMonsterSpawner:UpdateMonsters(dt)
	local sanity = self.inst.components.sanity:GetPercent()

	if self.popchangetimer and self.popchangetimer > 0 then
		self.popchangetimer = self.popchangetimer - dt
	elseif self.inst.components.sanity.inducedinsanity then
		self.popchangetimer = 5
		local maxpop = 5
		local inc_chance = 0.7
		local dec_chance = 0.4

		--figure out our new target
		if self.currenttargetpop > maxpop then
			self.currenttargetpop = self.currenttargetpop - 1
		else
			if inc_chance > 0 and math.random() < inc_chance then
				self.currenttargetpop = self.currenttargetpop + 1
			elseif dec_chance > 0 and math.random() < dec_chance then
				self.currenttargetpop = self.currenttargetpop - 1
			end
		end
	else
		self.popchangetimer = 10 + math.random()*10
		
		local maxpop = 0
		local inc_chance = 0
		local dec_chance = 0
		
		if sanity > 100/200 then
			--we're pretty sane. clean up the monsters
			maxpop = 0
		elseif sanity > 20/200 then
			--have at most one monster, sometimes
			maxpop = 1
			if self.currenttargetpop == 0 then
				inc_chance = .3
			else
				dec_chance = .1
			end
		else
			--have at most one or two monsters, usually 1
			maxpop = 2
			if self.currenttargetpop == 0 then
				inc_chance = .3
			elseif self.currenttargetpop == 2 then
				dec_chance = .2
			else
				inc_chance = .2
				dec_chance = .2
			end
		end
		
		--figure out our new target
		if self.currenttargetpop > maxpop then
			self.currenttargetpop = self.currenttargetpop - 1
		else
			if inc_chance > 0 and math.random() < inc_chance then
				self.currenttargetpop = self.currenttargetpop + 1
			elseif dec_chance > 0 and math.random() < dec_chance then
				self.currenttargetpop = self.currenttargetpop - 1
			end
		end
	end
	
	if self.spawntimer and self.spawntimer > 0 then
		self.spawntimer	= self.spawntimer - dt
	end
	
	
	if self.currenttargetpop > self.currentpop and (not self.spawntimer or self.spawntimer <= 0) then
		
		local pt = self:FindSpawnPoint()	
		if pt and GetMap():GetTileAtPoint(pt:Get()) ~= GROUND.IMPASSABLE then
			local prefab = "crawlinghorror"
			if sanity < 20/200 and math.random() < .5 then
				prefab = "terrorbeak"
			end
			self:AddMonsterOfType(prefab,pt)
		end
		
	elseif self.currenttargetpop < self.currentpop then
		self:RemoveRandomMonster()
	end
end

function SanityMonsterSpawner:GetMaxCreepyEyes()
	local sanity = self.inst.components.sanity:GetPercent()
	local maxeyes = 0
	for k,v in ipairs(TUNING.CREEPY_EYES) do
	    if sanity < v.maxsanity then
	        maxeyes = v.maxeyes
	    elseif sanity >= v.maxsanity then
	        return maxeyes
	    end
	end
	
	return maxeyes
end

function SanityMonsterSpawner:UpdateCreepyEyes(dt)

	if GetClock():IsNight() then
		local sanity = self.inst.components.sanity:GetPercent()
		
		if self.noeyestime and self.noeyestime > 0 then
			self.noeyestime = self.noeyestime - dt
		else
		
			local maxeyes = self:GetMaxCreepyEyes()
			local spawn_interval = 5
			
			if self.num_creepy_eyes < maxeyes then
				local pt = self:FindCreepyEyeSpawnPoint()
				
				if pt then
					local monster = SpawnPrefab("creepyeyes")		
					monster.Transform:SetPosition(pt:Get() )
					monster:ListenForEvent("onremove", function() self.num_creepy_eyes = self.num_creepy_eyes - 1 end, monster )
					self.noeyestime = spawn_interval + math.random()*spawn_interval*.5
					self.num_creepy_eyes = self.num_creepy_eyes + 1
				end
			end
		end
	end
end

function SanityMonsterSpawner:ShadowHandRemoved(hand)
	for k,v in pairs(self.shadowhands) do
		if v == hand then
			table.remove(self.shadowhands, k)
			return
		end
	end

end

function SanityMonsterSpawner:UpdateCreepyHands(dt)

	local sanity = self.inst.components.sanity:GetPercent()
	
	if GetClock():IsNight() and sanity <= .75 and #self.shadowhands == 0 then
		if self.creepyhandtimer and self.creepyhandtimer > 0 then
			self.creepyhandtimer = self.creepyhandtimer - dt
		else
		
			local num = math.random(2)
			
			local pts = {}
			for k = 1, num*2 do
				local pt = self:FindHandSpawnPoint()
				if pt then
					table.insert(pts, pt)				
					if #pts >= num then break end
				end
			end
			
			if #pts == num then
				for k,pt in pairs(pts) do
					local monster = SpawnPrefab("shadowhand")		
					monster.Transform:SetPosition(pt:Get())
					monster:ListenForEvent("onremove", function() self:ShadowHandRemoved(monster) end, monster )
					table.insert(self.shadowhands, monster)
				end
				self.creepyhandtimer = TUNING.SEG_TIME*4 + math.random()*TUNING.SEG_TIME*8
			end
		end
	end

end

function SanityMonsterSpawner:UpdateWatchers(dt)

	local sanity = self.inst.components.sanity:GetPercent()
	
	if GetClock():IsNight() and sanity <= .5 then
		if self.nowatchertime and self.nowatchertime > 0 then
			self.nowatchertime = self.nowatchertime - dt
		else
			local maxwatchers = 0
			local spawn_interval = 30
			if sanity > .3 then
				maxwatchers = 1
			else
			    maxwatchers = 2
			end
			
			if self.num_watchers < maxwatchers then
				local pt = self:FindWatcherSpawnPoint()
				
				if pt then
					local monster = SpawnPrefab("shadowwatcher")		
					monster.Transform:SetPosition(pt:Get() )
					monster:ListenForEvent("onremove", function() self.num_watchers = self.num_watchers - 1 end, monster )
					self.nowatchertime = spawn_interval + math.random()*spawn_interval*.5
					self.num_watchers = self.num_watchers + 1
				end
			end
		end
	end

end

function SanityMonsterSpawner:UpdateSkitters(dt)
	local sanity = self.inst.components.sanity:GetPercent()
	
	if self.noskitterstime and self.noskitterstime > 0 then
		self.noskitterstime = self.noskitterstime - dt
	else
	
		local maxskitters = 0
		local spawn_interval = 10
		if sanity > .8 then
			maxskitters = 0
		elseif sanity > .6 then
			maxskitters = 4
		elseif sanity > .4 then
			maxskitters = 6
		elseif sanity > .2 then
			maxskitters = 8
		end
		
		if self.num_skitters < maxskitters then
			local pt = self:FindSpawnPoint()
			
			if pt then
				local monster = SpawnPrefab("shadowskittish")		
				monster.Transform:SetPosition(pt:Get() )
				monster:ListenForEvent("onremove", function() self.num_skitters = self.num_skitters - 1 end, monster )
				self.noskitterstime = spawn_interval + math.random()*spawn_interval*.5
				self.num_skitters = self.num_skitters + 1
			end
		end
	end
end


function SanityMonsterSpawner:OnUpdate(dt)
	self:UpdateMonsters(dt)	
	self:UpdateCreepyEyes(dt)
	self:UpdateCreepyHands(dt)
	self:UpdateWatchers(dt)
	self:UpdateSkitters(dt)
end

function SanityMonsterSpawner:LongUpdate(dt)
	self:OnUpdate(dt)
end

return SanityMonsterSpawner
