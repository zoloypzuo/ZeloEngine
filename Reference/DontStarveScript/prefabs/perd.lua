require "brains/perdbrain"
require "stategraphs/SGperd"

local assets=
{
	Asset("ANIM", "anim/perd_basic.zip"),
	Asset("ANIM", "anim/perd.zip"),
	Asset("SOUND", "sound/perd.fsb"),
}

local prefabs =
{
    "drumstick",
}

local loot = 
{
    "drumstick",
    "drumstick",
}
 
local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.5, .75 )
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 50, .5)    
     
    anim:SetBank("perd")
    anim:SetBuild("perd")
    
    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.PERD_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.PERD_WALK_SPEED
    
    inst:SetStateGraph("SGperd")
    anim:Hide("hat")

    inst:AddTag("character")
    inst:AddTag("berrythief")

    inst:AddComponent("homeseeker")
    local brain = require "brains/perdbrain"
    inst:SetBrain(brain)
    
    inst:AddComponent("eater")
    inst.components.eater:SetVegetarian()
    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest( function() return true end)    --always wake up if we're asleep

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.PERD_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.PERD_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.PERD_ATTACK_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)
    
    inst:AddComponent("inventory")
    
    inst:AddComponent("inspectable")
    
    MakeMediumBurnableCharacter(inst, "pig_torso")
    MakeMediumFreezableCharacter(inst, "pig_torso")
    
    return inst
end

return Prefab( "forest/animals/perd", fn, assets, prefabs) 
