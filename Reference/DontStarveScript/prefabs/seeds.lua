require "prefabs/veggies"
local assets=
{
	Asset("ANIM", "anim/seeds.zip"),
}

local prefabs =
{
    "seeds_cooked",
    "spoiled_food",
}    

for k,v in pairs(VEGGIES) do
	table.insert(prefabs, k)
end

local function pickproduct(inst)
	
	local total_w = 0
	for k,v in pairs(VEGGIES) do
		total_w = total_w + (v.seed_weight or 1)
	end
	
	local rnd = math.random()*total_w
	for k,v in pairs(VEGGIES) do
		rnd = rnd - (v.seed_weight or 1)
		if rnd <= 0 then
			return k
		end
	end
	
	return "carrot"
end


local function common()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("seeds")
    inst.AnimState:SetBuild("seeds")
    inst.AnimState:SetRayTestOnBB(true)
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "SEEDS"

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    
    inst:AddComponent("inventoryitem")
    
	inst:AddComponent("perishable")

	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
    
    return inst
end

local function raw()
    local inst = common()
    inst.AnimState:PlayAnimation("idle")
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2
    
    inst:AddComponent("cookable")
    inst.components.cookable.product = "seeds_cooked"
    
	inst:AddComponent("bait")
    inst:AddComponent("plantable")
    inst.components.plantable.growtime = TUNING.SEEDS_GROW_TIME
    inst.components.plantable.product = pickproduct
    
    
    
    return inst
end

local function cooked()
    local inst = common()
    inst.AnimState:PlayAnimation("cooked")
	inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2
    inst.components.edible.foodstate = "COOKED"
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    
    return inst
end

return Prefab( "common/inventory/seeds", raw, assets, prefabs),
       Prefab("common/inventory/seeds_cooked", cooked, assets) 
