local assets=
{
	Asset("ANIM", "anim/beefalo_wool.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("beefalo_wool")
    anim:SetBuild("beefalo_wool")
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

return Prefab( "common/inventory/beefalowool", fn, assets) 
