require "stategraphs/SGwormhole_limited"

local assets = {
    Asset("ANIM", "anim/teleporter_worm.zip"),
    Asset("ANIM", "anim/teleporter_sickworm_build.zip"),
    Asset("SOUND", "sound/common.fsb"),
    Asset("MINIMAP_IMAGE", "wormhole_sick"),
}

local function onsave(inst, data)
    data.usesleft = inst.usesleft
end

local function onload(inst, data)
    if data and data.usesleft then
        inst.usesleft = data.usesleft
    end
end

local function GetStatus(inst)
    if inst.sg.currentstate.name ~= "idle" then
        return "OPEN"
    else
        return "CLOSED"
    end
end

local function incrementuses(inst)

    local sisterworm = inst.components.teleporter.targetTeleporter
    inst.usesleft = inst.usesleft - 1
    print("Worm Uses Left:", inst.usesleft)
    if inst.usesleft <= 0 then
        inst.sg:GoToState("death")
        inst.components.teleporter.targetTeleporter = nil
    end

    if sisterworm then
        sisterworm.usesleft = sisterworm.usesleft - 1
        if sisterworm.usesleft <= 0 then
            sisterworm.sg:GoToState("death")
            sisterworm.components.teleporter.targetTeleporter = nil
        end
    end

end

local function OnActivate(inst, doer)
    if inst.components.teleporter.targetTeleporter and inst.usesleft > 0 then
        if doer:HasTag("player") then
            ProfileStatsSet("wormhole_ltd_used", true)
            doer.components.health:SetInvincible(true)
            doer.components.playercontroller:Enable(false)

            if inst.components.teleporter.targetTeleporter ~= nil then
                DeleteCloseEntsWithTag(inst.components.teleporter.targetTeleporter, "WORM_DANGER", 15)
            end

            TheFrontEnd:SetFadeLevel(1)
            doer:DoTaskInTime(4, function()
                TheFrontEnd:Fade(true, 2)
                doer.sg:GoToState("wakeup")
                if doer.components.sanity then
                    doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
                end
                doer:PushEvent("wormholespit")
                doer.components.health:SetInvincible(false)
                doer.components.playercontroller:Enable(true)
                inst:DoTaskInTime(0.5, incrementuses)
            end)
        elseif doer.SoundEmitter then
            inst.SoundEmitter:PlaySound("dontstarve/common.teleportworm/swallow", "wormhole_swallow")
        end

    end
end

local function onnear(inst)
    if inst.components.teleporter.targetTeleporter ~= nil then
        inst.sg:GoToState("opening")
    end
end

local function onfar(inst)
    inst.sg:GoToState("closing")
end

local function onaccept(reciever, giver, item)
    if giver and giver.components.inventory then
        giver.components.inventory:DropItem(item)
    end
    if reciever and reciever.components.teleporter then
        ProfileStatsSet("wormhole_ltd_accept_item", item.prefab)
        reciever.components.teleporter:Activate(item)
    end
end
local function makewormhole(uses)

    local function fn()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()

        inst.usesleft = uses

        local minimap = inst.entity:AddMiniMapEntity()
        minimap:SetIcon("wormhole_sick.png")

        anim:SetBank("teleporter_worm")
        anim:SetBuild("teleporter_sickworm_build")
        anim:PlayAnimation("idle_loop", true)
        anim:SetLayer(LAYER_BACKGROUND)
        anim:SetSortOrder(3)

        inst:SetStateGraph("SGwormhole_limited")

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = GetStatus
        inst.components.inspectable.nameoverride = "WORMHOLE_LIMITED"
        inst.components.inspectable:RecordViews()

        inst:AddComponent("playerprox")
        inst.components.playerprox:SetDist(4, 5)
        inst.components.playerprox.onnear = onnear
        inst.components.playerprox.onfar = onfar

        inst:AddComponent("teleporter")
        inst.components.teleporter.onActivate = OnActivate

        inst:AddComponent("inventory")

        inst:AddComponent("trader")
        inst.components.trader.onaccept = onaccept

        inst.OnSave = onsave
        inst.OnLoad = onload

        return inst
    end

    return Prefab("common/wormhole_limited_" .. uses, fn, assets)
end

return makewormhole(1) 
