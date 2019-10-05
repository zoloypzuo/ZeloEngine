local assets =
{
	Asset("ANIM", "anim/cutgrass.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cutgrass")
    inst.AnimState:SetBuild("cutgrass")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ROUGHAGE"
    inst.components.edible.woodiness = 1

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
    
	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    
	inst:AddComponent("repairer")
	inst.components.repairer.repairmaterial = "hay"
	inst.components.repairer.healthrepairvalue = TUNING.REPAIR_CUTGRASS_HEALTH
    
    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab( "common/inventory/cutgrass", fn, assets) 

