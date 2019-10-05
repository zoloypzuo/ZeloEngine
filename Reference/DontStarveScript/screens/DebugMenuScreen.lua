require "util"
require "consolecommands"

local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Widget = require "widgets/widget"

local RunningProfilePopup = require "screens/runningprofilepopup"

local menus = require "debugmenu"

local time_warp =1
local DebugMenuScreen = Class(Screen, function(self)
	Screen._ctor(self, "DebugMenuScreen")

   	self.blackoverlay = self:AddChild(Image("images/global.xml", "square.tex"))
    self.blackoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.blackoverlay:SetClickable(false)
	self.blackoverlay:SetTint(0,0,0,.75)

	self.text = self:AddChild(Text(BODYTEXTFONT, 16, "blah"))
	self.text:SetVAlign(ANCHOR_TOP)
	self.text:SetHAlign(ANCHOR_LEFT)
    self.text:SetVAnchor(ANCHOR_MIDDLE)
    self.text:SetHAnchor(ANCHOR_MIDDLE)
	self.text:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self.text:SetRegionSize(900, 700)
	self.text:SetPosition(0,0,0)

	TheFrontEnd:HideConsoleLog()
end)



local map_reveal = false
local free_craft = false

function DebugMenuScreen:OnBecomeActive()
	DebugMenuScreen._base.OnBecomeActive(self)
	SetPause(true,"console")	

	self.menu = menus.TextMenu(InGamePlay() and "IN GAME DEBUG MENU" or "FRONT END DEBUG MENU")
	local main_options = {}


	local map = TheSim:FindFirstEntityWithTag("minimap")
	local god = false


	local craft_menus = {}
	local valid_recipes = GetAllRecipes()
	for k,v in pairs(valid_recipes) do
		craft_menus[v.tab] = craft_menus[v.tab] or {}
		table.insert(craft_menus[v.tab], menus.DoAction(v.name, function() for kk,vv in pairs(v.ingredients) do c_give(vv.type, vv.amount) end end))
	end

	local spawncraft = {}
	for k,v in pairs(craft_menus) do
		table.insert(spawncraft, menus.Submenu(k.str, v))
	end


	local bars = {
		menus.NumericToggle("Health", 1, 100, function() return math.floor(GetPlayer().components.health:GetPercent()*100) end, function(val) GetPlayer().components.health:SetPercent(val/100) end,5),
		menus.NumericToggle("Sanity", 1, 100, function() return math.floor(GetPlayer().components.sanity:GetPercent()*100) end, function(val) GetPlayer().components.sanity:SetPercent(val/100) end,5),
		menus.NumericToggle("Hunger", 1, 100, function() return math.floor(GetPlayer().components.hunger:GetPercent()*100) end, function(val) GetPlayer().components.hunger:SetPercent(val/100) end,5)
	}
	local timecontrol = {
		menus.NumericToggle("Adjust Time Warp", 0, 4, function() return time_warp end, function(val) time_warp = val end,.25),
		menus.DoAction("Advance Day", function() LongUpdate(TUNING.TOTAL_DAY_TIME, true) end),
		menus.DoAction("Advance Segment", function() LongUpdate(TUNING.TOTAL_DAY_TIME / 16, true) end)
	}
	local teleport = {
		menus.DoAction("Eyebone", function() c_gonext("chester_eyebone") self:Close() end),
		menus.DoAction("Maxwell Door", function() c_gonext("adventure_portal") self:Close() end),
		menus.DoAction("Cave Entrance", function() c_gonext("cave_entrance") self:Close() end),
		menus.DoAction("Cave Exit", function() c_gonext("cave_exit") self:Close() end),
	}

	local allprefabs = {}
	for k, v in pairs(Prefabs) do
		local can_spawn = not string.find(v.name, "blueprint") and not string.find(v.name, "placer")
		if v.name == "forest" or v.name == "cave" then can_spawn = false end
		if can_spawn then
			table.insert(allprefabs, v.name)
		end
	end
	table.sort(allprefabs)

	local PER_PAGE = 30
	local spawn_lists = {}
	local current = {}
	for k = 1, #allprefabs do
		table.insert(current, allprefabs[k])
		
		if k % PER_PAGE == 0 then
			table.insert(spawn_lists, current)
			current = {}
		end
	end
	if #current > 0 then
		table.insert(spawn_lists, current)
	end
	current = nil
	local spawn = {}

	for k,v in pairs(spawn_lists) do
		local inner_list = {}
		for kk, vv in pairs(v) do
			table.insert(inner_list, menus.DoAction(vv, function() DebugSpawn(vv).Transform:SetPosition(GetPlayer().Transform:GetWorldPosition()) end))
		end
		table.insert(spawn, menus.Submenu(v[1] .. " thru " .. v[#v], inner_list))
	end


	local weathercontrol = {
		menus.CheckBox("Toggle Precipitation", function() return GetSeasonManager().precip end, 
			function(val) 
				if val then 
					GetSeasonManager().atmo_moisture = GetSeasonManager().moisture_limit*2 GetSeasonManager():OnUpdate(0)
				else
					GetSeasonManager().atmo_moisture = 0 GetSeasonManager():OnUpdate(0)
				end
			end),
			menus.CheckBox("Toggle Winter", function() return GetSeasonManager():IsWinter() end,
			function(val)
				if val then
					GetSeasonManager():StartWinter()
					GetSeasonManager().percent_season = .5
				else
					GetSeasonManager():StartSummer()
					GetSeasonManager().percent_season = .5
				end
			end)
	}


	if InGamePlay() then
		table.insert(main_options, menus.CheckBox("Toggle God Mode", function() return god end, function(val) god = val GetPlayer().components.health:SetInvincible(god) end))		
		table.insert(main_options, menus.CheckBox("Toggle Reveal Map", function() return map_reveal end, function(val) map_reveal = val map.MiniMap:EnableFogOfWar(not map_reveal) end))		
		table.insert(main_options, menus.CheckBox("Toggle Free Crafting", function() return free_craft end, function(val) free_craft = val GetPlayer().components.builder:GiveAllRecipes() GetPlayer():PushEvent("techlevelchange") end))		
		table.insert(main_options, menus.DoAction("Run Profiler", function() self:Close() self:RunProfiler() end ))
		table.insert(main_options, menus.Submenu("Teleport", teleport))
		table.insert(main_options, menus.Submenu("Time Control", timecontrol))
		table.insert(main_options, menus.Submenu("Weather Control", weathercontrol))
		table.insert(main_options, menus.Submenu("Player Bars", bars))
		table.insert(main_options, menus.Submenu("Spawn", spawn))
		table.insert(main_options, menus.Submenu("Give Ingredients for", spawncraft))
	else


		local adv_slot = 1
		local adventure_mode_menu = {menus.NumericToggle("Overwrite Slot:", 1, 4, function() return adv_slot end, function(v) adv_slot = v end)}

		for k = 1, 7 do

			local opt = menus.DoAction(STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[k], function()
				local function onstart()
					StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = adv_slot})
				end
				SaveGameIndex:FakeAdventure(onstart, adv_slot, k)
			end)

			table.insert(adventure_mode_menu, opt)
		end

		table.insert(main_options, menus.DoAction("Unlock All Characters", function() Profile:UnlockEverything() self:Close() end ))
		table.insert(main_options, menus.DoAction("Reset Profile", function() Profile:Reset() self:Close() end ))
		table.insert(main_options, menus.Submenu("Test Adventure Level", adventure_mode_menu, "Pick A level"))
	end

	table.insert(main_options, menus.DoAction("Restart", function() StartNextInstance() self:Close() end ))


	self.menu:PushOptions(main_options, "")

	self.text:SetString(tostring(self.menu))

end

function DebugMenuScreen:RunProfiler()
	local RECORD_SECONDS = 3
	TheFrontEnd:PushScreen(RunningProfilePopup(RECORD_SECONDS, function() --[[pass]] end))
end

function DebugMenuScreen:OnControl(control, down)
	if DebugMenuScreen._base.OnControl(self, control, down) then return true end

	if not down and control == CONTROL_OPEN_DEBUG_MENU then 
		self:Close()
		return true
	end

	if not down then
		if control == CONTROL_CANCEL then
			if not self.menu:Cancel() then
				self:Close()
			end
		elseif control == CONTROL_ACCEPT then
			self.menu:Accept()
		else
			return false
		end
	else
		if control == CONTROL_INVENTORY_UP or control == CONTROL_FOCUS_UP then
			self.menu:Up()
		elseif control == CONTROL_INVENTORY_DOWN or control == CONTROL_FOCUS_DOWN then
			self.menu:Down()
		elseif control == CONTROL_INVENTORY_LEFT or control == CONTROL_FOCUS_LEFT then
			self.menu:Left()
		elseif control == CONTROL_INVENTORY_RIGHT or control == CONTROL_FOCUS_RIGHT then
			self.menu:Right()
		else
			return false
		end
	end

	self.text:SetString(tostring(self.menu))
	return true
end

function DebugMenuScreen:Close()
	SetPause(false)
	TheSim:SetTimeScale(time_warp)
	TheFrontEnd:PopScreen()
end

return DebugMenuScreen
