local brain = require "brains/koalefantbrain"
require "stategraphs/SGkoalefant"

local assets=
{
	Asset("ANIM", "anim/koalefant_basic.zip"),
    Asset("ANIM", "anim/koalefant_actions.zip"),
    --Asset("ANIM", "anim/koalefant_build.zip"),
    Asset("ANIM", "anim/koalefant_summer_build.zip"),
    Asset("ANIM", "anim/koalefant_winter_build.zip"),
	Asset("SOUND", "sound/koalefant.fsb"),
}

local prefabs =
{
    "meat",
    "poop",
    "trunk_summer",
    "trunk_winter",
}

local loot_summer = {"meat","meat","meat","meat","meat","meat","meat","meat","trunk_summer"}
local loot_winter = {"meat","meat","meat","meat","meat","meat","meat","meat","trunk_winter"}


local WAKE_TO_RUN_DISTANCE = 10
local SLEEP_NEAR_ENEMY_DISTANCE = 14

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or inst:IsNear(GetPlayer(), WAKE_TO_RUN_DISTANCE)
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not inst:IsNear(GetPlayer(), SLEEP_NEAR_ENEMY_DISTANCE)
end

local function Retarget(inst)

end

local function KeepTarget(inst, target)
    return distsq(Vector3(target.Transform:GetWorldPosition() ), Vector3(inst.Transform:GetWorldPosition() ) ) < TUNING.KOALEFANT_CHASE_DIST * TUNING.KOALEFANT_CHASE_DIST
end

local function OnNewTarget(inst, data)

end

local function GetStatus(inst)

end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30,function(dude)
        return dude:HasTag("koalefant") and not dude:HasTag("player") and not dude.components.health:IsDead()
    end, 5)
end

local function create_base(sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 4.5, 2 )
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 100, .75)
    
    inst:AddTag("koalefant")
    anim:SetBank("koalefant")
    anim:PlayAnimation("idle_loop", true)
    
    inst:AddTag("animal")
    inst:AddTag("largecreature")

    
    inst:AddComponent("eater")
    inst.components.eater:SetVegetarian()
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "beefalo_body"
    inst.components.combat:SetDefaultDamage(TUNING.KOALEFANT_DAMAGE)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("attacked", function(inst, data) OnAttacked(inst, data) end)
    
     
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.KOALEFANT_HEALTH)

    inst:AddComponent("lootdropper")
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    
    inst:AddComponent("knownlocations")
    
    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()

    inst:AddComponent("timer")
    inst:AddComponent("saltlicker")
    inst.components.saltlicker:SetUp(TUNING.SALTLICK_KOALEFANT_USES)

    MakeLargeBurnableCharacter(inst, "beefalo_body")
    MakeLargeFreezableCharacter(inst, "beefalo_body")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 1.5
    inst.components.locomotor.runspeed = 7
    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)
    
    inst:SetBrain(brain)
    inst:SetStateGraph("SGkoalefant")
    return inst
end

local function create_summer(sim)
	local inst = create_base(sim)

    inst.AnimState:SetBuild("koalefant_summer_build")
    inst.components.lootdropper:SetLoot(loot_summer)

	return inst
end

local function create_winter(sim)
	local inst = create_base(sim)

    inst.AnimState:SetBuild("koalefant_winter_build")
    inst.components.lootdropper:SetLoot(loot_winter)

	return inst
end

return Prefab( "forest/animals/koalefant_summer", create_summer, assets, prefabs),
	   Prefab( "forest/animals/koalefant_winter", create_winter, assets, prefabs) 
