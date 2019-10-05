require "prefabutil"

function MakeWallType(data)

	local assets =
	{
		Asset("ANIM", "anim/wall.zip"),
		Asset("ANIM", "anim/wall_".. data.name..".zip"),
		Asset("INV_IMAGE", "rockwall"),
	}

	local function ondeploywall(inst, pt, deployer)
		--inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spider_egg_sack")
		local wall = SpawnPrefab("wall_"..data.name) 
		if wall then 
			pt = Vector3(math.floor(pt.x)+.5, 0, math.floor(pt.z)+.5)
			wall.Physics:SetCollides(false)
			wall.Physics:Teleport(pt.x, pt.y, pt.z) 
			wall.Physics:SetCollides(true)
			inst.components.stackable:Get():Remove()

		    local ground = GetWorld()
		    if ground then
		    	ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
		    end
		end 		
	end

	local function onhammered(inst, worker)
		if data.maxloots and data.loot then
			local num_loots = math.max(1, math.floor(data.maxloots*inst.components.health:GetPercent()))
			for k = 1, num_loots do
				inst.components.lootdropper:SpawnLootPrefab(data.loot)
			end
		end		
		
		SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
		
		if data.destroysound then
			inst.SoundEmitter:PlaySound(data.destroysound)		
		end
		
		inst:Remove()
	end



	local function test_wall(inst, pt)
		local tiletype = GetGroundTypeAtPosition(pt)
		local ground_OK = tiletype ~= GROUND.IMPASSABLE 
		
		if ground_OK then
			local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 2, nil, {"NOBLOCK", "player", "FX", "INLIMBO", "DECOR"}) -- or we could include a flag to the search?

			for k, v in pairs(ents) do
				if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
					local dsq = distsq( Vector3(v.Transform:GetWorldPosition()), pt)
					if v:HasTag("wall") then
						if dsq < .1 then return false end
					else
						if  dsq< 1 then return false end
					end
				end
			end
			
			return true

		end
		return false
		
	end

	local function makeobstacle(inst)
	
	
		inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)	
	    inst.Physics:ClearCollisionMask()
		--inst.Physics:CollidesWith(COLLISION.WORLD)
		inst.Physics:SetMass(0)
		inst.Physics:CollidesWith(COLLISION.ITEMS)
		inst.Physics:CollidesWith(COLLISION.CHARACTERS)
		inst.Physics:SetActive(true)
	    local ground = GetWorld()
	    if ground then
	    	local pt = Point(inst.Transform:GetWorldPosition())
			--print("    at: ", pt)
	    	ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
	    end
	end

	local function clearobstacle(inst)
		-- Alia: 
		-- Since we are removing the wall anytway we may as well not bother setting the physics    
	    -- We had better wait for the callback to complete before trying to remove ourselves
	    inst:DoTaskInTime(2*FRAMES, function() inst.Physics:SetActive(false) end)

	    local ground = GetWorld()
	    if ground then
	    	local pt = Point(inst.Transform:GetWorldPosition())
	    	ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z)
	    end
	end

	local anims =
	{
	    { threshold = 0, anim = "broken" },
	    { threshold = 0.4, anim = "onequarter" },
	    { threshold = 0.5, anim = "half" },
	    { threshold = 0.99, anim = "threequarter" },
	    { threshold = 1, anim = { "fullA", "fullB", "fullC" } },
	}

	local function resolveanimtoplay(inst,percent)

	    local function getbasename(inst, percent)
	        for i, v in ipairs(anims) do
	            if percent <= v.threshold then
	                if type(v.anim) == "table" then
	                    -- get a stable animation, by basing it on world position
	                    local x, y, z = inst.Transform:GetWorldPosition()
	                    local x = math.floor(x)
	                    local z = math.floor(z)
	                    local q1 = #v.anim + 1
	                    local q2 = #v.anim + 4
	                    local t = ( ((x%q1)*(x+3)%q2) + ((z%q1)*(z+3)%q2) )% #v.anim + 1
	                    return v.anim[t]
	                else
	                    return v.anim
	                end
	            end
	        end
	    end
	    
	    local animname = getbasename(inst, percent)
    	return animname	    

	end

	local function onhealthchange(inst, old_percent, new_percent)
		
		if old_percent <= 0 and new_percent > 0 then makeobstacle(inst) end
		if old_percent > 0 and new_percent <= 0 then clearobstacle(inst) end

		local anim_to_play = resolveanimtoplay(inst,new_percent)
		if new_percent > 0 then
			inst.AnimState:PlayAnimation(anim_to_play.."_hit")		
			inst.AnimState:PushAnimation(anim_to_play, false)		
		else
			inst.AnimState:PlayAnimation(anim_to_play)		
		end
	end
	
	local function itemfn(Sim)

		local inst = CreateEntity()
		inst:AddTag("wallbuilder")
		
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		MakeInventoryPhysics(inst)
	    
		inst.AnimState:SetBank("wall")
		inst.AnimState:SetBuild("wall_"..data.name)
		inst.AnimState:PlayAnimation("idle")

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")
		
		inst:AddComponent("repairer")

        if data.name == "ruins" then
		    inst.components.repairer.repairmaterial = "thulecite"
        else
		    inst.components.repairer.repairmaterial = data.name
        end

		inst.components.repairer.healthrepairvalue = data.maxhealth / 6
	    
		
		if data.flammable then
			MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
			MakeSmallPropagator(inst)
			
			inst:AddComponent("fuel")
			inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
		end
		
		inst:AddComponent("deployable")
		inst.components.deployable.ondeploy = ondeploywall
		inst.components.deployable.test = test_wall
		inst.components.deployable.min_spacing = 0
		inst.components.deployable.placer = "wall_"..data.name.."_placer"
		
		return inst
	end

	local function onhit(inst)
		-- if data.destroysound then
		-- 	inst.SoundEmitter:PlaySound(data.destroysound)		
		-- end

		local healthpercent = inst.components.health:GetPercent()
		local anim_to_play = resolveanimtoplay(inst,healthpercent)
		if healthpercent > 0 then
			inst.AnimState:PlayAnimation(anim_to_play.."_hit")		
			inst.AnimState:PushAnimation(anim_to_play, false)	
		end	

	end

	local function onrepaired(inst)
		if data.buildsound then
			inst.SoundEmitter:PlaySound(data.buildsound)		
		end
		makeobstacle(inst)
	end
	    
	local function onload(inst, data)
		--print("walls - onload")
		makeobstacle(inst)
		if inst.components.health:GetPercent() <= 0 then
			clearobstacle(inst)
		end
	end

	local function onremoveentity(inst)
		clearobstacle(inst)
	end

	local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		trans:SetEightFaced()
		--trans:SetScale(1.3,1.3,1.3)
		inst:AddTag("wall")
		MakeObstaclePhysics(inst, .5)    
        inst.Physics:SetDontRemoveOnSleep(true)

		anim:SetBank("wall")
		anim:SetBuild("wall_"..data.name)
	    anim:PlayAnimation("half", false)
	    
		inst:AddComponent("inspectable")
		inst:AddComponent("lootdropper")
		
		for k,v in ipairs(data.tags) do
		    inst:AddTag(v)
		end
				
		inst:AddComponent("repairable")
        if data.name == "ruins" then
		    inst.components.repairable.repairmaterial = "thulecite"
        else
		    inst.components.repairable.repairmaterial = data.name
        end
		inst.components.repairable.onrepaired = onrepaired
		
		inst:AddComponent("combat")
		inst.components.combat.onhitfn = onhit
		
		inst:AddComponent("health")
		inst.components.health:SetMaxHealth(data.maxhealth)
		inst.components.health.currenthealth = data.maxhealth / 2
		inst.components.health.ondelta = onhealthchange
		inst.components.health.nofadeout = true
		inst.components.health.canheal = false
		inst:AddTag("noauradamage")
		
		if data.flammable then
			MakeLargeBurnable(inst)
			MakeLargePropagator(inst)
			inst.components.burnable.flammability = .5
			
			--lame!
			if data.name == "wood" then
				inst.components.propagator.flashpoint = 30+math.random()*10			
			end
		else
			inst.components.health.fire_damage_scale = 0
		end

		if data.buildsound then
			inst.SoundEmitter:PlaySound(data.buildsound)		
		end
		
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(3)
		inst.components.workable:SetOnFinishCallback(onhammered)
		inst.components.workable:SetOnWorkCallback(onhit) 
				
		
	    inst.OnLoad = onload
	    inst.OnRemoveEntity = onremoveentity
		
		MakeSnowCovered(inst)
		
		return inst
	end

	return Prefab( "common/wall_"..data.name, fn, assets),
		   Prefab( "common/wall_"..data.name.."_item", itemfn, assets, {"wall_"..data.name, "wall_"..data.name.."_placer"}),
		   --MakePlacer("common/wall_"..data.name.."_placer", "wall", "wall_"..data.name, "half", false, false, true) 
		   MakePlacer("common/wall_"..data.name.."_placer", "wall", "wall_"..data.name, "half", false, false, true, nil,"eight")
	end

local wallprefabs = {}

--6 rock, 8 wood, 4 straw
--NOTE: Stacksize is now set in the actual recipe for the item.
local walldata = {
			{name = "stone", tags={"stone"}, loot = "rocks", maxloots = 2, maxhealth=TUNING.STONEWALL_HEALTH, buildsound="dontstarve/common/place_structure_stone", destroysound="dontstarve/common/destroy_stone"},
			{name = "wood", tags={"wood"}, loot = "log", maxloots = 2, maxhealth=TUNING.WOODWALL_HEALTH, flammable = true, buildsound="dontstarve/common/place_structure_wood", destroysound="dontstarve/common/destroy_wood"},
			{name = "hay", tags={"grass"}, loot = "cutgrass", maxloots = 2, maxhealth=TUNING.HAYWALL_HEALTH, flammable = true, buildsound="dontstarve/common/place_structure_straw", destroysound="dontstarve/common/destroy_straw"},
			{name = "ruins", tags={"stone", "ruins"}, loot = "thulecite_pieces", maxloots = 2, maxhealth=TUNING.RUINSWALL_HEALTH, buildsound="dontstarve/common/place_structure_stone", destroysound="dontstarve/common/destroy_stone"},
        }


for k,v in pairs(walldata) do
	local wall, item, placer = MakeWallType(v)
	table.insert(wallprefabs, wall)
	table.insert(wallprefabs, item)
	table.insert(wallprefabs, placer)
end


return unpack(wallprefabs) 
