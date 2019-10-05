require "brains/walrusbrain"
require "stategraphs/SGwalrus"

local assets=
{
    Asset("ANIM", "anim/walrus_actions.zip"),
    Asset("ANIM", "anim/walrus_attacks.zip"),
    Asset("ANIM", "anim/walrus_basic.zip"),
    Asset("ANIM", "anim/walrus_build.zip"),
    Asset("ANIM", "anim/walrus_baby_build.zip"),
    Asset("SOUND", "sound/mctusky.fsb"),
    Asset("INV_IMAGE", "walrushat"),
    Asset("INV_IMAGE", "walrus_tusk"),
}

local prefabs =
{
    "meat",
    "blowdart_walrus", -- creature weapon
    "blowdart_pipe", -- player loot
    "walrushat",
    "walrus_tusk",
}

SetSharedLootTable( 'walrus',
{
    {'meat',            1.00},
    {'blowdart_pipe',   1.00},
    {'walrushat',       0.25},
    {'walrus_tusk',     0.50},
})

SetSharedLootTable( 'walrus_wee_loot',
{
    ['meat']     = 1.0,
})

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
        return dude:HasTag("walrus") and not dude.components.health:IsDead()
    end, 5)
end

local function Retarget(inst)
    return FindEntity(inst, TUNING.WALRUS_TARGET_DIST, function(guy) 
        return (guy:HasTag("animal") or guy:HasTag("character") or guy:HasTag("monster")) and not (guy:HasTag("hound") or guy:HasTag("walrus")) and inst.components.combat:CanTarget(guy)
    end)
end

local function KeepTarget(inst, target)
    return inst:IsNear(target, TUNING.WALRUS_LOSETARGET_DIST)
end

local function DoReturn(inst)
    --print("DoReturn", inst)
    if inst.components.homeseeker and inst.components.homeseeker.home then
        inst.components.homeseeker.home:PushEvent("onwenthome", {doer = inst})
        inst:Remove()
    end
end

local function OnNight(inst)
    --print("OnNight", inst)
    if inst:IsAsleep() then
        DoReturn(inst)  
    end
end


local function OnEntitySleep(inst)
    --print("OnEntitySleep", inst)
    if not GetClock():IsDay() then
        DoReturn(inst)
    end
end

local function ShouldSleep(inst)
    return not (inst.components.homeseeker and inst.components.homeseeker:HasHome()) and DefaultSleepTest(inst)
end

local function BlowdartDropped(inst)
    inst:Remove()
end

local function EquipBlowdart(inst)
    if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local blowdart = CreateEntity()
        blowdart.entity:AddTransform()
        blowdart:AddComponent("weapon")
        blowdart:AddTag("sharp")
        blowdart.components.weapon:SetDamage(inst.components.combat.defaultdamage)
        blowdart.components.weapon:SetRange(inst.components.combat.attackrange)
        blowdart.components.weapon:SetProjectile("blowdart_walrus")
        blowdart:AddComponent("inventoryitem")
        blowdart.persists = false
        blowdart.components.inventoryitem:SetOnDroppedFn(BlowdartDropped)
        blowdart:AddComponent("equippable")
        
        inst.components.inventory:Equip(blowdart)
    end
end

local function create()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 2.5, 1.5 )
    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(1.5,1.5,1.5)

    MakeCharacterPhysics(inst, 50, .5)    
     
    anim:SetBank("walrus")
    anim:SetBuild("walrus_build")
    
    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = 4
    inst.components.locomotor.walkspeed = 2
    
    inst:SetStateGraph("SGwalrus")
    inst.soundgroup = "mctusk"

    --anim:Hide("hat")

    inst:AddTag("character")
    inst:AddTag("walrus")
    inst:AddTag("houndfriend")

    local brain = require "brains/walrusbrain"
    inst:SetBrain(brain)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetSleepTest(ShouldSleep)

    inst:AddComponent("eater")
    inst.components.eater:SetCarnivore()
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst.components.combat:SetRange(TUNING.WALRUS_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.WALRUS_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.WALRUS_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WALRUS_HEALTH)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('walrus')
    
    inst:AddComponent("inventory")
    
    inst:AddComponent("inspectable")
    
    MakeMediumBurnableCharacter(inst, "swap_fire")
    MakeMediumFreezableCharacter(inst, "pig_torso")
   
    inst:AddComponent("leader")
    
    inst:ListenForEvent("attacked", OnAttacked)

    inst:ListenForEvent( "dusktime", function() OnNight( inst ) end, GetWorld()) 
    inst:ListenForEvent( "nighttime", function() OnNight( inst ) end, GetWorld()) 
    inst.OnEntitySleep = OnEntitySleep
    
    inst:DoTaskInTime(1, EquipBlowdart)

    return inst
end


local function create_little()
    local inst = create()

    inst:AddTag("taunt_attack")

    inst.soundgroup = "wee_mctusk"

    inst.components.lootdropper:SetChanceLootTable('walrus_wee_loot')

    inst.AnimState:SetBuild("walrus_baby_build")

    inst:AddComponent("follower")

    inst.Transform:SetScale(1, 1, 1)

    inst.components.locomotor.runspeed = 5
    inst.components.locomotor.walkspeed = 3

    inst.components.health:SetMaxHealth(TUNING.LITTLE_WALRUS_HEALTH)

    inst.components.combat:SetRange(TUNING.LITTLE_WALRUS_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.LITTLE_WALRUS_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.LITTLE_WALRUS_ATTACK_PERIOD)

    return inst
end

return Prefab( "forest/animals/walrus", create, assets, prefabs), 
    Prefab( "forest/animals/little_walrus", create_little, assets) 
