local assets =
{
	Asset("ANIM", "anim/cutreeds.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cutreeds")
    inst.AnimState:SetBuild("cutreeds")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
    
	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    
    
    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab( "common/inventory/cutreeds", fn, assets) 

