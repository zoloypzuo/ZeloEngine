local stalagmite_assets = 
{
	Asset("ANIM", "anim/rock_stalagmite.zip"),
}

local prefabs =
{
	"rocks",
	"nitre",
	"flint",
	"goldnugget",
	"orangegem",
}

SetSharedLootTable( 'full_rock',
{
    {'rocks',     	1.00},
    {'rocks',       1.00},
    {'rocks',       1.00},
    {'goldnugget',  1.00},
    {'flint',       1.00},
    {'goldnugget',  0.25},
    {'flint',       0.60},
    {'bluegem',     0.05},
    {'redgem',      0.05},
})

SetSharedLootTable( 'med_rock',
{
    {'rocks',     	1.00},
    {'rocks',       1.00},
    {'flint',       1.00},
    {'goldnugget',  0.50},
    {'flint',       0.60},
})

SetSharedLootTable( 'low_rock',
{
    {'rocks',     	1.00},
    {'flint',       1.00},
    {'goldnugget',  0.25},
    {'flint',       0.30},
})

local function workcallback(inst, worker, workleft)
	local pt = Point(inst.Transform:GetWorldPosition())
	if workleft <= 0 then
		inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
		inst.components.lootdropper:DropLoot(pt)
		inst:Remove()
	else			
		if workleft <= TUNING.ROCKS_MINE*(1/3) then
			inst.AnimState:PlayAnimation("low")
		elseif workleft <= TUNING.ROCKS_MINE*(2/3) then
			inst.AnimState:PlayAnimation("med")
		else
			inst.AnimState:PlayAnimation("full")
		end
	end
end

local function commonfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("stalagmite.png")

	MakeObstaclePhysics(inst, 1.)

    local color = 0.5 + math.random() * 0.5
    anim:SetMultColour(color, color, color, 1)

	anim:SetBank("rock_stalagmite")
	anim:SetBuild("rock_stalagmite")

	inst:AddComponent("lootdropper") 
	
	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "stalagmite"


	inst:AddComponent("named")
	inst.components.named:SetName(STRINGS.NAMES["STALAGMITE"])

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)

	inst.components.workable:SetOnWorkCallback(workcallback)

	return inst
end

local function fullrock()
	local inst = commonfn()

	inst.components.lootdropper:SetChanceLootTable('full_rock')
	
	inst.AnimState:PlayAnimation("full")
	return inst
end

local function medrock()
	local inst = commonfn()
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE_MED)
	inst.AnimState:PlayAnimation("med")

	inst.components.lootdropper:SetChanceLootTable('med_rock')

	return inst
end

local function lowrock()
	local inst = commonfn()
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE_LOW)
	inst.AnimState:PlayAnimation("low")

	inst.components.lootdropper:SetChanceLootTable('low_rock')

	return inst
end

return Prefab("cave/objects/stalagmite_full", fullrock, stalagmite_assets, prefabs),
Prefab("cave/objects/stalagmite_med", medrock, stalagmite_assets, prefabs),
Prefab("cave/objects/stalagmite_low", lowrock, stalagmite_assets, prefabs),
Prefab("cave/objects/stalagmite", fullrock, stalagmite_assets, prefabs) 
