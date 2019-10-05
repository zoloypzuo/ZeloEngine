require "brains/penguinbrain"
require "stategraphs/SGpenguin"

local assets=
{
	Asset("ANIM", "anim/penguin.zip"),
	Asset("ANIM", "anim/penguin_build.zip"),
	Asset("SOUND", "sound/pengull.fsb"),
}

local prefabs =
{
    "smallmeat",
    "drumstick",
    "feather_crow",
    "bird_egg",
}


SetSharedLootTable( 'penguin',
{
    {'feather_crow',  0.2},
    {'smallmeat',     0.1},
    {'drumstick',     0.1},
})

local SLEEP_DIST_FROMHOME = 3
local SLEEP_DIST_FROMTHREAT = 8
local MAX_CHASEAWAY_DIST = 80
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40


local function OnEntityWake(inst)
    if CHEATS_ENABLED then return end
    if GetSeasonManager():IsSummer() or GetSeasonManager():GetDaysLeftInSeason() < 3 then
        inst:Remove()
    end
end

local function OnEntitySleep(inst)
    if CHEATS_ENABLED then return end
    if GetSeasonManager():IsSummer() or GetSeasonManager():GetDaysLeftInSeason() < 3 then
        inst:Remove()
    end
end


local function OnSave(inst, data)
    if inst.colonyNum then
        data.colonyNum = inst.colonyNum
    end
end

local function OnLoad(inst, data)
    if data and data.colonyNum then
        inst.colonyNum = data.colonyNum
        local spawner = GetWorld().components.penguinspawner
        if spawner then
            spawner:AddToColony(inst.colonyNum,inst)
        end
    end
end


local function ShouldSleep(inst)
    local homePos = inst.components.knownlocations:GetLocation("rookery")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if not (homePos and distsq(homePos, myPos) <= SLEEP_DIST_FROMHOME*SLEEP_DIST_FROMHOME)
       or (inst.components.combat and inst.components.combat.target)
       or (inst.components.burnable and inst.components.burnable:IsBurning() )
       or (inst.components.freezable and inst.components.freezable:IsFrozen() ) then
        return false
    end
    local nearestEnt = GetClosestInstWithTag("character", inst, SLEEP_DIST_FROMTHREAT)
    return nearestEnt == nil
end

local function ShouldWake(inst)
    local homePos = inst.components.knownlocations:GetLocation("rookery")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > SLEEP_DIST_FROMHOME*SLEEP_DIST_FROMHOME)
       or (inst.components.combat and inst.components.combat.target)
       or (inst.components.burnable and inst.components.burnable:IsBurning() )
       or (inst.components.freezable and inst.components.freezable:IsFrozen() ) then
        return true
    end
    local nearestEnt = GetClosestInstWithTag("character", inst, SLEEP_DIST_FROMTHREAT)
    return nearestEnt
end

local function GetStatus(inst)
    if inst.components.hunger then
        if inst.components.hunger:IsStarving(inst) then
            return "STARVING"
        elseif inst.components.hunger:GetPercent() < .5 then
            return "HUNGRY"
        end
    end
end

local function OnEat(inst, food)
    if food.components.edible and math.random()<.2 then
        --[[  -- Not until we have a small poop...
		local poo = SpawnPrefab("poop")
        poo.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE/2
        poo.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES/2
		poo.Transform:SetPosition(inst.Transform:GetWorldPosition())		
		poo.Transform:SetScale(.5,.5,.5)
        --]]
	end
end

local function MakeTeam(inst, attacker)
        local leader = SpawnPrefab("teamleader")
dprint("<<<<<<<<================>>>>> Making TEAM:",attacker)
        leader:AddTag("penguin")
        leader.components.teamleader.threat = attacker
        leader.components.teamleader.radius = 10
        leader.components.teamleader:SetAttackGrpSize(5+math.random(1,3))
        leader.components.teamleader.timebetweenattacks = 0  -- first attack happens immediately
        leader.components.teamleader.attackinterval = 2  -- first attack happens immediately
        leader.components.teamleader.maxchasetime = 10
        leader.components.teamleader.min_team_size = 0
        leader.components.teamleader.max_team_size = 8
        leader.components.teamleader.team_type = inst.components.teamattacker.team_type
        leader.components.teamleader:NewTeammate(inst)
        leader.components.teamleader:BroadcastDistress(inst)
dprint("<<<<<<<>>>>>")
end
local function Retarget(inst)

    local ta = inst.components.teamattacker

   
    if inst.components.hunger and not inst.components.hunger:IsStarving() then
        return nil
    end

    local newtarget = FindEntity(inst, 3, function(guy)
            return (guy:HasTag("character") or guy:HasTag("monster") or guy:HasTag("wall") )
                   and not guy:HasTag("penguin")
                   and inst.components.combat:CanTarget(guy)
            end)

    if newtarget and ta and not ta.inteam and not ta:SearchForTeam() then
        dprint("===============================MakeTeam on Retarget")
        MakeTeam(inst, newtarget)
    end

    if ta.inteam and not ta.teamleader:CanAttack() then
        return newtarget
    end

end

local function KeepTarget(inst, target)
    if not inst.components.teamattacker then
        return false
    end

    if (inst.components.teamattacker.teamleader and not inst.components.teamattacker.teamleader:CanAttack())
        or inst.components.teamattacker.orders == "ATTACK" then
        return true
    else
        dprint(inst,"Looses TARGET")
        return false
    end 
end

local function OnAttacked(inst, data)

    if not inst.components.teamattacker then return end
    dprint("OnAttacked")

    if not inst.components.teamattacker.inteam and not inst.components.teamattacker:SearchForTeam() then
        dprint("MakeTeam")
        MakeTeam(inst, data.attacker)
    elseif inst.components.teamattacker.teamleader then    
        inst.components.teamattacker.teamleader:BroadcastDistress()   --Ask for  help!
        dprint("ASK FOR HELP!")
    end

    if inst.components.teamattacker.inteam and not inst.components.teamattacker.teamleader:CanAttack() then
        local attacker = data and data.attacker
        dprint(inst,"OnAttack:settarget",attacker)
        inst.components.combat:SetTarget(attacker)
        inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("penguin") end, MAX_TARGET_SHARES)
    end
end


local function OnThrown(inst, data)

    dprint("OnThrow",data.attacker)
    if not inst.components.teamattacker or
       data.target ~= inst then
        return
    end

    if not inst.components.teamattacker.inteam and not inst.components.teamattacker:SearchForTeam() then
        dprint("MakeTeam",data.attacker)
        MakeTeam(inst, data.attacker)
    elseif inst.components.teamattacker.teamleader then    
        inst.components.teamattacker.teamleader:BroadcastDistress()   --Ask for  help!
        dprint("ASK FOR HELP!")
    end

    if inst.components.teamattacker.inteam and not inst.components.teamattacker.teamleader:CanAttack() then
        local attacker = data.attacker
        dprint(inst,"OnAttack:settarget",attacker)
        inst.components.combat:SetTarget(attacker)
        inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("penguin") end, MAX_TARGET_SHARES)
    end
end


local function OnEnterMood(inst)
    inst.nesting = true
end

local function OnLeaveMood(inst)
    inst.nesting = false
end

local function OnIgnite(inst)
    local egg = inst.components.inventory and inst.components.inventory:GetItemInSlot(1)
    local newEgg
    if egg then
        inst.components.inventory:RemoveItemBySlot(1)
        if egg.prefab == "bird_egg_cooked" or math.random() > .3 then
            newEgg = SpawnPrefab("rottenegg")
        else
            newEgg = SpawnPrefab("bird_egg_cooked")
        end
        inst.components.inventory:GiveItem( newEgg, 1 )
        egg:Remove()
    end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.5, .75 )
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 50, .5)    
     
    anim:SetBank("penguin")
    anim:SetBuild("penguin_build")
    
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 0.75
    inst.components.locomotor.directdrive = false
    
    inst:SetStateGraph("SGpenguin")

    inst:AddTag("penguin")
    inst:AddTag("animal")
    inst:AddTag("smallcreature")

    local brain = require "brains/penguinbrain"
    inst:SetBrain(brain)
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetAttackPeriod(TUNING.PENGUIN_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.PENGUIN_ATTACK_DIST)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetDefaultDamage(TUNING.PENGUIN_DAMAGE)
    inst.components.combat:SetAttackPeriod(3)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.PENGUIN_HEALTH)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('penguin')
     
    inst:AddComponent("homeseeker")

    inst:AddComponent("knownlocations")
    inst.components.knownlocations:RememberLocation("rookery", Vector3(0,0,0))
    -- inst.components.knownlocations:RememberLocation("home", Vector3(0,0,0))
    inst:DoTaskInTime(1*FRAMES, function()
                            if inst:IsValid() then  -- yes it can die in one frame
                                inst.components.knownlocations:RememberLocation("home", Vector3(inst.Transform:GetWorldPosition()), true)
                            end
                        end)

    inst:AddComponent("herdmember")
    inst.components.herdmember.herdprefab = "penguinherd"

    inst:AddComponent("teamattacker")
    inst.components.teamattacker.team_type = "penguin"
    inst.components.teamattacker.leashdistance = 99999
    
    inst:AddComponent("eater")
    inst.components.eater:SetOmnivore()
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater.strongstomach = true -- can eat monster meat!
    inst.components.eater:SetOnEatFn(OnEat)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    -- inst.components.sleeper:SetNocturnal(false)

    inst:ListenForEvent("entermood", OnEnterMood)
    inst:ListenForEvent("leavemood", OnLeaveMood)
    inst:ListenForEvent("onignite", OnIgnite)
    --inst.components.sleeper:SetSleepTest(ShouldSleep)
    --inst.components.sleeper:SetWakeTest(ShouldWake)
    
    MakeSmallBurnableCharacter(inst, "body")

    MakeMediumFreezableCharacter(inst, "body")
    inst.components.freezable:SetResistance(5)
    inst.components.freezable:SetDefaultWearOffTime(1)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("inventory")
	inst.components.inventory.maxslots = 1
	inst.components.inventory.acceptsstacks = false

    inst:AddComponent("hunger")
    inst.components.hunger:SetMax(TUNING.PENGUIN_HUNGER)
    inst.components.hunger:SetRate(TUNING.PENGUIN_HUNGER/TUNING.PENGUIN_STARVE_TIME)
    inst.components.hunger:SetKillRate(TUNING.SMALLBIRD_HEALTH/TUNING.SMALLBIRD_STARVE_KILL_TIME)
    
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("hostileprojectile", OnThrown)
    
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep
    inst.eggsLayed = 0
    
    return inst
end

return Prefab( "forest/animals/penguin", fn, assets, prefabs) 

