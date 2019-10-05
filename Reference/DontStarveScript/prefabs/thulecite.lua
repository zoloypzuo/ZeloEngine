local assets =
{
	Asset("ANIM", "anim/thulecite.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("thulecite")
    inst.AnimState:SetBuild("thulecite")
    inst.AnimState:PlayAnimation("anim")

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = "thulecite"
    inst.components.repairer.workrepairvalue = TUNING.REPAIR_THULECITE_WORK
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_THULECITE_HEALTH
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ELEMENTAL"
    inst.components.edible.hungervalue = 3

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")

    return inst
end

return Prefab( "common/inventory/thulecite", fn, assets)
