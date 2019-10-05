
function ModInfoname(name)
	local prettyname = KnownModIndex:GetModFancyName(name)
	if prettyname == name then
		return name
	else
		return name.." ("..prettyname..")"
	end
end

-- This isn't for modders to use: see mods.lua, CreateEnvironment function (line 94 specifically)
function GetModConfigData(optionname, modname)
	assert(modname, "modname must be supplied manually if calling GetModConfigData from outside of modmain or modworldgenmain. Use ModIndex:GetModActualName(fancyname) function [fancyname is name string from modinfo].")
	local config = KnownModIndex:GetModConfigurationOptions(modname)
	if config and type(config) == "table" then
		for i,v in pairs(config) do
			if v.name == optionname then
				if v.saved ~= nil then
					return v.saved 
				else 
					return v.default
				end
			end
		end
	end
	return nil
end

function GetModConfigDataFn(modname)

	local function PublicGetModData( optionname )
		return GetModConfigData(optionname, modname)
	end

	return PublicGetModData
end


local function AddModCharacter(name)
	table.insert(MODCHARACTERLIST, name)
end


local function initprint(...)
	if KnownModIndex:IsModInitPrintEnabled() then
		local modname = getfenv(3).modname
		print(ModInfoname(modname), ...)
	end
end

-- Based on @no_signal's AddWidgetPostInit :)
local function DoAddClassPostConstruct(classdef, postfn)
	local constructor = classdef._ctor
	classdef._ctor = function (self, ...)
		constructor(self, ...)
		postfn(self, ...)
	end
	local mt = getmetatable(classdef)
	mt.__call = function(class_tbl, ...)
        local obj = {}
        setmetatable(obj, classdef)
        if classdef._ctor then
            classdef._ctor(obj, ...)
        end
        return obj
    end
end

local function AddClassPostConstruct(package, postfn)
	local classdef = require(package)
	assert(type(classdef) == "table", "Class file path '"..package.."' doesn't seem to return a valid class.")
	DoAddClassPostConstruct(classdef, postfn)
end

local function AddGlobalClassPostConstruct(package, classname, postfn)
	require(package)
	local classdef = rawget(_G, classname)
	if classdef == nil then
		classdef = require(package)
	end

	assert(type(classdef) == "table", "Class '"..classname.."' wasn't loaded to global from '"..package.."'.")
	DoAddClassPostConstruct(classdef, postfn)
end

local function InsertPostInitFunctions(env)


	env.postinitfns = {}
	env.postinitdata = {}

	env.postinitfns.LevelPreInit = {}
	env.AddLevelPreInit = function(levelid, fn)
		initprint("AddLevelPreInit", levelid)
		if env.postinitfns.LevelPreInit[levelid] == nil then
			env.postinitfns.LevelPreInit[levelid] = {}
		end
		table.insert(env.postinitfns.LevelPreInit[levelid], fn)
	end
	env.postinitfns.LevelPreInitAny = {}
	env.AddLevelPreInitAny = function(fn)
		initprint("AddLevelPreInitAny")
		table.insert(env.postinitfns.LevelPreInitAny, fn)
	end
	env.postinitfns.TaskPreInit = {}
	env.AddTaskPreInit = function(taskname, fn)
		initprint("AddTaskPreInit", taskname)
		if env.postinitfns.TaskPreInit[taskname] == nil then
			env.postinitfns.TaskPreInit[taskname] = {}
		end
		table.insert(env.postinitfns.TaskPreInit[taskname], fn)
	end
	env.postinitfns.RoomPreInit = {}
	env.AddRoomPreInit = function(roomname, fn)
		initprint("AddRoomPreInit", roomname)
		if env.postinitfns.RoomPreInit[roomname] == nil then
			env.postinitfns.RoomPreInit[roomname] = {}
		end
		table.insert(env.postinitfns.RoomPreInit[roomname], fn)
	end

	env.AddLevel = function(...)
		arg = {...}
		initprint("AddLevel", arg[1], arg[2].id)
		require("map/levels")
		AddLevel(...)
	end
	env.AddTask = function(...)
		arg = {...}
		initprint("AddTask", arg[1])
		require("map/tasks")
		AddTask(...)
	end
	env.AddRoom = function(...)
		arg = {...}
		initprint("AddRoom", arg[1])
		require("map/rooms")
		AddRoom(...)
	end

	env.AddAction = function(action)
		assert(action.id ~= nil, "Must specify an ID for your custom action! Example: myaction.id = \"MYACTION\"")
		initprint("AddAction", action.id)
		ACTIONS[action.id] = action
		STRINGS.ACTIONS[action.id] = action.str
	end

	env.postinitdata.MinimapAtlases = {}
	env.AddMinimapAtlas = function( atlaspath )
		initprint("AddMinimapAtlas", atlaspath)
		table.insert(env.postinitdata.MinimapAtlases, atlaspath)
	end

	env.postinitdata.StategraphActionHandler = {}
	env.AddStategraphActionHandler = function(stategraph, handler)
		initprint("AddStategraphActionHandler", stategraph)
		if not env.postinitdata.StategraphActionHandler[stategraph] then
			env.postinitdata.StategraphActionHandler[stategraph] = {}
		end
		table.insert(env.postinitdata.StategraphActionHandler[stategraph], handler)
	end

	env.postinitdata.StategraphState = {}
	env.AddStategraphState = function(stategraph, state)
		initprint("AddStategraphState", stategraph)
		if not env.postinitdata.StategraphState[stategraph] then
			env.postinitdata.StategraphState[stategraph] = {}
		end
		table.insert(env.postinitdata.StategraphState[stategraph], state)
	end

	env.postinitdata.StategraphEvent = {}
	env.AddStategraphEvent = function(stategraph, event)
		initprint("AddStategraphEvent", stategraph)
		if not env.postinitdata.StategraphEvent[stategraph] then
			env.postinitdata.StategraphEvent[stategraph] = {}
		end
		table.insert(env.postinitdata.StategraphEvent[stategraph], event)
	end

	env.postinitfns.StategraphPostInit = {}
	env.AddStategraphPostInit = function(stategraph, fn)
		initprint("AddStategraphPostInit", stategraph)
		if env.postinitfns.StategraphPostInit[stategraph] == nil then
			env.postinitfns.StategraphPostInit[stategraph] = {}
		end
		table.insert(env.postinitfns.StategraphPostInit[stategraph], fn)
	end


	env.postinitfns.ComponentPostInit = {}
	env.AddComponentPostInit = function(component, fn)
		initprint("AddComponentPostInit", component)
		if env.postinitfns.ComponentPostInit[component] == nil then
			env.postinitfns.ComponentPostInit[component] = {}
		end
		table.insert(env.postinitfns.ComponentPostInit[component], fn)
	end

	-- You can use this as a post init for any prefab. If you add a global prefab post init function, it will get called on every prefab that spawns.
	-- This is powerful but also be sure to check that you're dealing with the appropriate type of prefab before doing anything intensive, or else
	-- you might hit some performance issues. The next function down, player post init, is both itself useful and a good example of how you might
	-- want to write your global prefab post init functions.
	env.postinitfns.PrefabPostInitAny = {}
	env.AddPrefabPostInitAny = function(fn)
		initprint("AddPrefabPostInitAny")
		table.insert(env.postinitfns.PrefabPostInitAny, fn)
	end

	-- An illustrative example of how to use a global prefab post init, in this case, we're making a player prefab post init.
	env.AddPlayerPostInit = function(fn)
		env.AddPrefabPostInitAny( function(inst)
			if inst and inst:HasTag("player") then fn(inst) end
		end)
	end

	env.postinitfns.PrefabPostInit = {}
	env.AddPrefabPostInit = function(prefab, fn)
		initprint("AddPrefabPostInit", prefab)
		if env.postinitfns.PrefabPostInit[prefab] == nil then
			env.postinitfns.PrefabPostInit[prefab] = {}
		end
		table.insert(env.postinitfns.PrefabPostInit[prefab], fn)
	end

	env.postinitfns.GamePostInit = {}
	env.AddGamePostInit = function(fn)
		initprint("AddGamePostInit")
		table.insert(env.postinitfns.GamePostInit, fn)
	end

	env.postinitfns.SimPostInit = {}
	env.AddSimPostInit = function(fn)
		initprint("AddSimPostInit")
		table.insert(env.postinitfns.SimPostInit, fn)
	end

	-- the non-standard ones

	env.AddBrainPostInit = function(brain, fn)
		initprint("AddBrainPostInit", brain)
		local brainclass = require("brains/"..brain)
		if brainclass.modpostinitfns == nil then
			brainclass.modpostinitfns = {}
		end
		table.insert(brainclass.modpostinitfns, fn)
	end

	env.AddGlobalClassPostConstruct = function(package, classname, fn)
		initprint("AddGlobalClassPostConstruct", package, classname)
		AddGlobalClassPostConstruct(package, classname, fn)
	end

	env.AddClassPostConstruct = function(package, fn)
		initprint("AddClassPostConstruct", package)
		AddClassPostConstruct(package, fn)
	end

	env.AddIngredientValues = function(names, tags, cancook, candry)
		require("cooking")
		initprint("AddIngredientValues", table.concat(names, ", "))
		AddIngredientValues(names, tags, cancook, candry)
	end

	env.cookerrecipes = {}
	env.AddCookerRecipe = function(cooker, recipe)
		require("cooking")
		initprint("AddCookerRecipe", cooker, recipe.name)
		AddCookerRecipe(cooker, recipe)
		if env.cookerrecipes[cooker] == nil then
	        env.cookerrecipes[cooker] = {}
	    end
	    if recipe.name then
	        table.insert(env.cookerrecipes[cooker], recipe.name)
	    end
	end

	env.AddModCharacter = function(name)
		initprint("AddModCharacter", name)
		AddModCharacter(name)
	end

	env.Recipe = function(...)
		arg = {...}
		initprint("Recipe", arg[1])
		require("recipe")
		return Recipe(...)
	end

	env.LoadPOFile = function(path, lang)
		initprint("LoadPOFile", lang)
		require("translator")
		LanguageTranslator:LoadPOFile(path, lang)
	end

	env.RemapSoundEvent = function(name, new_name)
		initprint("RemapSoundEvent", name, new_name)
		TheSim:RemapSoundEvent(name, new_name)
	end

	env.postinitfns.TreasurePreInit = {}
	env.AddTreasurePreInit = function(treasurename, fn)
		initprint("AddTreasurePreInit", treasurename)
		if env.postinitfns.TreasurePreInit[treasurename] == nil then
			env.postinitfns.TreasurePreInit[treasurename] = {}
		end
		table.insert(env.postinitfns.TreasurePreInit[treasurename], fn)
	end

	env.postinitfns.TreasureLootPreInit = {}
	env.AddTreasureLootPreInit = function(lootname, fn)
		initprint("AddTreasureLootPreInit", lootname)
		if env.postinitfns.TreasureLootPreInit[lootname] == nil then
			env.postinitfns.TreasureLootPreInit[lootname] = {}
		end
		table.insert(env.postinitfns.TreasureLootPreInit[lootname], fn)
	end

	env.AddTreasure = function(...)
		arg = {...}
		initprint("AddTreasure", arg[1])
		require("map/treasurehunt")
		AddTreasure(...)
	end

	env.AddTreasureLoot = function(...)
		arg = {...}
		initprint("AddTreasureLoot", arg[1])
		require("map/treasurehunt")
		AddTreasureLoot(...)
	end

end

return {
			InsertPostInitFunctions = InsertPostInitFunctions,
		}
