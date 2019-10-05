local FlotsamSpawner = Class(function(self, inst)
    self.inst = inst

    self.rebatchtime = TUNING.FLOTSAM_REBATCH_TIME
    self.individualtime = 0
    self.batchremaining = 0

    self.spawnradius = TUNING.FLOTSAM_SPAWN_RADIUS
    self.batchsize = TUNING.FLOTSAM_BATCH_SIZE

    if GetWorld().prefab == "forest" then
        inst:StartUpdatingComponent(self)
    end
end)

function FlotsamSpawner:RainModifier()
    -- flotsam batches are more likely when it's raining ("storms!")
    return 1 + GetWorld().components.seasonmanager:GetPrecipitationRate() * 15
end

function FlotsamSpawner:OnUpdate(dt)
    self.rebatchtime = self.rebatchtime - dt * self:RainModifier()

    if self.rebatchtime <= 0 then
        self.rebatchtime = TUNING.FLOTSAM_REBATCH_TIME
        self.batchremaining = self.batchremaining + self.batchsize.min + math.random(self.batchsize.max-self.batchsize.min)
    end

    self.individualtime = self.individualtime - dt

    if self.individualtime <= 0 and self.batchremaining > 0 then
        self.individualtime = TUNING.FLOTSAM_INDIVIDUAL_TIME
        self.batchremaining = self.batchremaining - 1
        self:SpawnSomeFlotsam()
    end
end

function FlotsamSpawner:SpawnSomeFlotsam()
    local pos = Vector3(self.inst.Transform:GetWorldPosition())
    local offset = FindValidPositionByFan(math.random()*360, self.spawnradius, 20, function(o)
        return GetGroundTypeAtPosition(pos + o) == GROUND.IMPASSABLE
            and nil == FindValidPositionByFan(0, 6, 8, function(o2)
                return GetGroundTypeAtPosition(pos + o + o2) ~= GROUND.IMPASSABLE
            end)
    end)
    if offset then
        --print("SPAWNING SOME FLOTSAM!")
        --c_teleport((pos+offset):Get())
        local flotsam = SpawnPrefab("flotsam")
        flotsam.Transform:SetPosition((pos + offset):Get())
        flotsam.components.drifter:SetDriftTarget(pos)
    end
end

function FlotsamSpawner:OnSave()
    return {
        rebatchtime = self.rebatchtime,
        individualtime = self.individualtime,
        batchremaining = self.batchremaining,
    }
end

function FlotsamSpawner:OnLoad(data)
    self.rebatchtime = data.rebatchtime
    self.individualtime = data.individualtime
    self.batchremaining = data.batchremaining
end

function FlotsamSpawner:GetDebugString()
    return string.format("rebatchtime: %.2f indivtime: %.2f batchremaining: %d", self.rebatchtime, self.individualtime, self.batchremaining)
end

return FlotsamSpawner
