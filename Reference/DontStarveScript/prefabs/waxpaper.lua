local assets =
{
    Asset("ANIM", "anim/wax_paper.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBuild("wax_paper")
    inst.AnimState:SetBank("wax_paper")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("tradable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.propagator.flashpoint = 10 + math.random() * 5

    return inst
end

return Prefab("waxpaper", fn, assets)