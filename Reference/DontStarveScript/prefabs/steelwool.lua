local assets =
{
    Asset("ANIM", "anim/steel_wool.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("steel_wool")
    inst.AnimState:SetBuild("steel_wool")
    inst.AnimState:PlayAnimation("idle")

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

return Prefab("steelwool", fn, assets)