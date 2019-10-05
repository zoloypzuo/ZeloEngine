local assets=
{
	Asset("ANIM", "anim/flint.zip"),
}


local function shine(inst)
    inst.task = nil
    inst.AnimState:PlayAnimation("sparkle")
    inst.AnimState:PushAnimation("idle")
    inst.task = inst:DoTaskInTime(4+math.random()*5, function() shine(inst) end)
end


local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.entity:AddSoundEmitter()
    
    inst.AnimState:SetRayTestOnBB(true);    
    inst.AnimState:SetBank("flint")
    inst.AnimState:SetBuild("flint")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ELEMENTAL"
    inst.components.edible.hungervalue = 1
    inst:AddComponent("tradable")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

	--shine(inst)
	
    return inst
end

return Prefab( "common/inventory/flint", fn, assets) 
