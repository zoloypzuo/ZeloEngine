local assets=
{
	Asset("ANIM", "anim/frog_legs.zip"),
}


local prefabs =
{
	"froglegs_cooked",
}    

local function commonfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.AnimState:SetBank("frog_legs")
    inst.AnimState:SetBuild("frog_legs")
    
    MakeInventoryPhysics(inst)
    
    inst:AddTag("smallmeat")
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    
    
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("bait")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 0


    return inst
end

local function defaultfn()
	local inst = commonfn()
    inst.AnimState:PlayAnimation("idle")
    
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
    
    
    inst:AddComponent("cookable")
    inst.components.cookable.product = "froglegs_cooked"
    inst:AddComponent("dryable")
    inst.components.dryable:SetProduct("smallmeat_dried")
    inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
	return inst
end

local function cookedfn()
	local inst = commonfn()
    inst.AnimState:PlayAnimation("cooked")

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.foodstate = "COOKED"
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    
	return inst
end

return Prefab("common/inventory/froglegs", defaultfn, assets, prefabs),
		Prefab("common/inventory/froglegs_cooked", cookedfn, assets) 
