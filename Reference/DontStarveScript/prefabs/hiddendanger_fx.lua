local assets = {
    Asset("ANIM", "anim/trap_marker_fx.zip"),
    Asset("ANIM", "anim/peculiar_marker_fx.zip"),
    Asset("ANIM", "anim/identified_marker_fx.zip"),
}

local function dangerfn(Sim)

    local inst = CreateEntity()
    inst.persists = false

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("trap_marker_fx")
    inst.AnimState:SetBuild("trap_marker_fx")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetTime(math.random() * 3)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    return inst
end

local function questionfn(Sim)

    local inst = CreateEntity()
    inst.persists = false

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("peculiar_marker_fx")
    inst.AnimState:SetBuild("peculiar_marker_fx")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetTime(math.random() * 3)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    return inst
end

local function idfn(Sim)

    local inst = CreateEntity()
    inst.persists = false

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("identified_marker_fx")
    inst.AnimState:SetBuild("identified_marker_fx")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetTime(math.random() * 3)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    return inst
end

return Prefab("common/inventory/hiddendanger_fx", dangerfn, assets),
Prefab("common/inventory/peculiar_marker_fx", questionfn, assets),
Prefab("common/inventory/identified_marker_fx", idfn, assets)
