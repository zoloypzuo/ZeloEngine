local assets =
{
	Asset("ANIM", "anim/bandage.zip"),
    Asset("INV_IMAGE", "bandage"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("bandage")
    inst.AnimState:SetBuild("bandage")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(TUNING.HEALING_MEDLARGE)
    
    return inst
end

return Prefab( "common/inventory/bandage", fn, assets)

