require "consolecommands"


----this gets called by the frontend code if a rawkey event has not been consumed by the current screen
handlers = {}

-- Add commonly used commands here. 
-- Hitting F2 will append them to the current console history 
-- Hit  SHIFT-CTRL-F2 to add the current console history to this list (list is not saved between reloads!)
local LOCAL_HISTORY = {
                            "c_godmode(true)",
                            "c_spawn('nightmarebeak',10)",
                            "c_spawn('minotaur')",
                            }

function DoDebugKey(key, down)
	if handlers[key] then
		for k,v in ipairs(handlers[key]) do
			if v(down) then
				return true
			end
		end
	end
end


--use this to register debug key handlers from within this file
function AddGameDebugKey(key, fn, down)
	down = down or true
	handlers[key] = handlers[key] or {}
	table.insert( handlers[key], function(_down) if _down == down and inGamePlay then return fn() end end)
end

function AddGlobalDebugKey(key, fn, down)
	down = down or true
	handlers[key] = handlers[key] or {}
	table.insert( handlers[key], function(_down) if _down == down then return fn() end end)
end


-------------------------------------DEBUG KEYS


local currentlySelected
global("c_ent")
global("c_ang")

local function Spawn(prefab)
    --TheSim:LoadPrefabs({prefab})
    return SpawnPrefab(prefab)
end


local userName = TheSim:GetUsersName() 
--
-- Put your own username in here to enable "dprint"s to output to the log window 
if CHEATS_ENABLED and userName == "My Username" then
    global("CHEATS_KEEP_SAVE")
    global("CHEATS_ENABLE_DPRINT")
    global("DPRINT_USERNAME")
    global("c_ps")

    DPRINT_USERNAME = "My Username"
    CHEATS_KEEP_SAVE = true
    CHEATS_ENABLE_DPRINT = true
end

function InitDevDebugSession()
    --[[ To setup this function to be called when the game starts up edit stats.lua and patch the context:
                    function RecordSessionStartStats()
                        if not STATS_ENABLE then
                            return
                        end

                        if InitDevDebugSession then
                            InitDevDebugSession()
                        end
                     --- rest of function
    --]]
    -- Add calls that you want executed whenever a session starts
    -- Here, for example the minhealth is set so the player can't be killed
    -- and the autosave timeout is set to a huge value so that the autosave
    -- doesnt' overwrite my carefully constructed debugging setup
    dprint("DEVDEBUGSESSION")
    global( "TheFrontEnd" )
    local player = GetPlayer()

    c_setminhealth(5)
    TheFrontEnd.consoletext.closeonrun = true
    if player.components.autosaver then
        player.components.autosaver.timeout = 9999e99
    end
end

AddGlobalDebugKey(KEY_HOME, function()
    if not TheSim:IsDebugPaused() then
        print("Home key pressed PAUSING GAME")
        TheSim:ToggleDebugPause()
    end

    print("Home key pressed STEPPING")
	TheSim:Step()
	return true
end)

AddGlobalDebugKey(KEY_R, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
		if TheInput:IsKeyDown(KEY_SHIFT) then
		    StartNextInstance({reset_action = RESET_ACTION.LOAD_SLOT, save_slot=SaveGameIndex:GetCurrentSaveSlot()})
        
        elseif TheInput:IsKeyDown(KEY_ALT) then
            SaveGameIndex:DeleteSlot(SaveGameIndex:GetCurrentSaveSlot(), function()
                StartNextInstance({reset_action = RESET_ACTION.LOAD_SLOT, save_slot=SaveGameIndex:GetCurrentSaveSlot()})
            end, true)
		else
			StartNextInstance()
		end
		return true
    
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
        local ents = TheInput:GetAllEntitiesUnderMouse()
        if ents[1] and ents[1].prefab then ents[1]:Remove() end
        return true
    else
        print ("REPEATING LAST COMMAND")
        c_repeatlastcommand()
        return true
    end
end)

AddGameDebugKey(KEY_F2, function()
    if TheInput:IsKeyDown(KEY_SHIFT) and TheInput:IsKeyDown(KEY_CTRL) then
        LOCAL_HISTORY = JoinArrays(GetConsoleHistory(),LOCAL_HISTORY)
    else
        SetConsoleHistory(JoinArrays(GetConsoleHistory(),LOCAL_HISTORY))
    end
end)

AddGameDebugKey(KEY_F3, function()

end)

AddGameDebugKey(KEY_F4, function()
    GetSeasonManager():ForcePrecip()
    return true
end)

AddGameDebugKey(KEY_F5, function()
	if TheInput:IsKeyDown(KEY_SHIFT) then
		print("Running stress test")
  		scheduler:ExecutePeriodic(0.01, function() 
            local MainCharacter = GetPlayer()
            local ground = GetWorld()

            if MainCharacter then

                local x = math.random()*(350.0*4.0)-(350.0/2.0)*4.0
                local z = math.random()*(350.0*4.0)-(350.0/2.0)*4.0
                local tile = ground.Map:GetTileAtPoint(x, 0, z)
                if tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID then
                    MainCharacter.Transform:SetPosition(x, 0, z)
                end
                -- local locaton = GetRandomItem(locations)
                -- MainCharacter.Transform:SetPosition(locaton.x, 0, locaton.z) 
            end   
        end)
    else
		local pos = TheInput:GetWorldPosition()
		GetSeasonManager():DoLightningStrike(pos)
	end
	return true
end)


AddGameDebugKey(KEY_F12, function()

    local mousepos = TheInput:GetWorldPosition()
    local ground = GetWorld()

    for t,node in ipairs(ground.topology.nodes)do
        if TheSim:WorldPointInPoly(pos.x, pos.z, node.poly) then
            print("AREA:",node.area)
        end
    end
end)


AddGameDebugKey(KEY_F7, function()
    local pt = GetPlayer():GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 40, {"selfstacker"})

    for k,v in pairs(ents) do
        v.components.selfstacker.stackpartner = nil
        if v and v.components.selfstacker:CanSelfStack() then
            v:DoTaskInTime(math.random() * .1, function() v.components.selfstacker:DoStack() end)
        end
    end

	return true
end)

---Spawn random items from the "items" table in a circles around me.

AddGameDebugKey(KEY_F8, function()
    --Spawns a lot of prefabs around you in rings.
    local items = {"houndstooth"} --Which items spawn. 
    local player = GetPlayer()
    local pt = Vector3(player.Transform:GetWorldPosition())
    local theta = math.random() * 2 * PI
    local numrings = 20 --How many rings of stuff you spawn
    local radius = 5 --Initial distance from player
    local radius_step_distance = .5 --How much the radius increases per ring.
    local itemdensity = 2 --(X items per unit)
    local ground = GetWorld()
    
    local finalRad = (radius + (radius_step_distance * numrings))
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, finalRad + 2)

    local numspawned = 0
    -- Walk the circle trying to find a valid spawn point
    for i = 1, numrings do
        local circ = 2*PI*radius
        local numitems = circ * itemdensity

        for i = 1, numitems do
            numspawned = numspawned + 1
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
            local wander_point = pt + offset
           
            if ground.Map and ground.Map:GetTileAtPoint(wander_point.x, wander_point.y, wander_point.z) ~= GROUND.IMPASSABLE then  
                local spawn = SpawnPrefab(GetRandomItem(items))
                spawn.Transform:SetPosition( wander_point.x, wander_point.y, wander_point.z )    
            end
            theta = theta - (2 * PI / numitems)
        end
        radius = radius + radius_step_distance
    end
    print("Made: ".. numspawned .." items")
    return true
end)

AddGameDebugKey(KEY_PAGEUP, function()
	if TheInput:IsKeyDown(KEY_SHIFT) then
		GetSeasonManager().moisture_limit = GetSeasonManager().moisture_limit + 100
	elseif TheInput:IsKeyDown(KEY_CTRL) then
		GetSeasonManager().atmo_moisture = GetSeasonManager().atmo_moisture + 100
	else
		GetWorld().components.seasonmanager:Advance()
	end
	
	return true
end)

AddGameDebugKey(KEY_PAGEDOWN, function()
	if TheInput:IsKeyDown(KEY_SHIFT) then
		GetSeasonManager().moisture_limit = math.max(0, GetSeasonManager().moisture_limit - 100)
	elseif TheInput:IsKeyDown(KEY_CTRL) then
		GetSeasonManager().atmo_moisture = math.max(0, GetSeasonManager().atmo_moisture - 100)
	else
		GetWorld().components.seasonmanager:Retreat()
	end
	return true
end)


AddGameDebugKey(KEY_O, function()
  	if TheInput:IsKeyDown(KEY_SHIFT) then
		print("Going normal...")
    	--GetClock():StartDusk()
    	--TheSim:SetAmbientColour(0.8,0.8,0.8)
  		-- Normal ruins (pretty, light, healthy)
		--GetCeiling().MapCeiling:AddSubstitue(GROUND.WALL_HUNESTONE,GROUND.WALL_HUNESTONE_GLOW)
		--GetCeiling().MapCeiling:AddSubstitue(GROUND.WALL_STONEEYE,GROUND.WALL_STONEEYE_GLOW)
		local retune = require("tuning_override")
	  	retune.OVERRIDES["ColourCube"].doit("ruins_light_cc")
	  	retune.OVERRIDES["areaambientdefault"].doit("cave")

	  	 GetWorld().components.ambientsoundmixer:SetSoundParam(1.0)
	  	--civruinsAMB (1.0)
	elseif TheInput:IsKeyDown(KEY_ALT) then
		print("Going evil...")
    	--GetClock():StartNight()
    	--TheSim:SetAmbientColour(0.0,0.0,0.0)
		--GetCeiling().MapCeiling:ClearSubstitues()
		-- Evil ruins (ugly, dark, unhealthy)
		local retune = require("tuning_override")
	  	retune.OVERRIDES["ColourCube"].doit("ruins_dark_cc")
	  	retune.OVERRIDES["areaambient"].doit("CIVRUINS")
	  	 GetWorld().components.ambientsoundmixer:SetSoundParam(2.0)
	  	--civruinsAMB (2.0)
	end
	
	return true
end)

AddGameDebugKey(KEY_F9, function()
    local skipPlayer = TheInput:IsKeyDown(KEY_CTRL)
    LongUpdate(TUNING.SEG_TIME, skipPlayer)
	return true
end)

AddGameDebugKey(KEY_F10, function()
	if TheInput:IsKeyDown(KEY_CTRL) then
		if GetClock().override_timeLeftInEra == nil then
			GetClock().override_timeLeftInEra = TUNING.SEG_TIME
		else
			GetClock().override_timeLeftInEra = nil
		end
	end

   	GetClock():NextPhase()
   	return true
end)


AddGameDebugKey(KEY_F11, function()
   	local nightmareclock = GetNightmareClock()
    if nightmareclock then
        nightmareclock:NextPhase()
    end
   	return true
end)

AddGameDebugKey(KEY_F1, function()
    local armour = SpawnPrefab("armorruins")
    local weapon = SpawnPrefab("ruins_bat")
    local hat = SpawnPrefab("ruinshat")

    local inv = GetPlayer().components.inventory

    inv:GiveItem(armour)
    inv:GiveItem(weapon)
    inv:GiveItem(hat)

    inv:Equip(armour)
    inv:Equip(weapon)
    inv:Equip(hat)

    local maxwell = c_spawn("shadowmaxwell")

end)

local potatoparts = { "teleportato_ring", "teleportato_box", "teleportato_crank", "teleportato_potato", "teleportato_base", "adventure_portal" }
local potatoindex = 1

AddGameDebugKey(KEY_1, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
		local MainCharacter = GetPlayer()
		local part = nil
		for k,v in pairs(Ents) do
			if v.prefab == potatoparts[potatoindex] then
				part = v
				break
			end
		end
		potatoindex = ((potatoindex) % #potatoparts)+1
        if MainCharacter and part then
            MainCharacter.Transform:SetPosition(part.Transform:GetWorldPosition())
        end
	    return true
    end
    
end)


AddGameDebugKey(KEY_X, function()
    currentlySelected = TheInput:GetWorldEntityUnderMouse()
    if currentlySelected then
        c_ent = currentlySelected
        dprint(c_ent)
    end
    if TheInput:IsKeyDown(KEY_CTRL) and c_ent then
        dtable(c_ent,1)
    end
    return true
end)

AddGlobalDebugKey(KEY_LEFTBRACKET, function()
	TheSim:SetTimeScale(TheSim:GetTimeScale() - .25)
	return true
end)

AddGlobalDebugKey(KEY_RIGHTBRACKET, function()
	TheSim:SetTimeScale(TheSim:GetTimeScale() + .25)
	return true
end)

AddGameDebugKey(KEY_KP_PLUS, function()
    local MainCharacter = GetPlayer()
    if TheInput:IsKeyDown(KEY_CTRL) then
    	c_setsanity(1)
    elseif MainCharacter then
		if TheInput:IsKeyDown(KEY_SHIFT) then
			MainCharacter.components.hunger:DoDelta(50)
		elseif TheInput:IsKeyDown(KEY_ALT) then
			MainCharacter.components.sanity:DoDelta(50)
		else
			MainCharacter.components.health:DoDelta(50, nil, "debug_key")
	        c_sethunger(1)
	        c_sethealth(1)
	        c_setsanity(1)
		end
    end
    
    return true
end)

AddGameDebugKey(KEY_KP_MINUS, function()
    local MainCharacter = GetPlayer()
    if MainCharacter then
        if TheInput:IsKeyDown(KEY_CTRL) then
		    --MainCharacter.components.temperature:DoDelta(-10)
            --TheSim:SetTimeScale(TheSim:GetTimeScale() - .25)
			MainCharacter.components.sanity:DoDelta(-20)
        elseif TheInput:IsKeyDown(KEY_SHIFT) then
			MainCharacter.components.hunger:DoDelta(-25)
		elseif TheInput:IsKeyDown(KEY_ALT) then
            MainCharacter.components.sanity:SetPercent(0)
		else
			MainCharacter.components.health:DoDelta(-25, nil, "debug_key")
		end
	end
	return true
end)

AddGameDebugKey(KEY_T, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local pt = GetPlayer():GetWorldPosition():Get()
        local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 20)
        for i,ent in ipairs(ents)do
            print(ent.prefab,ent:HasTag("INTERIOR_LIMBO"))
        end
    else
	-- Moving Teleport to just plain T as I am getting a sore hand from CTRL-T - Alia
        local MainCharacter = GetPlayer()
        if MainCharacter then
    	    MainCharacter.Transform:SetPosition(TheInput:GetWorldPosition():Get() )
        end   
    end
    return true
end)

AddGameDebugKey(KEY_G, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
        if MouseCharacter then
            if MouseCharacter.components.growable then
                MouseCharacter.components.growable:DoGrowth()
            elseif MouseCharacter.components.fueled then
                MouseCharacter.components.fueled:SetPercent(1)
            elseif MouseCharacter.components.breeder then
                MouseCharacter.components.breeder:updatevolume(1)
            end
        end
    else
		c_godmode()
    end
	return true
end)

AddGameDebugKey(KEY_K, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
        if MouseCharacter then
			if MouseCharacter.components.health and MouseCharacter ~= GetPlayer() then
				MouseCharacter.components.health:Kill()
			elseif MouseCharacter.Remove then
				MouseCharacter:Remove()
			end
        end
    end
    return true
end)

local DebugTextureVisible = false
local MapLerpVal = 0.0

AddGlobalDebugKey(KEY_SLASH, function()
    if TheInput:IsKeyDown(KEY_ALT) then
    	print("ToggleFrameProfiler")
		TheSim:ToggleFrameProfiler()
	else
		TheSim:ToggleDebugTexture()

		DebugTextureVisible = not DebugTextureVisible
		print("DebugTextureVisible",DebugTextureVisible)
	end
	return true
end)

AddGlobalDebugKey(KEY_EQUALS, function()
	if DebugTextureVisible then
		local val = 1
		if TheInput:IsKeyDown(KEY_ALT) then
			val = 10
		elseif TheInput:IsKeyDown(KEY_CTRL) then
			val = 100
		end
		TheSim:UpdateDebugTexture(val)
	else
		MapLerpVal = MapLerpVal + 0.1
		if GetMap() then
			GetMap():SetOverlayLerp( MapLerpVal )
		end
	end
	return true
end)

AddGameDebugKey(KEY_MINUS, function()
	if DebugTextureVisible then
		local val = 1
		if TheInput:IsKeyDown(KEY_ALT) then
			val = 10
		elseif TheInput:IsKeyDown(KEY_CTRL) then
			val = 100
		end
		TheSim:UpdateDebugTexture(-val)
	else
		MapLerpVal = MapLerpVal - 0.1 
		if GetMap() then
			GetMap():SetOverlayLerp( MapLerpVal )
		end
	end
	
	return true
end)

local enable_fog = true
local hide_revealed = false
AddGameDebugKey(KEY_M, function()
    local MainCharacter = GetPlayer()
    local map = TheSim:FindFirstEntityWithTag("minimap")
    if MainCharacter and map then
        if TheInput:IsKeyDown(KEY_CTRL) then
		    enable_fog = not enable_fog
		    map.MiniMap:EnableFogOfWar(enable_fog)
        elseif TheInput:IsKeyDown(KEY_SHIFT) then
            hide_revealed = not hide_revealed
            map.MiniMap:ClearRevealedAreas(hide_revealed)
        end
    end
    return true
end)


AddGameDebugKey(KEY_S, function()
	if TheInput:IsKeyDown(KEY_CTRL) then
		GetPlayer().components.autosaver:DoSave()
		return true			
	end
end)

AddGameDebugKey(KEY_A, function()
	if TheInput:IsKeyDown(KEY_CTRL) then
		local MainCharacter = GetPlayer()
		MainCharacter.components.builder:GiveAllRecipes()
		MainCharacter:PushEvent("techlevelchange")
		MainCharacter:PushEvent("techtreechange")
		return true
	end
    if TheInput:IsKeyDown(KEY_SHIFT) then 
    end
end)

AddGameDebugKey(KEY_KP_MULTIPLY, function()
	if TheInput:IsDebugToggleEnabled() then
		c_give("devtool")
		return true
	end
end)

AddGameDebugKey(KEY_KP_DIVIDE, function()
	if TheInput:IsDebugToggleEnabled() then
		GetPlayer().components.inventory:DropEverything(false, true)
		return true
	end
end)


AddGameDebugKey(KEY_C, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local pos = TheInput:GetWorldPosition()
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 5, {"SELECT_ME"},{"INLIMBO"})
        if #ents >0 then
            for i, ent in ipairs(ents)do
                print("-------------")
                dumptable(ent,1,1,1)
            end
        else
            print("NO ENTS")
        end
    end
    --[[
    if userName ~= "David Forsey" then
        if TheInput:IsKeyDown(KEY_CTRL) then
            local IDENTITY_COLOURCUBE = "images/colour_cubes/identity_colourcube.tex"
            PostProcessor:SetColourCubeData( 0, IDENTITY_COLOURCUBE, IDENTITY_COLOURCUBE )
            PostProcessor:SetColourCubeLerp( 0, 0 )
        end
    else
        if not c_ent then return end

        global("c_ent_mood")
        local pos = c_ent.components.knownlocations.GetLocation and c_ent.components.knownlocations:GetLocation("rookery")
        if pos and TheInput:IsKeyDown(KEY_CTRL) then
            c_teleport(pos.x, pos.y, pos.z)
        elseif pos then
            c_teleport(pos.x, pos.y, pos.z, c_ent)
        end
    end
    ]]
    return true
end)


AddGlobalDebugKey(KEY_PAUSE, function()
    print("Toggle pause")
	
    TheSim:ToggleDebugPause()
    TheSim:ToggleDebugCamera()
	
    if TheSim:IsDebugPaused() then
	    TheSim:SetDebugRenderEnabled(true)
	    if TheCamera.targetpos then
		    TheSim:SetDebugCameraTarget(TheCamera.targetpos.x, TheCamera.targetpos.y, TheCamera.targetpos.z)
	    end
		
	    if TheCamera.headingtarget then
		    TheSim:SetDebugCameraRotation(-TheCamera.headingtarget-90)	
	    end
    end
    return true
end)

--[[AddGameDebugKey(KEY_H, function()
	if TheInput:IsKeyDown(KEY_LCTRL) then
		GetPlayer().HUD:Toggle()
	end

end)--]]

AddGameDebugKey(KEY_INSERT, function()
    if TheInput:IsDebugToggleEnabled() then
        if not TheSim:GetDebugRenderEnabled() then
            TheSim:SetDebugRenderEnabled(true)
        end
	    if TheInput:IsKeyDown(KEY_SHIFT) then
		    TheSim:ToggleDebugCamera()
	    else
			TheSim:SetDebugPhysicsRenderEnabled(not TheSim:GetDebugPhysicsRenderEnabled())
	    end
    end
    return true
end)


-------------------------------------------MOUSE HANDLING


local function DebugRMB(x,y)
    dprint("MBHAND:CTRL=",TheInput:IsKeyDown(KEY_CTRL)," SHIFT=", TheInput:IsKeyDown(KEY_SHIFT))
    local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
    local pos = TheInput:GetWorldPosition()

    if TheInput:IsKeyDown(KEY_CTRL) and
       TheInput:IsKeyDown(KEY_SHIFT) and
       c_ent.prefab then
        global("c_ent")
        local spawn = c_spawn(c_ent.prefab)
        if spawn then
            spawn.Transform:SetPosition(pos:Get())
        end
   elseif TheInput:IsKeyDown(KEY_CTRL) then
        if MouseCharacter then
			if MouseCharacter.components.health and MouseCharacter ~= GetPlayer() then
				MouseCharacter.components.health:Kill()
			elseif MouseCharacter.Remove then
				MouseCharacter:Remove()
			end
        else
            local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 5)
            for k,v in pairs(ents) do
                if v.components.health and v ~= GetPlayer() then
                    v.components.health:Kill()
                end
            end
        end
    elseif TheInput:IsKeyDown(KEY_ALT) then

        print(GetPlayer():GetAngleToPoint(pos))

    elseif TheInput:IsKeyDown(KEY_SHIFT) then
        if MouseCharacter then
            global("c_ent")
            c_ent = MouseCharacter
            SetDebugEntity(MouseCharacter)
            dprint("Selected: ",c_ent)
        else
            SetDebugEntity(GetWorld())
        end
    end
end

local function DebugLMB(x,y)
	if TheSim:IsDebugPaused() then
		SetDebugEntity(TheInput:GetWorldEntityUnderMouse())
	end
end




function DoDebugMouse(button, down,x,y)
	if not down then return false end
	
	if button == MOUSEBUTTON_RIGHT then
		DebugRMB(x,y)
	elseif button == MOUSEBUTTON_LEFT then
		DebugLMB(x,y)	
	end
	
end
