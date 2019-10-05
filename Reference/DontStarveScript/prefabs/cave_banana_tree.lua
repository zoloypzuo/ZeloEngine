local assets=
{
	Asset("ANIM", "anim/cave_banana_tree.zip"),
}


local prefabs =
{
    "cave_banana",
    "charcoal",
    "log",
    "twigs",
}    



local function onregenfn(inst)
	inst.AnimState:PlayAnimation("grow") 
	inst.AnimState:PushAnimation("idle_loop", true)
	inst.AnimState:Show("BANANA") 
end

local function makefullfn(inst)
	inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:Show("BANANA") 
end


local function onpickedfn(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
	inst.AnimState:PlayAnimation("pick") 
	inst.AnimState:PushAnimation("idle_loop") 
	inst.AnimState:Hide("BANANA") 
end

local function makeemptyfn(inst)
	inst.AnimState:PlayAnimation("idle_loop")
	inst.AnimState:Hide("BANANA") 
end

local function dug(inst)
	inst:Remove()
	inst.components.lootdropper:SpawnLootPrefab("log")
end

local function setupstump(inst)
	inst.stump = true
	inst:RemoveComponent("pickable")
	inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(dug)
	inst.AnimState:PlayAnimation("idle_stump")
end

local function chopped(inst)
	if inst.stump then
		return
	end
	inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")

	if inst.burnt then
		inst:RemoveComponent("workable")
		inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
		inst.components.lootdropper:SpawnLootPrefab("charcoal")
		inst.persists = false
		inst.AnimState:PlayAnimation("chop_burnt")
		inst:DoTaskInTime(50*FRAMES, function() inst:Remove() end)
	else
	              
		inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")

		inst.components.lootdropper:SpawnLootPrefab("log")
		inst.components.lootdropper:SpawnLootPrefab("twigs")
		inst.components.lootdropper:SpawnLootPrefab("twigs")
		inst.AnimState:Hide("BANANA") 
		if inst.components.pickable and inst.components.pickable.canbepicked then
			inst.components.lootdropper:SpawnLootPrefab("cave_banana")
		end
		setupstump(inst)
		inst.AnimState:PlayAnimation("fall")
		inst.AnimState:PushAnimation("idle_stump")
	end

end

local function chop(inst)
	inst.AnimState:PlayAnimation("chop")
	inst.AnimState:PushAnimation("idle_loop", true)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")          

end

local function startburn(inst)
	inst.burnt = true
    if inst.components.pickable then
        inst:RemoveComponent("pickable")
    end
    
end


local function makeburnt(inst)
	inst.burnt = true
	
	inst:RemoveComponent("burnable")
	inst:RemoveComponent("propagator")
	inst:RemoveComponent("pickable")

	if inst.stump then
		inst:Remove()
	else
		inst.AnimState:PlayAnimation("burnt")
		inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    	inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    	inst.components.workable:SetWorkLeft(1)
    end
end


local function onsave(inst, data)
	data.stump = inst.stump
	data.burnt = inst.burnt
end

local function onload(inst, data)
	if data and data.stump then
		setupstump(inst)
	elseif data and data.burnt then
		makeburnt(inst)
	end
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
	local minimap = inst.entity:AddMiniMapEntity()
	MakeObstaclePhysics(inst,.5)
	minimap:SetIcon( "cave_banana_tree.png" )
    
    anim:SetBank("cave_banana_tree")
    anim:SetBuild("cave_banana_tree")
    anim:PlayAnimation("idle_loop",true)
    anim:SetTime(math.random()*2)

	inst:AddComponent("pickable")
	inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
	
	inst.components.pickable:SetUp("cave_banana", TUNING.CAVE_BANANA_GROW_TIME)
	inst.components.pickable.onregenfn = onregenfn
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makeemptyfn = makeemptyfn
	inst.components.pickable.makefullfn = makefullfn


	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(chopped)
    inst.components.workable:SetOnWorkCallback(chop)


	inst:AddComponent("lootdropper")
    inst:AddComponent("inspectable")    

    ---------------------        
    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)
	MakeNoGrowInWinter(inst)    
    ---------------------   
    inst.components.burnable:SetOnIgniteFn(startburn)
	inst.components.burnable:SetOnBurntFn(makeburnt)
    inst.OnSave = onsave
    inst.OnLoad = onload
  
    return inst
end

return Prefab("cave/cave_banana_tree", fn, assets, prefabs)
