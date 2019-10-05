local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()

	inst.entity:AddGroundCreepEntity()

	inst.GroundCreepEntity:SetRadius( 3 )

	inst:DoTaskInTime(5, function() inst:Remove() end)
	inst.persists = false

	return inst
end

return Prefab("common/spider_web_spit_creep", fn) 