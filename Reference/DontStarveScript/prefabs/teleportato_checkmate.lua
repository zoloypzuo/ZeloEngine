local assets = 
{
	Asset("ANIM", "anim/teleportato.zip"),
	Asset("ANIM", "anim/teleportato_build.zip"),
	Asset("ANIM", "anim/teleportato_adventure_build.zip"),
}


local function reset(inst)
	inst.activatedonce = false
	inst.components.activatable.inactive = true
	inst.AnimState:PlayAnimation("idle_off", true)
end

local function DoTeleport(inst, wilson)	
	wilson.sg:GoToState("teleportato_teleport")	


	local function dowakeup(inst, wilson)
		wilson.sg:GoToState("wakeup")
		TheFrontEnd:Fade(true, 3)
		reset(inst)
	end

	local function onsave()
		scheduler:ExecuteInTime(110*FRAMES, function() 
			inst.AnimState:PlayAnimation("laugh", false)
			inst.AnimState:PushAnimation("active_idle", true)
			inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_maxwelllaugh", "teleportato_laugh")
			TheFrontEnd:Fade(false, 3)
		end)
		
		scheduler:ExecuteInTime(110*FRAMES+3, function() 			
			if inst.teleportposition then
				inst:DoTaskInTime(3, function() dowakeup(inst, wilson) end)
				GetPlayer().Transform:SetPosition(inst.teleportposition.Transform:GetWorldPosition())
				local puppet = TheSim:FindFirstEntityWithTag("maxwellthrone")
				if puppet and puppet.puppet then 
					puppet = puppet.puppet
					if puppet.telefail then	puppet.telefail(puppet) end
				end
			end
		end)
	end
	wilson.profile:Save(onsave)	
end

local function GetStatus(inst)
    return "ACTIVE"
end

local function OnActivate(inst)
	inst.components.activatable.inactive = false
	if not inst.activatedonce then
		inst.activatedonce = true
		inst.AnimState:PlayAnimation("activate", false)
		inst.AnimState:PushAnimation("active_idle", true)
		inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_activate", "teleportato_activate")
		inst.SoundEmitter:KillSound("teleportato_idle")
		inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_activeidle_LP", "teleportato_active_idle")

		inst:DoTaskInTime(40*FRAMES, function()
			inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_activate_mouth", "teleportato_activatemouth")
		end)

		inst:DoTaskInTime(2.0, function()
			DoTeleport(inst, GetPlayer())
		end)
	end

end

local function PowerUp(inst)
	inst.AnimState:PlayAnimation("power_on", false)
	inst.AnimState:PushAnimation("idle_on", true)

	inst.components.activatable.inactive = true

	inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_powerup", "teleportato_on")
	inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_idle_LP", "teleportato_idle")
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	inst:AddTag("teleportato")

	MakeObstaclePhysics(inst, 1.1)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon("teleportato.png")
	minimap:SetPriority( 1 )

	

	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "teleportato_base"
	inst.components.inspectable.getstatus = GetStatus

	anim:SetBank("teleporter")
	anim:SetBuild("teleportato_adventure_build")
	anim:PlayAnimation("idle_off", true)

	inst:AddComponent("activatable")	
	inst.components.activatable.OnActivate = OnActivate
	inst.components.activatable.inactive = true
	inst.components.activatable.quickaction = true

	inst.teleportposition = TheSim:FindFirstEntityWithTag("teleportlocation")

	return inst
end

return Prefab( "common/objects/teleportato_checkmate", fn, assets) 
