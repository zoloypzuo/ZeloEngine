local assets = {
    Asset("ANIM", "anim/wagstaff_thumper.zip"),
    Asset("MINIMAP_IMAGE", "wagstaff_thumper"),
}

local projectile_assets = {

}

local prefabs = {

}

RANGE = 8

local function spawndrop(inst)
    local drop = SpawnPrefab("raindrop")
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local angle = math.random() * 2 * PI
    local dist = math.random() * RANGE
    local offset = Vector3(dist * math.cos(angle), 0, -dist * math.sin(angle))
    drop.Transform:SetPosition(pt.x + offset.x, 0, pt.z + offset.z)
end

local function TurnOn(inst)
    inst.sg:GoToState("raise")
end

local function TurnOff(inst)
    --inst.sg:GoToState("idle")
end

local function CanInteract(inst)
    if inst.components.machine.ison then
        return false
    end
    return true
end

local function GetStatus(inst, viewer)
    if inst.on then
        return "ON"
    else
        return "OFF"
    end
end

local function OnSave(inst, data)
    local refs = {}

    return refs
end

local function OnLoad(inst, data)

end

local function OnBuilt(inst)
    inst.sg:GoToState("place")
end

local function OnHammered(inst, worker)
    if inst:HasTag("fire") and inst.components.burnable then
        inst.components.burnable:Extinguish()
    end

    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
    TurnOff(inst, true)
    inst:Remove()
end

local function OnHit(inst, dist)
    if inst.sg:HasStateTag("idle") then
        inst.sg:GoToState("hit_low")
    end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("wagstaff_thumper.png")

    inst:AddTag("groundpoundimmune")
    inst:AddTag("metal")
    MakeObstaclePhysics(inst, 1)

    anim:SetBank("wagstaff_thumper")
    anim:SetBuild("wagstaff_thumper")
    anim:PlayAnimation("idle")
    inst.on = false

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = TurnOn
    inst.components.machine.turnofffn = TurnOff
    inst.components.machine.caninteractfn = CanInteract
    inst.components.machine.cooldowntime = 0.5

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)

    inst:AddComponent("groundpounder")
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 2
    inst.components.groundpounder.destructionRings = 3
    inst.components.groundpounder.numRings = 3

    inst:AddComponent("combat")
    inst.components.combat.defaultdamage = 30

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("onbuilt", OnBuilt)

    MakeSnowCovered(inst, .01)

    inst:SetStateGraph("SGthumper")

    return inst
end

require "prefabutil"

return Prefab("common/thumper", fn, assets, prefabs),
MakePlacer("common/thumper_placer", "wagstaff_thumper", "wagstaff_thumper", "idle")