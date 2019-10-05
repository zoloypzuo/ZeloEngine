require "stategraphs/SGwormhole"

local assets=
{
	Asset("ANIM", "anim/teleporter_worm.zip"),
	Asset("ANIM", "anim/teleporter_worm_build.zip"),
    Asset("SOUND", "sound/common.fsb"),
}


local function GetStatus(inst)
	if inst.sg.currentstate.name ~= "idle" then
		return "OPEN"
	end
end

local function OnActivate(inst, doer)
	--print("OnActivated!")
	if doer:HasTag("player") then
        ProfileStatsSet("wormhole_used", true)
		doer.components.health:SetInvincible(true)
		doer.components.playercontroller:Enable(false)
		
		if inst.components.teleporter.targetTeleporter ~= nil then
			DeleteCloseEntsWithTag(inst.components.teleporter.targetTeleporter, "WORM_DANGER", 15)
		end

		GetPlayer().HUD:Hide()
		TheFrontEnd:SetFadeLevel(1)
		doer:DoTaskInTime(4, function() 
			TheFrontEnd:Fade(true,2)
			GetPlayer().HUD:Show()
			doer.sg:GoToState("wakeup")
			if doer.components.sanity then
				doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
			end
		end)
		doer:DoTaskInTime(5, function()
			doer:PushEvent("wormholespit")
			doer.components.health:SetInvincible(false)
			doer.components.playercontroller:Enable(true)
		end)
		--doer.SoundEmitter:PlaySound("dontstarve/common/teleportworm/travel", "wormhole_travel")
	elseif doer.SoundEmitter then
		inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/swallow", "wormhole_swallow")
	end
end

local function OnActivateOther(inst, other, doer)
	other.sg:GoToState("open")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "wormhole.png" )
   
    anim:SetBank("teleporter_worm")
    anim:SetBuild("teleporter_worm_build")
    anim:PlayAnimation("idle_loop", true)
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
    
	inst:SetStateGraph("SGwormhole")
    
    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus
	inst.components.inspectable:RecordViews()

	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(4,5)
	inst.components.playerprox.onnear = function()
		if inst.components.teleporter.targetTeleporter ~= nil and not inst.sg:HasStateTag("open") then
			inst.sg:GoToState("opening")
		end
	end
	inst.components.playerprox.onfar = function()
		inst.sg:GoToState("closing")
	end

	inst:AddComponent("teleporter")
	inst.components.teleporter.onActivate = OnActivate
	inst.components.teleporter.onActivateOther = OnActivateOther

	inst:AddComponent("inventory")

	inst:AddComponent("trader")
	inst.components.trader.onaccept = function(reciever, giver, item)
		-- pass this on to our better half
		reciever.components.inventory:DropItem(item)
		inst.components.teleporter:Activate(item)
	end
	
	--print("Wormhole Spawned!")

    return inst
end

return Prefab( "common/wormhole", fn, assets) 
