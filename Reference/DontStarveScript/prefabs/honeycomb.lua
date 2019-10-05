local assets=
{
	Asset("ANIM", "anim/honeycomb.zip"),
}


local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    
    inst.AnimState:SetBuild("honeycomb")
    inst.AnimState:SetBank("honeycomb")
    inst.AnimState:PlayAnimation("idle")
    
    --inst:AddComponent("edible")
    --inst.components.edible.healthvalue = TUNING.HONEYCOMB_HEALTH
    --inst.components.edible.hungervalue = TUNING.HONEYCOMB_HUNGER

    inst:AddComponent("stackable")
    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    return inst
end

return Prefab( "common/inventory/honeycomb", fn, assets) 
