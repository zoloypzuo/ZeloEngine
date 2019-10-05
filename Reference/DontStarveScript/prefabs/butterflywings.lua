local assets=
{
	Asset("ANIM", "anim/butterfly_wings.zip"),
}

local prefabs = 
{
	"spoiled_food",
}
local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    
    
    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.foodtype = "VEGGIE"

    
    inst.AnimState:SetBank("butterfly_wings")
    inst.AnimState:SetBuild("butterfly_wings")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
    
    
    return inst
end

return Prefab( "common/inventory/butterflywings", fn, assets, prefabs) 
