local function OnNear(inst)
	for k,v in pairs(inst.components.maxlightspawner.lights) do
		v.components.burnable:Ignite()
	end
end

local function OnFar(inst)
	for k,v in pairs(inst.components.maxlightspawner.lights) do
		v.components.burnable:Extinguish()
	end
end



local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()

	inst:AddComponent("playerprox")

	inst:AddComponent("maxlightspawner")	
	
	inst.components.playerprox:SetOnPlayerNear(OnNear)
	inst.components.playerprox:SetOnPlayerFar(OnFar)
	inst.components.playerprox:SetDist(6,8)
	inst:DoTaskInTime(0, function() inst.components.maxlightspawner:SpawnAllLights() end)

	return inst
end

local function horizontal()
	local inst = fn()

	return inst
end

local function vertical()
	local inst = fn()
	inst.components.maxlightspawner.angleoffset = 90
	return inst
end


local function quad()
	local inst = fn()
	inst.components.maxlightspawner.angleoffset = 45
	inst.components.maxlightspawner.maxlights = 4
	inst.components.maxlightspawner.radius = 4.2
	return inst
end

return Prefab("forest/objects/horizontal_maxwelllight", horizontal),
Prefab("forest/objects/vertical_maxwelllight", vertical),
Prefab("forest/objects/quad_maxwelllight", quad) 
