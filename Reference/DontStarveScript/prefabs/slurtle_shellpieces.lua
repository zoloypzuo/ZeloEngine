local assets=
{
	Asset("ANIM", "anim/slurtle_shellpieces.zip"),
	Asset("INV_IMAGE", "slurtle_shellpieces"),
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("slurtle_shellpieces")
	inst.AnimState:SetBuild("slurtle_shellpieces")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")

	inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

	return inst
end


return Prefab("common/inventory/slurtle_shellpieces", fn, assets) 
