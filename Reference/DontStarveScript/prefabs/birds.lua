--[[
birds.lua

Different birds are just reskins of crow without any special powers at the moment.
To make a new bird add it at the bottom of the file as a 'makebird(name)' call

This assumes the bird already has a build, inventory icon, sounds and a feather_name prefab exists

]]--

require "brains/birdbrain"
require "stategraphs/SGbird"

local function TrackInSpawner(inst)
    local ground = GetWorld()
    if ground and ground.components.birdspawner then
        ground.components.birdspawner:StartTracking(inst)
    end
end

local function StopTrackingInSpawner(inst)
    local ground = GetWorld()
    if ground and ground.components.birdspawner then
        ground.components.birdspawner:StopTracking(inst)
    end
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("flying")
end

local function ondrop(inst)
    inst.sg:GoToState("stunned")
end

local function OnAttacked(inst, data)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 30, { 'bird' })

    local num_friends = 0
    local maxnum = 5
    for k, v in pairs(ents) do
        if v ~= inst then
            v:PushEvent("gohome")
            num_friends = num_friends + 1
        end

        if num_friends > maxnum then
            break
        end

    end
end

local function seedspawntest()
    return GetWorld().components.seasonmanager:IsSummer()
end

local function makebird(name, soundname)
    local assets = {
        Asset("ANIM", "anim/crow.zip"),
        Asset("ANIM", "anim/" .. name .. "_build.zip"),
        Asset("SOUND", "sound/birds.fsb"),
    }

    local prefabs = {
        "seeds",
        "smallmeat",
        "cookedsmallmeat",
        "feather_" .. name,
        "note",
    }

    local sounds = {
        takeoff = "dontstarve/birds/takeoff_" .. soundname,
        chirp = "dontstarve/birds/chirp_" .. soundname,
        flyin = "dontstarve/birds/flyin",
    }

    local function OnTrapped(inst, data)
        if data and data.trapper and data.trapper.settrapsymbols then
            data.trapper.settrapsymbols(name .. "_build")
        end
    end

    local function canbeattacked(inst, attacked)
        return not inst.sg:HasStateTag("flying")
    end

    local function fn()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        local sound = inst.entity:AddSoundEmitter()
        inst.sounds = sounds
        inst.entity:AddPhysics()
        inst.Transform:SetTwoFaced()
        local shadow = inst.entity:AddDynamicShadow()
        shadow:SetSize(1, .75)
        shadow:Enable(false)

        inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:SetSphere(1)
        inst.Physics:SetMass(1)

        inst:AddTag("bird")
        inst:AddTag(name)
        inst:AddTag("smallcreature")

        anim:SetBank("crow")
        anim:SetBuild(name .. "_build")
        anim:PlayAnimation("idle")
        inst.trappedbuild = name .. "_build"

        inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        inst.components.locomotor:SetTriggersCreep(false)
        inst:SetStateGraph("SGbird")

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:AddRandomLoot("feather_" .. name, 1)
        inst.components.lootdropper:AddRandomLoot("smallmeat", 1)
        inst.components.lootdropper.numrandomloot = 1

        inst:AddComponent("occupier")

        inst:AddComponent("eater")
        inst.components.eater:SetBird()

        inst:AddComponent("sleeper")
        inst.components.sleeper:SetSleepTest(ShouldSleep)

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.nobounce = true
        inst.components.inventoryitem.canbepickedup = false
        inst.components.inventoryitem:SetOnDroppedFn(ondrop)

        inst:AddComponent("cookable")
        inst.components.cookable.product = "cookedsmallmeat"

        inst:AddComponent("combat")
        inst.components.combat.hiteffectsymbol = "crow_body"
        inst.components.combat.canbeattackedfn = canbeattacked
        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(TUNING.BIRD_HEALTH)
        inst.components.health.murdersound = "dontstarve/wilson/hit_animal"

        inst:AddComponent("inspectable")

        local brain = require "brains/birdbrain"
        inst:SetBrain(brain)

        MakeSmallBurnableCharacter(inst, "crow_body")
        MakeTinyFreezableCharacter(inst, "crow_body")

        inst:AddComponent("periodicspawner")
        inst.components.periodicspawner:SetPrefab("seeds")
        inst.components.periodicspawner:SetDensityInRange(20, 2)
        inst.components.periodicspawner:SetMinimumSpacing(8)
        inst.components.periodicspawner:SetSpawnTestFn(seedspawntest)

        inst.TrackInSpawner = TrackInSpawner

        inst:ListenForEvent("ontrapped", OnTrapped)
        inst:ListenForEvent("onremove", StopTrackingInSpawner)
        inst:ListenForEvent("enterlimbo", StopTrackingInSpawner)
        inst:ListenForEvent("exitlimbo", TrackInSpawner)
        inst:ListenForEvent("attacked", OnAttacked)

        return inst
    end

    return Prefab("forest/animals/" .. name, fn, assets, prefabs)
end

return makebird("crow", "crow"),
makebird("robin", "robin"),
makebird("robin_winter", "junco")
       