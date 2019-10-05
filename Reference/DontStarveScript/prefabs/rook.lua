require "brains/rookbrain"
require "stategraphs/SGrook"

local assets=
{
	Asset("ANIM", "anim/rook.zip"),
	Asset("ANIM", "anim/rook_build.zip"),
	Asset("ANIM", "anim/rook_nightmare.zip"),
	Asset("SOUND", "sound/chess.fsb"),
}

local prefabs =
{
	"gears",
    "thulecite_pieces",
    "nightmarefuel",
}

SetSharedLootTable( 'rook',
{
    {'gears',  1.0},
    {'gears',  1.0},
})

SetSharedLootTable( 'rook_nightmare',
{
    {'gears',            1.0},
    {'nightmarefuel',    0.6},
    {'thulecite_pieces', 0.5},
})

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 40
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local function ShouldSleep(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
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
    local homePos = inst.components.knownlocations:GetLocation("home")
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

local function Retarget(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > 40*40)  and not
    (inst.components.follower and inst.components.follower.leader)then
        return
    end
    
    local newtarget = FindEntity(inst, TUNING.ROOK_TARGET_DIST, function(guy)
            return (guy:HasTag("character") or guy:HasTag("monster"))
                   and not (inst.components.follower and inst.components.follower.leader == guy)
                   and not (guy:HasTag("chess") and (guy.components.follower and not guy.components.follower.leader))
                   and not ((inst.components.follower and inst.components.follower.leader == GetPlayer()) and (guy.components.follower and guy.components.follower.leader == GetPlayer()))
                   and inst.components.combat:CanTarget(guy)
    end)
    return newtarget
end

local function KeepTarget(inst, target)

    if (inst.components.follower and inst.components.follower.leader) then
        return true
    end

    if inst.sg and inst.sg:HasStateTag("running") then
        return true
    end

    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    return (homePos and distsq(homePos, myPos) < 40*40)
end

local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    if attacker and attacker:HasTag("chess") then return end
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("chess") end, MAX_TARGET_SHARES)
end

local function HitShake()
        --       :Shake(shakeType, duration, speed, scale)
        -- TheCamera:Shake("SIDE", 0.2, 0.05, .1)
        TheCamera:Shake("SIDE", 0.5, 0.05, 0.1)
end

local function DoChargeDamage(inst, target)
    if not inst.recentlycharged then
        inst.recentlycharged = {}
    end

    for k,v in pairs(inst.recentlycharged) do
        if v == target then
            --You've already done damage to this by charging it recently.
            return
        end
    end
    inst.recentlycharged[target] = target
    inst:DoTaskInTime(3, function() inst.recentlycharged[target] = nil end)
    inst.components.combat:DoAttack(target, inst.weapon)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/rook/explo") 
end

local function oncollide(inst, other)
    local v1 = Vector3(inst.Physics:GetVelocity())
    if other == GetPlayer() then
        return
    end
    if v1:LengthSq() < 42 then return end

    HitShake()

    inst:DoTaskInTime(2*FRAMES, function()   
            if  (other and other:HasTag("smashable")) then
                --other.Physics:SetCollides(false)
                other.components.health:Kill()
            elseif other and other.components.workable and other.components.workable.workleft > 0 then
                SpawnPrefab("collapse_small").Transform:SetPosition(other:GetPosition():Get())
                other.components.workable:Destroy(inst)
            elseif other and other.components.health and other.components.health:GetPercent() >= 0 then
                DoChargeDamage(inst, other)
            end
    end)

end

local function CreateWeapon(inst)
    local weapon = CreateEntity()
    weapon.entity:AddTransform()
    weapon:AddComponent("weapon")
    weapon.components.weapon:SetDamage(200)
    weapon.components.weapon:SetRange(0)
    weapon:AddComponent("inventoryitem")
    weapon.persists = false
    weapon.components.inventoryitem:SetOnDroppedFn(function() weapon:Remove() end)
    weapon:AddComponent("equippable")
    inst.components.inventory:GiveItem(weapon)
    inst.weapon = weapon
end

local function MakeRook(nightmare)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 3, 1.25 )
    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(0.66, 0.66, 0.66)
    MakeCharacterPhysics(inst, 50, 1.5)
    inst.Physics:SetCollisionCallback(oncollide)

    anim:SetBank("rook")

    inst:AddComponent("lootdropper")

    if nightmare then

        inst.components.lootdropper:SetChanceLootTable('rook_nightmare')

        inst.kind = "_nightmare"
        inst.soundpath   = "dontstarve/creatures/rook_nightmare/"
        inst.effortsound = "dontstarve/creatures/rook_nightmare/rattle"
		    --TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.soundpath .. "steam") end ),
        anim:SetBuild("rook_nightmare") -- name of flash file
    else

        inst.components.lootdropper:SetChanceLootTable('rook')

        inst.kind = ""
        inst.soundpath   = "dontstarve/creatures/rook/"
        inst.effortsound = "dontstarve/creatures/rook/steam"
        anim:SetBuild("rook_build")
    end
    
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.ROOK_WALK_SPEED
    inst.components.locomotor.runspeed =  TUNING.ROOK_RUN_SPEED
    
    inst:SetStateGraph("SGrook")

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("chess")
    inst:AddTag("rook")

    local brain = require "brains/rookbrain"
    inst:SetBrain(brain)
    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "spring"
    inst.components.combat:SetAttackPeriod(2)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ROOK_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.ROOK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.ROOK_ATTACK_PERIOD)
    --inst.components.combat.playerdamagepercent = 2

    inst:AddComponent("follower")

    inst:AddComponent("inventory")


    
    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")
    
    inst:DoTaskInTime(2*FRAMES, function() inst.components.knownlocations:RememberLocation("home", Vector3(inst.Transform:GetWorldPosition()), true) end)

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeMediumFreezableCharacter(inst, "spring")
    
    inst:ListenForEvent("attacked", OnAttacked)

    CreateWeapon(inst)

    --inst:AddComponent("debugger")

    return inst
end

return Prefab("chessboard/rook", function() return MakeRook(false) end , assets, prefabs),
       Prefab("cave/monsters/rook_nightmare", function() return MakeRook(true) end , assets, prefabs)