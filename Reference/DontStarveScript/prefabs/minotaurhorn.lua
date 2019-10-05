local assets=
{
	Asset("ANIM", "anim/horn_rhino.zip"),
    Asset("INV_IMAGE", "minotaurhorn"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.AnimState:SetBank("horn_rhino")
    inst.AnimState:SetBuild("horn_rhino")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryPhysics(inst)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible.healthvalue = TUNING.HEALING_HUGE
    inst.components.edible.hungervalue = TUNING.CALORIES_HUGE
    inst.components.edible.sanityvalue = -TUNING.SANITY_MED

    return inst
end

return Prefab( "common/inventory/minotaurhorn", fn, assets) 
