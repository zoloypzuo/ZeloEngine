local assets=
{
	Asset("ANIM", "anim/hounds_tooth.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.AnimState:SetBank("houndstooth")
    inst.AnimState:SetBuild("hounds_tooth")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryPhysics(inst)
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst:AddComponent("selfstacker")
    return inst
end

return Prefab( "common/inventory/houndstooth", fn, assets) 
