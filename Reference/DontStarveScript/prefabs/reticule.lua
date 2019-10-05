local assets = 
{
    Asset("ANIM", "anim/reticule.zip"),

}

local function reticule()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    anim:SetBank("reticule")
    anim:SetBuild("reticule")
    anim:PlayAnimation("idle")
    anim:SetOrientation( ANIM_ORIENTATION.OnGround )
    anim:SetLayer( LAYER_BACKGROUND )
    anim:SetSortOrder( 3 )

    inst:AddComponent("colourtweener")
    inst.components.colourtweener:StartTween({0,0,0,1}, 0)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.persists = false

    return inst
end

return Prefab("common/reticule", reticule, assets)