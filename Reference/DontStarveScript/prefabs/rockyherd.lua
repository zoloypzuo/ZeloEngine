local assets =
{
    --Asset("ANIM", "anim/arrow_indicator.zip"),
}

local prefabs = 
{
    "rocky",
}

local function CanSpawn(inst)
    -- Note that there are other conditions inside periodic spawner governing this as well.
    
    if not inst.components.herd then
        return false
    end

    if inst.components.herd:IsFull() then
        return false
    end

    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, inst.components.herd.gatherrange, inst.components.herd.membertag and {inst.components.herd.membertag} or nil )
    return #ents < TUNING.ROCKYHERD_MAX_IN_RANGE
end

local function OnSpawned(inst, newent)
    if inst.components.herd then
        inst.components.herd:AddMember(newent)
        newent.components.scaler:SetScale(TUNING.ROCKY_MIN_SCALE)
    end
end

local function OnEmpty(inst)
    inst:Remove()
end

local function OnFull(inst)
    --TODO: mark some beefalo for death
end
   
local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    inst:AddTag("herd")
    inst:AddComponent("herd")
    inst.components.herd:SetMemberTag("rocky")
    inst.components.herd:SetGatherRange(TUNING.ROCKYHERD_RANGE)
    inst.components.herd:SetUpdateRange(20)
    inst.components.herd:SetOnEmptyFn(OnEmpty)
    inst.components.herd:SetOnFullFn(OnFull)
    inst.components.herd.maxsize = 6
    
    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetRandomTimes(TUNING.ROCKY_SPAWN_DELAY, TUNING.ROCKY_SPAWN_VAR)
    inst.components.periodicspawner:SetPrefab("rocky")
    inst.components.periodicspawner:SetOnSpawnFn(OnSpawned)
    inst.components.periodicspawner:SetSpawnTestFn(CanSpawn)
    inst.components.periodicspawner:SetDensityInRange(20, 6)
    inst.components.periodicspawner:Start()
    inst.components.periodicspawner:SetOnlySpawnOffscreen(true)
    
    return inst
end

return Prefab( "cave/rockyherd", fn, assets, prefabs) 
