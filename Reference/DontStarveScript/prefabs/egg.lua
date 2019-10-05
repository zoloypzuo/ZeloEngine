local assets=
{
	Asset("ANIM", "anim/bird_eggs.zip"),
}


local prefabs =
{
    "bird_egg_cooked",
    "rottenegg",
}    

local function commonfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.AnimState:SetBank("birdegg")
    inst.AnimState:SetBuild("bird_eggs")
    
    MakeInventoryPhysics(inst)
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "rottenegg"
    
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("bait")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 1


    return inst
end

local function defaultfn()
	local inst = commonfn()
    inst.AnimState:PlayAnimation("idle")
    
    inst.components.edible.healthvalue = 0
    inst.components.edible.sanityvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    
    inst:AddComponent("cookable")
    inst.components.cookable.product = "bird_egg_cooked"
	return inst
end

local function cookedfn()
	local inst = commonfn()
    inst.AnimState:PlayAnimation("cooked")

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable.onperishreplacement = "spoiled_food"    

	return inst
end


local function rottenfn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("birdegg")
    anim:SetBuild("bird_eggs")
    anim:PlayAnimation("rotten")
    
    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.SPOILEDFOOD_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.SPOILEDFOOD_SOILCYCLES
    
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    
    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.SPOILED_HEALTH
    inst.components.edible.hungervalue = TUNING.SPOILED_HUNGER
    
    return inst
end

return Prefab("common/inventory/bird_egg", defaultfn, assets, prefabs),
		Prefab("common/inventory/bird_egg_cooked", cookedfn, assets),
        Prefab("common/inventory/rottenegg", rottenfn, assets) 
