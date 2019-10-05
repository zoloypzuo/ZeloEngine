local NUM_TREES = 4

local assets = 
{
	Asset("ANIM", "anim/marble_trees.zip"),
}

local prefabs =
{
	"marble",
}

SetSharedLootTable( 'marble_tree',
{
    {'marble', 1.0},
    {'marble', 0.5},
})

local function onsave(inst, data)
	data.anim = inst.animnumber
end

local function onload(inst, data)
	if data and data.anim then
		inst.animnumber = data.anim
		inst.AnimState:PlayAnimation("full_"..inst.animnumber)
	end
end

local function makeMarbleTree(animnumber)

	local name = "marbletree"
	if animnumber > 0 then
		name = name.."_"..tostring(animnumber)
	end
	local prefabname = "forest/objects/"..name


	local function fn()
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()	
		inst.entity:AddSoundEmitter()

		MakeObstaclePhysics(inst, 0.1)

		inst:AddComponent("lootdropper")
		inst.components.lootdropper:SetChanceLootTable('marble_tree')

		if animnumber and animnumber > 0 then
			inst.animnumber = animnumber
		else
			inst.animnumber = math.random(1, 4)
		end
		anim:SetBank("marble_trees")
		anim:SetBuild("marble_trees")
		anim:PlayAnimation("full_"..inst.animnumber)


		inst.entity:AddMiniMapEntity()
		inst.MiniMapEntity:SetIcon( "marbletree.png" )
		inst.MiniMapEntity:SetPriority(-1)

		inst:AddComponent("inspectable")
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.MINE)
		inst.components.workable:SetWorkLeft(TUNING.MARBLETREE_MINE)
		inst.components.workable:SetOnWorkCallback(          
			function(inst, worker, workleft)
				local pt = Point(inst.Transform:GetWorldPosition())
				if workleft <= 0 then
					inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
					inst.components.lootdropper:DropLoot(pt)
					inst:Remove()
				else	            
					if workleft < TUNING.MARBLETREE_MINE*(1/3) then
						inst.AnimState:PlayAnimation("low_"..inst.animnumber)
					elseif workleft < TUNING.MARBLETREE_MINE*(2/3) then
						inst.AnimState:PlayAnimation("med_"..inst.animnumber)
					else
						inst.AnimState:PlayAnimation("full_"..inst.animnumber)
					end
				end
			end)

		MakeSnowCovered(inst, 0.1)

		inst.OnSave = onsave
		inst.OnLoad = onload

		inst:SetPrefabName( "marbletree" )

		return inst
	end
	return Prefab(prefabname, fn, assets, prefabs)
end

local ret = {}
for k=0,NUM_TREES do -- 0 is the "random" tree
	table.insert(ret, makeMarbleTree(k))
end

return unpack(ret) 

