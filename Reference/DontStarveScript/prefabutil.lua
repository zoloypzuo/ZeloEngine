function MakePlacer(name, bank, build, anim, onground, snap, metersnap, scale, facing, placeTestFn, preSetPrefabfn)

	local function fn(Sim)
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.AnimState:SetBank(bank)
		inst.AnimState:SetBuild(build)
		inst.AnimState:PlayAnimation(anim, true)
        inst.AnimState:SetLightOverride(1)
		
        if facing == "two" then
            inst.Transform:SetTwoFaced()
        elseif facing == "four" then
            inst.Transform:SetFourFaced()
        elseif facing == "six" then
            inst.Transform:SetSixFaced()
        elseif facing == "eight" then
            inst.Transform:SetEightFaced()
        end

		inst:AddComponent("placer")
		inst.persists = false
		inst.components.placer.snaptogrid = snap
		inst.components.placer.snap_to_meters = metersnap

		if placeTestFn then
			inst.components.placer.placeTestFn = placeTestFn
		end
		
		if scale then
			inst.Transform:SetScale(scale, scale, scale)
		end

		if onground then
			inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
		end

		if preSetPrefabfn then
			preSetPrefabfn(inst)
		end		
		
		return inst
	end
	
	return Prefab(name, fn)
end
