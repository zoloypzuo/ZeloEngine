local assets=
{
	Asset("ANIM", "anim/anim_test.zip"),
}


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    
    anim:SetBank("anim_test_bank")
    anim:SetBuild("anim_test")
    anim:PlayAnimation("anim0", true)
    
    return inst
end

return Prefab( "common/anim_test", fn, assets) 