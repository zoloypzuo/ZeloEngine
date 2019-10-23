local assets = {
    Asset("ANIM", "anim/lightning_rod.zip"),
    Asset("ANIM", "anim/lightning_rod_fx.zip"),
    Asset("MINIMAP_IMAGE", "lightningrod"),
}

local prefabs = {
    "lightning_rod_fx"
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)
end

local function discharge(inst)
    inst.AnimState:SetBloomEffectHandle("")
    inst.charged = false
    inst.chargeleft = nil
    inst.Light:Enable(false)
    if inst.zaptask then
        inst.zaptask:Cancel()
        inst.zaptask = nil
    end
end

local function dozap(inst)
    if inst.zaptask then
        inst.zaptask:Cancel()
        inst.zaptask = nil
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")

    local fx = SpawnPrefab("lightning_rod_fx")
    local pos = inst:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)


    --PlayFX(Vector3(inst.Transform:GetWorldPosition() ), "lightning_rod_fx", "lightning_rod_fx", "idle")
    inst.zaptask = inst:DoTaskInTime(math.random(10, 40), dozap)
end

local function setcharged(inst)
    dozap(inst)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.Light:Enable(true)
    inst.charged = true
    inst.chargeleft = 3
    inst:ListenForEvent("daycomplete", function()
        if inst.chargeleft then
            dozap(inst)
            inst.chargeleft = inst.chargeleft - 1
            if inst.chargeleft <= 0 then
                discharge(inst)
            end
        end
    end, GetWorld())
end

local function onlightning(inst)
    onhit(inst)
    setcharged(inst)
end

local function OnSave(inst, data)
    if inst.charged then
        data.charged = inst.charged
        data.chargeleft = inst.chargeleft
    end
end

local function OnLoad(inst, data)
    if data and data.charged and data.chargeleft then
        setcharged(inst)
        inst.chargeleft = data.chargeleft
    end
end

local function getstatus(inst)
    if inst.charged then
        return "CHARGED"
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
    inst.SoundEmitter:PlaySound("dontstarve/common/craftable/lightning_rod")
end

local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("lightningrod.png")

    local light = inst.entity:AddLight()
    inst.Light:Enable(false)
    inst.Light:SetRadius(1.5)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235 / 255, 121 / 255, 12 / 255)

    inst.entity:AddSoundEmitter()
    inst:AddTag("structure")
    inst:AddTag("lightningrod")

    anim:SetBank("lightning_rod")
    anim:SetBuild("lightning_rod")
    anim:PlayAnimation("idle")

    inst:ListenForEvent("lightningstrike", onlightning)
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    MakeSnowCovered(inst, .01)
    inst:ListenForEvent("onbuilt", onbuilt)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    return inst
end

return Prefab("common/objects/lightning_rod", fn, assets, prefabs),
MakePlacer("common/lightning_rod_placer", "lightning_rod", "lightning_rod", "idle")
