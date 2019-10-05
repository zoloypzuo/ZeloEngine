local BatSpawner = Class(function(self, inst)
	self.inst = inst
	self.inst:StartUpdatingComponent(self)
	self.bats = {}
	self.timetospawn = 0
	self.batcap = 6
	self.spawntime = TUNING.BIRD_SPAWN_DELAY

	self.battypes =
	{
		"bat"
	}

end)

function BatSpawner:GetDebugString()
	return string.format("Bats: %d/%d", GetTableSize(self.bats), self.batcap)
end

function BatSpawner:SetSpawnTimes(times)
	self.spawntime = times
end

function BatSpawner:SetMaxBats(max)
	self.batcap = max
end

function BatSpawner:StartTracking(inst)
    inst.persists = false

    self.bats[inst] = function()
	    if self.bats[inst] then
	        inst:Remove()
	    end
	end

	self.inst:ListenForEvent("entitysleep", self.bats[inst], inst)
end

function BatSpawner:GetSpawnPoint(pt)
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

