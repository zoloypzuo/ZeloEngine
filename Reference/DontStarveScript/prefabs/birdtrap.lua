require "stategraphs/SGtrap"

local assets = {
    Asset("ANIM", "anim/birdtrap.zip"),
    Asset("SOUND", "sound/common.fsb"),

    Asset("ANIM", "anim/crow_build.zip"),
    Asset("ANIM", "anim/robin_build.zip"),
    Asset("ANIM", "anim/robin_winter_build.zip"),

    Asset("INV_IMAGE", "birdtrap"),

    -- Swapsymbol assets
}

local prefabs = {
    -- everything it can "produce" and might need symbol swaps from
    "crow",
    "robin",
    "robin_winter",
}

--this should be redone as a periodic test, probably, so that we can control the expected return explicitly
local function OnSleep(inst)
    if inst.components.trap and inst.components.trap:IsBaited() then
        local ground = GetWorld()
        if ground and ground.components.birdspawner and math.random() < .5 then
            local bird = ground.components.birdspawner:SpawnBird(Vector3(inst.Transform:GetWorldPosition()))
            if bird then
                bird.Transform:SetPosition(inst.Transform:GetWorldPosition())
                bird:ReturnToScene()
                inst.components.trap.target = bird
                inst.components.trap:DoSpring()
                inst.sg:GoToState("full")
            end
        end
    end
end

local sounds = {
    close = "dontstarve/common/birdtrap_close",
    rustle = "dontstarve/common/birdtrap_rustle",
}

local function OnFinished(inst)
    inst:Remove()
end

local function OnHarvested(inst)
    if inst.components.finiteuses then
        inst.components.finiteuses:Use(1)
    end
end

local function SetTrappedSymbols(inst, build)
    inst.trappedbuild = build
    inst.AnimState:OverrideSymbol("trapped", build, "trapped")
end

local function OnSpring(inst, target, bait)
    if target.trappedbuild then
        SetTrappedSymbols(inst, target.trappedbuild)
    end
end

local function OnSave(inst, data)
    if inst.trappedbuild then
        data.trappedbuild = inst.trappedbuild
    end
end

local function OnLoad(inst, data)
    if data and data.trappedbuild then
        SetTrappedSymbols(inst, data.trappedbuild)
    end
end

local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("birdtrap.png")

    anim:SetBank("birdtrap")
    anim:SetBuild("birdtrap")
    anim:PlayAnimation("idle")
    inst.sounds = sounds

    inst:AddTag("trap")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.TRAP_USES)
    inst.components.finiteuses:SetUses(TUNING.TRAP_USES)
    inst.components.finiteuses:SetOnFinished(OnFinished)

    inst:AddComponent("trap")
    inst.components.trap.targettag = "bird"
    inst.components.trap:SetOnHarvestFn(OnHarvested)
    inst.components.trap:SetOnSpringFn(OnSpring)

    inst:ListenForEvent("entitysleep", OnSleep)

    inst:SetStateGraph("SGtrap")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("common/inventory/birdtrap", fn, assets, prefabs)
