require "brains/houndbrain"
require "stategraphs/SGhound"

local trace = function() end

local assets=
{
	Asset("ANIM", "anim/hound_basic.zip"),
	Asset("ANIM", "anim/hound.zip"),
	Asset("ANIM", "anim/hound_red.zip"),
	Asset("ANIM", "anim/hound_ice.zip"),
	Asset("SOUND", "sound/hound.fsb"),
}

local prefabs =
{
	"houndstooth",
	"monstermeat",
	"redgem",
	"bluegem",
}

SetSharedLootTable( 'hound',
{
    {'monstermeat', 1.000},
    {'houndstooth',  0.125},
})
 
SetSharedLootTable( 'hound_fire',
{
    {'monstermeat', 1.0},
    {'houndstooth', 1.0},
    {'houndfire',   1.0},
    {'houndfire',   1.0},
    {'houndfire',   1.0},
    {'redgem',      0.2},
})

SetSharedLootTable( 'hound_cold',
{
    {'monstermeat', 1.0},
    {'houndstooth', 1.0},
    {'houndstooth', 1.0},
    {'bluegem',     0.2},
})

local WAKE_TO_FOLLOW_DISTANCE = 8
local SLEEP_NEAR_HOME_DISTANCE = 10
local SHARE_TARGET_DIST = 30
local HOME_TELEPORT_DIST = 30

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or (inst.components.follower and inst.components.follower.leader and not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE))
end

local function ShouldSleep(inst)
    return inst:HasTag("pet_hound")
    and not GetClock():IsDay()
    and not (inst.components.combat and inst.components.combat.target)
    and not (inst.components.burnable and inst.components.burnable:IsBurning() )
    and (not inst.components.homeseeker or inst:IsNear(inst.components.homeseeker.home, SLEEP_NEAR_HOME_DISTANCE))
end

local function OnNewTarget(inst, data)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end


local function retargetfn(inst)
    local dist = TUNING.HOUND_TARGET_DIST
    if inst:HasTag("pet_hound") then
        dist = TUNING.HOUND_FOLLOWER_TARGET_DIST
    end
    return FindEntity(inst, dist, function(guy) 
		return not guy:HasTag("wall") and not guy:HasTag("houndmound") and not (guy:HasTag("hound") or guy:HasTag("houndfriend")) and inst.components.combat:CanTarget(guy)
    end)
end

local function KeepTarget(inst, target)
    return inst.components.combat:CanTarget(target) and (not inst:HasTag("pet_hound") or inst:IsNear(target, TUNING.HOUND_FOLLOWER_TARGET_KEEP))
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("hound") or dude:HasTag("houndfriend") and not dude.components.health:IsDead() end, 5)
end

local function OnAttackOther(inst, data)
    inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST, function(dude) return dude:HasTag("hound") or dude:HasTag("houndfriend") and not dude.components.health:IsDead() end, 5)
end

local function GetReturnPos(inst)
    local rad = 2
    local pos = inst:GetPosition()
    trace("GetReturnPos", inst, pos)
    local angle = math.random()*2*PI
    pos = pos + Point(rad*math.cos(angle), 0, -rad*math.sin(angle))
    trace("    ", pos)
    return pos:Get()
end

local function DoReturn(inst)
    --print("DoReturn", inst)
    if inst.components.homeseeker and inst.components.homeseeker:HasHome()  then
        if inst:HasTag("pet_hound") then
            if inst.components.homeseeker.home:IsAsleep() and not inst:IsNear(inst.components.homeseeker.home, HOME_TELEPORT_DIST) then
                local x, y, z = GetReturnPos(inst.components.homeseeker.home)
                inst.Physics:Teleport(x, y, z)
                trace("hound warped home", x, y, z)
            end
        elseif inst.components.homeseeker.home.components.childspawner then
            inst.components.homeseeker.home.components.childspawner:GoHome(inst)
        end
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

local function OnSave(inst, data)
    data.ispet = inst:HasTag("pet_hound")
    --print("OnSave", inst, data.ispet)
end
        
local function OnLoad(inst, data)
    --print("OnLoad", inst, data.ispet)
    if data and data.ispet then
        inst:AddTag("pet_hound")
        inst:AddComponent("follower")
        if inst.sg then
            inst.sg:GoToState("idle")
        end
    end
end

local function fncommon()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 2.5, 1.5 )
    inst.Transform:SetFourFaced()
	
	inst:AddTag("scarytoprey")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("hound")
	
    MakeCharacterPhysics(inst, 10, .5)
     
    anim:SetBank("hound")
    anim:SetBuild("hound")
    anim:PlayAnimation("idle")
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.HOUND_SPEED
    inst:SetStateGraph("SGhound")


    local brain = require "brains/houndbrain"
    inst:SetBrain(brain)
    
    inst:AddComponent("eater")
    inst.components.eater:SetCarnivore()
	inst.components.eater:SetCanEatHorrible()

    inst.components.eater.strongstomach = true -- can eat monster meat!
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.HOUND_HEALTH)
    
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
    
    
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.HOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.HOUND_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, retargetfn)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetHurtSound("dontstarve/creatures/hound/hurt")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('hound')
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)
    inst:ListenForEvent("newcombattarget", OnNewTarget)

    inst:ListenForEvent( "dusktime", function() OnNight( inst ) end, GetWorld()) 
    inst:ListenForEvent( "nighttime", function() OnNight( inst ) end, GetWorld()) 
    inst.OnEntitySleep = OnEntitySleep

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)

    return inst
end

local function fndefault()
	local inst = fncommon(Sim)
	
    MakeMediumFreezableCharacter(inst, "hound_body")
    MakeMediumBurnableCharacter(inst, "hound_body")
	return inst
end

local function fnfire(Sim)
	local inst = fncommon(Sim)
	inst.AnimState:SetBuild("hound_red")
	
    MakeMediumFreezableCharacter(inst, "hound_body")
    inst.components.freezable:SetResistance(4) --because fire

    inst.components.combat:SetDefaultDamage(TUNING.FIREHOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.FIREHOUND_ATTACK_PERIOD)
    inst.components.locomotor.runspeed = TUNING.FIREHOUND_SPEED
    inst.components.health:SetMaxHealth(TUNING.FIREHOUND_HEALTH)
    inst.components.lootdropper:SetChanceLootTable('hound_fire')

	inst:ListenForEvent("death", function(inst)
		inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/firehound_explo", "explosion")
	end)
	
	return inst
end

local function fncold(Sim)
	local inst = fncommon(Sim)
	inst.AnimState:SetBuild("hound_ice")

    MakeMediumBurnableCharacter(inst, "hound_body")

    inst.components.combat:SetDefaultDamage(TUNING.ICEHOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.ICEHOUND_ATTACK_PERIOD)
    inst.components.locomotor.runspeed = TUNING.ICEHOUND_SPEED
    inst.components.health:SetMaxHealth(TUNING.ICEHOUND_HEALTH)
    inst.components.lootdropper:SetChanceLootTable('hound_cold')
	
	inst:ListenForEvent("death", function(inst)
		inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/icehound_explo", "explosion")
	end)

	return inst
end

local function fnfiredrop(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
    MakeInventoryPhysics(inst)

    MakeLargeBurnable(inst, 6+ math.random()*6)
    MakeLargePropagator(inst)
    inst.components.burnable:Ignite()
    inst.persists = false
    inst.components.burnable:SetOnExtinguishFn(function(inst) inst:Remove() end)
    return inst
end


return Prefab( "monsters/hound", fndefault, assets, prefabs),
		Prefab( "monsters/firehound", fnfire, assets, prefabs),
		Prefab( "monsters/icehound", fncold, assets, prefabs),
		Prefab( "monsters/houndfire", fnfiredrop, assets, prefabs) 
