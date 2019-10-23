local assets = {
    Asset("ANIM", "anim/monkey_barrel.zip"),
    Asset("SOUND", "sound/monkey.fsb"),
    Asset("MINIMAP_IMAGE", "monkey_barrel"),
}

local prefabs = {
    "monkey",
    "poop",
    "cave_banana"
}

SetSharedLootTable('monkey_barrel',
        {
            { 'poop', 1.0 },
            { 'poop', 1.0 },
            { 'cave_banana', 1.0 },
            { 'cave_banana', 1.0 },
            { 'trinket_4', .01 },
        })

local function shake(inst)
    local anim = ((math.random() > .5) and "move1") or "move2"
    inst.AnimState:PlayAnimation(anim)
    inst.AnimState:PushAnimation("idle")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/monkey/barrel_rattle")
end

local function onhammered(inst, worker)
    inst.shake:Cancel()
    inst.shake = nil
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/monkey_barrel_place")
end

local function onhit(inst, worker)
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren(worker)
    end
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)

    inst.shake:Cancel()
    inst.shake = nil
    inst.shake = inst:DoPeriodicTask(GetRandomWithVariance(10, 3), shake)
end

local function ReturnChildren(inst)
    for k, child in pairs(inst.components.childspawner.childrenoutside) do
        if child.components.homeseeker then
            child.components.homeseeker:GoHome()
        end
        child:PushEvent("gohome")
    end

    if not inst.task then
        inst.task = inst:DoTaskInTime(math.random(60, 120), function()
            inst.task = nil
            inst:PushEvent("safetospawn")
        end)
    end
end

local function OnIgniteFn(inst)
    inst.AnimState:PlayAnimation("shake", true)
    inst.shake:Cancel()
    inst.shake = nil
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren()
        inst:RemoveComponent("childspawner")
    end
end

local function ongohome(inst, child)
    if child.components.inventory then
        child.components.inventory:DropEverything(false, true)
    end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeObstaclePhysics(inst, 1)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("monkey_barrel.png")

    anim:SetBank("barrel")
    anim:SetBuild("monkey_barrel")
    anim:PlayAnimation("idle", true)

    inst:AddComponent("childspawner")
    inst.components.childspawner:SetRegenPeriod(120)
    inst.components.childspawner:SetSpawnPeriod(30)
    inst.components.childspawner:SetMaxChildren(math.random(3, 4))
    inst.components.childspawner:StartRegen()
    inst.components.childspawner.childname = "monkey"
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner.ongohome = ongohome
    inst.components.childspawner:SetSpawnedFn(shake)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('monkey_barrel')

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent("warnquake", function()
        --Monkeys all return on a quake start
        if inst.components.childspawner then
            inst.components.childspawner:StopSpawning()
            ReturnChildren(inst)
        end
    end, GetWorld())

    inst:ListenForEvent("monkeydanger", function()
        --Monkeys all return on a quake start
        if inst.components.childspawner then
            inst.components.childspawner:StopSpawning()
            ReturnChildren(inst)
        end
    end)

    inst:ListenForEvent("safetospawn", function()
        if inst.components.childspawner then
            inst.components.childspawner:StartSpawning()
        end
    end)

    inst:AddComponent("inspectable")

    inst:ListenForEvent("onbuilt", onbuilt)

    MakeLargeBurnable(inst)

    inst.shake = inst:DoPeriodicTask(GetRandomWithVariance(10, 3), shake)
    return inst
end

return Prefab("cave/objects/monkeybarrel", fn, assets, prefabs)
