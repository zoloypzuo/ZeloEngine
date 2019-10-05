local rock1_assets =
{
	Asset("ANIM", "anim/rock.zip"),
	Asset("MINIMAP_IMAGE", "rock"),
}

local rock2_assets =
{
	Asset("ANIM", "anim/rock2.zip"),
	Asset("MINIMAP_IMAGE", "rock_gold"),
}

local rock_flintless_assets =
{
	Asset("ANIM", "anim/rock_flintless.zip"),
	Asset("MINIMAP_IMAGE", "rock"),
}

local prefabs =
{
    "rocks",
    "nitre",
    "flint",
    "goldnugget",
}    

SetSharedLootTable( 'rock1',
{
    {'rocks',  1.00},
    {'rocks',  1.00},
    {'rocks',  1.00},
    {'nitre',  1.00},
    {'flint',  1.00},
    {'nitre',  0.25},
    {'flint',  0.60},
})

SetSharedLootTable( 'rock2',
{
    {'rocks',     	1.00},
    {'rocks',     	1.00},
    {'rocks',     	1.00},
    {'goldnugget',  1.00},
    {'flint',     	1.00},
    {'goldnugget',  0.25},
    {'flint',     	0.60},
})

SetSharedLootTable( 'rock_flintless',
{
    {'rocks',   1.0},
    {'rocks',   1.0},
    {'rocks',   1.0},
    {'rocks',  	1.0},
    {'rocks',   0.6},
})

SetSharedLootTable( 'rock_flintless_med',
{
    {'rocks', 1.0},
    {'rocks', 1.0},
    {'rocks', 1.0},
    {'rocks', 0.4},
})


SetSharedLootTable( 'rock_flintless_low',
{
    {'rocks', 1.0},
    {'rocks', 1.0},
    {'rocks', 0.2},
})

local function baserock_fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	MakeObstaclePhysics(inst, 1.)
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "rock.png" )

	inst:AddComponent("lootdropper") 
	
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
	
	inst.components.workable:SetOnWorkCallback(
		function(inst, worker, workleft)
			local pt = Point(inst.Transform:GetWorldPosition())
			if workleft <= 0 then
				inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
				inst.components.lootdropper:DropLoot(pt)
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
		end)     

    local color = 0.5 + math.random() * 0.5
    anim:SetMultColour(color, color, color, 1)    

	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "ROCK"
	MakeSnowCovered(inst, .01)        
	return inst
end

local function rock1_fn(Sim)
	local inst = baserock_fn(Sim)
	inst.AnimState:SetBank("rock")
	inst.AnimState:SetBuild("rock")
	inst.AnimState:PlayAnimation("full")

	inst.components.lootdropper:SetChanceLootTable('rock1')

	return inst
end

local function rock2_fn(Sim)
	local inst = baserock_fn(Sim)
	inst.AnimState:SetBank("rock2")
	inst.AnimState:SetBuild("rock2")
	inst.AnimState:PlayAnimation("full")
	inst.MiniMapEntity:SetIcon( "rock_gold.png" )

	inst.components.lootdropper:SetChanceLootTable('rock2')

	return inst
end

local function rock_flintless_fn(Sim)


	local inst = baserock_fn(Sim)
	inst.AnimState:SetBank("rock_flintless")
	inst.AnimState:SetBuild("rock_flintless")
	inst.AnimState:PlayAnimation("full")
	inst.MiniMapEntity:SetIcon( "rock_flintless.png" )

	inst.components.lootdropper:SetChanceLootTable('rock_flintless')

	return inst
end


local function rock_flintless_med()
	local inst = baserock_fn(Sim)
	inst.AnimState:SetBank("rock_flintless")
	inst.AnimState:SetBuild("rock_flintless")
	inst.AnimState:PlayAnimation("med")
	inst.MiniMapEntity:SetIcon("rock_flintless.png")
	

	inst:AddComponent("named")
	inst.components.named:SetName(STRINGS.NAMES["ROCK_FLINTLESS"])

	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE_MED)

	inst.components.lootdropper:SetChanceLootTable('rock_flintless_med')

	return inst
end

local function rock_flintless_low()
	local inst = baserock_fn(Sim)
	inst.AnimState:SetBank("rock_flintless")
	inst.AnimState:SetBuild("rock_flintless")
	inst.AnimState:PlayAnimation("low")
	inst.MiniMapEntity:SetIcon( "rock_flintless.png" )

	inst:AddComponent("named")
	inst.components.named:SetName(STRINGS.NAMES["ROCK_FLINTLESS"])
	inst.components.lootdropper:SetChanceLootTable('rock_flintless_low')
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE_LOW)

	return inst
end


return Prefab("forest/objects/rocks/rock1", rock1_fn, rock1_assets, prefabs),
        Prefab("forest/objects/rocks/rock2", rock2_fn, rock2_assets, prefabs),
        Prefab("forest/objects/rocks/rock_flintless", rock_flintless_fn, rock_flintless_assets, prefabs),
        Prefab("forest/objects/rocks/rock_flintless_med", rock_flintless_med, rock_flintless_assets, prefabs),
        Prefab("forest/objects/rocks/rock_flintless_low", rock_flintless_low, rock_flintless_assets, prefabs)

