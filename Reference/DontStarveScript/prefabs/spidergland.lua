local assets=
{
	Asset("ANIM", "anim/spider_gland.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("spider_gland")
    inst.AnimState:SetBuild("spider_gland")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
    
	MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)

    ---------------------       
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(TUNING.HEALING_MEDSMALL)
    
    return inst
end

return Prefab( "common/inventory/spidergland", fn, assets) 

