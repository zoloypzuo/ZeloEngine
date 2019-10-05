require "brains/slurtlesnailbrain"
require "stategraphs/SGslurtle"

local assets =
{
	Asset("ANIM", "anim/slurtle.zip"),
    Asset("ANIM", "anim/slurtle_snaily.zip"),
    Asset("SOUND", "sound/slurtle.fsb"),
}

local prefabs =
{
    "slurtleslime",
    "slurtle_shellpieces",
    "slurtlehat",
    "armorsnurtleshell",
    "explode_small"
}

SetSharedLootTable( 'slurtle',
{
    {'slurtleslime',  1.0},
    {'slurtleslime',  1.0},
    {'slurtle_shellpieces',  1.0},
    {'slurtlehat',    0.1},
})

SetSharedLootTable( 'snurtle',
{
    {'slurtleslime',      1.0},
    {'slurtleslime',      1.0},
    {'slurtle_shellpieces',  1.0},
    {'armorsnurtleshell', 0.75},
})

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 40
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40
local SPAWN_SLIME_VALUE = 6


local function KeepTarget(inst, target)
    if target:IsValid() then    
        local homePos = inst.components.knownlocations:GetLocation("home")
        local targetPos = Vector3(target.Transform:GetWorldPosition() )
        return homePos and distsq(homePos, targetPos) < MAX_CHASEAWAY_DIST*MAX_CHASEAWAY_DIST
    end
end

local function Slurtle_OnAttacked(inst, data)
    local attacker = data and data.attacker
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("slurtle") end, MAX_TARGET_SHARES)
end

local function Snurtle_OnAttacked(inst, data)
    local attacker = data and data.attacker
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("slurtle") end, MAX_TARGET_SHARES)
end

local function OnIgniteFn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/rattle", "rattle")
end

local function OnExplodeFn(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:KillSound("rattle")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/explode")
    local explode = SpawnPrefab("explode_small")
    local pos = inst:GetPosition()
    explode.Transform:SetPosition(pos.x, pos.y, pos.z)
    explode.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    explode.AnimState:SetLightOverride(1)
end

local function OnEatElement(inst, data)    
    local value = data.food.components.edible.hungervalue
    inst.stomach = inst.stomach + value
    if inst.stomach >= SPAWN_SLIME_VALUE then
        local stacksize = 0
        while inst.stomach >= SPAWN_SLIME_VALUE do
            inst.stomach = inst.stomach - SPAWN_SLIME_VALUE
            stacksize = stacksize + 1
        end
        local slime = SpawnPrefab("slurtleslime")
        slime.Transform:SetPosition(inst.Transform:GetWorldPosition())
        slime.components.stackable:SetStackSize(stacksize or 1)
    end
end


local function commonfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 2, 1.5 )

    inst.lastmeal = 0
    inst.stomach = 0

    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 50, .5)

    anim:SetBank("slurtle")
    
    inst:AddComponent("locomotor")
    
    inst:SetStateGraph("SGslurtle")    

    inst:AddComponent("eater")
    inst.components.eater:SetElemental()

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "shell"

    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:AddComponent("health")

    inst:AddComponent("lootdropper")
    
    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")
    
    inst:DoTaskInTime(1*FRAMES, function() inst.components.knownlocations:RememberLocation("home", Vector3(inst.Transform:GetWorldPosition()), true) end)
    
    MakeMediumFreezableCharacter(inst, "shell")
    MakeMediumBurnableCharacter(inst, "shell")

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("slurtleslime")
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()

    inst:AddComponent("thief")

    inst:AddComponent("inventory")

    inst:AddComponent("explosive")
    inst.components.explosive.explosiverange = 3
    inst.components.explosive.lightonexplode = false

    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    inst.components.explosive:SetOnIgniteFn(OnIgniteFn)

    inst:ListenForEvent("oneatsomething", function(inst, data) OnEatElement(inst, data) end)

    inst:ListenForEvent("ifnotchanceloot", function() inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/shatter") end)
    
    
    return inst
end

local function makeslurtle()
    local inst = commonfn()

    inst.AnimState:SetBuild("slurtle")

    inst:AddTag("slurtle")
    inst:AddTag("animal")
    local brain = require "brains/slurtlebrain"
    inst:SetBrain(brain)

    inst.components.locomotor.walkspeed = TUNING.SLURTLE_WALK_SPEED
    inst.components.explosive.explosivedamage = TUNING.SLURTLE_EXPLODE_DAMAGE
    inst.components.health:SetMaxHealth(TUNING.SLURTLE_HEALTH)
    inst.components.combat:SetRange(TUNING.SLURTLE_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.SLURTLE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SLURTLE_ATTACK_PERIOD)

    inst.components.lootdropper:SetChanceLootTable('slurtle')

    inst:ListenForEvent("attacked", Slurtle_OnAttacked)

    return inst
end


local function makesnurtle()
    local inst = commonfn()

    inst.AnimState:SetBuild("slurtle_snaily")
    inst.AnimState:SetBank("snurtle")

    inst:AddTag("snurtle")
    inst:AddTag("animal")
    local brain = require "brains/slurtlesnailbrain"
    inst:SetBrain(brain)

    inst.components.locomotor.walkspeed = TUNING.SNURTLE_WALK_SPEED
    inst.components.explosive.explosivedamage = TUNING.SNURTLE_EXPLODE_DAMAGE
    inst.components.health:SetMaxHealth(TUNING.SNURTLE_HEALTH)

    inst.components.lootdropper:SetChanceLootTable('snurtle')

    inst:ListenForEvent("attacked", Snurtle_OnAttacked)

    return inst
end

return Prefab("cave/slurtle", makeslurtle, assets, prefabs),
Prefab("cave/snurtle", makesnurtle, assets, prefabs) 
