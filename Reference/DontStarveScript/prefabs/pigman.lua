require "brains/pigbrain"
require "brains/pigguardbrain"
require "brains/werepigbrain"
require "stategraphs/SGpig"
require "stategraphs/SGwerepig"

local assets =
{
	Asset("ANIM", "anim/ds_pig_basic.zip"),
	Asset("ANIM", "anim/ds_pig_actions.zip"),
	Asset("ANIM", "anim/ds_pig_attacks.zip"),
	Asset("ANIM", "anim/pig_build.zip"),
	Asset("ANIM", "anim/pigspotted_build.zip"),
	Asset("ANIM", "anim/pig_guard_build.zip"),
	Asset("ANIM", "anim/werepig_build.zip"),
	Asset("ANIM", "anim/werepig_basic.zip"),
	Asset("ANIM", "anim/werepig_actions.zip"),
	Asset("SOUND", "sound/pig.fsb"),
}

local prefabs =
{
    "meat",
    "monstermeat",
    "poop",
    "tophat",
    "strawhat",
    "pigskin",
}

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30

local function ontalk(inst, script)
	inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
end


local function CalcSanityAura(inst, observer)
	if inst.components.werebeast
       and inst.components.werebeast:IsInWereState() then
		return -TUNING.SANITYAURA_LARGE
	end
	
	if inst.components.follower and inst.components.follower.leader == observer then
		return TUNING.SANITYAURA_SMALL
	end
	
	return 0
end


local function ShouldAcceptItem(inst, item)
    if inst.components.sleeper:IsAsleep() then
        return false
    end

    if item.components.equippable and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        return true
    end
    if item.components.edible then
        
        if (item.components.edible.foodtype == "MEAT" or item.components.edible.foodtype == "HORRIBLE")
           and inst.components.follower.leader
           and inst.components.follower:GetLoyaltyPercent() > 0.9 then
            return false
        end
        
        if item.components.edible.foodtype == "VEGGIE" then
			local last_eat_time = inst.components.eater:TimeSinceLastEating()
			if last_eat_time and last_eat_time < TUNING.PIG_MIN_POOP_PERIOD then        
				return false
			end

            if inst.components.inventory:Has(item.prefab, 1) then
                return false
            end
		end
		
        return true
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
    
    --I eat food
    if item.components.edible then
        --meat makes us friends (unless I'm a guard)
        if item.components.edible.foodtype == "MEAT" or item.components.edible.foodtype == "HORRIBLE" then
            if inst.components.combat.target and inst.components.combat.target == giver then
                inst.components.combat:SetTarget(nil)
            elseif giver.components.leader and not inst:HasTag("guard") then
				inst.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
				giver.components.leader:AddFollower(inst)
                inst.components.follower:AddLoyaltyTime(item.components.edible:GetHunger() * TUNING.PIG_LOYALTY_PER_HUNGER)
            end
        end
        if inst.components.sleeper:IsAsleep() then
            inst.components.sleeper:WakeUp()
        end
    end

    
    --I wear hats
    if item.components.equippable and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        local current = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if current then
            inst.components.inventory:DropItem(current)
        end
        
        inst.components.inventory:Equip(item)
        inst.AnimState:Show("hat")
    end
end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function OnEat(inst, food)
    if food.components.edible
       and food.components.edible.foodtype == "MEAT"
       and inst.components.werebeast
       and not inst.components.werebeast:IsInWereState() then
        if food.components.edible:GetHealth() < 0 then
            inst.components.werebeast:TriggerDelta(1)
        end
    end
    
    if food.components.edible and food.components.edible.foodtype == "VEGGIE" then
		local poo = SpawnPrefab("poop")
		poo.Transform:SetPosition(inst.Transform:GetWorldPosition())		
	end
    
end

local function OnAttacked(inst, data)
    --print(inst, "OnAttacked")
    local attacker = data.attacker

    inst.components.combat:SetTarget(attacker)

    if inst:HasTag("werepig") then
        inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("werepig") end, MAX_TARGET_SHARES)
    elseif inst:HasTag("guard") then
            inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("pig") and (dude:HasTag("guard") or not attacker:HasTag("pig")) end, MAX_TARGET_SHARES)
    else
        if not (attacker:HasTag("pig") and attacker:HasTag("guard") ) then
            inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("pig") and not dude:HasTag("werepig") end, MAX_TARGET_SHARES)
        end
    end
end

local function OnNewTarget(inst, data)
    if inst:HasTag("werepig") then
        --print(inst, "OnNewTarget", data.target)
        inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST, function(dude) return dude:HasTag("werepig") end, MAX_TARGET_SHARES)
    end
end

local builds = {"pig_build", "pigspotted_build"}
local guardbuilds = {"pig_guard_build"}


local function NormalRetargetFn(inst)
    return FindEntity(inst, TUNING.PIG_TARGET_DIST,
        function(guy)
            if not guy.LightWatcher or guy.LightWatcher:IsInLight() then
                return guy:HasTag("monster") and guy.components.health and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy) and not 
                (inst.components.follower.leader ~= nil and guy:HasTag("abigail"))
            end
        end)
end
local function NormalKeepTargetFn(inst, target)
    --give up on dead guys, or guys in the dark, or werepigs
    return inst.components.combat:CanTarget(target)
           and (not target.LightWatcher or target.LightWatcher:IsInLight())
           and not (target.sg and target.sg:HasStateTag("transform") )
end
local function NormalShouldSleep(inst)
    if inst.components.follower and inst.components.follower.leader then
        local fire = FindEntity(inst, 6, function(ent)
            return ent.components.burnable
                   and ent.components.burnable:IsBurning()
        end, {"campfire"})
        return DefaultSleepTest(inst) and fire and (not inst.LightWatcher or inst.LightWatcher:IsInLight())
    else
        return DefaultSleepTest(inst)
    end
end
local function SetNormalPig(inst)
    inst:RemoveTag("werepig")
    inst:RemoveTag("guard")
    local brain = require "brains/pigbrain"
    inst:SetBrain(brain)
    inst:SetStateGraph("SGpig")
	inst.AnimState:SetBuild(inst.build)
    
	inst.components.werebeast:SetOnNormalFn(SetNormalPig)
    inst.components.sleeper:SetResistance(2)

    inst.components.combat:SetDefaultDamage(TUNING.PIG_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.PIG_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
    inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED
    
    inst.components.sleeper:SetSleepTest(NormalShouldSleep)
    inst.components.sleeper:SetWakeTest(DefaultWakeTest)
    
    inst.components.lootdropper:SetLoot({})
    inst.components.lootdropper:AddRandomLoot("meat",3)
    inst.components.lootdropper:AddRandomLoot("pigskin",1)
    inst.components.lootdropper.numrandomloot = 1

    inst.components.health:SetMaxHealth(TUNING.PIG_HEALTH)
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    inst.components.combat:SetTarget(nil)
    
    inst.components.trader:Enable()
    inst.components.talker:StopIgnoringAll()
    inst.components.combat:SetHurtSound(nil)

end

local function GuardRetargetFn(inst)
    local home = inst.components.homeseeker and inst.components.homeseeker.home
    --defend the king, then the torch, then myself
    local defenseTarget = FindEntity(inst, TUNING.PIG_GUARD_DEFEND_DIST, function(guy) return guy:HasTag("king") end)
    if not defenseTarget and home and inst:GetDistanceSqToInst(home) < TUNING.PIG_GUARD_DEFEND_DIST*TUNING.PIG_GUARD_DEFEND_DIST then
        defenseTarget = home
    end
    if not defenseTarget then
        defenseTarget = inst
    end
    local invader = FindEntity(defenseTarget or inst, TUNING.PIG_GUARD_TARGET_DIST, function(guy)
        return guy:HasTag("character") and not guy:HasTag("guard")
    end)
    if not defenseTarget.happy then
        if invader
           and not (defenseTarget.components.trader and defenseTarget.components.trader:IsTryingToTradeWithMe(invader) )
           and not (inst.components.trader and inst.components.trader:IsTryingToTradeWithMe(invader) ) then
            return invader
        end
        if not GetClock():IsDay() and home and home.components.burnable and home.components.burnable:IsBurning() then
            local lightThief = FindEntity(home, home.components.burnable:GetLargestLightRadius(), function(guy)
                return guy:HasTag("player")
                       and guy.LightWatcher:IsInLight()
                       and not (defenseTarget.components.trader and defenseTarget.components.trader:IsTryingToTradeWithMe(guy) ) 
                       and not (inst.components.trader and inst.components.trader:IsTryingToTradeWithMe(guy) ) 
            end)
            if lightThief then
                return lightThief
            end
        end
    end
    return FindEntity(defenseTarget, TUNING.PIG_GUARD_DEFEND_DIST, function(guy)
        return guy:HasTag("monster")
    end)
end
local function GuardKeepTargetFn(inst, target)
    local home = inst.components.homeseeker and inst.components.homeseeker.home
    if home then
        local defendDist = TUNING.PIG_GUARD_DEFEND_DIST
        if not GetClock():IsDay() and home.components.burnable and home.components.burnable:IsBurning() then
            defendDist = home.components.burnable:GetLargestLightRadius()
        end
        return home:GetDistanceSqToInst(target) < defendDist*defendDist
               and home:GetDistanceSqToInst(inst) < defendDist*defendDist
    end
    return inst.components.combat:CanTarget(target)     
           and not (target.sg and target.sg:HasStateTag("transform") )
end
local function GuardShouldSleep(inst)
    return false
end
local function GuardShouldWake(inst)
    return true
end
local function SetGuardPig(inst)
    inst:RemoveTag("werepig")
    inst:AddTag("guard")
    local brain = require "brains/pigguardbrain"
    inst:SetBrain(brain)
    inst:SetStateGraph("SGpig")
	inst.AnimState:SetBuild(inst.build)
    
	inst.components.werebeast:SetOnNormalFn(SetGuardPig)
    inst.components.sleeper:SetResistance(3)

    inst.components.health:SetMaxHealth(TUNING.PIG_GUARD_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.PIG_GUARD_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.PIG_GUARD_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(GuardKeepTargetFn)
    inst.components.combat:SetRetargetFunction(1, GuardRetargetFn)
    inst.components.combat:SetTarget(nil)
    inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED
    
    inst.components.sleeper:SetSleepTest(GuardShouldSleep)
    inst.components.sleeper:SetWakeTest(GuardShouldWake)
    
    inst.components.lootdropper:SetLoot({})
    inst.components.lootdropper:AddRandomLoot("meat",3)
    inst.components.lootdropper:AddRandomLoot("pigskin",1)
    inst.components.lootdropper.numrandomloot = 1

    
    inst.components.trader:Enable()
    inst.components.talker:StopIgnoringAll()
    inst.components.follower:SetLeader(nil)

    inst.components.combat:SetHurtSound(nil)

end

local function WerepigRetargetFn(inst)
    return FindEntity(inst, TUNING.PIG_TARGET_DIST, function(guy)
        return inst.components.combat:CanTarget(guy)
               and not guy:HasTag("werepig")
               and not (guy.sg and guy.sg:HasStateTag("transform") )
               and not guy:HasTag("alwaysblock")
    end)
end
local function WerepigKeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
           and not target:HasTag("werepig")
           and not (target.sg and target.sg:HasStateTag("transform") )
end
local function WerepigSleepTest(inst)
    return false
end
local function WerepigWakeTest(inst)
    return true
end
local function SetWerePig(inst)
    inst:AddTag("werepig")
    inst:RemoveTag("guard")
    local brain = require "brains/werepigbrain"
    inst:SetBrain(brain)
    inst:SetStateGraph("SGwerepig")
    inst.AnimState:SetBuild("werepig_build")

    inst.components.sleeper:SetResistance(3)
    
    inst.components.combat:SetDefaultDamage(TUNING.WEREPIG_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.WEREPIG_ATTACK_PERIOD)
    inst.components.locomotor.runspeed = TUNING.WEREPIG_RUN_SPEED 
    inst.components.locomotor.walkspeed = TUNING.WEREPIG_WALK_SPEED 
    
    inst.components.sleeper:SetSleepTest(WerepigSleepTest)
    inst.components.sleeper:SetWakeTest(WerepigWakeTest)
    
    inst.components.lootdropper:SetLoot({"meat","meat", "pigskin"})
    inst.components.lootdropper.numrandomloot = 0
    
    inst.components.health:SetMaxHealth(TUNING.WEREPIG_HEALTH)
    inst.components.combat:SetTarget(nil)
    inst.components.combat:SetRetargetFunction(3, WerepigRetargetFn)
    inst.components.combat:SetKeepTargetFunction(WerepigKeepTargetFn)
    
    inst.components.trader:Disable()
    inst.components.follower:SetLeader(nil)
    inst.components.talker:IgnoreAll()
    inst.components.combat:SetHurtSound("dontstarve/creatures/werepig/hurt")

end


local function common()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.5, .75 )
    inst.Transform:SetFourFaced()

    inst.entity:AddLightWatcher()
    
    inst:AddComponent("talker")
    inst.components.talker.ontalk = ontalk
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    --inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
    inst.components.talker.offset = Vector3(0,-400,0)



    MakeCharacterPhysics(inst, 50, .5)
    
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED --5
    inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED --3

    inst:AddTag("character")
    inst:AddTag("pig")
    inst:AddTag("scarytoprey")
    anim:SetBank("pigman")
    anim:PlayAnimation("idle_loop")
    anim:Hide("hat")

    ------------------------------------------
    inst:AddComponent("eater")
    inst.components.eater:SetOmnivore()
	inst.components.eater:SetCanEatHorrible()
    inst.components.eater.strongstomach = true -- can eat monster meat!
    inst.components.eater:SetOnEatFn(OnEat)
    ------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"

    MakeMediumBurnableCharacter(inst, "pig_torso")

    inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.PIGNAMES
    inst.components.named:PickNewName()
    
    ------------------------------------------
	inst:AddComponent("werebeast")
	inst.components.werebeast:SetOnWereFn(SetWerePig)
	inst.components.werebeast:SetTriggerLimit(4)
	
    ------------------------------------------
    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.PIG_LOYALTY_MAXTIME
    ------------------------------------------
    inst:AddComponent("health")

    ------------------------------------------

    inst:AddComponent("inventory")
    
    ------------------------------------------

    inst:AddComponent("lootdropper")

    ------------------------------------------

    inst:AddComponent("knownlocations")
    

    ------------------------------------------

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    
    ------------------------------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura


    ------------------------------------------

    inst:AddComponent("sleeper")
    
    ------------------------------------------
    MakeMediumFreezableCharacter(inst, "pig_torso")
    
    ------------------------------------------


    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        if inst:HasTag("werepig") then
			return "WEREPIG"
        elseif inst:HasTag("guard") then
            return "GUARD"
        elseif inst.components.follower.leader ~= nil then
            return "FOLLOWER"
        end
    end
    ------------------------------------------
   
    
    
    inst.OnSave = function(inst, data)
        data.build = inst.build
    end        
    
    inst.OnLoad = function(inst, data)    
		if data then
			inst.build = data.build or builds[1]
			if not inst.components.werebeast:IsInWereState() then
				inst.AnimState:SetBuild(inst.build)
			end
		end
    end           
    
    inst:ListenForEvent("attacked", OnAttacked)    
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    
    return inst
end

local function normal()
    local inst = common()
    inst.build = builds[math.random(#builds)]
    inst.AnimState:SetBuild(inst.build)
    SetNormalPig(inst)
    return inst
end

local function guard()
    local inst = common()
    inst.build = guardbuilds[math.random(#guardbuilds)]
    inst.AnimState:SetBuild(inst.build)
    SetGuardPig(inst)
    return inst
end

return Prefab( "common/characters/pigman", normal, assets, prefabs),
       Prefab("common/character/pigguard", guard, assets, prefabs) 
