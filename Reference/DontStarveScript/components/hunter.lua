local trace = function() end
--local trace = function(...) print(...) end

local HUNT_UPDATE = 2

local MIN_TRACKS = 6
local MAX_TRACKS = 12

local Hunter = Class(function(self, inst)
    self.inst = inst
    
    self.dirt_prefab = "dirtpile"
    self.track_prefab = "animal_track"
    self.beast_prefab_summer = "koalefant_summer"
    self.beast_prefab_winter = "koalefant_winter"
    self.alternate_beast_prefab = "spat"

    self.trackspawned = 0
    self.numtrackstospawn = 0

    self.inst:DoTaskInTime(0, function(inst) inst.components.hunter:StartCooldown() end)
end)

function Hunter:OnSave()
    trace("Hunter:OnSave")
    local time = GetTime()
    local data = {}
    local references = {}

    if self.lastkillpos then
        trace("       last kill", self.lastkillpos)
        data.lastkillpos = { x = self.lastkillpos.x, y = self.lastkillpos.y, z = self.lastkillpos.z }
    end

    if self.lastdirttime then
        data.timesincedirt = GetTime() - self.lastdirttime
    end

    if self.cooldowntask then
        -- we're cooling down
        data.cooldownremaining = math.max(1, self.cooldowntime - time)
        trace("   cooling down", data.cooldownremaining)
    else
        trace("   hunting")
        -- we're hunting

        if self.lastdirt then
            table.insert(references, self.lastdirt.GUID)
            data.lastdirtid = self.lastdirt.GUID
            trace("       has dirt", data.lastdirtid)
    
            data.numtrackstospawn = self.numtrackstospawn
            data.trackspawned = self.trackspawned
            data.direction = self.direction

            trace("       numtrackstospawn", data.numtrackstospawn)
            trace("       trackspawned", data.trackspawned)
            trace("       direction", data.direction)
        elseif self.huntedbeast then
            data.beastid = self.huntedbeast.GUID
            table.insert(references, self.huntedbeast.GUID)
            trace("       has beast", data.beastid)
        end
    end
    return data, references
end

function Hunter:OnLoad(data)
    trace("Hunter:OnLoad")

    if data.lastkillpos then
        self.lastkillpos = Point(data.lastkillpos.x, data.lastkillpos.y, data.lastkillpos.z)
        trace("   last kill", self.lastkillpos)
    end

    if data.timesincedirt then
        self.lastdirttime = -data.timesincedirt
    end

    if data.cooldownremaining then
        trace("   cooling down", data.cooldownremaining)
        self:StartCooldown(math.clamp(data.cooldownremaining, 1, TUNING.HUNT_COOLDOWN + TUNING.HUNT_COOLDOWNDEVIATION))
    else
        trace("   hunting")

        self:StopCooldown()

        -- continued in LoadPostPass
    end
end

function Hunter:LoadPostPass(newents, data)
    trace("Hunter:LoadPostPass")

    if not data.cooldownremaining then

        trace("   hunting")
        if data.lastdirtid then
            trace("       has dirt", data.lastdirtid)
            self.lastdirt = newents[data.lastdirtid] and newents[data.lastdirtid].entity

            --dumptable(self.lastdirt)
    
            if self.lastdirt then
                self.numtrackstospawn = data.numtrackstospawn or math.random(MIN_TRACKS, MAX_TRACKS)
                self.trackspawned = data.trackspawned or 0
                self.direction = data.direction -- nil ok

                trace("       numtrackstospawn", self.numtrackstospawn)
                trace("       trackspawned", self.trackspawned)
                trace("       direction", self.direction)
            end

            self:BeginHunt()
        elseif data.beastid then
            trace("       has beast", data.beastid)
            self.huntedbeast = newents[data.beastid] and newents[data.beastid].entity

            --dumptable(self.huntedbeast)

            if self.huntedbeast then
                self:StopCooldown()
                self.inst:ListenForEvent("death", function(inst, data) self:OnBeastDeath(self.huntedbeast) end, self.huntedbeast)
            else
                self:BeginHunt()
            end
        else
            self:BeginHunt()
        end
    end

end

function Hunter:RemoveDirt()
    trace("Hunter:RemoveDirt")
    if self.lastdirt then
        trace("   removing old dirt")
        self.lastdirt:Remove()
        self.lastdirt = nil
    else
        trace("   nothing to remove")
    end
end

function Hunter:StartDirt()
    trace("Hunter:StartDirt")

    self:RemoveDirt()

    local pt = Vector3(GetPlayer().Transform:GetWorldPosition())

    self.numtrackstospawn = math.random(MIN_TRACKS, MAX_TRACKS)
    self.trackspawned = 0
    self.direction = self:GetNextSpawnAngle(pt, nil, TUNING.HUNT_SPAWN_DIST)
    if self.direction then
        trace(string.format("   first angle: %2.2f", self.direction/DEGREES))

        trace("    numtrackstospawn", self.numtrackstospawn)

        -- it's ok if this spawn fails, because we'll keep trying every HUNT_UPDATE
        if self:SpawnDirt() then
            print("Suspicious dirt placed")
        end
    else
        print("Failed to find suitable dirt placement point")
    end
end

function Hunter:OnUpdate()
    trace("Hunter:OnUpdate")

    local mypos = Point(GetPlayer().Transform:GetWorldPosition())

    if not self.lastdirt then
        local distance = 0
        if not self.lastkillpos then
            self.lastkillpos = Point(GetPlayer().Transform:GetWorldPosition())
        end

        distance = math.sqrt( distsq( mypos, self.lastkillpos ) )
        self.distance = distance
        trace(string.format("    %2.2f", distance)) 

        if distance > TUNING.MIN_HUNT_DISTANCE then
            self:StartDirt()
        end
    else
        local distance = 0
        local dirtpos = Point(self.lastdirt.Transform:GetWorldPosition())

        distance = math.sqrt( distsq( mypos, dirtpos ) )
        self.distance = distance
        trace(string.format("    dirt %2.2f", distance))

        if distance > TUNING.MAX_DIRT_DISTANCE then
            self:StartDirt()
        end
    end
end

-- something went unrecoverably wrong, try again after a breif pause
function Hunter:ResetHunt()
    trace("Hunter:ResetHunt")

    print("The Hunt was a dismal failure, please stand by...")

    --self.lastkillpos = nil
    self:StartCooldown(TUNING.HUNT_RESET_TIME)
    GetPlayer():PushEvent("huntlosttrail")
end

-- if anything fails during this step, it's basically unrecoverable, since we only have this one chance
-- to spawn whatever we need to spawn.  if that fails, we need to restart the whole process from the beginning
-- and hope we end up in a better place
function Hunter:OnDirtInvestigated(pt)
    trace("Hunter:OnDirtInvestigated")

    if self.numtrackstospawn and self.numtrackstospawn > 0 then
        if self:SpawnTrack(pt) then
            trace("    ", self.trackspawned, self.numtrackstospawn)
            if self.trackspawned < self.numtrackstospawn then
                if self:SpawnDirt() then
                    trace("...good job, you found a track!")
                else
                    print("SpawnDirt FAILED! RESETTING")
                    self:ResetHunt()
                end
            elseif self.trackspawned == self.numtrackstospawn then
                if self:SpawnHuntedBeast() then
                    trace("...you found the last track, now find the beast!")
                    GetPlayer():PushEvent("huntbeastnearby")
                    self:StopHunt()
                else
                    print("SpawnHuntedBeast FAILED! RESETTING")
                    self:ResetHunt()
                end
            end
        else
            print("SpawnTrack FAILED! RESETTING")
            self:ResetHunt()
        end
    end
end

function Hunter:OnBeastDeath(spawned)
    trace("Hunter:OnBeastDeath")
    self:StartCooldown()
    self.lastkillpos = Point(GetPlayer().Transform:GetWorldPosition())
end

function Hunter:GetRunAngle(pt, angle, radius)
    local offset, result_angle = FindWalkableOffset(pt, angle, radius, 14, true)
    if result_angle then
        return result_angle
    end
end

function Hunter:GetNextSpawnAngle(pt, direction, radius)
    trace("Hunter:GetNextSpawnAngle", tostring(pt), radius)

    local base_angle = direction or math.random() * 2 * PI
    local deviation = math.random(-TUNING.TRACK_ANGLE_DEVIATION, TUNING.TRACK_ANGLE_DEVIATION)*DEGREES

    local start_angle = base_angle + deviation
    trace(string.format("   original: %2.2f, deviation: %2.2f, starting angle: %2.2f", base_angle/DEGREES, deviation/DEGREES, start_angle/DEGREES))

    local angle = self:GetRunAngle(pt, start_angle, radius)
    trace(string.format("Hunter:GetSpawnPoint RESULT %s", tostring(angle and angle/DEGREES)))
    return angle
end

function Hunter:GetSpawnPoint(pt, radius)
    trace("Hunter:GetSpawnPoint", tostring(pt), radius)

    local angle = self.direction
    if angle then
        local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
        local spawn_point = pt + offset
        trace(string.format("Hunter:GetSpawnPoint RESULT %s, %2.2f", tostring(spawn_point), angle/DEGREES))
        return spawn_point
    end

end

function Hunter:GetAlternateBeastChance()
    local day = GetClock():GetNumCycles()
    local chance = Lerp(TUNING.HUNT_ALTERNATE_BEAST_CHANCE_MIN, TUNING.HUNT_ALTERNATE_BEAST_CHANCE_MAX, day/100)
    chance = math.clamp(chance, TUNING.HUNT_ALTERNATE_BEAST_CHANCE_MIN, TUNING.HUNT_ALTERNATE_BEAST_CHANCE_MAX)
    return chance
end

function Hunter:SpawnHuntedBeast()
    trace("Hunter:SpawnHuntedBeast")
    local pt = Vector3(GetPlayer().Transform:GetWorldPosition())
        
    local spawn_pt = self:GetSpawnPoint(pt, TUNING.HUNT_SPAWN_DIST)
    if spawn_pt then
        if math.random() > self:GetAlternateBeastChance() then
            if GetWorld().components.seasonmanager:IsWinter() then
                self.huntedbeast = SpawnPrefab(self.beast_prefab_winter)
            else
                self.huntedbeast = SpawnPrefab(self.beast_prefab_summer)
            end
        else
            self.huntedbeast = SpawnPrefab(self.alternate_beast_prefab)
        end
        if self.huntedbeast then
            print("Kill the Beast!")
            self.huntedbeast.Physics:Teleport(spawn_pt:Get())
            self.inst:ListenForEvent("death", function(inst, data) self:OnBeastDeath(self.huntedbeast) end, self.huntedbeast)
            return true
        end
    end
    print("Hunter:SpawnHuntedBeast FAILED")
    return false
end

function Hunter:SpawnDirt()
    trace("Hunter:SpawnDirt")
    local pt = Vector3(GetPlayer().Transform:GetWorldPosition())

    local spawn_pt = self:GetSpawnPoint(pt, TUNING.HUNT_SPAWN_DIST)
    if spawn_pt then
        local spawned = SpawnPrefab(self.dirt_prefab)
        if spawned then
            self.lastdirttime = GetTime()
            spawned.Transform:SetPosition(spawn_pt:Get())
            self.lastdirt = spawned
            return true
        end
    end
    print("Hunter:SpawnDirt FAILED")
    return false
end

function Hunter:SpawnTrack(spawn_pt)
    trace("Hunter:SpawnTrack")

    if spawn_pt then
        local next_angle = self:GetNextSpawnAngle(spawn_pt, self.direction, TUNING.HUNT_SPAWN_DIST)
        if next_angle then
            local spawned = SpawnPrefab(self.track_prefab)
            if spawned then
                spawned.Transform:SetPosition(spawn_pt:Get())

                self.direction = next_angle

                trace(string.format("   next angle: %2.2f", self.direction/DEGREES))
                spawned.Transform:SetRotation(self.direction/DEGREES - 90)

                self.trackspawned = self.trackspawned + 1
                trace(string.format("   spawned %u/%u", self.trackspawned, self.numtrackstospawn))
                return true
            end
        end
    end
    print("Hunter:SpawnTrack FAILED")
    return false
end

function Hunter:StopHunt()
    trace("Hunter:StopHunt")

    self:RemoveDirt()

    if self.hunttask then
        trace("   stopping")
        self.hunttask:Cancel()
        self.hunttask = nil
    else
        trace("   nothing to stop")
    end
end

function Hunter:BeginHunt()
    trace("Hunter:BeginHunt")

    self.hunttask = self.inst:DoPeriodicTask(HUNT_UPDATE, function() self:OnUpdate() end)
    if self.hunttask then
        trace("The Hunt Begins!")
    else
        trace("The Hunt ... failed to begin.")
    end

end

function Hunter:OnCooldownEnd()
    trace("Hunter:OnCooldownEnd")
    
    self:StopCooldown() -- clean up references
    self:StopHunt()

    self:BeginHunt()
end

function Hunter:StopCooldown()
    trace("Hunter:StopCooldown")
    if self.cooldowntask then
        trace("    stopping")
        self.cooldowntask:Cancel()
        self.cooldowntask = nil
        self.cooldowntime = nil
    else
        trace("    nothing to stop")
    end
end

function Hunter:StartCooldown(cooldown)
    local cooldown = cooldown or math.random(TUNING.HUNT_COOLDOWN - TUNING.HUNT_COOLDOWNDEVIATION, TUNING.HUNT_COOLDOWN + TUNING.HUNT_COOLDOWNDEVIATION)
    trace("Hunter:StartCooldown", cooldown)

    self:StopHunt()
    self:StopCooldown()

    if GetPlayer() and GetPlayer().components.health:IsDead() then
        return
    end

    if cooldown and cooldown > 0 then
        --print("The Hunt begins in", cooldown)
        self.lastdirttime = nil
        self.cooldowntask = self.inst:DoTaskInTime(cooldown, function() self:OnCooldownEnd() end)
        self.cooldowntime = GetTime() + cooldown
    end
end

function Hunter:GetDebugString()
    local str = ""
    
    str = str.." Cooldown: ".. (self.cooldowntime and string.format("%2.2f", math.max(1, self.cooldowntime - GetTime())) or "-")
    if not self.lastdirt then
        str = str.." No last dirt."
        str = str.." Distance: ".. (self.distance and string.format("%2.2f", self.distance) or "-")
        str = str.."/"..tostring(TUNING.MIN_HUNT_DISTANCE)
    else
        str = str.." Dirt"
        str = str.." Distance: ".. (self.distance and string.format("%2.2f", self.distance) or "-")
        str = str.."/"..tostring(TUNING.MAX_DIRT_DISTANCE)
    end
    return str
end


return Hunter
