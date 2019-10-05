require "brains/krampusbrain"
require "stategraphs/SGkrampus"

local assets=
{
	Asset("ANIM", "anim/krampus_basic.zip"),
	Asset("ANIM", "anim/krampus_build.zip"),
	Asset("SOUND", "sound/krampus.fsb"),
}

local prefabs =
{
	"charcoal",
	"monstermeat",
	"krampus_sack",
}

SetSharedLootTable( 'krampus',
{
    {'monstermeat',  1.0},
    {'charcoal',     1.0},
    {'charcoal',     1.0},
    {'krampus_sack', .01},
})

local function makebagfull(inst)
	inst.AnimState:Show("SACK")
	inst.AnimState:Hide("ARM")
end 

local function makebagempty(inst)
	inst.AnimState:Hide("SACK")
	inst.AnimState:Show("ARM")
end 

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    --inst.components.combat:ShareTarget(data.attacker, SEE_DIST, function(dude) return dude:HasTag("hound") and not dude.components.health:IsDead() end, 5)
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 3, 1 )
    inst.Transform:SetFourFaced()
	inst.AnimState:Hide("ARM")
	
	inst:AddTag("scarytoprey")
	
    MakeCharacterPhysics(inst, 10, .5)

    inst:AddComponent("inventory")
    inst.components.inventory.ignorescangoincontainer = true

     
    anim:SetBank("krampus")
    anim:SetBuild("krampus_build")
    anim:PlayAnimation("run_loop", true)
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.KRAMPUS_SPEED
    inst:SetStateGraph("SGkrampus")

    inst:AddTag("monster")
    inst:AddTag("hostile")

    local brain = require "brains/krampusbrain"
    inst:SetBrain(brain)
    
    MakeLargeBurnableCharacter(inst, "krampus_torso")
    MakeLargeFreezableCharacter(inst, "krampus_torso")
    
 --[[   inst:AddComponent("eater")
    inst.components.eater:SetCarnivore()
	inst.components.eater:SetCanEatHorrible()
    inst.components.eater.strongstomach = true -- can eat monster meat!--]]
    
    inst:AddComponent("sleeper")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.KRAMPUS_HEALTH)
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "krampus_torso"
    inst.components.combat:SetDefaultDamage(TUNING.KRAMPUS_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.KRAMPUS_ATTACK_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('krampus')
    
    inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()
    
    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end


return Prefab( "monsters/krampus", fn, assets, prefabs) 
