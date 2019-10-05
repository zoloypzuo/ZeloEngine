require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/tent.zip"),
}


local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("idle", true)
end

local function onfinished(inst)
	inst.AnimState:PlayAnimation("destroy")
	inst:ListenForEvent("animover", function(inst, data) inst:Remove() end)
	inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_pre")
	inst.persists = false
	inst:DoTaskInTime(16*FRAMES, function() inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_twirl") end)
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", true)
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/tent")
end


local function onsleep(inst, sleeper)


	if GetClock():IsDay() then
		local tosay = "ANNOUNCE_NODAYSLEEP"
		if GetWorld():IsCave() then
			tosay = "ANNOUNCE_NODAYSLEEP_CAVE"
		end
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, tosay))
			return
		end
	end
	
	local hounded = GetWorld().components.hounded

	local danger = FindEntity(inst, 10, function(target) return target:HasTag("monster") or target.components.combat and target.components.combat.target == inst end)
	
	if hounded and (hounded.warning or hounded.timetoattack <= 0) then
		danger = true
	end
	
	if danger then
		if sleeper.components.talker then
			sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NODANGERSLEEP"))
		end
		return
	end

	if sleeper.components.hunger.current < TUNING.CALORIES_MED then
		sleeper.components.talker:Say(GetString(sleeper.prefab, "ANNOUNCE_NOHUNGERSLEEP"))
		return
	end
	
	sleeper.components.health:SetInvincible(true)
	sleeper.components.playercontroller:Enable(false)

	GetPlayer().HUD:Hide()
	TheFrontEnd:Fade(false,1)

	inst:DoTaskInTime(1.2, function() 
		
		GetPlayer().HUD:Show()
		TheFrontEnd:Fade(true,1) 
		
		if GetClock():IsDay() then

			local tosay = "ANNOUNCE_NODAYSLEEP"
			if GetWorld():IsCave() then
				tosay = "ANNOUNCE_NODAYSLEEP_CAVE"
			end

			if sleeper.components.talker then				
				sleeper.components.talker:Say(GetString(sleeper.prefab, tosay))
				sleeper.components.health:SetInvincible(false)
				sleeper.components.playercontroller:Enable(true)
				return
			end
		end
		
		if sleeper.components.sanity then
			sleeper.components.sanity:DoDelta(TUNING.SANITY_HUGE)
		end
		
		if sleeper.components.hunger then
			sleeper.components.hunger:DoDelta(-TUNING.CALORIES_HUGE, false, true)
		end
		
		if sleeper.components.health then
			sleeper.components.health:DoDelta(TUNING.HEALING_HUGE, false, "tent", true)
		end
		
		if sleeper.components.temperature then
			sleeper.components.temperature:SetTemperature(sleeper.components.temperature.maxtemp)
		end
		
		
		inst.components.finiteuses:Use()
		GetClock():MakeNextDay()
		
		sleeper.components.health:SetInvincible(false)
		sleeper.components.playercontroller:Enable(true)
		sleeper.sg:GoToState("wakeup")	
	end)
	
	
	
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst:AddTag("tent")    
    
    MakeObstaclePhysics(inst, 1)    

    inst:AddTag("structure")
    anim:SetBank("tent")
    anim:SetBuild("tent")
    anim:PlayAnimation("idle", true)
    
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "tent.png" )
	
    --[[inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = 2
    inst.components.fuel.startsize = "medium"
    --]]
    
    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.TENT_USES)
    inst.components.finiteuses:SetUses(TUNING.TENT_USES)
    inst.components.finiteuses:SetOnFinished( onfinished )
	    
		    
	inst:AddComponent("sleepingbag")
	inst.components.sleepingbag.onsleep = onsleep
	MakeSnowCovered(inst, .01)
	inst:ListenForEvent( "onbuilt", onbuilt)
    return inst
end

return Prefab( "common/objects/tent", fn, assets),
		MakePlacer( "common/tent_placer", "tent", "tent", "idle" ) 
