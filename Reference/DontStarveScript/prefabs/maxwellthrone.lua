local EndGameDialog = require("screens/endgamedialog")
local assets =
{
	Asset("ANIM", "anim/maxwell_throne.zip"),
    Asset("SOUND", "sound/sanity.fsb"),
    Asset("SOUND", "sound/common.fsb"),
    Asset("SOUND", "sound/wilson.fsb")

}

local prefabs =
{
    "maxwellendgame",
    "puppet_wilson",
    "puppet_willow",
    "puppet_wendy",
    "puppet_wickerbottom",
    "puppet_wolfgang",
    "puppet_wx78",
    "puppet_wes", 
}

local function SpawnPuppet(inst, name)

    if name ~= "maxwellendgame" then
        name = "puppet_"..name
    end 
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local puppet = SpawnPrefab(name)

    if not puppet then
        print("THIS PUPPET DIDNT EXIST, USE MAXWELL")
        name = "maxwellendgame"
        puppet = SpawnPrefab(name)
        inst.isMaxwell = true
    end
    if puppet then
        puppet.Transform:SetPosition(pt.x, pt.y + 0.1, pt.z)
        puppet.persists = false
    end
    return puppet
end

local function DoCharacterUnlock(inst, whendone)
    GetPlayer().profile:UnlockCharacter("waxwell")  --unlock waxwell    
    GetPlayer().profile:SetValue("characterinthrone", SaveGameIndex:GetSlotCharacter() or "wilson") --The character that will be locked next time.    
    GetPlayer().profile.dirty = true
    GetPlayer().profile:Save(whendone)
end

local function ZoomAndFade(inst)
    if not inst.isMaxwell then
        TheCamera:SetOffset(Vector3(0, 1.45, 0))
    end
    TheCamera:SetDistance(7)
    Sleep(2)
    if inst.phonograph then
        inst.phonograph.songToPlay = "dontstarve/maxwell/ragtime_2d"
        if not inst.phonograph.components.machine:IsOn() then
            inst.phonograph.components.machine:TurnOn()
        end
    end
    Sleep(5)
    TheFrontEnd:Fade(false, 3)

    Sleep(4)
    --endgame screen
    TheFrontEnd:DoFadeIn(0)
    DoCharacterUnlock(inst, function() 
		TheFrontEnd:PushScreen(EndGameDialog( {
			{text=STRINGS.UI.ENDGAME.YES, cb = function()
				--restart as waxwell
	            
				SaveGameIndex:SetSlotCharacter(SaveGameIndex:GetCurrentSaveSlot(), inst.previousLock, function() 
					SaveGameIndex:OnFailAdventure( function()
						StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot(), playeranim="wakeup", character="waxwell"}, true)
					end)
				end)
			end}
		}))
    end)

end

local function DecomposePuppet(inst)
    local tick_time = TheSim:GetTickTime()
    local time_to_erode = 4
    inst.puppet:StartThread( function()
        local ticks = 0
        while ticks * tick_time < time_to_erode do
            local erode_amount = ticks * tick_time / time_to_erode
            inst.puppet.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
            ticks = ticks + 1
            Yield()
        end
        inst.puppet:Remove()
    end)
end

local function SpawnNewPuppet(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/throne/thronemagic", "deathrattle")    
    DecomposePuppet(inst)
    TheCamera:Shake("FULL", 4, 0.033, 0.1)
    GetPlayer().sg:GoToState("teleportato_teleport")
    if GetPlayer().DynamicShadow then
        GetPlayer().DynamicShadow:Enable(false)
    end
    Sleep(4)
    inst.SoundEmitter:KillSound("deathrattle")
    GetPlayer():Hide()
    local puppetToSpawn = SaveGameIndex:GetSlotCharacter() or "wilson"    
    if puppetToSpawn == "waxwell" then 
        puppetToSpawn = "maxwellendgame" 
    end
    local puppet = SpawnPuppet(inst, puppetToSpawn)

    if puppet.prefab == "maxwellendgame" then
        puppetToSpawn = "maxwellendgame"
    end

    if puppet.components.maxwelltalker then puppet:RemoveComponent("maxwelltalker") end    
    local pos = Vector3( inst.Transform:GetWorldPosition() )
    GetSeasonManager():DoLightningStrike(pos)

    if puppetToSpawn == "maxwellendgame" then 
        inst.AnimState:PlayAnimation("appear")
        inst.AnimState:PushAnimation("idle")
        inst.isMaxwell = true
        puppet.AnimState:PlayAnimation("appear")
        puppet.AnimState:PushAnimation("idle_loop", true)
    else
        inst.AnimState:PlayAnimation("player_appear")
        inst.AnimState:PushAnimation("player_idle_loop")
        inst.isMaxwell = false
        puppet.AnimState:PlayAnimation("appear")
        puppet.AnimState:PushAnimation("throne_loop", true)
    end

    if inst.DynamicShadow then
        inst.DynamicShadow:Enable(true)
    end

    local soundframedelay = 2
    Sleep(soundframedelay * (1/30))

    inst.SoundEmitter:PlaySound("dontstarve/common/throne/playerappear")


    Sleep(3)

    inst:StartThread(function() ZoomAndFade(inst) end)

end


local function MaxwellDie(inst)
    inst.AnimState:PlayAnimation("death")
    inst.puppet.AnimState:PlayAnimation("death")
    inst.SoundEmitter:PlaySound("dontstarve/maxwell/breakchains")    
    inst:DoTaskInTime(113 * (1/30), function() inst.SoundEmitter:PlaySound("dontstarve/maxwell/blowsaway") end)
    inst:DoTaskInTime(95 * (1/30), function() inst.SoundEmitter:PlaySound("dontstarve/maxwell/throne_scream") end)    
    inst:DoTaskInTime(213 * (1/30), function() inst.SoundEmitter:KillSound("deathrattle") end)
    Sleep(9.5)
    inst:StartThread(function() SpawnNewPuppet(inst) end)
end


local function PlayerDie(inst)
    inst.AnimState:PlayAnimation("player_death")
    inst.puppet.AnimState:PlayAnimation("dismount")
    inst.puppet.AnimState:PushAnimation("death", false)
    inst:DoTaskInTime(24 * (1/30), function() inst.SoundEmitter:PlaySound("dontstarve/wilson/death") end)
    inst:DoTaskInTime(40 * (1/30), function() inst.SoundEmitter:KillSound("deathrattle") end)
    Sleep(4)
    inst:StartThread(function() SpawnNewPuppet(inst) end)
end

local function SetUpCutscene(inst)
    --Put game into "cutscene" mode. 
    if inst.puppet.components.maxwelltalker then
        if inst.puppet.components.maxwelltalker:IsTalking() then
            inst.puppet.components.maxwelltalker:StopTalking()
        end
        inst.puppet:RemoveComponent("maxwelltalker")
        inst.puppet.AnimState:PlayAnimation("idle_loop")
    end
    local pt = Vector3(inst.Transform:GetWorldPosition())
    GetPlayer():FacePoint(Vector3(pt.x - 100, pt.y, pt.z))

    GetPlayer().components.playercontroller:Enable(false)
    GetPlayer().HUD:Hide()

    TheCamera:CutsceneMode(true)
    TheCamera:SetCustomLocation(Vector3(pt.x, pt.y, pt.z))
    TheCamera:SetGains(0.5, .1, 2)
    TheCamera:SetMinDistance(5)

    inst.previousLock = GetPlayer().profile:GetValue("characterinthrone") or "waxwell"
    
    TheCamera:Shake("FULL", 5, 0.033, 0.1)

    inst.phonograph = TheSim:FindFirstEntityWithTag("maxwellphonograph")
    if inst.phonograph then
        if inst.phonograph.components.machine:IsOn() then
            inst.phonograph.components.machine:TurnOff()
        end
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/throne/thronemagic", "deathrattle")

    Sleep(3)

    TheCamera:SetGains(0.5, .1, .3)

    Sleep(2)
    if inst.DynamicShadow then
        inst.DynamicShadow:Enable(false)
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/throne/thronedisappear")
    if inst.isMaxwell then
        inst:StartThread(function() MaxwellDie(inst) end)
    else
        inst:StartThread(function() PlayerDie(inst) end)
    end
end

local function startthread(inst)
    inst.task =  inst:StartThread(function() SetUpCutscene(inst) end)
end

local function fn(Sim)

    local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 3, 2 )    

    anim:SetBank("throne")
    anim:SetBuild("maxwell_throne")
    anim:PlayAnimation("idle")

    inst:AddTag("maxwellthrone")

    inst:AddComponent("inspectable")    

    local characterinthrone = GetPlayer().profile:GetValue("characterinthrone") or "waxwell"

    inst.lock = nil
    inst.startthread = startthread


    if characterinthrone == "waxwell" then --special case for maxwell
        
        inst.isMaxwell = true
        characterinthrone = "maxwellendgame"
        inst:ListenForEvent("free", function()EndGameSequence(inst) end, inst.lock)

    else

        inst.isMaxwell = false
        anim:PlayAnimation("player_idle_loop")
        inst:ListenForEvent("free", function() EndGameSequenceNoMaxwell(inst) end, inst.lock)

    end
    
    inst:DoTaskInTime(0, function() inst.puppet = SpawnPuppet(inst, characterinthrone) end)

    return inst
end

return Prefab( "common/characters/maxwellthrone", fn, assets, prefabs) 
