local assets =
{
	Asset("ANIM", "anim/bulb.zip"),
    Asset("INV_IMAGE", "lightbulb"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("bulb")
    inst.AnimState:SetBuild("bulb")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")
 
    inst:AddComponent("inspectable")
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
    inst.components.fuel.fueltype = "CAVE"
    
	MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)    
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = 0
    inst.components.edible.foodtype = "VEGGIE"
    
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
    
    local light = inst.entity:AddLight()
    light:SetFalloff(0.7)
    light:SetIntensity(.5)
    light:SetRadius(0.5)
    light:SetColour(237/255, 237/255, 209/255)
    light:Enable(true)
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

    inst.components.inventoryitem:SetOnDroppedFn(function() inst.Light:Enable(true) end)
    inst.components.inventoryitem:SetOnPickupFn(function() inst.Light:Enable(false) end)
    
    return inst
end

return Prefab( "common/inventory/lightbulb", fn, assets) 

