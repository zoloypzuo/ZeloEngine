local PopupDialogScreen = require "screens/popupdialog"

local assets=
{
	Asset("ANIM", "anim/cave_exit_rope.zip"),
}


local function GetVerb(inst)
	return STRINGS.ACTIONS.ACTIVATE.CLIMB
end

local function onnear(inst)
	inst.AnimState:PlayAnimation("down")
    inst.AnimState:PushAnimation("idle_loop", true)
    inst.SoundEmitter:PlaySound("dontstarve/cave/rope_down")
end

local function onfar(inst)
    inst.AnimState:PlayAnimation("up")
    inst.SoundEmitter:PlaySound("dontstarve/cave/rope_up")
end



local function OnActivate(inst)

	SetPause(true)
	local level = GetWorld().topology.level_number or 1
	local function head_upwards()
		SaveGameIndex:GetSaveFollowers(GetPlayer())

		local function onsaved()
		    SetPause(false)
		    StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot()}, true)
		end

		local cave_num =  SaveGameIndex:GetCurrentCaveNum()
		if level == 1 then
			SaveGameIndex:SaveCurrent(function() SaveGameIndex:EnterWorld("survival", onsaved) end, "ascend", cave_num)
		else
			-- Ascend
			local level = level - 1
			
			SaveGameIndex:SaveCurrent(function() SaveGameIndex:EnterWorld("cave", onsaved, nil, cave_num, level) end, "ascend", cave_num)
		end
	end
	GetPlayer().HUD:Hide()
	TheFrontEnd:Fade(false, 2, function()
									head_upwards()
								end)
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
     
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "cave_open2.png" )
    
    anim:SetBank("exitrope")
    anim:SetBuild("cave_exit_rope")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(5,7)
    inst.components.playerprox:SetOnPlayerFar(onfar)
    inst.components.playerprox:SetOnPlayerNear(onnear)

    inst:AddComponent("inspectable")

	inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = true
    inst.components.activatable.getverb = GetVerb
	inst.components.activatable.quickaction = true

    return inst
end

return Prefab( "common/cave_exit", fn, assets) 
