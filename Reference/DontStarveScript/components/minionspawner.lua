local function generatefreepositions(max)
    local pos_table = {}
    for num = 1, max do
        table.insert(pos_table, num)
    end
    return pos_table
end

local pos_modifier = 1.2

local MinionSpawner = Class(function(self, inst)
    self.inst = inst
    self.miniontype = "eyeplant"
    self.maxminions = 27
    self.minionspawntime = { min = 5, max = 10 }
    self.minions = {}
    self.numminions = 0
    self.distancemodifier = 11
    self.onspawnminionfn = nil
    self.onlostminionfn = nil
    self.onminionattacked = nil
    self.onminionattack = nil
    self.spawninprogress = false
    self.nextspawninfo = {}
    self.shouldspawn = true
    self.timeuntilspawn = nil
    self.minionpositions = nil
    self.validtiletypes = { 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 }
    self.freepositions = generatefreepositions(self.maxminions * pos_modifier)
    self.inst:DoTaskInTime(1, function()
        self:StartNextSpawn()
    end)
end)

function MinionSpawner:GetDebugString()
    local str = string.format("Num Minions: %s, Spawn In Progress: %s,  Time For Spawn: %s, Should Spawn: %s",
            tostring(self.numminions), tostring(self.spawninprogress), tostring(self.nextspawninfo.time) or "NIL", tostring(self.shouldspawn))
    return str
end

function MinionSpawner:RemovePosition(num)
    for k, v in pairs(self.freepositions) do
        if v == num then
            table.remove(self.freepositions, k)
        end
    end
    table.sort(self.freepositions)
end

function MinionSpawner:AddPosition(num)
    table.insert(self.freepositions, num)
    table.sort(self.freepositions)
end

local function MakeSaveable(table)
    local tosave = {}
    for k, v in pairs(table) do
        tosave[k] = { x = v.x, y = v.y, z = v.z }
    end
    return tosave
end

local function UnpackSave(table)
    local touse = {}
    for k, v in pairs(table) do
        touse[k] = Vector3(v.x, v.y, v.z)
    end
    return touse
end

function MinionSpawner:OnSave()
    local data = {}
    local guidtable = {}
    for k, v in pairs(self.minions) do
        if not data.minions then
            data.minions = { { GUID = v.GUID, NUMBER = v.minionnumber } }
        else
            table.insert(data.minions, { GUID = v.GUID, NUMBER = v.minionnumber })
        end
        table.insert(guidtable, v.GUID)
    end

    data.maxminions = self.maxminions

    if self.minionpositions ~= nil then
        data.minionpositions = MakeSaveable(self.minionpositions)
    end
    if self.spawninprogress then
        data.spawninprogress = self.spawninprogress
        self.timeuntilspawn = (self.nextspawninfo.start + self.nextspawninfo.time) - GetTime()
        if self.timeuntilspawn < 0 then
            self.timeuntilspawn = 1
        end
        data.timeuntilspawn = self.timeuntilspawn
    end

    return data, guidtable
end

function MinionSpawner:OnLoad(data)

    if data.maxminions then
        self.maxminions = data.maxminions
    end

    self.freepositions = generatefreepositions(self.maxminions * pos_modifier)

    if data.minionpositions then
        self.minionpositions = UnpackSave(data.minionpositions)
    end

    if data.spawninprogress then
        self:ResumeSpawn(data.timeuntilspawn)
    end
end

function MinionSpawner:LoadPostPass(newents, savedata)
    if savedata.minions then
        for k, v in pairs(savedata.minions) do
            local minion = newents[v.GUID]
            if minion then
                minion = minion.entity
                minion.minionnumber = v.NUMBER
                self:TakeOwnership(minion)
                local pos = self:GetSpawnLocation(minion.minionnumber)
                if pos then
                    minion.Transform:SetPosition(pos.x, pos.y, pos.z)
                    self:RemovePosition(minion.minionnumber)
                end
            end
        end
    end
end

function MinionSpawner:TakeOwnership(minion)
    if self.onminionattacked then
        minion.attackedfn = function()
            self.onminionattacked(self.inst)
        end
        self.inst:ListenForEvent("attacked", minion.attackedfn, minion)
    end

    if self.onminionattack then
        minion.attackedotherfn = function()
            self.onminionattack(self.inst)
        end
        self.inst:ListenForEvent("onattackother", minion.attackedotherfn, minion)
    end

    minion.deathfn = function()
        minion:PushEvent("attacked")
        self:OnLostMinion(minion)
    end
    self.inst:ListenForEvent("death", minion.deathfn, minion)
    self.inst:ListenForEvent("onremove", minion.deathfn, minion)
    minion.minionlord = self.inst
    self.minions[minion] = minion
    self.numminions = self.numminions + 1
    self.inst:PushEvent("minionchange")
    if not minion.minionnumber then
        minion.minionnumber = self.freepositions[math.random(#self.freepositions)]
    end
end

function MinionSpawner:OnLostMinion(minion)
    if minion then

        self.inst:DoTaskInTime(3, self:AddPosition(minion.minionnumber))

        if self.onminionattacked then
            self.inst:RemoveEventCallback("attacked", minion.attackedfn, minion)
        end
        if self.onminionattack then
            self.inst:RemoveEventCallback("onattackother", minion.attackedotherfn, minion)
        end

        self.inst:RemoveEventCallback("death", minion.deathfn, minion)
        self.inst:RemoveEventCallback("onremove", minion.deathfn, minion)

        self.minions[minion] = nil
        self.numminions = self.numminions - 1

        self.inst:PushEvent("minionchange")

        if not self:MaxedMinions() and self.shouldspawn then
            self:StartNextSpawn()
        end
    end
end

function MinionSpawner:MakeMinion()
    if self.miniontype and not self:MaxedMinions() then
        return SpawnPrefab(self.miniontype)
    end
end

function MinionSpawner:CheckTileCompatibility(tile)
    for k, v in pairs(self.validtiletypes) do
        if v == tile then
            return true
        end
    end
end

function MinionSpawner:MakeSpawnLocations()
    local positions = {}
    for i = 1, 100 do
        local s = i / 32.0--(num/2) -- 32.0
        local a = math.sqrt(s * 512.0)
        local b = math.sqrt(s)
        table.insert(positions, Vector3(math.sin(a) * b, 0, math.cos(a) * b))
    end

    local useablepositions = {}
    local pt = Vector3(self.inst.Transform:GetWorldPosition())
    local ground = GetWorld()
    for k, v in pairs(positions) do
        local offset = Vector3(v.x * self.distancemodifier, 0, v.z * self.distancemodifier)
        local try_pos = offset + pt
        if not (ground.Map and ground.Map:GetTileAtPoint(try_pos.x, try_pos.y, try_pos.z) == GROUND.IMPASSABLE or ground.Map:GetTileAtPoint(try_pos.x, try_pos.y, try_pos.z) > GROUND.UNDERGROUND) and
                self:CheckTileCompatibility(ground.Map:GetTileAtPoint(try_pos.x, try_pos.y, try_pos.z)) and
                ground.Pathfinder:IsClear(pt.x, pt.y, pt.z, try_pos.x, try_pos.y, try_pos.z, { ignorewalls = true }) and
                #TheSim:FindEntities(try_pos.x, try_pos.y, try_pos.z, 2.5, { "eyeplant" }) <= 0 and
                #TheSim:FindEntities(try_pos.x, try_pos.y, try_pos.z, 1) <= 0 then

            table.insert(useablepositions, try_pos)
            if #useablepositions >= (self.maxminions * pos_modifier) then
                return useablepositions
            end

        end
    end
    --if it couldn't find enough spots for minions.
    self.maxminions = #useablepositions
    self.freepositions = generatefreepositions(self.maxminions)
    if #useablepositions > 0 then
        return useablepositions
    else
        return nil
    end
end

function MinionSpawner:GetSpawnLocation(num)
    -- local pt = Vector3(self.inst.Transform:GetWorldPosition())
    if not self.minionpositions then
        return
    end

    local offset = self.minionpositions[num]
    -- return (pt.x + (offset.x * self.minionradius)), pt.y, (pt.z + (offset.z * self.minionradius))
    if offset and self:CheckTileCompatibility(GetWorld().Map:GetTileAtPoint(offset.x, offset.y, offset.z)) then
        return Vector3(offset.x, offset.y, offset.z)
    end

end

function MinionSpawner:GetNextSpawnTime()
    return math.random(self.minionspawntime.min, self.minionspawntime.max)
end

function MinionSpawner:KillAllMinions()
    self.spawninprogress = false
    for k, v in pairs(self.minions) do
        self.inst:DoTaskInTime(math.random(), function()
            v.components.health:Kill()
        end)
    end
end

function MinionSpawner:SpawnNewMinion()

    if not self.minionpositions then
        self.minionpositions = self:MakeSpawnLocations()
    end

    if not self.minionpositions then
        self.failedFindingPositions = true
        return
    end

    if self.shouldspawn and not self:MaxedMinions() then
        self.spawninprogress = false
        local minion = self:MakeMinion()
        if minion then
            minion.sg:GoToState("spawn")
            self:TakeOwnership(minion)
            local pos = self:GetSpawnLocation(minion.minionnumber)
            if pos then
                minion.Transform:SetPosition(pos.x, pos.y, pos.z)
                self:RemovePosition(minion.minionnumber)

                if self.onspawnminionfn then
                    self.onspawnminionfn(self.inst, minion)
                end
            else
                -- self:RemovePosition(minion.minionnumber)
                -- minion:Remove()
                self.minionpositions = self:MakeSpawnLocations()
            end
        end

        if not self:MaxedMinions() and self.shouldspawn then
            self:StartNextSpawn()
        end
    end
end

function MinionSpawner:MaxedMinions()
    return self.numminions >= self.maxminions
end

function MinionSpawner:SetSpawnInfo(time)
    self.nextspawninfo = {}
    self.nextspawninfo.start = GetTime()
    self.nextspawninfo.time = time
    return time
end

function MinionSpawner:StartNextSpawn()

    if not self.shouldspawn then
        return
    end

    if not self.spawninprogress and not self:MaxedMinions() then
        self.spawninprogress = true
        local time = self:SetSpawnInfo(self:GetNextSpawnTime())
        self.task = self.inst:DoTaskInTime(time, function()
            self:SpawnNewMinion()
        end)
    end
end

function MinionSpawner:ResumeSpawn(time)
    if time < 1 then
        time = 1
    end
    self:SetSpawnInfo(time)
    self.task = self.inst:DoTaskInTime(time, function()
        self:SpawnNewMinion()
    end)
    self.spawninprogress = true
end

function MinionSpawner:LongUpdate(dt)

    local useuptime = function(time)
        local iterations = 0
        while time > 0 do
            time = time - self:GetNextSpawnTime()
            iterations = iterations + 1
        end
        return iterations
    end

    if self.spawninprogress and self.shouldspawn then
        if self.task then
            self.task:Cancel()
            self.task = nil
        end

        local possiblespawns = useuptime(dt)

        -- we don't want to try to generate positions for every minion we spawn
        self.failedFindingPositions = nil
        for i = 1, possiblespawns do
            if self.task then
                self.task:Cancel()
                self.task = nil
            end
            if not self.failedFindingPositions then
                self:SpawnNewMinion()
            end
        end
        self.failedFindingPositions = nil
    end
end

return MinionSpawner