require "prefabutil"
require "tuning"

local assets = {
    Asset("ANIM", "anim/teleport_pad.zip"),
    Asset("ANIM", "anim/teleport_pad_beacon.zip"),
    Asset("MINIMAP_IMAGE", "telipad"),
}

local prefabs = {

}

--[[
local back = -1
local front = 0
local left = 1.5
local right = -1.5
]]

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
end

local function onhit(inst, worker)
    --inst.AnimState:PlayAnimation("hit")
    --inst.AnimState:PushAnimation("idle")
end

local function onbuilt(inst, sound)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
    inst.SoundEmitter:PlaySound(sound)
end

local function onremove(inst)
    if GetWorld().telipads then
        for i, pad in ipairs(GetWorld().telipads) do
            if pad == inst then
                table.remove(GetWorld().telipads, i)
                break
            end
        end
    end
end

local function turnoff(inst)
    if inst.decor then
        for i, deco in ipairs(inst.decor) do
            if not deco.AnimState:IsCurrentAnimation("place") then
                deco.AnimState:PlayAnimation("off")
            end
        end
    end
end

local function turnon(inst)
    if inst.decor then
        for i, deco in ipairs(inst.decor) do
            if not deco.AnimState:IsCurrentAnimation("place") then
                deco.AnimState:PlayAnimation("on")
            end
        end
    end
end

local function base()
    local rock_front = 1

    local decor_defs = {
        beacon = { { -1.28, 0, 1.14 } },
    }

    return function(Sim)
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()

        inst:AddTag("structure")

        anim:SetBank("teleport_pad")
        anim:SetBuild("teleport_pad")
        anim:PlayAnimation("idle")
        anim:SetOrientation(ANIM_ORIENTATION.OnGround)
        anim:SetLayer(LAYER_BACKGROUND)
        anim:SetSortOrder(3)

        local minimap = inst.entity:AddMiniMapEntity()
        minimap:SetIcon("telipad.png")

        inst:AddComponent("inspectable")
        --[[
          inst.components.inspectable.nameoverride = "FARMPLOT"
          inst.components.inspectable.getstatus = function(inst)
              if not inst.components.grower:IsFertile() then
                  return "NEEDSFERTILIZER"
              elseif not inst.components.grower:IsEmpty() then
                  return "GROWING"
              end
          end
          ]]

        inst.turnoff = turnoff
        inst.turnon = turnon

        inst.Transform:SetRotation(0)

        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(4)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)

        local sound_name = "dontstarve_wagstaff/characters/wagstaff/telepad_1"

        inst:ListenForEvent("onbuilt", function()
            onbuilt(inst, sound_name)
        end)
        inst:ListenForEvent("onremove", function()
            onremove(inst)
        end)

        local decor_items = decor_defs
        inst.decor = {}
        for item_name, data in pairs(decor_items) do
            for l, offset in pairs(data) do
                local item_inst = SpawnPrefab(item_name)
                item_inst.AnimState:PlayAnimation("place")
                item_inst.AnimState:PushAnimation("off")
                item_inst.entity:SetParent(inst.entity)
                item_inst.Transform:SetPosition(offset[1], offset[2], offset[3])
                table.insert(inst.decor, item_inst)
                if item_inst.placesound then
                    inst.SoundEmitter:PlaySound(item_inst.placesound)
                end
            end
        end

        if not GetWorld().telipads then
            GetWorld().telipads = {}
        end
        table.insert(GetWorld().telipads, inst)

        return inst
    end
end

local function makefn(bankname, buildname, animname)
    local function fn(Sim)
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        inst:AddTag("DECOR")

        anim:SetBank(bankname)
        anim:SetBuild(buildname)
        anim:PlayAnimation(animname)

        inst.placesound = "dontstarve_wagstaff/characters/wagstaff/telepad_2"

        return inst
    end
    return fn
end

local function item(name, bankname, buildname, animname)
    return Prefab("forest/objects/farmdecor/" .. name, makefn(bankname, buildname, animname), assets)
end

return item("beacon", "teleport_pad_beacon", "teleport_pad_beacon", "off"),
Prefab("common/objects/telipad", base(), assets, prefabs),
MakePlacer("common/telipad_placer", "teleport_pad", "teleport_pad", "idle", true)