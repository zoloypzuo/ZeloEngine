require "class"
local ScriptErrorScreen = require "screens/scripterrorscreen"
require "modutil"
require "prefabs"

MOD_API_VERSION = 6

function AreAnyModsEnabled()
	if ModManager == nil then
		print("AreAnyModsEnabled returning false because ModManager hasn't been created yet.")
		return false
	end
	
	local enabled_mod_names = ModManager:GetEnabledModNames()
	return (#enabled_mod_names > 0)
end

function GetModVersion(mod_name)
	print("mod_name " .. mod_name)
	if KnownModIndex ~= nil  then
		print( KnownModIndex )
	else
		print( "KnownModIndex is nil" )
	end
		
	local modinfo = KnownModIndex:GetModInfo(mod_name)
	if modinfo ~= nil and modinfo.version ~= nil then
		return modinfo.version 
	else
		return "mod_not_found"
	end	
end


local function modprint(...)
	--print(unpack({...}))
end

local runmodfn = function(fn,mod,modtype)
	return (function(...)
		if fn then
			local status, r = xpcall( function() return fn(unpack(arg)) end, debug.traceback)
			if not status then
				print("error calling "..modtype.." in mod "..ModInfoname(mod.modname)..": \n"..r)
				ModManager:RemoveBadMod(mod.modname,r)
				ModManager:DisplayBadMods()
			else
				return r
			end
		end
	end)
end

ModWrangler = Class(function(self)
	self.modnames = {}
	self.mods = {}
	self.records = {}
	self.failedmods = {}
	self.enabledmods = {}
	self.loadedprefabs = {}
end)

function ModWrangler:GetEnabledModNames()
	return self.enabledmods
end

function ModWrangler:GetMod(modname)
	for i,mod in ipairs(self.mods) do
		if mod.modname == modname then
			return mod
		end
	end
end

function ModWrangler:SetModRecords(records)
	self.records = records
	for mod,record in pairs(self.records) do
		if table.contains(self.enabledmods, mod) then
			record.active = true
		else
			record.active = false
		end
	end

	for i,mod in ipairs(self.enabledmods) do
		if not self.records[mod] then
			self.records[mod] = {}
			self.records[mod].active = true
		end
	end
end

function ModWrangler:GetModRecords()
	return self.records
end

function CreateEnvironment(modname, isworldgen)

	local modutil = require("modutil")
	require("recipe") -- for Ingredient

	local env = 
	{
		TUNING=TUNING,
		modname = modname,
		pairs = pairs,
		ipairs = ipairs,
		print = print,
		math = math,
		table = table,
		type = type,
		string = string,
		tostring = tostring,
		Class = Class,
		GLOBAL = _G,
		MODROOT = "../mods/"..modname.."/",
		Prefab = Prefab,
		Asset = Asset,
		Ingredient = Ingredient,
		MODCONFIG = KnownModIndex:GetModConfigurationOptions(modname) or {}, -- Direct access to the mod config table (WARNING: modifying it directly while the game is running could result in weird behavior)
		GetModConfigData = GetModConfigDataFn(modname) -- Call is GetModConfigData(optionname) to fetch saved value of the specified option (name must match name field in config options table)
	}

	if isworldgen == false then
		env.CHARACTERLIST = GetActiveCharacterList()
	end

	env.env = env

	--install our crazy loader!
	env.modimport = function(modulename)
		print("modimport: "..env.MODROOT..modulename)
        local result = kleiloadlua(env.MODROOT..modulename)
		if result == nil then
			error("Error in modimport: "..modulename.." not found!")
		elseif type(result) == "string" then
			error("Error in modimport: "..ModInfoname(modname).." importing "..modulename.."!\n"..result)
		else
        	setfenv(result, env.env)
            result()
        end
	end

	modutil.InsertPostInitFunctions(env)

	return env
end

function ModWrangler:LoadMods(worldgen)
	if not MODS_ENABLED then
		return
	end

	self.worldgen = worldgen or false

	if not worldgen then
		KnownModIndex:UpdateModInfo()
	end
	local moddirs = KnownModIndex:GetModsToLoad(self.worldgen)
	
	for i,modname in ipairs(moddirs) do
		if self.worldgen == false or (self.worldgen == true and KnownModIndex:IsModCompatibleWithMode(modname)) then
			table.insert(self.modnames, modname)

			if self.worldgen == false then
				-- Make sure we load the config data before the mod (but not during worldgen)
				KnownModIndex:LoadModConfigurationOptions(modname)
			end

			local initenv = KnownModIndex:GetModInfo(modname)
			local env = CreateEnvironment(modname,  self.worldgen)
			env.modinfo = initenv

			table.insert( self.mods, env )
			local loadmsg = "Loading mod: "..ModInfoname(modname)
			if initenv.modinfo_message and initenv.modinfo_message ~= "" then
				loadmsg = loadmsg .. " ("..initenv.modinfo_message..")"
			end
			print(loadmsg)
		end
	end

	-- Sort the mods by priority, so that "library" mods can load first
	local function modPrioritySort(a,b)
		local apriority = (a.modinfo and a.modinfo.priority) or 0
		local bpriority = (b.modinfo and b.modinfo.priority) or 0
		return apriority > bpriority
	end
	table.sort(self.mods, modPrioritySort)

	for i,mod in ipairs(self.mods) do
		table.insert(self.enabledmods, mod.modname)
		package.path = "..\\mods\\"..mod.modname.."\\scripts\\?.lua;"..package.path
		self:InitializeModMain(mod.modname, mod, "modworldgenmain.lua")
		if not self.worldgen then 
			-- worldgen has to always run (for customization screen) but modmain can be
			-- skipped for worldgen. This reduces a lot of issues with missing globals.
			self:InitializeModMain(mod.modname, mod, "modmain.lua")
		end
	end
end

function ModWrangler:InitializeModMain(modname, env, mainfile)
	if not KnownModIndex:IsModCompatibleWithMode(modname) then return end

	print("Mod: "..ModInfoname(modname), "Loading "..mainfile)

	local fn = kleiloadlua("../mods/"..modname.."/"..mainfile)
	if type(fn) == "string" then
		print("Mod: "..ModInfoname(modname), "  Error loading mod!\n"..fn.."\n")
		table.insert( self.failedmods, {name=modname,error=fn} )
		return false
	elseif not fn then
		print("Mod: "..ModInfoname(modname), "  Mod had no "..mainfile..". Skipping.")
		return true
	else
		local status, r = RunInEnvironment(fn,env)

		if status == false then
			print("Mod: "..ModInfoname(modname), "  Error loading mod!\n"..r.."\n")
			table.insert( self.failedmods, {name=modname,error=r} )
			return false
		else
			-- the env is an "out reference" so we're done here.
			return true
		end
	end
end

function ModWrangler:RemoveBadMod(badmodname,error)
	KnownModIndex:DisableBecauseBad(badmodname)

	table.insert( self.failedmods, {name=badmodname,error=error} )
end

function ModWrangler:DisplayBadMods()
	if self.worldgen then
		-- we can't save or show errors from worldgen! Up to the main game to display the error.
		for k,badmod in ipairs(self.failedmods) do
			local errormsg = badmod.error
			error(errormsg)
		end
		return
	end
	
			
	-- If the frontend isn't ready yet, just hold onto this until we can display it.

	if #self.failedmods > 0 then
		for i,failedmod in ipairs(self.failedmods) do
			KnownModIndex:DisableBecauseBad(failedmod.name)
			self:GetMod(failedmod.name).modinfo.failed = true
			print("Disabling "..ModInfoname(failedmod.name).." because it had an error.")
		end
	end
	-- There are several flows which may have disabled mods; now is a safe place to save those changes.
	KnownModIndex:Save()

	if TheFrontEnd then
		for k,badmod in ipairs(self.failedmods) do
			TheFrontEnd:DisplayError(
				ScriptErrorScreen(
					STRINGS.UI.MAINSCREEN.MODFAILTITLE, 
					STRINGS.UI.MAINSCREEN.MODFAILDETAIL.." "..KnownModIndex:GetModFancyName(badmod.name).."\n"..badmod.error.."\n",
					{
						{text=STRINGS.UI.MAINSCREEN.SCRIPTERRORQUIT, cb = function() TheSim:ForceAbort() end},
						{text=STRINGS.UI.MAINSCREEN.MODQUIT, cb = function()
																	KnownModIndex:DisableAllMods()
																	KnownModIndex:Save(function()
																		SimReset()
																	end)
																end},
						{text=STRINGS.UI.MAINSCREEN.MODFORUMS, nopop=true, cb = function() VisitURL("http://forums.kleientertainment.com/index.php?/forum/26-dont-starve-mods-and-tools/") end }
					},
					ANCHOR_LEFT,
					STRINGS.UI.MAINSCREEN.MODFAILDETAIL2,
					20
					))
		end
		self.failedmods = {}
	end
end

function ModWrangler:RegisterPrefabs()
	if not MODS_ENABLED then
		return
	end

	for i,modname in ipairs(self.enabledmods) do
		local mod = self:GetMod(modname)

		mod.LoadPrefabFile = LoadPrefabFile
		mod.RegisterPrefabs = RegisterPrefabs
		mod.Prefabs = {}

		print("Mod: "..ModInfoname(mod.modname), "Registering prefabs")

		-- We initialize the prefabs in the sandbox and collect all the created prefabs back
		-- into the main world.
		if mod.PrefabFiles then
			for i,prefab_path in ipairs(mod.PrefabFiles) do
				print("Mod: "..ModInfoname(mod.modname), "  Registering prefab file: prefabs/"..prefab_path)
				local ret = runmodfn( mod.LoadPrefabFile, mod, "LoadPrefabFile" )("prefabs/"..prefab_path)
				if ret then
					for i,prefab in ipairs(ret) do
						print("Mod: "..ModInfoname(mod.modname), "    "..prefab.name)
						mod.Prefabs[prefab.name] = prefab
					end
				end
			end
		end

		local prefabnames = {}
		for name, prefab in pairs(mod.Prefabs) do
			table.insert(prefabnames, name)
			Prefabs[name] = prefab -- copy the prefabs back into the main environment
		end

		print("Mod: "..ModInfoname(mod.modname), "  Registering default mod prefab")

		RegisterPrefabs( Prefab("modbaseprefabs/MOD_"..mod.modname, nil, mod.Assets, prefabnames) )

		local modname = "MOD_"..mod.modname
		TheSim:LoadPrefabs({modname})
		table.insert(self.loadedprefabs, modname)
	end
end

function ModWrangler:UnloadPrefabs()
	for i, modname in ipairs( self.loadedprefabs ) do
		print("unloading prefabs for mod "..ModInfoname(modname))
		TheSim:UnloadPrefabs({modname})
	end
end

function ModWrangler:SetPostEnv()

	local moddetail = ""

	--print("\n\n---MOD INFO SCREEN---\n\n")

	local modnames = ""
	local newmodnames = ""
	local oldmodnames = ""
	local failedmodnames = ""
	local forcemodnames = ""

	if #self.mods > 0 then
		for i,mod in ipairs(self.mods) do
			modprint("###"..mod.modname)
			--dumptable(mod.modinfo)
			if KnownModIndex:IsModNewlyBad(mod.modname) then
				modprint("@NEWLYBAD")
				failedmodnames = failedmodnames.."\""..KnownModIndex:GetModFancyName(mod.modname).."\" "
			elseif KnownModIndex:IsModNewlyOld(mod.modname) and KnownModIndex:WasModEnabled(mod.modname) then
					modprint("@NEWLYOLD")
					oldmodnames = oldmodnames.."\""..KnownModIndex:GetModFancyName(mod.modname).."\" "
				--elseif KnownModIndex:IsModNew(mod.modname) then
					--print("@NEW")
					--newmodnames = newmodnames.."\""..KnownModIndex:GetModFancyName(mod.modname).."\" "
				--end
			elseif KnownModIndex:IsModForceEnabled(mod.modname) then
				modprint("@FORCEENABLED")
				mod.TheFrontEnd = TheFrontEnd
				mod.TheSim = TheSim
				mod.Point = Point
				mod.TheGlobalInstance = TheGlobalInstance

				for i,modfn in ipairs(mod.postinitfns.GamePostInit) do
					runmodfn( modfn, mod, "gamepostinit" )()
				end
	
				forcemodnames = forcemodnames.."\""..KnownModIndex:GetModFancyName(mod.modname).."\" "
			elseif KnownModIndex:IsModEnabled(mod.modname) then
				modprint("@ENABLED")
				mod.TheFrontEnd = TheFrontEnd
				mod.TheSim = TheSim
				mod.Point = Point
				mod.TheGlobalInstance = TheGlobalInstance

				for i,modfn in ipairs(mod.postinitfns.GamePostInit) do
					runmodfn( modfn, mod, "gamepostinit" )()
				end

				modnames = modnames.."\""..KnownModIndex:GetModFancyName(mod.modname).."\" "
			else
				modprint("@DISABLED")
			end
		end
	end

	--print("\n\n---END MOD INFO SCREEN---\n\n")
	if oldmodnames ~= "" then
		moddetail = moddetail.. STRINGS.UI.MAINSCREEN.OLDMODS.." "..oldmodnames.."\n"
	end
	if failedmodnames ~= "" then
		moddetail = moddetail.. STRINGS.UI.MAINSCREEN.FAILEDMODS.." "..failedmodnames.."\n"
	end

	if oldmodnames ~= "" or failedmodnames ~= "" then
		moddetail = moddetail..STRINGS.UI.MAINSCREEN.OLDORFAILEDMODS.."\n\n"
	end

	if newmodnames ~= "" then
		moddetail = moddetail.. STRINGS.UI.MAINSCREEN.NEWMODDETAIL.." "..newmodnames.."\n"..STRINGS.UI.MAINSCREEN.NEWMODDETAIL2.."\n\n"
	end
	if modnames ~= "" then
		moddetail = moddetail.. STRINGS.UI.MAINSCREEN.MODDETAIL.." "..modnames.."\n\n"
	end
	if newmodnames ~= "" or modnames ~= "" then
		moddetail = moddetail.. STRINGS.UI.MAINSCREEN.MODDETAIL2.."\n\n"
	end
	if forcemodnames ~= "" then
		moddetail = moddetail.. STRINGS.UI.MAINSCREEN.FORCEMODDETAIL.." "..forcemodnames.."\n\n"
	end

	if (modnames ~= "" or newmodnames ~= "" or oldmodnames ~= "" or failedmodnames ~= "" or forcemodnames ~= "")  and TheSim:ShouldWarnModsLoaded() then
	--if (#self.enabledmods > 0)  and TheSim:ShouldWarnModsLoaded() then
		TheFrontEnd:PushScreen(
			ScriptErrorScreen(
				STRINGS.UI.MAINSCREEN.MODTITLE, 
				moddetail,
				{
					{text=STRINGS.UI.MAINSCREEN.TESTINGYES, cb = function() TheFrontEnd:PopScreen() end},
					{text=STRINGS.UI.MAINSCREEN.MODQUIT, cb = function()
																	KnownModIndex:DisableAllMods()
																	KnownModIndex:Save(function()
																		SimReset()
																	end)
																end},
					{text=STRINGS.UI.MAINSCREEN.MODFORUMS, nopop=true, cb = function() VisitURL("http://forums.kleientertainment.com/index.php?/forum/26-dont-starve-mods-and-tools/") end }
				}))
	elseif KnownModIndex:WasLoadBad() then
		TheFrontEnd:PushScreen(
			ScriptErrorScreen(
				STRINGS.UI.MAINSCREEN.MODSBADTITLE, 
				STRINGS.UI.MAINSCREEN.MODSBADLOAD,
				{
					{text=STRINGS.UI.MAINSCREEN.TESTINGYES, cb = function() TheFrontEnd:PopScreen() end},
					{text=STRINGS.UI.MAINSCREEN.MODFORUMS, nopop=true, cb = function() VisitURL("http://forums.kleientertainment.com/index.php?/forum/26-dont-starve-mods-and-tools/") end }
				}))
	end

	self:DisplayBadMods()
end

function ModWrangler:SimPostInit(wilson)
	for i,modname in ipairs(self.enabledmods) do
		local mod = self:GetMod(modname)
		for i,modfn in ipairs(mod.postinitfns.SimPostInit) do
			runmodfn( modfn, mod, "simpostinit" )(wilson)
		end
	end

	self:DisplayBadMods()
end

function ModWrangler:GetPostInitFns(type, id)
	local retfns = {}
	for i,modname in ipairs(self.enabledmods) do
		local mod = self:GetMod(modname)
		if mod.postinitfns[type] then
			local modfns = nil
			if id then
				modfns = mod.postinitfns[type][id]
			else
				modfns = mod.postinitfns[type]
			end
			if modfns ~= nil then
				for i,modfn in ipairs(modfns) do
					--print(modname, "added modfn "..type.." for "..tostring(id))
					table.insert(retfns, runmodfn(modfn, mod, id and type..": "..id or type))
				end
			end
		end
	end
	return retfns
end

function ModWrangler:GetPostInitData(type, id)
	local moddata = {}
	for i,modname in ipairs(self.enabledmods) do
		local mod = self:GetMod(modname)
		if mod.postinitdata[type] then
			local data = nil
			if id then
				data = mod.postinitdata[type][id]
			else
				data = mod.postinitdata[type]
			end

			if data ~= nil then
				--print(modname, "added moddata "..type.." for "..tostring(id))
				table.insert(moddata, data)
			end
		end
	end
	return moddata
end

ModManager = ModWrangler()

---------------------------------------------

