
local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()

	inst:AddComponent("teamleader")
	inst:AddTag("teamleader")
	return inst
end

return Prefab("cave/objects/teamleader", fn) 