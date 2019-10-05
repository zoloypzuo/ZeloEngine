local assets=
{
	Asset("ANIM", "anim/spoiled_food.zip"),
}


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("spoiled")
    anim:SetBuild("spoiled_food")
    anim:PlayAnimation("idle")
    
    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.SPOILEDFOOD_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.SPOILEDFOOD_SOILCYCLES
    
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("selfstacker")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    
    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.SPOILED_HEALTH
    inst.components.edible.hungervalue = TUNING.SPOILED_HUNGER
    
    
    
    return inst
end

return Prefab( "common/spoiled_food", fn, assets) 
