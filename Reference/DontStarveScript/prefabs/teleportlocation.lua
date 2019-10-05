local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()

	inst:AddTag("teleportlocation")
	
	return inst
end

return Prefab("common/teleportlocation", fn) 