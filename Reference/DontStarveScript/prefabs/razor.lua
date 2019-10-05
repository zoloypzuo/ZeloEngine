local assets=
{
	Asset("ANIM", "anim/razor.zip"),
}
    
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("razor")
    anim:SetBuild("razor")
    anim:PlayAnimation("idle")
    
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("shaver")

    return inst
end

return Prefab( "common/inventory/razor", fn, assets) 
