require "brains/monkeybrain"
require "brains/nightmaremonkeybrain"
require "stategraphs/SGmonkey"

local assets = {
    Asset("ANIM", "anim/kiki_basic.zip"),
    Asset("ANIM", "anim/kiki_build.zip"),
    Asset("ANIM", "anim/kiki_nightmare_skin.zip"),
    Asset("SOUND", "sound/monkey.fsb"),
}

local prefabs = {
    "poop",
    "monkeyprojectile",
    "smallmeat",
    "cave_banana",
}

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 80
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

SetSharedLootTable('monkey',
        {
            { 'smallmeat', 1.0 },
            { 'cave_banana', 1.0 },
            { 'nightmarefuel', 0.5 },
        })

local function WeaponDropped(inst)
    inst:Remove()
end

local function oneat(inst)
    --Monkey ate some food. Give him some poop!
    if inst.components.inventory then
        local maxpoop = 3
        local poopstack = inst.components.inventory:FindItem(function(item)
            return item.prefab == "poop"
        end)
        if poopstack and poopstack.components.stackable.stacksize < maxpoop then
            local newpoop = SpawnPrefab("poop")
            inst.components.inventory:GiveItem(newpoop)
        elseif not poopstack then
            local newpoop = SpawnPrefab("poop")
            inst.components.inventory:GiveItem(newpoop)
        end
    end
end

local function onthrow(weapon, inst)
    if inst.components.inventory then
        local poopstack = inst.components.inventory:FindItem(function(item)
            return item.prefab == "poop"
        end)
        if poopstack then
            inst.components.inventory:ConsumeByName("poop", 1)
        end
    end
end

local function hasammo(inst)
    if inst.components.inventory then
        local poopstack = inst.components.inventory:FindItem(function(item)
            return item.prefab == "poop"
        end)
        return poopstack ~= nil
    end
end

local function GetWeaponMode(weapon)
    local inst = weapon.components.inventoryitem.owner
    if hasammo(inst) and (inst.components.combat.target and inst.components.combat.target == GetPlayer()) then
        return weapon.components.weapon.modes["RANGE"]
    else
        return weapon.components.weapon.modes["MELEE"]
    end
end

local function MakeProjectileWeapon(inst)
    if inst.components.inventory then
        local weapon = CreateEntity()
        weapon.entity:AddTransform()
        MakeInventoryPhysics(weapon)
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(1)
        --weapon.components.weapon:SetRange(17)
        weapon.components.weapon.modes = {
            RANGE = { damage = 0, ranged = true, attackrange = TUNING.MONKEY_RANGED_RANGE, hitrange = TUNING.MONKEY_RANGED_RANGE + 2 },
            MELEE = { damage = TUNING.MONKEY_MELEE_DAMAGE, ranged = false, attackrange = 0, hitrange = 1 }
        }
        weapon.components.weapon.variedmodefn = GetWeaponMode
        weapon.components.weapon:SetProjectile("monkeyprojectile")
        weapon.components.weapon:SetOnProjectileLaunch(onthrow)
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(function()
            WeaponDropped(weapon)
        end)
        weapon:AddComponent("equippable")
        inst.components.inventory:Equip(weapon)
        return weapon
    end
end

local function OnAttacked(inst, data)

    inst.components.combat:SetTarget(data.attacker)
    inst.harassplayer = false
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
    inst.task = inst:DoTaskInTime(math.random(55, 65), function()
        inst.components.combat:SetTarget(nil)
    end)    --Forget about target after a minute

    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 30, { "monkey" })
    for k, v in pairs(ents) do
        if v ~= inst then
            v.components.combat:SuggestTarget(data.attacker)
            v.harassplayer = false

            if v.task then
                v.task:Cancel()
                v.task = nil
            end
            v.task = v:DoTaskInTime(math.random(55, 65), function()
                v.components.combat:SetTarget(nil)
            end)    --Forget about target after a minute
        end
    end
end

local function FindTargetOfInterest(inst)

    if not inst.curious then
        return
    end

    if not inst.harassplayer and not inst.components.combat.target then
        local m_pt = inst:GetPosition()
        local target = GetPlayer()
        if target and target.components.inventory and distsq(m_pt, target:GetPosition()) < 25 * 25 then
            local interest_chance = 0.15
            local item = target.components.inventory:FindItem(function(item)
                return item.prefab == "cave_banana" or item.prefab == "cave_banana_cooked"
            end)

            if item then
                -- He has bananas! Maybe we should start following...
                interest_chance = 0.6
            end
            if math.random() < interest_chance then

                inst.harassplayer = true
                inst:DoTaskInTime(120, function()
                    inst.harassplayer = false
                end)
            end
        end
    end
end

local function retargetfn(inst)
    if inst:HasTag("nightmare") then
        local newtarget = FindEntity(inst, 20, function(guy)
            return (guy:HasTag("character") or guy:HasTag("monster"))
                    and inst.components.combat:CanTarget(guy)
        end)
        return newtarget
    end
end

local function shouldKeepTarget(inst, target)
    if inst:HasTag("nightmare") then
        return true
    end

    return true
end

local function IsInCharacterList(name)
    local characters = GetActiveCharacterList()

    for k, v in pairs(characters) do
        if name == v then
            return true
        end
    end
end

local function OnMonkeyDeath(inst, data)
    if data.inst:HasTag("monkey") then
        --A monkey died!
        if IsInCharacterList(data.cause) then
            --And it was the player! Run home!
            --Drop all items, go home
            inst:DoTaskInTime(math.random(), function()
                if inst.components.inventory then
                    inst.components.inventory:DropEverything(false, true)
                end

                if inst.components.homeseeker and inst.components.homeseeker.home then
                    inst.components.homeseeker.home:PushEvent("monkeydanger")
                end
            end)
        end
    end
end

local function onpickup(inst, data)
    if data.item then
        if data.item.components.equippable and
                data.item.components.equippable.equipslot == EQUIPSLOTS.HEAD and not
        inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) then
            --Ugly special case for how the PICKUP action works.
            --Need to wait until PICKUP has called "GiveItem" before equipping item.
            inst:DoTaskInTime(0.1, function()
                inst.components.inventory:Equip(data.item)
            end)
        end
    end
end

local function DoFx(inst)
    if ExecutingLongUpdate then
        return
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")

    local fx = SpawnPrefab("statue_transition_2")
    if fx then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx.AnimState:SetScale(.8, .8, .8)
    end
    fx = SpawnPrefab("statue_transition")
    if fx then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx.AnimState:SetScale(.8, .8, .8)
    end
end

local function SetNormalMonkey(inst)
    inst:RemoveTag("nightmare")
    local brain = require "brains/monkeybrain"
    inst:SetBrain(brain)
    inst.AnimState:SetBuild("kiki_basic")
    inst.AnimState:SetMultColour(1, 1, 1, 1)
    inst.curious = true
    inst.soundtype = ""
    inst.components.lootdropper:SetLoot({ "smallmeat", "cave_banana" })
    inst.components.lootdropper.droppingchanceloot = false

    inst.components.combat:SetTarget(nil)

    inst:ListenForEvent("entity_death", inst.listenfn, GetWorld())
end

local function SetNightmareMonkey(inst)
    inst:AddTag("nightmare")
    inst.AnimState:SetMultColour(1, 1, 1, .6)
    local brain = require "brains/nightmaremonkeybrain"
    inst:SetBrain(brain)
    inst.AnimState:SetBuild("kiki_nightmare_skin")
    inst.soundtype = "_nightmare"
    inst.harassplayer = false
    inst.curious = false
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end

    inst.components.lootdropper:SetLoot({ "beardhair" })
    inst.components.lootdropper.droppingchanceloot = true
    inst.components.combat:SetTarget(nil)

    inst:RemoveEventCallback("entity_death", inst.listenfn, GetWorld())
end

local function OnSave(inst, data)
    data.harassplayer = inst.harassplayer
end

local function OnLoad(inst, data)
    if data and data.harassplayer then
        inst.harassplayer = data.harassplayer
    end

    if GetNightmareClock() then
        local phase = GetNightmareClock():GetPhase()

        if phase == "nightmare" or phase == "dawn" then
            SetNightmareMonkey(inst)
        else
            SetNormalMonkey(inst)
        end
    end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    inst.soundtype = ""
    local shadow = inst.entity:AddDynamicShadow()
    shadow:SetSize(2, 1.25)

    inst.Transform:SetSixFaced()

    MakeCharacterPhysics(inst, 10, 0.25)
    MakeMediumBurnableCharacter(inst)
    MakeMediumFreezableCharacter(inst)

    anim:SetBank("kiki")
    anim:SetBuild("kiki_basic")

    anim:PlayAnimation("idle_loop", true)

    inst:AddTag("monkey")

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")

    inst:AddComponent("thief")

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier(1)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = false }
    inst.components.locomotor.walkspeed = TUNING.MONKEY_MOVE_SPEED

    inst:AddComponent("combat")
    inst.components.combat:SetAttackPeriod(TUNING.MONKEY_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.MONKEY_MELEE_RANGE)
    inst.components.combat:SetRetargetFunction(1, retargetfn)

    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
    inst.components.combat:SetDefaultDamage(0)    --This doesn't matter, monkey uses weapon damage

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MONKEY_HEALTH)

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner:SetRandomTimes(200, 400)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(15)
    inst.components.periodicspawner:Start()

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('monkey')
    inst.components.lootdropper.droppingchanceloot = false

    inst:AddComponent("eater")
    inst.components.eater:SetVegetarian()
    inst.components.eater:SetOnEatFn(oneat)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetNocturnal()

    local brain = require "brains/monkeybrain"
    inst:SetBrain(brain)
    inst:SetStateGraph("SGmonkey")

    inst.FindTargetOfInterestTask = inst:DoPeriodicTask(10, FindTargetOfInterest)    --Find something to be interested in!

    inst.HasAmmo = hasammo
    inst.curious = true

    inst:AddComponent("knownlocations")

    inst.listenfn = function(listento, data)
        OnMonkeyDeath(inst, data)
    end

    inst:ListenForEvent("onpickup", onpickup)
    inst:ListenForEvent("attacked", OnAttacked)

    inst:ListenForEvent("calmstart", function()
        DoFx(inst)
        SetNormalMonkey(inst)
    end, GetWorld())
    inst:ListenForEvent("nightmarestart", function()
        DoFx(inst)
        SetNightmareMonkey(inst)
    end, GetWorld())

    if GetNightmareClock() then
        local phase = GetNightmareClock():GetPhase()
        if phase == "nightmare" or phase == "dawn" then
            SetNightmareMonkey(inst)
        else
            SetNormalMonkey(inst)
        end
    end

    inst.weapon = MakeProjectileWeapon(inst)

    inst.harassplayer = false

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("cave/monsters/monkey", fn, assets, prefabs)
