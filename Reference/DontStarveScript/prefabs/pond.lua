local assets =
{
	Asset("ANIM", "anim/marsh_tile.zip"),
	Asset("ANIM", "anim/splash.zip"),
}

local prefabs =
{
	"marsh_plant",
	"fish",
	"frog",
	"mosquito",
}


local function ReturnChildren(inst)
	for k,child in pairs(inst.components.childspawner.childrenoutside) do
		if child.components.homeseeker then
			child.components.homeseeker:GoHome()
		end
		child:PushEvent("gohome")
	end
end

local function SpawnPlants(inst, plantname)

	if inst.decor then
		for i,item in ipairs(inst.decor) do
			item:Remove()
		end
	end
	inst.decor = {}

	local plant_offsets = {}

	for i=1,math.random(2,4) do
		local a = math.random()*math.pi*2
		local x = math.sin(a)*1.9+math.random()*0.3
		local z = math.cos(a)*2.1+math.random()*0.3
		table.insert(plant_offsets, {x,0,z})
	end

	for k, offset in pairs( plant_offsets ) do
		local plant = SpawnPrefab( plantname )
		plant.entity:SetParent( inst.entity )
		plant.Transform:SetPosition( offset[1], offset[2], offset[3] )
		table.insert( inst.decor, plant )
	end
end


local function OnSnowCoverChange(inst, thresh)
	thresh = thresh or .02
	local snow_cover = GetSeasonManager() and GetSeasonManager():GetSnowPercent() or 0

	if snow_cover > thresh and not inst.frozen then
		inst.frozen = true
		inst.AnimState:PlayAnimation("frozen")
		inst.SoundEmitter:PlaySound("dontstarve/winter/pondfreeze")
	    inst.components.childspawner:StopSpawning()
		inst.components.fishable:Freeze()

        inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.ITEMS)

		for i,item in ipairs(inst.decor) do
			item:Remove()
		end
		inst.decor = {}
	elseif snow_cover < thresh and inst.frozen then
		inst.frozen = false
		inst.AnimState:PlayAnimation("idle"..inst.pondtype)
	    inst.components.childspawner:StartSpawning()
		inst.components.fishable:Unfreeze()

		inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.ITEMS)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)

		SpawnPlants(inst, inst.planttype)
	end
end

local function onload(inst, data, newents)
	OnSnowCoverChange(inst)
end


local function commonfn(pondtype)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.pondtype = pondtype
    MakeObstaclePhysics( inst, 1.95)

    anim:SetBuild("marsh_tile")
    anim:SetBank("marsh_tile")
    anim:PlayAnimation("idle"..pondtype, true)
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "pond"..pondtype..".png" )

	inst:AddComponent( "childspawner" )
	inst.components.childspawner:SetRegenPeriod(TUNING.POND_REGEN_TIME)
	inst.components.childspawner:SetSpawnPeriod(TUNING.POND_SPAWN_TIME)
	inst.components.childspawner:SetMaxChildren(math.random(3,4))
	inst.components.childspawner:StartRegen()

	inst.frozen = false


    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "pond"
    inst.no_wet_prefix = true

	inst:AddComponent("fishable")
	inst.components.fishable:SetRespawnTime(TUNING.FISH_RESPAWN_TIME)

	inst.OnLoad = onload

	return inst
end

local function pondmos()
	local inst = commonfn("_mos")
	inst.components.childspawner.childname = "mosquito"
	inst.components.fishable:AddFish("fish")
	inst.planttype = "marsh_plant"
	SpawnPlants(inst,inst.planttype )


	inst:ListenForEvent("dusktime", function()
	    if not GetSeasonManager() or not GetSeasonManager():IsWinter() then
		    inst.components.childspawner:StartSpawning()
		end
	end, GetWorld())
	inst:ListenForEvent("daytime", function() 
		ReturnChildren(inst)
		inst.components.childspawner:StopSpawning()
		ReturnChildren(inst)
	end, GetWorld())
	inst:ListenForEvent("snowcoverchange", function() OnSnowCoverChange(inst) end, GetWorld())
	return inst
end	

local function pondfrog()
	local inst = commonfn("")
	inst.components.childspawner.childname = "frog"
	inst.components.fishable:AddFish("fish")
		inst.planttype = "marsh_plant"
	SpawnPlants(inst, inst.planttype)

	inst:ListenForEvent("dusktime", function()
			inst.components.childspawner:StopSpawning()    
		    ReturnChildren(inst)	
	end, GetWorld())

	inst:ListenForEvent("daytime", function()
		if not GetSeasonManager() or not GetSeasonManager():IsWinter() then
			inst.components.childspawner:StartSpawning()			
		end
	end, GetWorld())

	inst:ListenForEvent("snowcoverchange", function() 
		OnSnowCoverChange(inst) 
	end, GetWorld())

	return inst
end

local function pondcave()
	local inst = commonfn("_cave")
	inst.components.fishable:AddFish("eel")
		inst.planttype = "pond_algae"
	SpawnPlants(inst, inst.planttype)

	--These spawn nothing at this time.
	return inst
end

return Prefab( "marsh/objects/pond", pondfrog, assets, prefabs),
	  Prefab("marsh/objects/pond_mos", pondmos, assets, prefabs),
	  Prefab("marsh/objects/pond_cave", pondcave, assets, prefabs) 

