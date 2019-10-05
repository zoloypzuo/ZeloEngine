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

local function spawnrabbits(inst)
	if math.random() <= 0.1 then
		local pt = inst:GetPosition()
		local rabbit = SpawnPrefab("rabbit")
		rabbit.Transform:SetPosition(pt.x, pt.y, pt.z)
	end
end

local function createmachine(level, name, soundprefix, sounddelay, techtree, mergeanims, onact)
	
	local function onturnon(inst)
		if mergeanims then
			inst.AnimState:PlayAnimation("proximity_pre")
			inst.AnimState:PushAnimation("proximity_loop", true)
		else
			inst.AnimState:PlayAnimation("proximity_loop", true)
		end
		inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_idle_LP","idlesound")
	end

	local function onturnoff(inst)
		if mergeanims then
			inst.AnimState:PushAnimation("proximity_pst")
		    inst.AnimState:PushAnimation("idle", true)
		else
		    inst.AnimState:PlayAnimation("idle", true)
		end
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

				if onact then
					onact(inst)
				end

				--inst.SoundEmitter:KillSound("sound")
				inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_ding")		
			end)
		end
		
		inst:ListenForEvent( "onbuilt", function()
			inst.components.prototyper.on = true
			anim:PlayAnimation("place")
			anim:PushAnimation("idle")
			anim:PushAnimation("proximity_loop", true)
			inst:DoTaskInTime(sounddelay, function()
				inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_place")
				inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_idle_LP","idlesound")
			end)				
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
return createmachine(3, "researchlab3", "lvl3", 0.15, TUNING.PROTOTYPER_TREES.SHADOWMANIPULATOR, true),
createmachine(4, "researchlab4", "lvl4", 0, TUNING.PROTOTYPER_TREES.PRESTIHATITATOR, false, spawnrabbits),
MakePlacer( "common/researchlab3_placer", "researchlab3", "researchlab3", "idle" ),
MakePlacer( "common/researchlab4_placer", "researchlab4", "researchlab4", "idle" )
