local assets =
{
	Asset("ANIM", "anim/warning_shadow.zip"),
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
    anim:SetBank("warning_shadow")
    anim:SetBuild("warning_shadow")
    anim:PlayAnimation("idle", true)
    anim:SetFinalOffset(-1)
    inst.persists = false
    inst:AddTag("fx")
    return inst
end

return Prefab("common/fx/warningshadow", fn, assets) 
