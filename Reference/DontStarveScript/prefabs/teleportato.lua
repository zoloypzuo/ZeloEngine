local PopupDialogScreen = require "screens/popupdialog"
local DeathScreen = require "screens/deathscreen"

local assets = {
    Asset("ANIM", "anim/teleportato.zip"),
    Asset("ANIM", "anim/teleportato_build.zip"),
    Asset("ANIM", "anim/teleportato_adventure_build.zip"),
    Asset("INV_IMAGE", "teleportato_base"),
    Asset("INV_IMAGE", "teleportato_box"),
    Asset("INV_IMAGE", "teleportato_box_adv"),
    Asset("INV_IMAGE", "teleportato_crank"),
    Asset("INV_IMAGE", "teleportato_crank_adv"),
    Asset("INV_IMAGE", "teleportato_potato"),
    Asset("INV_IMAGE", "teleportato_potato_adv"),
    Asset("INV_IMAGE", "teleportato_ring"),
    Asset("INV_IMAGE", "teleportato_ring_adv"),
    Asset("MINIMAP_IMAGE", "teleportato"),
}

local prefabs = {
    "ash",
}

local function TransitionToNextLevel(inst, wilson)

    -- local all_resurrectors = SaveGameIndex:GetAllResurrectors()
    -- if all_resurrectors then



    -- end

    -- local resurrectors_overworld = {}
    -- local resurrectors_caves = {}
    -- local res = wilson.components.resurrectable:FindClosestResurrector()
    -- if not res then -- If there are no resurrectors in this world
    -- 	res = SaveGameIndex:GetResurrector() -- Check the caves
    -- 	while res do -- While we have more resurrectors in the caves, do this business
    -- 		if res then
    -- 			SaveGameIndex:DeregisterResurrector(res)
    -- 		end
    -- 		res = SaveGameIndex:GetResurrector()
    -- 	end
    -- end

    wilson.sg:GoToState("teleportato_teleport")
    local days_survived, start_xp, reward_xp, new_xp, capped = CalculatePlayerRewards(wilson)

    local function onsave()
        scheduler:ExecuteInTime(110 * FRAMES, function()
            inst.AnimState:PlayAnimation("laugh", false)
            inst.AnimState:PushAnimation("active_idle", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_maxwelllaugh", "teleportato_laugh")

        end)

        scheduler:ExecuteInTime(110 * FRAMES + 3, function()
            if inst.action == "restart" then
                local function onsaved()
                    StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot(), maxwell = inst.maxwell }, true)
                end
                if inst.teleportpos then
                    GetPlayer().Transform:SetPosition(inst.teleportpos:Get())
                end
                SaveGameIndex:SaveCurrent(onsaved)
            else

                --THIS IS THE COMMON PATH!!

                if SaveGameIndex:GetCurrentMode() ~= "adventure" then
                    SaveGameIndex:ClearCavesResurrectors()
                end
                SaveGameIndex:CompleteLevel(function()
                    TheFrontEnd:PushScreen(DeathScreen(days_survived, start_xp, true, capped))
                end)
            end
        end)
    end

    wilson.profile:Save(onsave)
end

local function GetBodyText()
    if SaveGameIndex:GetCurrentMode(Settings.save_slot) == "adventure" then
        return STRINGS.UI.TELEPORTBODY_ADVENTURE
    end
    return STRINGS.UI.TELEPORTBODY_SURVIVAL
end

local function CheckNextLevelSure(inst, doer)
    SetPause(true, "portal")

    TheFrontEnd:PushScreen(
            PopupDialogScreen(STRINGS.UI.TELEPORTTITLE, GetBodyText(),
                    {
                        { text = STRINGS.UI.TELEPORTYES, cb = function()

                            print("Lets Go!")
                            TheFrontEnd:PopScreen()
                            SetPause(false)
                            ProfileStatsSet("teleportato_used", true)
                            local wilson = GetPlayer()
                            wilson.is_teleporting = true
                            scheduler:ExecuteInTime(1, function()
                                TransitionToNextLevel(inst, doer)
                            end)
                        end },
                        { text = STRINGS.UI.TELEPORTNO, cb = function()
                            print("Think I'll stay here")
                            TheFrontEnd:PopScreen()
                            SetPause(false)
                            inst.components.activatable.inactive = true
                        end }
                    }))
end

local function OnActivate(inst, doer)
    --inst.components.activatable.inactive = false
    if not inst.activatedonce then
        inst.activatedonce = true
        inst.AnimState:PlayAnimation("activate", false)
        inst.AnimState:PushAnimation("active_idle", true)
        inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_activate", "teleportato_activate")
        inst.SoundEmitter:KillSound("teleportato_idle")
        inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_activeidle_LP", "teleportato_active_idle")

        inst:DoTaskInTime(40 * FRAMES, function()
            inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_activate_mouth", "teleportato_activatemouth")
        end)

        if inst.action == "restart" then
            inst:DoTaskInTime(2.0, function()
                TransitionToNextLevel(inst, doer)
            end)
        elseif SaveGameIndex:GetCurrentMode(Settings.save_slot) == "adventure" then
            inst.components.container.canbeopened = true
            inst:DoTaskInTime(2.0, function()
                inst.components.container:Open(doer)
            end)
        else
            inst:DoTaskInTime(3.0, function()
                CheckNextLevelSure(inst, doer)
            end)
        end
    elseif SaveGameIndex:GetCurrentMode(Settings.save_slot) == "survival" then
        CheckNextLevelSure(inst, doer)
    end
end

local function GetStatus(inst)
    ProfileStatsSet("teleportato_inspected", true)
    local partsCount = 0
    for part, found in pairs(inst.collectedParts) do
        if found == true then
            partsCount = partsCount + 1
        end
    end

    if partsCount == 4 then
        if SaveGameIndex:GetCurrentMode(Settings.save_slot) == "adventure" then
            local rodbase = TheSim:FindFirstEntityWithTag("rodbase")
            if rodbase and rodbase.components.lock and rodbase.components.lock:IsLocked() then
                return "LOCKED"
            end
        else
            return "ACTIVE"
        end
    elseif partsCount > 0 then
        return "PARTIAL"
    end
end

local function ItemTradeTest(inst, item)
    if item:HasTag("teleportato_part") then
        return true
    end
    return false
end

local function PowerUp(inst)
    ProfileStatsSet("teleportato_powerup", true)
    inst.AnimState:PlayAnimation("power_on", false)
    inst.AnimState:PushAnimation("idle_on", true)

    inst.components.activatable.inactive = true

    if SaveGameIndex:GetCurrentMode(Settings.save_slot) == "adventure" then
        inst:SetInherentSceneAltAction(ACTIONS.TRAVEL)
    end

    inst.travel_action_fn = function(doer)
        CheckNextLevelSure(inst, doer)
    end

    inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_powerup", "teleportato_on")
    inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_idle_LP", "teleportato_idle")

end

local partSymbols = { teleportato_ring = "RING", teleportato_crank = "CRANK", teleportato_box = "BOX", teleportato_potato = "POTATO" }

local function TestForPowerUp(inst)
    local allParts = true
    for part, found in pairs(inst.collectedParts) do
        if found == false then
            inst.AnimState:Hide(partSymbols[part])
            allParts = false
        else
            inst.AnimState:Show(partSymbols[part])
        end
    end
    if allParts == true then

        --this is a controller hack. It's... kinda gross

        inst.components.trader:Disable()
        local rodbase = TheSim:FindFirstEntityWithTag("rodbase")
        if rodbase and rodbase.components.lock and rodbase.components.lock:IsLocked() then
            rodbase:PushEvent("ready")
            inst:ListenForEvent("powerup", PowerUp)
        else
            inst:DoTaskInTime(0.5, PowerUp)
        end
    end
end

local function ItemGet(inst, giver, item)
    if inst.collectedParts[item.prefab] ~= nil then
        inst.collectedParts[item.prefab] = true
        inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_addpart", "teleportato_addpart")
        TestForPowerUp(inst)
    end
end

local function MakeComplete(inst)
    print("Made Complete")
    inst.collectedParts = { teleportato_ring = true, teleportato_crank = true, teleportato_box = true, teleportato_potato = true }
end

local function OnLoad(inst, data)
    if data then
        if data.makecomplete == 1 then
            print("has make complete data")
            MakeComplete(inst)
            TestForPowerUp(inst)
        end
        if data.collectedParts then
            inst.collectedParts = data.collectedParts
            TestForPowerUp(inst)
        end
        inst.action = data.action
        inst.maxwell = data.maxwell
        if data.teleportposx and data.teleportposz then
            inst.teleportpos = Vector3(data.teleportposx, 0, data.teleportposz)
        end
    end
end

local function OnPlayerFar(inst)
    inst.components.container:Close()
end

local slotpos = { Vector3(0, 64 + 32 + 8 + 4, 0),
                  Vector3(0, 32 + 4, 0),
                  Vector3(0, -(32 + 4), 0),
                  Vector3(0, -(64 + 32 + 8 + 4), 0) }

local widgetbuttoninfo = {
    text = "Activate",
    position = Vector3(0, -165, 0),
    fn = function(inst, doer)
        CheckNextLevelSure(inst, doer)
    end,
}

local function ItemTest(inst, item, slot)
    return not item:HasTag("nonpotatable")
end

local function OnSave(inst, data)
    data.collectedParts = inst.collectedParts
    data.action = inst.action
    data.maxwell = inst.maxwell
    if inst.teleportpos then
        data.teleportposx = inst.teleportpos.x
        data.teleportposz = inst.teleportpos.z
    end
end

local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    anim:SetBank("teleporter")

    if SaveGameIndex:GetCurrentMode(Settings.save_slot) == "adventure" then
        anim:SetBuild("teleportato_adventure_build")
    else
        anim:SetBuild("teleportato_build")
    end

    inst:AddTag("teleportato")

    anim:PlayAnimation("idle_off", true)

    MakeObstaclePhysics(inst, 1.1)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetPriority(5)
    minimap:SetIcon("teleportato.png")
    minimap:SetPriority(1)

    inst.entity:AddSoundEmitter()

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    inst.components.inspectable:RecordViews()

    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = false
    inst.components.activatable.quickaction = true

    inst:AddComponent("container")
    inst.components.container.canbeopened = false
    inst.components.container.itemtestfn = ItemTest
    inst.components.container:SetNumSlots(4)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_cookpot_1x4"
    inst.components.container.widgetanimbuild = "ui_cookpot_1x4"
    inst.components.container.widgetpos = Vector3(0, 0, 0)
    inst.components.container.side_align_tip = 100
    inst.components.container.widgetbuttoninfo = widgetbuttoninfo
    inst.components.container.type = "cooker"

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3, 5)
    inst.components.playerprox:SetOnPlayerFar(OnPlayerFar)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = ItemGet

    -- The "construction" requires a list of parts to have been added
    inst.collectedParts = { teleportato_ring = false, teleportato_crank = false, teleportato_box = false, teleportato_potato = false }
    for part, symbol in pairs(partSymbols) do
        inst.AnimState:Hide(symbol)
    end

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("common/objects/teleportato_base", fn, assets, prefabs)

