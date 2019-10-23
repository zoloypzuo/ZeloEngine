local assets = {
    Asset("ANIM", "anim/twigs.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    anim:SetBank("twigs")
    anim:SetBuild("twigs")
    anim:PlayAnimation("idle")

    -----------------
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    -----------------
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ROUGHAGE"
    inst.components.edible.woodiness = 5

    ---------------------
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inspectable")
    ----------------------

    inst:AddComponent("inventoryitem")

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = "wood"
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_STICK_HEALTH

    return inst
end

return Prefab("common/inventory/twigs", fn, assets)
