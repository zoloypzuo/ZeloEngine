local assets =
{
	Asset("ANIM", "anim/ruins_rubble.zip"),
}

local prefabs =
{
    "rocks",
    "thulecite",
    "cutstone",
    "trinket_6",
    "gears",
    "nightmarefuel",
    "greengem",
    "orangegem",
    "yellowgem",
}    

local function workcallback(inst, worker, workleft)
	local pt = Point(inst.Transform:GetWorldPosition())
	if workleft <= 0 then
		inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
        inst.components.lootdropper:DropLoot()
	    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst:Remove()
	else				
		if workleft < TUNING.ROCKS_MINE*(1/3) then
			inst.AnimState:PlayAnimation("low")
		elseif workleft < TUNING.ROCKS_MINE*(2/3) then
			inst.AnimState:PlayAnimation("med")
		else
			inst.AnimState:PlayAnimation("full")
		end
	end
end

local function common_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	inst.AnimState:SetBank("rubble")
	inst.AnimState:SetBuild("ruins_rubble")

	MakeObstaclePhysics(inst, 1.)
	
	--local minimap = inst.entity:AddMiniMapEntity()
	--minimap:SetIcon( "rock.png" )

	inst:AddComponent("lootdropper") 
    inst.components.lootdropper:SetLoot({"rocks"})
    inst.components.lootdropper.numrandomloot = 1
    inst.components.lootdropper:AddRandomLoot("rocks"         , 0.99)
    inst.components.lootdropper:AddRandomLoot("cutstone"      , 0.10)
	inst.components.lootdropper:AddRandomLoot("trinket_6"     , 0.10) -- frayed wires
	inst.components.lootdropper:AddRandomLoot("gears"         , 0.01)
	inst.components.lootdropper:AddRandomLoot("greengem"      , 0.01)
	inst.components.lootdropper:AddRandomLoot("yellowgem"     , 0.01)
	inst.components.lootdropper:AddRandomLoot("orangegem"     , 0.01)
	inst.components.lootdropper:AddRandomLoot("nightmarefuel" , 0.01)
    if GetWorld() and GetWorld():IsCave() and GetWorld().topology.level_number == 2 then  -- ruins
        inst.components.lootdropper:AddRandomLoot("thulecite" , 0.01)
    end
	
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)

	inst.components.workable:SetOnWorkCallback(workcallback)         

	inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "rubble"
	MakeSnowCovered(inst, .01)    

	return inst
end

local function rubble_fn(Sim)
	local inst = common_fn()
	inst.AnimState:PlayAnimation("full")
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)	

	return inst
end

local function rubble_med_fn(Sim)
	local inst = common_fn()
	inst.AnimState:PlayAnimation("med")
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)	
	inst.components.workable:WorkedBy(inst, TUNING.ROCKS_MINE * 0.34)
	return inst
end

local function rubble_low_fn(Sim)
	local inst = common_fn()
	inst.AnimState:PlayAnimation("low")
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)	
	inst.components.workable:WorkedBy(inst, TUNING.ROCKS_MINE * 0.67)
	return inst
end


return Prefab("cave/objects/rocks/rubble", rubble_fn, assets, prefabs),
        Prefab("forest/objects/rocks/rubble_med", rubble_med_fn, assets, prefabs),
        Prefab("forest/objects/rocks/rubble_low", rubble_low_fn, assets, prefabs) 
