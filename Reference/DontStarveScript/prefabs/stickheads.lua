local pig_assets =
{
	Asset("ANIM", "anim/pig_head.zip")
}

local merm_assets =
{
	Asset("ANIM", "anim/merm_head.zip")
}

local pig_prefabs =
{
	"flies",
	"pigskin",
	"twigs",
}

local merm_prefabs =
{
	"flies",
	"spoiled_food",
	"twigs",
}


local function OnFinish(inst)
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst.components.lootdropper:DropLoot()
	inst:Remove()
end

local function create_common(inst)
	inst.entity:AddSoundEmitter()

	inst.AnimState:PlayAnimation("idle_asleep")

	inst:AddComponent("lootdropper")

	inst:AddComponent("inspectable")

	inst.flies = inst:SpawnChild("flies")

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(3)
	inst.components.workable:SetOnWorkCallback(function(inst) 
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("idle_asleep")
		end)
	inst.components.workable.onfinish = OnFinish

	return inst
end

local function create_pighead()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("pig_head")
	inst.AnimState:SetBuild("pig_head")

	create_common(inst)

	inst.components.lootdropper:SetLoot({"pigskin", "pigskin", "twigs", "twigs"})

	return inst
end

local function create_mermhead()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("merm_head")
	inst.AnimState:SetBuild("merm_head")

	create_common(inst)

	inst.components.lootdropper:SetLoot({"spoiled_food", "spoiled_food", "twigs", "twigs"})

	return inst
end

return Prefab("forest/objects/pighead", create_pighead, pig_assets, pig_prefabs),
	   Prefab("forest/objects/mermhead", create_mermhead, merm_assets, merm_prefabs) 
