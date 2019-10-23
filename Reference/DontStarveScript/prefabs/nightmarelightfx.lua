local assets = {
    Asset("ANIM", "anim/rock_light_fx.zip"),
    Asset("ANIM", "anim/nightmare_crack_ruins_fx.zip"),
    Asset("ANIM", "anim/nightmare_crack_upper_fx.zip"),
}

local function lightfn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    inst:AddTag("NOCLICK")

    anim:SetBank("rock_light_fx")
    anim:SetBuild("rock_light_fx")
    anim:PlayAnimation("idle_closed", false)

    inst.persists = false

    return inst
end

local function crackfn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    inst:AddTag("NOCLICK")

    anim:SetBank("nightmare_crack_ruins_fx")
    anim:SetBuild("nightmare_crack_ruins_fx")
    anim:PlayAnimation("idle_closed", false)

    inst.persists = false

    return inst
end

local function upper_crackfn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    inst:AddTag("NOCLICK")

    inst:AddComponent("colourtweener")
    anim:SetBank("nightmare_crack_upper_fx")
    anim:SetBuild("nightmare_crack_upper_fx")
    anim:PlayAnimation("idle_closed", false)

    inst.persists = false

    return inst
end

return Prefab("common/nightmarelightfx", lightfn, assets),
Prefab("common/nightmarefissurefx", crackfn, assets),
Prefab("common/upper_nightmarefissurefx", upper_crackfn, assets)