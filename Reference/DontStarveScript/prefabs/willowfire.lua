
local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
    MakeInventoryPhysics(inst)

	MakeSmallBurnable(inst, 4+ math.random()*4)
    MakeSmallPropagator(inst)
    inst.components.burnable:Ignite()
    
    inst:AddComponent("heater")
    inst.components.heater.heat = 20
    
    return inst
end

return Prefab( "common/willowfire", fn) 


