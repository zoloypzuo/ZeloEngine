local function RegisterAreaAware(inst)
	local ground = GetWorld()
	for i,node in ipairs(ground.topology.nodes) do
		local story = ground.topology.ids[i]
		-- guard for old saves
		local story_depth = nil
		if ground.topology.story_depths then
			story_depth = ground.topology.story_depths[i]
		end
		if story ~= "START" then
			story = string.sub(story, 1, string.find(story,":")-1)
--					
--					if Profile:IsWorldGenUnlocked("tasks", story) == false then
--						wilson.components.area_unlock:RegisterStory(story)
--					end
		end
		inst.components.area_aware:RegisterArea({idx=i, type=node.type, poly=node.poly, story=story, story_depth=story_depth, cent=node.cent})
	end
end


local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()

	inst:AddComponent("area_aware")
	RegisterAreaAware(inst)

	inst:DoTaskInTime(0, function(inst)
		inst.components.area_aware:UpdatePosition()
		local node = inst.components.area_aware.current_area

		local x, y, z = inst.Transform:GetWorldPosition()
		local mist = SpawnPrefab("mist")
		mist.Transform:SetPosition(x, 0, z)
		mist.components.emitter.area_emitter = CreateAreaEmitter(node.poly, node.cent)	
		if node.area == nil then
			node.area = 1
		end	
		mist.components.emitter.density_factor = math.ceil(node.area / 4)/31
		mist.components.emitter:Emit()
	end)

	return inst
end


return Prefab("common/forest/mistarea", fn) 
