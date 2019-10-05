local assets =
{
	Asset("ANIM", "anim/thulecite_pieces.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("thulecite_pieces")
    inst.AnimState:SetBuild("thulecite_pieces")
    inst.AnimState:PlayAnimation("anim")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ELEMENTAL"
    inst.components.edible.hungervalue = 1

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = "thulecite"
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_THULECITE_PIECES_HEALTH
    inst.components.repairer.workrepairvalue = TUNING.REPAIR_THULECITE_PIECES_WORK

    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    return inst
end

return Prefab( "common/inventory/thulecite_pieces", fn, assets)
