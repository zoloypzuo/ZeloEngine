local prefabs =
{
	"spider",
    "spider_warrior",
    "silk",
    "spidereggsack",
    "spiderqueen",
}

local assets =
{
    Asset("ANIM", "anim/spider_cocoon.zip"),
	Asset("SOUND", "sound/spider.fsb"),
}


local function SetStage(inst, stage)
	if stage <= 3 then
		inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_grow")
		if inst.components.childspawner then
			inst.components.childspawner:SetMaxChildren(TUNING.SPIDERDEN_SPIDERS[stage])
		end
		if inst.components.health then
			inst.components.health:SetMaxHealth(TUNING.SPIDERDEN_HEALTH[stage])
		end
    
		inst.AnimState:PlayAnimation(inst.anims.init)
		inst.AnimState:PushAnimation(inst.anims.idle, true)
	end
    
    inst.data.stage = stage -- track here, as growable component may go away
end

local function SetSmall(inst)
    inst.anims = {
    	hit="cocoon_small_hit", 
    	idle="cocoon_small", 
    	init="grow_sac_to_small", 
    	freeze="frozen_small", 
    	thaw="frozen_loop_pst_small",
    }
    SetStage(inst, 1)
    inst.components.lootdropper:SetLoot({ "silk","silk"})

    if inst.components.burnable then
        inst.components.burnable:SetFXLevel(3)
        inst.components.burnable:SetBurnTime(10)
    end

    if inst.components.freezable then
	    inst.components.freezable:SetShatterFXLevel(3)
	    inst.components.freezable:SetResistance(2)
    end

	inst.GroundCreepEntity:SetRadius( 5 )
end


local function SetMedium(inst)
    inst.anims = {
    	hit="cocoon_medium_hit", 
    	idle="cocoon_medium", 
    	init="grow_small_to_medium", 
    	freeze="frozen_medium", 
    	thaw="frozen_loop_pst_medium",
    }
    SetStage(inst, 2)
    inst.components.lootdropper:SetLoot({ "silk","silk","silk","silk"})

    if inst.components.burnable then
        inst.components.burnable:SetFXLevel(3)
        inst.components.burnable:SetBurnTime(10)
    end

    if inst.components.freezable then
	    inst.components.freezable:SetShatterFXLevel(4)
	    inst.components.freezable:SetResistance(3)
    end

	inst.GroundCreepEntity:SetRadius( 9 )
end

local function SetLarge(inst)
    inst.anims = {
    	hit="cocoon_large_hit", 
    	idle="cocoon_large", 
    	init="grow_medium_to_large", 
    	freeze="frozen_large", 
    	thaw="frozen_loop_pst_large",
    }
    SetStage(inst, 3)
    inst.components.lootdropper:SetLoot({ "silk","silk","silk","silk","silk","silk", "spidereggsack"})

    if inst.components.burnable then
        inst.components.burnable:SetFXLevel(4)
        inst.components.burnable:SetBurnTime(15)
    end

    if inst.components.freezable then
	    inst.components.freezable:SetShatterFXLevel(5)
	    inst.components.freezable:SetResistance(4)
    end

	inst.GroundCreepEntity:SetRadius( 9 )
end

local function AttemptMakeQueen(inst)
	if inst.data.stage == nil or inst.data.stage ~= 3 then
		-- we got here directly (probably by loading), so reconfigure to the level 3 state.
		SetLarge(inst)
	end

	local player = GetPlayer()
	if not player or player:GetDistanceSqToInst(inst) > 30*30 then
		inst.components.growable:StartGrowing(60 + math.random(60) )
		return
	end
	
	local check_range = 60
	local cap = 4
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, check_range)
	local num_dens = 0
	
	for k,v in pairs(ents) do
		if v:HasTag("spiderden") or v.prefab == "spiderqueen" then
			num_dens = num_dens + 1
		end
		
		if num_dens >= cap then break end
	end
	local should_duplicate = num_dens < cap
		
	inst.components.growable:SetStage(1)
	
	inst.AnimState:PlayAnimation("cocoon_large_burst")
	inst.AnimState:PushAnimation("cocoon_large_burst_pst")
	inst.AnimState:PushAnimation("cocoon_small", true)
	

	inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/legburst")
	inst:DoTaskInTime(5*FRAMES, function() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/legburst") end)
	inst:DoTaskInTime(15*FRAMES, function() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/legburst") end)
	
	inst:DoTaskInTime(35*FRAMES, function() 
		local queen = SpawnPrefab("spiderqueen")
		local pt = Vector3(inst.Transform:GetWorldPosition())
		local rad = 1.25
		local angle = math.random(2*PI)
		pt = pt + Vector3(rad*math.cos(angle), 0, rad*math.sin(angle))
		queen.Transform:SetPosition(pt:Get())
		queen.sg:GoToState("birth")
		
		if not should_duplicate then
			inst:Remove()
		end
	end)
	
	inst.components.growable:StartGrowing(60)
end

local function onspawnspider(inst, spider)
	spider.sg:GoToState("taunt")
end

local function OnKilled(inst)
    inst.AnimState:PlayAnimation("cocoon_dead")
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren()
    end
    inst.Physics:ClearCollisionMask()

    inst.SoundEmitter:KillSound("loop")

    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_destroy")
    inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
end

local function SpawnDefenders(inst, attacker)
    if not inst.components.health:IsDead() then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_hit")
        inst.AnimState:PlayAnimation(inst.anims.hit)
        inst.AnimState:PushAnimation(inst.anims.idle)
        if inst.components.childspawner then
        
			local max_release_per_stage = {2, 4, 6}
            local num_to_release = math.min( max_release_per_stage[inst.data.stage] or 1, inst.components.childspawner.childreninside)
            local num_warriors = math.min(num_to_release, TUNING.SPIDERDEN_WARRIORS[inst.data.stage])
            num_warriors = num_warriors - inst.components.childspawner:CountChildrenOutside(function(child)
                return child.prefab == "spider_warrior"
            end)
            for k = 1,num_to_release do
                if k <= num_warriors then
                    inst.components.childspawner.childname = "spider_warrior"
                else
                    inst.components.childspawner.childname = "spider"
                end
                local spider = inst.components.childspawner:SpawnChild()
                if spider and attacker and spider.components.combat then
                    spider.components.combat:SetTarget(attacker)
                    spider.components.combat:BlankOutAttacks(1.5 + math.random()*2)
                end
            end
            inst.components.childspawner.childname = "spider"
        end
    end
end

local function SpawnInvestigators(inst, data)
    if not inst.components.health:IsDead() and not (inst.components.freezable and inst.components.freezable:IsFrozen()) then
        inst.AnimState:PlayAnimation(inst.anims.hit)
        inst.AnimState:PushAnimation(inst.anims.idle)
        if inst.components.childspawner then
			local max_release_per_stage = {1, 2, 3}
            local num_to_release = math.min( max_release_per_stage[inst.data.stage] or 1, inst.components.childspawner.childreninside)
            local num_investigators = inst.components.childspawner:CountChildrenOutside(function(child)
                return child.components.knownlocations:GetLocation("investigate") ~= nil
            end)
            num_to_release = num_to_release - num_investigators
            for k = 1,num_to_release do
                local spider = inst.components.childspawner:SpawnChild()
                if spider and data and data.target then
                    spider.components.knownlocations:RememberLocation("investigate", Vector3(data.target.Transform:GetWorldPosition() ) )
                end
            end
        end
    end
end


local function StartSpawning(inst)
    if inst.components.childspawner then
    	local frozen = (inst.components.freezable and inst.components.freezable:IsFrozen())
    	if not frozen and not GetClock():IsDay() then
	        inst.components.childspawner:StartSpawning()
    	end
    end
end

local function StopSpawning(inst)
    if inst.components.childspawner then
        inst.components.childspawner:StopSpawning()
    end
end

local function OnIgnite(inst)
    if inst.components.childspawner then
        SpawnDefenders(inst)
        inst:RemoveComponent("childspawner")
    end
    inst.SoundEmitter:KillSound("loop")
    DefaultBurnFn(inst)
end

local function OnBurnt(inst)

end

local function OnFreeze(inst)
	print(inst, "OnFreeze")
    inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
	inst.AnimState:PlayAnimation(inst.anims.freeze, true)
    inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

    StopSpawning(inst)

    if inst.components.growable then
    	inst.components.growable:Pause()
    end
end

local function OnThaw(inst)
	print(inst, "OnThaw")
	inst.AnimState:PlayAnimation(inst.anims.thaw, true)
    inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
    inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
end

local function OnUnFreeze(inst)
	print(inst, "OnUnFreeze")
	inst.AnimState:PlayAnimation(inst.anims.idle, true)
    inst.SoundEmitter:KillSound("thawing")
    inst.AnimState:ClearOverrideSymbol("swap_frozen")

    StartSpawning(inst)

    if inst.components.growable then
    	inst.components.growable:Resume()
    end
end

local function GetSmallGrowTime(inst)
	return TUNING.SPIDERDEN_GROW_TIME[1] + math.random()*TUNING.SPIDERDEN_GROW_TIME[1]
end

local function GetMedGrowTime(inst)
	return TUNING.SPIDERDEN_GROW_TIME[2]+ math.random()*TUNING.SPIDERDEN_GROW_TIME[2]
end

local function GetLargeGrowTime(inst)
	return TUNING.SPIDERDEN_GROW_TIME[3]+ math.random()*TUNING.SPIDERDEN_GROW_TIME[3]
end



local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spidernest_LP", "loop")
end

local function OnEntitySleep(inst)
	inst.SoundEmitter:KillSound("loop")
end


local growth_stages = {
    {name="small", time = GetSmallGrowTime, fn = SetSmall },
    {name="med", time = GetMedGrowTime , fn = SetMedium },
	{name="large", time = GetLargeGrowTime, fn = SetLarge},
	{name="queen", fn = AttemptMakeQueen}}

local function MakeSpiderDenFn(den_level)
	local spiderden_fn = function(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		inst.entity:AddGroundCreepEntity()

		inst.entity:AddSoundEmitter()

		inst.data = {}

		MakeObstaclePhysics(inst, .5)

		local minimap = inst.entity:AddMiniMapEntity()
		minimap:SetIcon( "spiderden.png" )

		anim:SetBank("spider_cocoon")
		anim:SetBuild("spider_cocoon")
		anim:PlayAnimation("cocoon_small", true)

		inst:AddTag("structure")
	    inst:AddTag("hostile")
		inst:AddTag("spiderden")
		inst:AddTag("hive")

		-------------------
		inst:AddComponent("health")
		inst.components.health:SetMaxHealth(200)

		-------------------
		inst:AddComponent("childspawner")
		inst.components.childspawner.childname = "spider"
		inst.components.childspawner:SetRegenPeriod(TUNING.SPIDERDEN_REGEN_TIME)
		inst.components.childspawner:SetSpawnPeriod(TUNING.SPIDERDEN_RELEASE_TIME)

		inst.components.childspawner:SetSpawnedFn(onspawnspider)
		--inst.components.childspawner:SetMaxChildren(TUNING.SPIDERDEN_SPIDERS[stage])
		--inst.components.childspawner:ScheduleNextSpawn(0)
		inst:ListenForEvent("creepactivate", SpawnInvestigators)

		---------------------
		inst:AddComponent("lootdropper")
		---------------------

		---------------------
		MakeMediumBurnable(inst)
		inst.components.burnable:SetOnIgniteFn(OnIgnite)
		-------------------

		---------------------
		MakeMediumFreezableCharacter(inst)
		inst:ListenForEvent("freeze", OnFreeze)
		inst:ListenForEvent("onthaw", OnThaw)
		inst:ListenForEvent("unfreeze", OnUnFreeze)
		-------------------

		inst:ListenForEvent("dusktime", function() StartSpawning(inst) end, GetWorld())
		inst:ListenForEvent("daytime", function() StopSpawning(inst) end , GetWorld())

		-------------------

		inst:AddComponent("combat")
		inst.components.combat:SetOnHit(SpawnDefenders)
		inst:ListenForEvent("death", OnKilled)

		---------------------
		MakeLargePropagator(inst)

		---------------------
		inst:AddComponent("growable")
		inst.components.growable.stages = growth_stages
		inst.components.growable:SetStage(den_level)
		inst.components.growable:StartGrowing()

		---------------------

		--inst:AddComponent( "spawner" )
		--inst.components.spawner:Configure( "resident", max, initial, rate )
		--inst.spawn_weight = global_spawn_weight

		inst:AddComponent("inspectable")
		
		MakeSnowCovered(inst)

		inst:SetPrefabName("spiderden")
		inst.OnEntitySleep = OnEntitySleep
		inst.OnEntityWake = OnEntityWake
		return inst
	end

	return spiderden_fn
end

	

return Prefab( "forest/monsters/spiderden", MakeSpiderDenFn(1), assets, prefabs ),
       Prefab( "forest/monsters/spiderden_2", MakeSpiderDenFn(2), assets, prefabs ),
       Prefab( "forest/monsters/spiderden_3", MakeSpiderDenFn(3), assets, prefabs ) 

