local assets=
{
	Asset("ANIM", "anim/log.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("log")
    inst.AnimState:SetBuild("log")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "WOOD"
    inst.components.edible.woodiness = 10

    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    
    
	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)

    ---------------------       
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
	inst:AddComponent("repairer")
	inst.components.repairer.repairmaterial = "wood"
	inst.components.repairer.healthrepairvalue = TUNING.REPAIR_LOGS_HEALTH


	--inst:ListenForEvent("burnt", function(inst) inst.entity:Retire() end)
    
    return inst
end

return Prefab( "common/inventory/log", fn, assets) 

