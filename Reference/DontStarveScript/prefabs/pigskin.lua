local assets=
{
	Asset("ANIM", "anim/pigskin.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.AnimState:SetBank("pigskin")
    inst.AnimState:SetBuild("pigskin")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryPhysics(inst)
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
	MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    

	inst:AddComponent("tradable")    
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
	
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "HORRIBLE"
    

    return inst
end

return Prefab( "common/inventory/pigskin", fn, assets) 
