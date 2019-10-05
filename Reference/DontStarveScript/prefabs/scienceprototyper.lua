require "prefabutil"

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation(inst.components.prototyper.on and "proximity_loop" or "idle", true)
end

local function createmachine(level, name, soundprefix, techtree)
	
	local function onturnon(inst)
		inst.AnimState:PlayAnimation("proximity_loop", true)
		
		inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_idle_LP","idlesound")
	end

	local function onturnoff(inst)
	    inst.AnimState:PushAnimation("idle", true)
		inst.SoundEmitter:KillSound("idlesound")
	end

	local assets = 
	{
		Asset("ANIM", "anim/"..name..".zip"),
	}


	local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		local minimap = inst.entity:AddMiniMapEntity()
		inst.entity:AddSoundEmitter()
		minimap:SetPriority( 5 )
		minimap:SetIcon( name..".png" )
	    
		MakeObstaclePhysics(inst, .4)
	    
		anim:SetBank(name)
		anim:SetBuild(name)
		anim:PlayAnimation("idle")

		inst:AddTag("prototyper")
        inst:AddTag("structure")
        inst:AddTag("level"..level)
		
		inst:AddComponent("inspectable")
		inst:AddComponent("prototyper")
		inst.components.prototyper.onturnon = onturnon
		inst.components.prototyper.onturnoff = onturnoff
		
		inst.components.prototyper.trees = techtree
		inst.components.prototyper.onactivate = function()
			inst.AnimState:PlayAnimation("use")
			inst.AnimState:PushAnimation("idle")
			inst.AnimState:PushAnimation("proximity_loop", true)
			inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_run","sound")

			inst:DoTaskInTime(1.5, function() 
				inst.SoundEmitter:KillSound("sound")
				inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_ding","sound")		
			end)
		end
		
		inst:ListenForEvent( "onbuilt", function()
			inst.components.prototyper.on = true
			anim:PlayAnimation("place")
			anim:PushAnimation("idle")
			anim:PushAnimation("proximity_loop", true)
			inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_place")
			inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_idle_LP","idlesound")				
		end)		

		inst:AddComponent("lootdropper")
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(4)
		inst.components.workable:SetOnFinishCallback(onhammered)
		inst.components.workable:SetOnWorkCallback(onhit)		
		MakeSnowCovered(inst, .01)
		return inst
	end
	return Prefab( "common/objects/"..name, fn, assets)
end
--Using old prefab names
return createmachine(1, "researchlab", "lvl1", TUNING.PROTOTYPER_TREES.SCIENCEMACHINE),
	createmachine(2, "researchlab2", "lvl2", TUNING.PROTOTYPER_TREES.ALCHEMYMACHINE),
	MakePlacer( "common/researchlab_placer", "researchlab", "researchlab", "idle" ),
	MakePlacer( "common/researchlab2_placer", "researchlab2", "researchlab2", "idle" )
