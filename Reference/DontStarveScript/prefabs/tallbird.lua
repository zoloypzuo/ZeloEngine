local brain = require "brains/tallbirdbrain"
require "stategraphs/SGtallbird"

local assets=
{
	Asset("ANIM", "anim/ds_tallbird_basic.zip"),
	Asset("SOUND", "sound/tallbird.fsb"),
}
    
    
local prefabs =
{
    "meat",
}

local loot = { "meat", "meat" }
local MAX_CHASEAWAY_DIST = 32
local MAX_CHASE_DIST = 256

local function FindThreatToNest(inst)
    if inst.components.homeseeker and inst.components.homeseeker:HasHome() then
        return FindEntity(inst.components.homeseeker.home, TUNING.TALLBIRD_DEFEND_DIST, function(guy)
            return (guy:HasTag("character") or guy:HasTag("animal") or guy:HasTag("monster") )
                and not guy:HasTag("tallbird")
                and guy.components.health
                and not guy.components.health:IsDead()
                and inst.components.combat:CanTarget(guy)
        end)
    end
end

local function Retarget(inst)
    local newtarget = FindThreatToNest(inst)
    
    if not newtarget then
        newtarget = FindEntity(inst, TUNING.TALLBIRD_TARGET_DIST, function(guy)
            return guy:HasTag("pig")
                   and not guy:HasTag("werepig")
                   and guy.components.health
                   and not guy.components.health:IsDead()
                   and inst.components.combat:CanTarget(guy)
        end)
    end

    if not newtarget then
        newtarget = FindEntity(inst, TUNING.TALLBIRD_TARGET_DIST, function(guy)
            return (guy:HasTag("character") or guy:HasTag("monster") )
                and not guy:HasTag("tallbird")
                and guy.components.health
                and not guy.components.health:IsDead()
                and inst.components.combat:CanTarget(guy)
        end)
    end
    
    return newtarget
end

local function KeepTarget(inst, target)
    local home = inst.components.homeseeker and inst.components.homeseeker.home
    if home and home.components.pickable then
        if not home.components.pickable:CanBePicked() and target == home.thief then
            return distsq(Vector3(home.Transform:GetWorldPosition() ), Vector3(inst.Transform:GetWorldPosition() ) ) < MAX_CHASE_DIST*MAX_CHASE_DIST
        else
            return distsq(Vector3(home.Transform:GetWorldPosition() ), Vector3(inst.Transform:GetWorldPosition() ) ) < MAX_CHASEAWAY_DIST*MAX_CHASEAWAY_DIST
        end
    else
        return true
    end
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not FindThreatToNest(inst)
end

local function ShouldWake(inst)
    return DefaultWakeTest(inst) or FindThreatToNest(inst)
end

local function OnAttacked(inst, data)
    inst.components.combat:SuggestTarget(data.attacker)
end

local function fn(Sim)
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLightWatcher()
    --inst.Transform:SetScale(1.5,1.5,1.5)
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 2.75, 1)
    inst.Transform:SetFourFaced()
    
    
    ----------
    
    MakeCharacterPhysics(inst, 10, .5)

    
    inst:AddTag("tallbird")
    inst:AddTag("animal")
    inst:AddTag("largecreature")
    inst.AnimState:SetBank("tallbird")
    inst.AnimState:SetBuild("ds_tallbird_basic")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("beakfull")
    
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 7

    inst:SetStateGraph("SGtallbird")
    
    
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)
   
    ---------------------        
    
    
    ------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.TALLBIRD_HEALTH)

    ------------------
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "head"
    inst.components.combat:SetDefaultDamage(TUNING.TALLBIRD_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.TALLBIRD_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetRange(TUNING.TALLBIRD_ATTACK_RANGE)

    MakeLargeBurnableCharacter(inst, "head")
    MakeLargeFreezableCharacter(inst, "head")
    ------------------
    
    inst:AddComponent("knownlocations")

    ------------------
    
    inst:AddComponent("eater")
    inst.components.eater:SetOmnivore()
    
    ------------------
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(function() 
        local sleep = GetClock():IsNight() and not inst.components.combat.target
        return sleep
    end)
    
    inst.components.sleeper:SetWakeTest(function() 
        local sleep = GetClock():IsDay() or inst.components.combat.target
        return sleep
    end)
    ------------------
    
    inst:AddComponent("inspectable")
    
    ------------------
    
    inst:SetBrain(brain)

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

return Prefab( "forest/monsters/tallbird", fn, assets, prefabs) 
