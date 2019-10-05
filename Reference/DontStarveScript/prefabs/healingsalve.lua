local assets =
{
	Asset("ANIM", "anim/spider_gland_salve.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("spider_gland_salve")
    inst.AnimState:SetBuild("spider_gland_salve")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(TUNING.HEALING_MED)
    
    return inst
end

return Prefab( "common/inventory/healingsalve", fn, assets) 

