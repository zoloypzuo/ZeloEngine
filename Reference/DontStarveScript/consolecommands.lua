

local function Spawn(prefab)
    --TheSim:LoadPrefabs({prefab})
    return SpawnPrefab(prefab)
end


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Console Functions -- These are simple helpers made to be typed at the console.
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------


function c_repeatlastcommand()
    local history = GetConsoleHistory()
    if #history > 0 then
        if history[#history] == "c_repeatlastcommand()" then
            -- top command is this one, so we want the second last command
            history[#history] = nil
        end
        ExecuteConsoleCommand(history[#history])
    end
end

-- Spawn At Cursor and select the new ent
-- Has a gimpy short name so it's easier to type from the console
function c_spawn(prefab, count)
	count = count or 1
	local inst = nil
	for i=1,count do
		inst = DebugSpawn(prefab)
		inst.Transform:SetPosition(TheInput:GetWorldPosition():Get())
	end
	SetDebugEntity(inst)
    SuUsed("c_spawn_" .. prefab , true)
	return inst
end

-- Get the currently selected entity, so it can be modified etc.
-- Has a gimpy short name so it's easier to type from the console
function c_sel()
	return GetDebugEntity()
end

function c_select(inst)
	return SetDebugEntity(inst)
end

-- Print the (visual) tile under the cursor
function c_tile()
	local s = ""

	local ground = GetWorld()
	local mx, my, mz = TheInput:GetWorldPosition():Get()
	local tx, ty = ground.Map:GetTileCoordsAtPoint(mx,my,mz)
	s = s..string.format("world[%f,%f,%f] tile[%d,%d] ", mx,my,mz, tx,ty)

	local tile = ground.Map:GetTileAtPoint(TheInput:GetWorldPosition():Get())
	for k,v in pairs(GROUND) do
		if v == tile then
			s = s..string.format("ground[%s] ", k)
			break
		end
	end

	print(s)
end

-- Apply a scenario script to the selection and run it.
function c_doscenario(scenario)
	local inst = GetDebugEntity()
	if not inst then
		print("Need to select an entity to apply the scenario to.")
		return
	end
	if inst.components.scenariorunner then
		inst.components.scenariorunner:ClearScenario()
	end

	-- force reload the script -- this is for testing after all!
	package.loaded["scenarios/"..scenario] = nil

	inst:AddComponent("scenariorunner")
	inst.components.scenariorunner:SetScript(scenario)
	inst.components.scenariorunner:Run()
    SuUsed("c_doscenario_"..scenario, true)
end


-- Some helper shortcut functions
function c_season() return GetWorld().components.seasonmanager end
function c_sel_health()
	if c_sel() then
		local health = c_sel().components.health
		if health then
			return health
		else
			print("Gah! Selection doesn't have a health component!")
			return
		end
	else
		print("Gah! Need to select something to access it's components!")
	end
end

function c_sethealth(n)
    SuUsed("c_sethealth", true)
	GetPlayer().components.health:SetPercent(n)
end

function c_setminhealth(n)
    SuUsed("c_minhealth", true)
    GetPlayer().components.health:SetMinHealth(n)
end

function c_setsanity(n)
    SuUsed("c_setsanity", true)
	GetPlayer().components.sanity:SetPercent(n)
end

function c_sethunger(n)
    SuUsed("c_sethunger", true)
	GetPlayer().components.hunger:SetPercent(n)
end

-- Put an item(s) in the player's inventory
function c_give(prefab, count)
	count = count or 1

    local MainCharacter = GetPlayer()
    
	if MainCharacter then
		for i=1,count do
			local inst = Spawn(prefab)
			if inst then
				MainCharacter.components.inventory:GiveItem(inst)
                SuUsed("c_give_" .. inst.prefab)
			end
		end
	end
end

function c_mat(recname)
    local player = GetPlayer()
    local recipe = GetRecipe(recname)
    if player.components.inventory and recipe then
      for ik, iv in pairs(recipe.ingredients) do
            for i = 1, iv.amount do
                local item = SpawnPrefab(iv.type)
                player.components.inventory:GiveItem(item)
                SuUsed("c_mat_" .. iv.type , true)
            end
        end
    end
end

function c_pos(inst)
	return inst and Point(inst.Transform:GetWorldPosition())
end

function c_printpos(inst)
	print(c_pos(inst))
end

function c_teleport(x, y, z, inst)
	inst = inst or GetPlayer()
	inst.Transform:SetPosition(x, y, z)
    SuUsed("c_teleport", true)
end

function c_move(inst)
	inst = inst or c_sel()
	inst.Transform:SetPosition(TheInput:GetWorldPosition():Get())
    SuUsed("c_move", true)
end

function c_goto(dest, inst)
	inst = inst or GetPlayer()
	inst.Transform:SetPosition(dest.Transform:GetWorldPosition())
    SuUsed("c_goto", true)
end

function c_inst(guid)
	return Ents[guid]
end

function c_list(prefab)
    local x,y,z = GetPlayer().Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 9001)
    for k,v in pairs(ents) do
    	if v.prefab == prefab then
	    	print(string.format("%s {%2.2f, %2.2f, %2.2f}", tostring(v), v.Transform:GetWorldPosition()))
    	end
    end
end

function c_listtag(tag)
    local tags = {tag}
    local x,y,z = GetPlayer().Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 9001, tags)
    for k,v in pairs(ents) do
    	print(string.format("%s {%2.2f, %2.2f, %2.2f}", tostring(v), v.Transform:GetWorldPosition()))
    end
end

local lastfound = -1
function c_findnext(prefab, radius, inst)
	inst = inst or GetPlayer()
	radius = radius or 9001

    local trans = inst.Transform
    local found = nil
	local foundlowestid = nil
	local reallowest = nil
	local reallowestid = nil

	print("Finding a ",prefab)

    local x,y,z = trans:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, radius)
    for k,v in pairs(ents) do
        if v ~= inst and v.prefab == prefab then
        	print(v.GUID,lastfound,foundlowestid )
			if v.GUID > lastfound and (foundlowestid == nil or v.GUID < foundlowestid) then
				found = v
				foundlowestid = v.GUID
			end
			if not reallowestid or v.GUID < reallowestid then
				reallowest = v
				reallowestid = v.GUID
			end
        end
    end
	if not found then
		found = reallowest
	end
	lastfound = found.GUID
    return found
end

local godmode = false
function c_godmode()
	if GetPlayer() then
		godmode = not godmode
		GetPlayer().components.health:SetInvincible(godmode)
        SuUsed("c_godmode", true)
		print("God mode: ",godmode) 
	end
end

function c_find(prefab, radius, inst)
	inst = inst or GetPlayer()
	radius = radius or 9001

    local trans = inst.Transform
    local found = nil
    local founddistsq = nil

    local x,y,z = trans:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, radius)
    for k,v in pairs(ents) do
        if v ~= inst and v.prefab == prefab then
            if not founddistsq or inst:GetDistanceSqToInst(v) < founddistsq then 
                found = v
                founddistsq = inst:GetDistanceSqToInst(v)
            end
        end
    end
    return found
end

function c_findtag(tag, radius, inst)
	return GetClosestInstWithTag(tag, inst or GetPlayer(), radius or 1000)
end

function c_gonext(name)
	c_goto(c_findnext(name))
end

function c_printtextureinfo( filename )
	TheSim:PrintTextureInfo( filename )
end

function c_simphase(phase)
	GetWorld():PushEvent("phasechange", {newphase = phase})
end

function c_anim(animname, loop)
	if GetDebugEntity() then
		GetDebugEntity().AnimState:PlayAnimation(animname, loop or false)
	else
		print("No DebugEntity selected")
	end
end

function c_light(c1, c2, c3)
	TheSim:SetAmbientColour(c1, c2 or c1, c3 or c1)
end

function c_spawn_ds(prefab, scenario)
	local inst = c_spawn(prefab)
	if not inst then
		print("Need to select an entity to apply the scenario to.")
		return
	end

	if inst.components.scenariorunner then
		inst.components.scenariorunner:ClearScenario()
	end

	-- force reload the script -- this is for testing after all!
	package.loaded["scenarios/"..scenario] = nil

	inst:AddComponent("scenariorunner")
	inst.components.scenariorunner:SetScript(scenario)
	inst.components.scenariorunner:Run()
end


function c_countprefabs(prefab, noprint)
	local count = 0
	for k,v in pairs(Ents) do
		if v.prefab == prefab then
			count = count + 1
		end
	end
	if not noprint then
		print("There are ", count, prefab.."s in the world.")
	end
	return count
end

function c_countallprefabs()
	local counted = {}
	for k,v in pairs(Ents) do
		if v.prefab and not table.findfield(counted, v.prefab) then 
			local num = c_countprefabs(v.prefab, true)
			counted[v.prefab] = num
		end
	end

    local function pairsByKeys (t, f)
      local a = {}
      for n in pairs(t) do table.insert(a, n) end
      table.sort(a, f)
      local i = 0      -- iterator variable
      local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
      end
      return iter
    end

    for k,v in pairsByKeys(counted) do
    	print(k, v)
    end

	print("There are ", GetTableSize(counted), " different prefabs in the world.")
end

function c_speed(speed)
	GetPlayer().components.locomotor.bonusspeed = speed
end

function c_forcecrash(unique)
    local path = "a"
    if unique then
        path = string.random(10, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV")
    end

    if GetWorld() then
        GetWorld():DoTaskInTime(0,function() _G[path].b = 0 end)
    elseif TheFrontEnd then
        TheFrontEnd.screenroot.inst:DoTaskInTime(0,function() _G[path].b = 0 end)
    end
end

function c_testruins()
	GetPlayer().components.builder:UnlockRecipesForTech({SCIENCE = 2, MAGIC = 2})
	c_give("log", 20)
	c_give("flint", 20)
	c_give("twigs", 20)
	c_give("cutgrass", 20)
	c_give("lightbulb", 5)
	c_give("healingsalve", 5)
	c_give("batbat")
	c_give("icestaff")
	c_give("firestaff")
	c_give("tentaclespike")
	c_give("slurtlehat")
	c_give("armorwood")
	c_give("minerhat")
	c_give("lantern")
	c_give("backpack")
end


function c_teststate(state)
	c_sel().sg:GoToState(state)
end

function c_sounddebug ( filter )
	if not package.loaded["debugsounds"] then
		require "debugsounds"
	end

	SOUNDDEBUG_ENABLED = true
	TheSim:SetDebugRenderEnabled(true)

	SetSoundDebug()

	if filter then
		SetEventSoundFilter(filter)
	end
end

-- CS stands for sounddebug
function cs_on(filter)
	c_sounddebug(filter)
end

function cs_off()
	SOUNDDEBUG_ENABLED = false
	ResetSoundDebug()
end

function cs_toggle()
	if SOUNDDEBUG_ENABLED then
		cs_off()
	else
		cs_on()
	end
end

function cs_prefab ( prefab )
	SetPrefabSoundFilter( prefab )
end

function cs_filter (filter)
	SetEventSoundFilter( filter )
end

function cs_entity (guid)
	SetEntitySoundFilter(guid)
end

function cs_sel()
	if c_sel() then
		cs_entity(c_sel().entity:GetGUID())
	end
end
