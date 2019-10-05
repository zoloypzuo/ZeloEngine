local BigPopupDialogScreen = require "screens/bigpopupdialog"

local assets=
{
	Asset("ANIM", "anim/portal_adventure.zip"),
	Asset("MINIMAP_IMAGE", "portal"),
}


local function GetVerb(inst)
	return STRINGS.ACTIONS.ACTIVATE.GENERIC
end

local function OnActivate(inst)
	--do popup confirmation
	--do portal presentation 
	--save and do restart
    ProfileStatsSet("portal_used", true)
	SetPause(true,"portal")
	
	local function startadventure()
		local function onsaved()
		    StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot()}, true)
		end
		TheFrontEnd:PopScreen()
		SetPause(false)
		GetPlayer().sg:GoToState("teleportato_teleport")
		ProfileStatsSet("portal_accepted", true)
		GetPlayer():DoTaskInTime(5, function() SaveGameIndex:StartAdventure(onsaved) end)
	end

	local function rejectadventure()
		TheFrontEnd:PopScreen()
		SetPause(false) 
		inst.components.activatable.inactive = true
		ProfileStatsSet("portal_rejected", true)
	end

	-- A/B test
	local bodytext = GetTestGroup() == 0 and STRINGS.UI.STARTADVENTURE.BODY or STRINGS.UI.STARTADVENTURE.BODY_TEST

	TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.STARTADVENTURE.TITLE, bodytext,
			{{text=STRINGS.UI.STARTADVENTURE.YES, cb = startadventure},
			 {text=STRINGS.UI.STARTADVENTURE.NO, cb = rejectadventure}  }))
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeObstaclePhysics(inst, 1)
    
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "portal.png" )
   
    anim:SetBank("portal_adventure")
    anim:SetBuild("portal_adventure")
    anim:PlayAnimation("idle_off", true)
    
    inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()

	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(4,5)
	inst.components.playerprox.onnear = function()
		inst.AnimState:PushAnimation("activate", false)
		inst.AnimState:PushAnimation("idle_loop_on", true)
		inst.SoundEmitter:PlaySound("dontstarve/common/maxwellportal_activate")
		inst.SoundEmitter:PlaySound("dontstarve/common/maxwellportal_idle", "idle")

		inst:DoTaskInTime(1, function()
			if inst.ragtime_playing == nil then
				inst.ragtime_playing = true
				inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/ragtime", "ragtime")
			else
				inst.SoundEmitter:SetVolume("ragtime",1)
			end
		end)
	end
	
	inst.components.playerprox.onfar = function()
		inst.AnimState:PushAnimation("deactivate", false)
		inst.AnimState:PushAnimation("idle_off", true)
		inst.SoundEmitter:KillSound("idle")
		inst.SoundEmitter:PlaySound("dontstarve/common/maxwellportal_shutdown")

		inst:DoTaskInTime(1, function()
			inst.SoundEmitter:SetVolume("ragtime",0)
		end)
	end

	inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = true
    inst.components.activatable.getverb = GetVerb
	inst.components.activatable.quickaction = true

    return inst
end

return Prefab( "common/adventure_portal", fn, assets) 
