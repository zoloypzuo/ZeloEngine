local assets = 
{
	Asset("ANIM", "anim/cook_pot_food.zip"),
}

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBuild("cook_pot_food")
	inst.AnimState:SetBank("food")
	inst.AnimState:PlayAnimation("bonestew", false)

	inst:AddTag("meat")

	inst:AddComponent("edible")
	inst.components.edible.ismeat = true    
	inst.components.edible.foodtype = "MEAT"
	local damage = GetPlayer().components.health.maxhealth
	inst.components.edible.healthvalue = -damage

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:ChangeImageName("bonestew")

	return inst
end

return Prefab("common/inventory/deadlyfeast", fn, assets) 
