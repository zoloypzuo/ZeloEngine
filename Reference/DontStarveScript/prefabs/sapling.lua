local assets=
{
	Asset("ANIM", "anim/sapling.zip"),
	Asset("SOUND", "sound/common.fsb"),
}


local prefabs =
{
    "twigs",
    "dug_sapling",
}    

local function ontransplantfn(inst)
	inst.components.pickable:MakeEmpty()
end


local function dig_up(inst, chopper)
	if inst.components.pickable and inst.components.pickable:CanBePicked() then
		inst.components.lootdropper:SpawnLootPrefab("twigs")
	end
	inst:Remove()
	local bush = inst.components.lootdropper:SpawnLootPrefab("dug_sapling")
end

local function onpickedfn(inst)
	inst.AnimState:PlayAnimation("rustle") 
	inst.AnimState:PushAnimation("picked", false) 
end

local function onregenfn(inst)
	inst.AnimState:PlayAnimation("grow") 
	inst.AnimState:PushAnimation("sway", true)
end

local function makeemptyfn(inst)
	inst.AnimState:PlayAnimation("empty")
end



local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local minimap = inst.entity:AddMiniMapEntity()
    inst.AnimState:SetRayTestOnBB(true);
    
    anim:SetBank("sapling")
    anim:SetBuild("sapling")
    anim:PlayAnimation("sway",true)
    anim:SetTime(math.random()*2)

	minimap:SetIcon( "sapling.png" )
    

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"
    
    inst.components.pickable:SetUp("twigs", TUNING.SAPLING_REGROW_TIME)
	inst.components.pickable.onregenfn = onregenfn
	inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
	inst.components.pickable.ontransplantfn = ontransplantfn

    inst:AddComponent("inspectable")
    
    
    
	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)

    
    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)
	MakeNoGrowInWinter(inst)    
    ---------------------   
    
    return inst
end

return Prefab( "forest/objects/sapling", fn, assets, prefabs) 
