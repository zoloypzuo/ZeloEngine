local function OnSane(inst)
    print("SANE!")
end

local function OnInsane(inst)
    inst.SoundEmitter:PlaySound("dontstarve/sanity/gonecrazy_stinger")
end

local function giveupstring(combat, target)
    local str = ""
    if target and target:HasTag("prey") then
        str = GetString(combat.inst.prefab, "COMBAT_QUIT", "prey")
    else
        str = GetString(combat.inst.prefab, "COMBAT_QUIT")
    end
    return str
end

local function MakePlayerCharacter(name, customprefabs, customassets, customfn, starting_inventory)

    local font = TALKINGFONT
    local fontsize = 28
    local assets = {
        Asset("ANIM", "anim/player_basic.zip"),
        Asset("ANIM", "anim/player_idles_shiver.zip"),
        Asset("ANIM", "anim/player_actions.zip"),
        Asset("ANIM", "anim/player_actions_axe.zip"),
        Asset("ANIM", "anim/player_actions_pickaxe.zip"),
        Asset("ANIM", "anim/player_actions_shovel.zip"),
        Asset("ANIM", "anim/player_actions_blowdart.zip"),
        Asset("ANIM", "anim/player_actions_eat.zip"),
        Asset("ANIM", "anim/player_actions_item.zip"),
        Asset("ANIM", "anim/player_cave_enter.zip"),
        Asset("ANIM", "anim/player_actions_uniqueitem.zip"),
        Asset("ANIM", "anim/book_uniqueitem_swap.zip"),
        Asset("ANIM", "anim/player_actions_bugnet.zip"),
        Asset("ANIM", "anim/player_actions_fishing.zip"),
        Asset("ANIM", "anim/player_actions_boomerang.zip"),
        Asset("ANIM", "anim/player_bush_hat.zip"),
        Asset("ANIM", "anim/player_attacks.zip"),
        Asset("ANIM", "anim/player_idles.zip"),
        Asset("ANIM", "anim/player_rebirth.zip"),
        Asset("ANIM", "anim/player_jump.zip"),
        Asset("ANIM", "anim/player_amulet_resurrect.zip"),
        Asset("ANIM", "anim/player_teleport.zip"),
        Asset("ANIM", "anim/wilson_fx.zip"),
        Asset("ANIM", "anim/player_one_man_band.zip"),
        Asset("ANIM", "anim/player_slurtle_armor.zip"),
        Asset("ANIM", "anim/player_staff.zip"),

        Asset("ANIM", "anim/shadow_hands.zip"),

        Asset("ANIM", "anim/player_mount.zip"),
        Asset("ANIM", "anim/player_mount_travel.zip"),
        Asset("ANIM", "anim/player_mount_actions.zip"),
        Asset("ANIM", "anim/player_mount_actions_item.zip"),
        Asset("ANIM", "anim/player_mount_unique_actions.zip"),
        Asset("ANIM", "anim/player_mount_one_man_band.zip"),
        Asset("ANIM", "anim/player_mount_blowdart.zip"),
        Asset("ANIM", "anim/player_mount_shock.zip"),
        Asset("ANIM", "anim/player_mount_frozen.zip"),
        Asset("ANIM", "anim/player_mount_groggy.zip"),
        Asset("ANIM", "anim/player_mount_hit_darkness.zip"),

        Asset("ANIM", "anim/player_actions_unsaddle.zip"),

        Asset("ANIM", "anim/goo.zip"),

        Asset("SOUND", "sound/sfx.fsb"),
        Asset("SOUND", "sound/wilson.fsb"),

        Asset("ANIM", "anim/fish01.zip"), --These are used for the fishing animations.
        Asset("ANIM", "anim/eel01.zip"),
        Asset("INV_IMAGE", "skull_" .. name),
        Asset("MINIMAP_IMAGE", name),
    }

    local prefabs = {
        "beardhair",
        "brokentool",
        "abigail",
        "terrorbeak",
        "crawlinghorror",
        "creepyeyes",
        "shadowskittish",
        "shadowwatcher",
        "shadowhand",
        "frostbreath",
        "book_birds",
        "book_tentacles",
        "book_gardening",
        "book_sleep",
        "book_brimstone",
        "pine_needles",
        "reticule",
        "shovel_dirt",
        "mining_fx",

        "gogglesnormalhat",
        "gogglesheathat",
        "gogglesarmorhat",
        "gogglesshoothat",
        "telebrella",
        "thumper",
        "groundpound_fx",
        "groundpoundring_fx",
        "telipad",
        "beacon",

    }

    if starting_inventory then
        for k, v in pairs(starting_inventory) do
            table.insert(prefabs, v)
        end
    end

    if customprefabs then
        for k, v in ipairs(customprefabs) do
            table.insert(prefabs, v)
        end
    end

    if customassets then
        for k, v in ipairs(customassets) do
            table.insert(assets, v)
        end
    end

    local fn = function(Sim)

        local inst = CreateEntity()
        inst.entity:SetCanSleep(false)

        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        local sound = inst.entity:AddSoundEmitter()
        local shadow = inst.entity:AddDynamicShadow()
        local minimap = inst.entity:AddMiniMapEntity()

        inst.Transform:SetFourFaced()

        inst.persists = false --handled in a special way

        MakeCharacterPhysics(inst, 75, .5)

        shadow:SetSize(1.3, .6)

        minimap:SetIcon(name .. ".png")
        minimap:SetPriority(10)

        local lightwatch = inst.entity:AddLightWatcher()
        lightwatch:SetLightThresh(.075)
        lightwatch:SetDarkThresh(.05)

        inst:AddTag("player")
        inst:AddTag("scarytoprey")
        inst:AddTag("character")

        anim:SetBank("wilson")
        anim:SetBuild(name)
        anim:PlayAnimation("idle")

        anim:Hide("ARM_carry")
        anim:Hide("hat")
        anim:Hide("hat_hair")
        anim:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
        anim:OverrideSymbol("fx_liquid", "wilson_fx", "fx_liquid")
        anim:OverrideSymbol("shadow_hands", "shadow_hands", "shadow_hands")

        inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
        inst.components.locomotor:SetSlowMultiplier(0.6)
        inst.components.locomotor.pathcaps = { player = true, ignorecreep = true } -- 'player' cap not actually used, just useful for testing
        inst.components.locomotor.fasteronroad = true

        inst:AddComponent("combat")
        inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
        inst.components.combat.GetGiveUpString = giveupstring
        inst.components.combat.hiteffectsymbol = "torso"

        inst:AddComponent("inventory")
        inst.components.inventory.starting_inventory = starting_inventory

        inst:AddComponent("dynamicmusic")
        inst:AddComponent("playercontroller")

        inst:AddComponent("sanitymonsterspawner")
        inst:AddComponent("flotsamspawner")

        inst:AddComponent("autosaver")
        ------

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(TUNING.WILSON_HEALTH)
        inst.components.health.nofadeout = true
        -------

        inst:AddComponent("hunger")
        inst.components.hunger:SetMax(TUNING.WILSON_HUNGER)
        inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE)
        inst.components.hunger:SetKillRate(TUNING.WILSON_HEALTH / TUNING.STARVE_KILL_TIME)

        inst:AddComponent("sanity")
        inst.components.sanity:SetMax(TUNING.WILSON_SANITY)
        inst.components.sanity.onSane = OnSane
        inst.components.sanity.onInsane = OnInsane

        -------

        inst:AddComponent("kramped")
        inst:AddComponent("talker")
        inst:AddComponent("trader")
        inst:AddComponent("wisecracker")
        inst:AddComponent("distancetracker")
        inst:AddComponent("resurrectable")

        inst:AddComponent("temperature")

        inst:AddComponent("catcher")

        -------

        inst:AddComponent("builder")

        --give the default recipes
        local valid_recipes = GetAllRecipes()
        for k, v in pairs(valid_recipes) do
            if v.level == 0 then
                inst.components.builder:AddRecipe(v.name)
            end
        end

        inst:AddComponent("eater")
        inst:AddComponent("playeractionpicker")
        inst:AddComponent("leader")
        inst:AddComponent("frostybreather")
        inst:AddComponent("age")

        inst:AddComponent("grue")
        inst.components.grue:SetSounds("dontstarve/charlie/warn", "dontstarve/charlie/attack")

        inst:AddComponent("bundler")

        inst:AddComponent("rider")
        inst:AddComponent("pinnable")

        inst:AddComponent("vision")

        -------
        if METRICS_ENABLED then
            inst:AddComponent("overseer")
        end
        -------

        inst.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
        inst.components.combat:SetRange(2)

        function inst.components.combat:GetBattleCryString(target)
            return target ~= nil
                    and target:IsValid()
                    and GetString(
                    inst.prefab,
                    "BATTLECRY",
                    (target:HasTag("prey") and not target:HasTag("hostile") and "PREY") or
                            (string.find(target.prefab, "pig") ~= nil and target:HasTag("pig") and not target:HasTag("werepig") and "PIG") or
                            target.prefab
            )
                    or nil
        end

        local brain = require "brains/wilsonbrain"
        inst:SetBrain(brain)

        inst:AddInherentAction(ACTIONS.PICK)
        inst:AddInherentAction(ACTIONS.SLEEPIN)

        inst:SetStateGraph("SGwilson")

        inst:ListenForEvent("startfiredamage", function(it, data)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/burned")
            inst.SoundEmitter:PlaySound("dontstarve/common/campfire", "burning")
            inst.SoundEmitter:SetParameter("burning", "intensity", 1)
        end)

        inst:ListenForEvent("stopfiredamage", function(it, data)
            inst.SoundEmitter:KillSound("burning")
        end)

        inst:ListenForEvent("containergotitem", function(it, data)
            inst.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource")
        end)

        inst:ListenForEvent("gotnewitem", function(it, data)
            if data.slot then
                Print(VERBOSITY.DEBUG, "gotnewitem: [" .. data.item.prefab .. "]")
                inst.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource")
            end
        end)

        inst:ListenForEvent("equip", function(it, data)
            Print(VERBOSITY.DEBUG, "equip: [" .. data.item.prefab .. "]")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item")
        end)

        inst:ListenForEvent("picksomething", function(it, data)
            if data.object and data.object.components.pickable and data.object.components.pickable.picksound then
                Print(VERBOSITY.DEBUG, "picksomething: [" .. data.object.prefab .. "]")    -- BTW why is this one 'object'?
                inst.SoundEmitter:PlaySound(data.object.components.pickable.picksound)
            end
        end)

        inst:ListenForEvent("dropitem", function(it, data)
            Print(VERBOSITY.DEBUG, "dropitem: [" .. data.item.prefab .. "]")
            inst.SoundEmitter:PlaySound("dontstarve/common/dropGeneric")
        end)

        inst:ListenForEvent("builditem", function(it, data)
            Print(VERBOSITY.DEBUG, "builditem: [" .. data.item.prefab .. "]")
            inst.SoundEmitter:PlaySound("dontstarve/HUD/collect_newitem")
        end)

        inst:ListenForEvent("buildstructure", function(it, data)
            Print(VERBOSITY.DEBUG, "buildstructure: [" .. data.item.prefab .. "]")
            inst.SoundEmitter:PlaySound("dontstarve/HUD/collect_newitem")
        end)

        --set up the UI root entity
        --HUD:SetMainCharacter(inst)

        inst:ListenForEvent("actionfailed", function(it, data)
            inst.components.talker:Say(GetActionFailString(inst.prefab, data.action.action.id, data.reason))
        end)

        inst:ListenForEvent("spawn", function(it, data)
            inst.components.bundler:StopBundling()
        end)

        inst.CanExamine = function()
            return not inst.beaver
        end

        if customfn then
            customfn(inst)
        end

        return inst
    end

    return Prefab("characters/" .. name, fn, assets, prefabs)
end

return MakePlayerCharacter
