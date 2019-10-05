local PopupDialogScreen = require "screens/popupdialog"

local assets=
{
	Asset("ANIM", "anim/cave_entrance.zip"),
	Asset("ANIM", "anim/ruins_entrance.zip"),
	Asset("MINIMAP_IMAGE", "cave_closed"),
	Asset("MINIMAP_IMAGE", "cave_open"),
	Asset("MINIMAP_IMAGE", "cave_open2"),
	Asset("MINIMAP_IMAGE", "ruins_closed"),
}

local prefabs = 
{
	"bat",
	"exitcavelight"
}

local function GetVerb(inst)
	return STRINGS.ACTIONS.ACTIVATE.SPELUNK
end

local function ReturnChildren(inst)
	for k,child in pairs(inst.components.childspawner.childrenoutside) do
		if child.components.homeseeker then
			child.components.homeseeker:GoHome()
		end
		child:PushEvent("gohome")
	end
end

local function OnActivate(inst)

	if not IsGamePurchased() then return end

    ProfileStatsSet("cave_entrance_used", true)

	SetPause(true)

	local function go_spelunking()
		SaveGameIndex:GetSaveFollowers(GetPlayer())

		local function onsaved()
		    SetPause(false)
		    StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot()}, true)
		end

		local function doenter()
			local level = 1
			if GetWorld().prefab == "cave" then
				level = (GetWorld().topology.level_number or 1 ) + 1
			end
			SaveGameIndex:SaveCurrent(function() SaveGameIndex:EnterWorld("cave", onsaved, nil, inst.cavenum, level) end, "descend", inst.cavenum)
		end

		if not inst.cavenum then
			-- We need to make sure we only ever have one cave underground
			-- this is because caves are vertical and dont have sub caves
			if GetWorld().prefab == "cave"  then
				inst.cavenum = SaveGameIndex:GetCurrentCaveNum()
				doenter()
			else
				inst.cavenum = SaveGameIndex:GetNumCaves() + 1
				SaveGameIndex:AddCave(nil, doenter)
			end
		else
			doenter()
		end
	end
	GetPlayer().HUD:Hide()

	TheFrontEnd:Fade(false, 2, function()
									go_spelunking()
								end)
end

local function MakeRuins(inst)
	inst.AnimState:SetBank("ruins_entrance")
	inst.AnimState:SetBuild("ruins_entrance")

	if inst.components.lootdropper then
		inst.components.lootdropper:SetLoot({"thulecite", "thulecite_pieces", "thulecite_pieces"})
	end

	inst.MiniMapEntity:SetIcon("ruins_closed.png")

end

local function Open(inst)

	inst.startspawningfn = function()	
		inst.components.childspawner:StopRegen()	
		inst.components.childspawner:StartSpawning()
	end

	inst.stopspawningfn = function()
		inst.components.childspawner:StartRegen()
		inst.components.childspawner:StopSpawning()
		ReturnChildren(inst)
	end
	inst.components.childspawner:StopSpawning()
	inst:ListenForEvent("dusktime", inst.startspawningfn, GetWorld())
	inst:ListenForEvent("daytime", inst.stopspawningfn, GetWorld())


    inst.AnimState:PlayAnimation("idle_open", true)
    inst:RemoveComponent("workable")
    
    inst.open = true

    inst.name = STRINGS.NAMES.CAVE_ENTRANCE_OPEN
	if SaveGameIndex:GetCurrentMode() == "cave" then
        inst.name = STRINGS.NAMES.CAVE_ENTRANCE_OPEN_CAVE
    end
	inst:RemoveComponent("lootdropper")

	inst.MiniMapEntity:SetIcon("cave_open.png")

    --inst:AddTag("NOCLICK")
    inst:DoTaskInTime(2, function() 

		if IsGamePurchased() then
			inst:AddComponent("activatable")
		    inst.components.activatable.OnActivate = OnActivate
		    inst.components.activatable.inactive = true
		    inst.components.activatable.getverb = GetVerb
			inst.components.activatable.quickaction = true
		end

	end)

end      

local function OnWork(inst, worker, workleft)
	local pt = Point(inst.Transform:GetWorldPosition())
	if workleft <= 0 then
		inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
		inst.components.lootdropper:DropLoot(pt)
        ProfileStatsSet("cave_entrance_opened", true)
		Open(inst)
	else				
		if workleft < TUNING.ROCKS_MINE*(1/3) then
			inst.AnimState:PlayAnimation("low")
		elseif workleft < TUNING.ROCKS_MINE*(2/3) then
			inst.AnimState:PlayAnimation("med")
		else
			inst.AnimState:PlayAnimation("idle_closed")
		end
	end
end


local function Close(inst)

	if inst.open then
		inst:RemoveEventCallback("daytime", inst.stopspawningfn)
		inst:RemoveEventCallback("dusktime", inst.startspawningfn)
	end
	inst:RemoveComponent("activatable")
    inst.AnimState:PlayAnimation("idle_closed", true)

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
	inst.components.workable:SetOnWorkCallback(OnWork)
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"rocks", "rocks", "flint", "flint", "flint"})

    inst.name = STRINGS.NAMES.CAVE_ENTRANCE_CLOSED
	if SaveGameIndex:GetCurrentMode() == "cave" then
        inst.name = STRINGS.NAMES.CAVE_ENTRANCE_CLOSED_CAVE
    end

    inst.open = false
end      


local function onsave(inst, data)
	data.cavenum = inst.cavenum
	data.open = inst.open
end           

local function onload(inst, data)
	inst.cavenum = data and data.cavenum 

	if GetWorld():IsCave() then
		MakeRuins(inst)
	end

	if data and data.open then
		Open(inst)
	end
end

local function GetStatus(inst)
    if inst.open then
        return "OPEN"
    end
end  

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeObstaclePhysics(inst, 1)
    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("cave_closed.png")
    anim:SetBank("cave_entrance")
    anim:SetBuild("cave_entrance")

    inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()
	inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent( "childspawner" )
	inst.components.childspawner:SetRegenPeriod(60)
	inst.components.childspawner:SetSpawnPeriod(.1)
	inst.components.childspawner:SetMaxChildren(6)
	inst.components.childspawner.childname = "bat"

    Close(inst)
	inst.OnSave = onsave
	inst.OnLoad = onload
	
	--this is a hack to make sure these don't show up in adventure mode
	if SaveGameIndex:GetCurrentMode() == "adventure" then
		inst:DoTaskInTime(0, function() inst:Remove() end)
	end
	
    return inst
end

return Prefab( "common/cave_entrance", fn, assets, prefabs) 
