require "brains/batbrain"
require "stategraphs/SGbat"

local assets = {
    Asset("ANIM", "anim/bat_basic.zip"),
    Asset("SOUND", "sound/bat.fsb"),
    Asset("INV_IMAGE", "bat"),
}

local prefabs = {
    "guano",
    "batwing",
}

SetSharedLootTable('bat',
        {
            { 'batwing', 0.15 },
            { 'guano', 0.15 },
            { 'monstermeat', 0.10 },
        })

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 80
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local function ShouldSleep(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition())
    if not (homePos and distsq(homePos, myPos) <= SLEEP_DIST_FROMHOME * SLEEP_DIST_FROMHOME)
            or (inst.components.combat and inst.components.combat.target)
            or (inst.components.burnable and inst.components.burnable:IsBurning())
            or (inst.components.freezable and inst.components.freezable:IsFrozen()) then
        return false
    end
    local nearestEnt = GetClosestInstWithTag("character", inst, SLEEP_DIST_FROMTHREAT)
    return nearestEnt == nil
end

local function ShouldWake(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition())
    if (homePos and distsq(homePos, myPos) > SLEEP_DIST_FROMHOME * SLEEP_DIST_FROMHOME)
            or (inst.components.combat and inst.components.combat.target)
            or (inst.components.burnable and inst.components.burnable:IsBurning())
            or (inst.components.freezable and inst.components.freezable:IsFrozen()) then
        return true
    end
    local nearestEnt = GetClosestInstWithTag("character", inst, SLEEP_DIST_FROMTHREAT)
    return nearestEnt
end

local function MakeTeam(inst, attacker)
    local leader = SpawnPrefab("teamleader")
    leader:AddTag("bat")
    leader.components.teamleader.threat = attacker
    leader.components.teamleader.team_type = inst.components.teamattacker.team_type
    leader.components.teamleader:NewTeammate(inst)
    leader.components.teamleader:BroadcastDistress(inst)
end

local function Retarget(inst)
    local ta = inst.components.teamattacker

    local newtarget = FindEntity(inst, TUNING.BISHOP_TARGET_DIST, function(guy)
        return (guy:HasTag("character") or guy:HasTag("monster"))
                and not guy:HasTag("bat")
                and inst.components.combat:CanTarget(guy)
    end)

    if newtarget and not ta.inteam and not ta:SearchForTeam() then
        MakeTeam(inst, newtarget)
    end

    if ta.inteam and not ta.teamleader:CanAttack() then
        return newtarget
    end
end

local function KeepTarget(inst, target)
    if (inst.components.teamattacker.teamleader and not inst.components.teamattacker.teamleader:CanAttack()) or
            inst.components.teamattacker.orders == "ATTACK" then
        return true
    else
        return false
    end
end

local function OnAttacked(inst, data)
    if not inst.components.teamattacker.inteam and not inst.components.teamattacker:SearchForTeam() then
        MakeTeam(inst, data.attacker)
    elseif inst.components.teamattacker.teamleader then
        inst.components.teamattacker.teamleader:BroadcastDistress()   --Ask for  help!
    end

    if inst.components.teamattacker.inteam and not inst.components.teamattacker.teamleader:CanAttack() then
        local attacker = data and data.attacker
        inst.components.combat:SetTarget(attacker)
        inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude)
            return dude:HasTag("bat")
        end, MAX_TARGET_SHARES)
    end
end

local function OnWingDown(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/flap")
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    local shadow = inst.entity:AddDynamicShadow()
    shadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    local scaleFactor = 0.75
    inst.Transform:SetScale(scaleFactor, scaleFactor, scaleFactor)

    MakeGhostPhysics(inst, 1, .5)

    anim:SetBank("bat")
    anim:SetBuild("bat_basic")

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier(1)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.walkspeed = TUNING.BAT_WALK_SPEED

    inst:SetStateGraph("SGbat")

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("bat")
    inst:AddTag("scarytoprey")
    inst:AddTag("flying")

    local brain = require "brains/batbrain"
    inst:SetBrain(brain)

    inst:AddComponent("eater")
    inst.components.eater:SetCarnivore()
    inst.components.eater.strongstomach = true

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper:SetNocturnal(true)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "bat_body"
    inst.components.combat:SetAttackPeriod(TUNING.BAT_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.BAT_ATTACK_DIST)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BAT_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.BAT_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BAT_ATTACK_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('bat')

    inst:AddComponent("inventory")

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("guano")
    inst.components.periodicspawner:SetRandomTimes(120, 240)
    inst.components.periodicspawner:SetDensityInRange(30, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:DoTaskInTime(1 * FRAMES, function()
        inst.components.knownlocations:RememberLocation("home", Vector3(inst.Transform:GetWorldPosition()), true)
    end)

    inst:ListenForEvent("wingdown", OnWingDown)

    MakeMediumBurnableCharacter(inst, "bat_body")
    MakeMediumFreezableCharacter(inst, "bat_body")

    inst:AddComponent("teamattacker")
    inst.components.teamattacker.team_type = "bat"

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

return Prefab("cave/monsters/bat", fn, assets, prefabs) 
