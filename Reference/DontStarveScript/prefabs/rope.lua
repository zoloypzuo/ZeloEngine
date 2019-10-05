local assets=
{
	Asset("ANIM", "anim/rope.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.AnimState:SetBank("rope")
    inst.AnimState:SetBuild("rope")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryPhysics(inst)
    
    inst:AddComponent("stackable")

    inst:AddComponent("inspectable")
    
	MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    
    
    inst:AddComponent("inventoryitem")
    
    return inst
end

return Prefab( "common/inventory/rope", fn, assets) 
