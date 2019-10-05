local assets=
{
	Asset("ANIM", "anim/gold_nugget.zip"),
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
	inst.entity:AddSoundEmitter()
	inst.entity:AddPhysics()
    MakeInventoryPhysics(inst)

	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )    
	
    inst.AnimState:SetBank("goldnugget")
    inst.AnimState:SetBuild("gold_nugget")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ELEMENTAL"
    inst.components.edible.hungervalue = 2
    inst:AddComponent("tradable")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("stackable")
    inst:AddComponent("inventoryitem")
    
    shine(inst)
    return inst
end

return Prefab( "common/inventory/goldnugget", fn, assets) 
