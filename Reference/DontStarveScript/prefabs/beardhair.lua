local assets=
{
	Asset("ANIM", "anim/beardhair.zip"),
    Asset("INV_IMAGE", "beardhair"),
}


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("beardhair")
    anim:SetBuild("beardhair")
    anim:PlayAnimation("idle")
    
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM


    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    
    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)
    
    
    return inst
end

return Prefab( "common/inventory/beardhair", fn, assets) 
