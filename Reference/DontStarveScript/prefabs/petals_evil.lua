local assets =
{
	Asset("ANIM", "anim/flower_petals_evil.zip"),
}

local function oneaten(inst, eater)
    if eater and eater.components.sanity then
        eater.components.sanity:DoDelta(-TUNING.SANITY_TINY)
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("flower_petals_evil")
    inst.AnimState:SetBuild("flower_petals_evil")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")
 
    inst:AddComponent("inspectable")
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.TINY_FUEL
    
	MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)
    
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("edible") --Different effect? Reduce health?
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0
    inst.components.edible.foodtype = "VEGGIE"
    inst.components.edible:SetOnEatenFn(oneaten)
    
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
    
    
    
    return inst
end

return Prefab( "common/inventory/petals_evil", fn, assets) 

