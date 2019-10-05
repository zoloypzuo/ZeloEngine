local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Spinner = require "widgets/spinner"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
require "os"

local WorldGenScreen = require "screens/worldgenscreen"
local CustomizationScreen = require "screens/customizationscreen"
local CharacterSelectScreen = require "screens/characterselectscreen"
local BigPopupDialogScreen = require "screens/bigpopupdialog"
local BigerPopupDialogScreen = require "screens/bigerpopupdialog"
local ComingSoonScreen = require "screens/comingsoonscreen"
local DlcCompatibilityPrompt = require "screens/dlccompatibilityprompt"

local REIGN_OF_GIANTS_DIFFICULTY_WARNING_XP_THRESHOLD = 20*32 --20 xp per day, 32 days

local NewGameScreen = Class(Screen, function(self, slotnum)
	Screen._ctor(self, "NewGameScreen")
    self.profile = Profile
    self.saveslot = slotnum
    self.character = "wilson"

	print("Loading slot",slotnum,"for new game")

   	self.scaleroot = self:AddChild(Widget("scaleroot"))
    self.scaleroot:SetVAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetHAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root = self.scaleroot:AddChild(Widget("root"))
    self.root:SetScale(.9)

    self.bg = self.root:AddChild(Image("images/fepanels.xml", "panel_saveslots.tex"))
    self.bg:SetScale(1.05)

    local TITLE_HEIGHT = 180

    self.title = self.root:AddChild(Text(TITLEFONT, 60))
    self.title:SetPosition( 75, TITLE_HEIGHT, 0)
    self.title:SetRegionSize(250,60)
    self.title:SetHAlign(ANCHOR_LEFT)
	self.title:SetString(STRINGS.UI.NEWGAMESCREEN.TITLE)

	self.portraitbg = self.root:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
	self.portraitbg:SetPosition(-120, TITLE_HEIGHT, 0)
	self.portraitbg:SetClickable(false)

	self.portrait = self.root:AddChild(Image())
	self.portrait:SetClickable(false)
	local atlas = (table.contains(MODCHARACTERLIST, self.character) and "images/saveslot_portraits/"..self.character..".xml") or "images/saveslot_portraits.xml"
	self.portrait:SetTexture(atlas, self.character..".tex")
	self.portrait:SetPosition(-120, TITLE_HEIGHT, 0)
  
  	local menuitems = {}

  	local start_btn = {text = STRINGS.UI.NEWGAMESCREEN.START, cb = function() self:Start() end}
  	local char_btn = {text = STRINGS.UI.NEWGAMESCREEN.CHANGECHARACTER, cb = function() self:ChangeCharacter() end}
  	local world_btn = {text = STRINGS.UI.NEWGAMESCREEN.CUSTOMIZE, cb = function() self:Customize() end}
  	local cancel_btn = {
  		text = STRINGS.UI.NEWGAMESCREEN.CANCEL, cb =
		function()
			if IsDLCInstalled(REIGN_OF_GIANTS) then
				EnableDLC(REIGN_OF_GIANTS)
			end

			if IsDLCInstalled(CAPY_DLC) then
				EnableDLC(CAPY_DLC)
			end

			if IsDLCInstalled(PORKLAND_DLC) then
				EnableDLC(PORKLAND_DLC)
			end

			TheFrontEnd:PopScreen(self)
		end
	}

  	if IsDLCInstalled(REIGN_OF_GIANTS) or IsDLCInstalled(CAPY_DLC) or IsDLCInstalled(PORKLAND_DLC) then
		self.dlc_buttons = {}

		table.insert(self.dlc_buttons, self:MakeVanillaButton())

		if IsDLCInstalled(REIGN_OF_GIANTS) then table.insert(self.dlc_buttons, self:MakeReignOfGiantsButton()) end
		if IsDLCInstalled(CAPY_DLC) then table.insert(self.dlc_buttons, self:MakeCapyButton()) end
		if IsDLCInstalled(PORKLAND_DLC) then table.insert(self.dlc_buttons, self:MakePorklandButton()) end

		table.insert(menuitems, start_btn)

		local xOffset = #self.dlc_buttons >= 2 and -80 or 0
		local yOffset = #self.dlc_buttons >= 2 and 5 or 0
		local yIncrement = #self.dlc_buttons >= 2 and 70 or 0

		local button_count = #self.dlc_buttons == 3 and #self.dlc_buttons - 1 or #self.dlc_buttons

		for i = 1, 2 do --button_count do
			table.insert(menuitems, {widget = self.dlc_buttons[i], offset = Vector3(xOffset, yOffset, 0)})

			xOffset = xOffset * -1
			yOffset = yOffset + yIncrement
		end

		if #self.dlc_buttons == 3 then
			table.insert(menuitems, {widget = self.dlc_buttons[3], offset = Vector3(0, yIncrement + 10, 0)})
			yOffset = yIncrement + 10
		elseif #self.dlc_buttons > 3 then
			table.insert(menuitems, {widget = self.dlc_buttons[3], offset = Vector3(xOffset, yIncrement + 10, 0)})
			yOffset = yIncrement + (yOffset/2) + 6
			table.insert(menuitems, {widget = self.dlc_buttons[4], offset = Vector3(-xOffset, yOffset, 0)})
		else
			yOffset = yIncrement
		end

		char_btn.offset   = Vector3(0, yOffset, 0)
		world_btn.offset  = Vector3(0, yOffset, 0)
		cancel_btn.offset = Vector3(0, yOffset, 0)

		table.insert(menuitems, char_btn)
		table.insert(menuitems, world_btn)
		table.insert(menuitems, cancel_btn)

		-- these get used in menu.lua
		start_btn.disable = true
		char_btn.disable = true
		world_btn.disable = true

  	else
  		menuitems =
	    {
			start_btn,
			char_btn,
			world_btn,
			cancel_btn,
	    }
  	end

    self.menu = self.root:AddChild(Menu(menuitems, -70))
	self.menu:SetPosition(0, TITLE_HEIGHT - 100, 0)

	self.default_focus = self.menu

end)

function NewGameScreen:OnGainFocus()
	NewGameScreen._base.OnGainFocus(self)
	self.menu:SetFocus()
end

function NewGameScreen:OnControl(control, down)
    if Screen.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:PopScreen(self)
        return true
    end
end

function NewGameScreen:SetSavedCustomOptions(options)
	if self.savedcustomoptions == nil then
		self.savedcustomoptions = {}
	end

	local currentdlc = MAIN_GAME
	local dlcs = {PORKLAND_DLC, CAPY_DLC, REIGN_OF_GIANTS, MAIN_GAME}
	for _, dlc in ipairs(dlcs) do
		if IsDLCInstalled(dlc) and IsDLCEnabled(dlc) then
			currentdlc = dlc
		end
	end
	self.savedcustomoptions[self:GetEnabledWorldIndex()] = options
end

function NewGameScreen:GetSavedCustomOptions()
	if self.savedcustomoptions == nil then
		self.savedcustomoptions = {}
	end

	print ("GETTING CUSTOM OPTIONS FOR ", self:GetEnabledWorldIndex())

	return self.savedcustomoptions[self:GetEnabledWorldIndex()]
end

function NewGameScreen:Customize()
	
	local function onSet(options, dlc)
		TheFrontEnd:PopScreen()

		if options then
			self:SetSavedCustomOptions(options)
			self.customoptions = options
		end
	end

	self.customoptions = self:GetSavedCustomOptions()
	package.loaded["map/customise"] = nil

	-- Clean up the preset setting since we're going back to customization screen, not to worldgen
	if self.customoptions and self.customoptions.actualpreset then
		self.customoptions.preset = self.customoptions.actualpreset
		self.customoptions.actualpreset = nil
	end
	-- Clean up the tweak table since we're going back to customization screen, not to worldgen
	if self.customoptions and self.customoptions.faketweak and self.customoptions.tweak and #self.customoptions.faketweak > 0 then
		for i,v in pairs(self.customoptions.faketweak) do
			for m,n in pairs(self.customoptions.tweak) do
				for j,k in pairs(n) do
					if v == j then -- Found the fake tweak setting, now remove it from the table
						self.customoptions.tweak[m][j] = nil
						break
					end
				end
			end
		end
	end

	TheFrontEnd:PushScreen(CustomizationScreen(Profile, onSet, self.customoptions, (self.RoG_btn and self.RoG_btn.is_enabled), nil, self:GetEnabledWorld()))--self.customization)
end

function NewGameScreen:ChangeCharacter()
	
	local function onSet(character, random)
		TheFrontEnd:PopScreen()
		if character and (IsDLCInstalled(REIGN_OF_GIANTS) or IsDLCInstalled(CAPY_DLC) or IsDLCInstalled(PORKLAND_DLC)) then
			package.loaded["map/customise"] = nil

			self.prevcharacter = nil
			self.characterreverted = false
			self.character = character

			local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
			self.portrait:SetTexture(atlas, self.character..".tex")
			if random then
				atlas = "images/saveslot_portraits.xml"
				self.portrait:SetTexture(atlas, "random.tex")
			end
		elseif character then
			self.character = character
			local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
			self.portrait:SetTexture(atlas, self.character..".tex")
			if random then
				atlas = "images/saveslot_portraits.xml"
				self.portrait:SetTexture(atlas, "random.tex")
			end
		end
	end

	TheFrontEnd:PushScreen(CharacterSelectScreen(Profile, onSet, false, self.character, (self.RoG_btn and self.RoG_btn.is_enabled)))
end

function NewGameScreen:GetEnabledWorld()
	local enabled_worlds =
	{
		MAIN_GAME = self.Vanilla_btn and self.Vanilla_btn.is_enabled,
		REIGN_OF_GIANTS = self.RoG_btn and self.RoG_btn.is_enabled,
		CAPY_DLC = self.CapyDLC_btn and self.CapyDLC_btn.is_enabled,
		PORKLAND_DLC = self.PorklandDLC_btn and self.PorklandDLC_btn.is_enabled
	}

	for k,v in pairs(enabled_worlds) do
		if v then
			return k
		end
	end

	if not (self.Vanilla_btn or self.RoG_btn or self.CapyDLC_btn or self.PorklandDLC_btn) then
		return "MAIN_GAME"
	end
end

function NewGameScreen:GetEnabledWorldIndex()
	local enabled_world = self:GetEnabledWorld()
	local world_indexes =
	{
		MAIN_GAME = 0,
		REIGN_OF_GIANTS = 1,
		CAPY_DLC = 2,
		PORKLAND_DLC = 3,
	}

	return world_indexes[enabled_world]
end

function NewGameScreen:GetEnabledDLCs()
	local dlc = 
	{
		REIGN_OF_GIANTS = IsDLCEnabled(REIGN_OF_GIANTS),
		CAPY_DLC = IsDLCEnabled(CAPY_DLC),
		PORKLAND_DLC = IsDLCEnabled(PORKLAND_DLC)
	}
	return dlc
end

function NewGameScreen:Start()
	local function onsaved()
	    StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = self.saveslot})
	end

	local function CleanupTweakTable()
		-- Clean up the tweak table since we don't want "default" overrides
		if self.customoptions and self.customoptions.faketweak and self.customoptions.tweak and #self.customoptions.faketweak > 0 then
			for i,v in pairs(self.customoptions.faketweak) do
				for m,n in pairs(self.customoptions.tweak) do
					for j,k in pairs(n) do
						if v == j and k == "default" then -- Found the fake tweak setting for "default", now remove it from the table
							self.customoptions.tweak[m][j] = nil
							break
						end
					end
				end
			end
		end
	end

	local function StartGame(mode)
		self.seemEApopup = nil

		local savedcustomoptions = self:GetSavedCustomOptions()

		if savedcustomoptions then
			local ROGEnabled = self.customoptions.ROGEnabled
			self.customoptions = savedcustomoptions
			self.customoptions.ROGEnabled = ROGEnabled
		else
			self.customoptions = {}
			self.customoptions.ROGEnabled = (self.RoG_btn and self.RoG_btn.is_enabled)
		end

		CleanupTweakTable()
		self.root:Disable()

		local enabled_dlc = self:GetEnabledDLCs()

		TheFrontEnd:Fade(false, 1, function()
			SaveGameIndex:StartSurvivalMode(self.saveslot, self.character, self.customoptions, onsaved, enabled_dlc, mode)
		end )
	end

	local xp = Profile:GetXP()

	local enabled_dlc = self:GetEnabledDLCs()
	if enabled_dlc["PORKLAND_DLC"] and not self.seemEApopup and EARLYACCESS_ON then

			self.seemEApopup = true

			TheFrontEnd:PushScreen(
				BigerPopupDialogScreen( STRINGS.UI.EARLYACCESS.EA_TITLE, 
					STRINGS.UI.EARLYACCESS.EA_BODY,
				  {
				  	{
				  		text = STRINGS.UI.EARLYACCESS.CLOSE,
				  		cb = function()			
				  			TheFrontEnd:PopScreen()
				  			self:Start()
						end
					},

				  	{
				  		text = STRINGS.UI.EARLYACCESS.OPEN_FORUMS,
				  		cb = function()
				  			VisitURL("https://forums.kleientertainment.com/forums/forum/195-dont-starve-hamlet-closed-beta/")
						end
					},
				  }
				)
			)
	
	elseif IsDLCInstalled(REIGN_OF_GIANTS) and (self.RoG_btn and self.RoG_btn.is_enabled) and xp <= REIGN_OF_GIANTS_DIFFICULTY_WARNING_XP_THRESHOLD and not Profile:HaveWarnedDifficultyRoG() then
		TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.NEWGAMESCREEN.ROG_WARNING_TITLE, STRINGS.UI.NEWGAMESCREEN.ROG_WARNING_BODY, 
			{{text=STRINGS.UI.NEWGAMESCREEN.YES,
				cb = function() 
					Profile:SetHaveWarnedDifficultyRoG()
					TheFrontEnd:PopScreen()
					self:Start()
				end},
			{text=STRINGS.UI.NEWGAMESCREEN.NO,
				cb = function()
					TheFrontEnd:PopScreen()
				end}
			})
		)
	elseif IsDLCInstalled(CAPY_DLC) and self.CapyDLC_btn and self.CapyDLC_btn.is_enabled then
		StartGame("shipwrecked")
	elseif IsDLCInstalled(PORKLAND_DLC) and self.PorklandDLC_btn and self.PorklandDLC_btn.is_enabled then
		StartGame("porkland")
	else
		StartGame("survival")
	end
end

function NewGameScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	return TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK
end

function NewGameScreen:MakeDLCButton( dlc_index, dlc_icon )

	local function SetForDLCGeneration(DLC)
		DisableAllDLC()
		EnableDLC(DLC)

        if self.customoptions == nil then
        	self.customoptions = {}
        end

        self.customoptions.ROGEnabled = self.RoG_btn and self.RoG_btn.is_enabled
	end

	local function PromptPlayerWithPORKCompatibility()
		
		local desc = STRINGS.UI.SAVEINTEGRATION.PORK_COMP_SW_DESCRIPTION
		TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.SAVEINTEGRATION.PORK_COMP, desc,
			{{text=STRINGS.UI.SAVEINTEGRATION.YES,
				cb = function()
					SetForDLCGeneration(PORKLAND_DLC)
					TheFrontEnd:PopScreen()
				end
			},
			{text=STRINGS.UI.SAVEINTEGRATION.NO,
				cb = function()
					TheFrontEnd:PopScreen()
				end
			},
			}, nil, 165, Vector3(0, 155, 0))
		)
	end

	local function PromptPlayerWithSWCompatibility()
		local enable_rog = self.RoG_btn and self.RoG_btn.is_enabled
		local desc = enable_rog and STRINGS.UI.SAVEINTEGRATION.SW_COMP_ROG_DESCRIPTION or STRINGS.UI.SAVEINTEGRATION.SW_COMP_DESCRIPTION

		TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.SAVEINTEGRATION.SW_COMP, desc,
			{{text=STRINGS.UI.SAVEINTEGRATION.YES,
				cb = function()
					SetForDLCGeneration(CAPY_DLC)
					TheFrontEnd:PopScreen()
				end
			},
			{text=STRINGS.UI.SAVEINTEGRATION.NO,
				cb = function()
					TheFrontEnd:PopScreen()
				end
			},
			}, nil, 165, Vector3(0, 155, 0))
		)
	end

	local function PromptPlayerWithDoubleCompatibility()
		TheFrontEnd:PushScreen( DlcCompatibilityPrompt(
			function(prompt)

				local selected_dlc = prompt:GetEnabledDLC()

				if selected_dlc == CAPY_DLC then
					DisableDLC(REIGN_OF_GIANTS)
					SetForDLCGeneration(CAPY_DLC)
				elseif selected_dlc == PORKLAND_DLC then
					DisableDLC(REIGN_OF_GIANTS)
					SetForDLCGeneration(PORKLAND_DLC)
				end

				TheFrontEnd:PopScreen()
			end)
		)
	end

	local dlc_btn = self:AddChild(Widget("option"))
	dlc_btn.image = dlc_btn:AddChild(Image("images/ui.xml", dlc_icon))
	dlc_btn.image:SetPosition(25,0,0)
	dlc_btn.image:SetTint(1,1,1,.3)

	dlc_btn.checkbox = dlc_btn:AddChild(Image("images/ui.xml", "button_checkbox1.tex"))
	dlc_btn.checkbox:SetPosition(-35,0,0)
	dlc_btn.checkbox:SetScale(0.5,0.5,0.5)
	dlc_btn.checkbox:SetTint(1.0,0.5,0.5,1)

	dlc_btn.bg = dlc_btn:AddChild(UIAnim())
	dlc_btn.bg:GetAnimState():SetBuild("savetile_small")
	dlc_btn.bg:GetAnimState():SetBank("savetile_small")
	dlc_btn.bg:GetAnimState():PlayAnimation("anim")
	dlc_btn.bg:SetPosition(-75,0,0)
	dlc_btn.bg:SetScale(1.12,1,1)

	dlc_btn.OnGainFocus = function()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
			dlc_btn:SetScale(1.1,1.1,1)
			dlc_btn.bg:GetAnimState():PlayAnimation("over")
		end

	dlc_btn.OnLoseFocus = function()
			dlc_btn:SetScale(1,1,1)
			dlc_btn.bg:GetAnimState():PlayAnimation("anim")
		end

	dlc_btn.OnControl = function(_, control, down)
		if Widget.OnControl(dlc_btn, control, down) then return true end
		if control == CONTROL_ACCEPT and not down then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			dlc_btn.is_enabled = not dlc_btn.is_enabled

			dlc_btn.enable()
			for i,v in ipairs(self.dlc_buttons) do
				if v.dlc_index ~= dlc_btn.dlc_index then
					v.disable()
				end
			end

			return true
		end
	end

	dlc_btn.enable = function()
		dlc_btn.is_enabled = true
		dlc_btn.checkbox:SetTint(1,1,1,1)
		dlc_btn.image:SetTint(1,1,1,1)
		dlc_btn.checkbox:SetTexture("images/ui.xml", "button_checkbox2.tex")
		--self:RestoreCharacter()
		EnableDLC(dlc_btn.dlc_index)

		local pork_installed = IsDLCInstalled(PORKLAND_DLC)
		local sw_installed =   IsDLCInstalled(CAPY_DLC)
		local rog_installed =  IsDLCInstalled(REIGN_OF_GIANTS)

		if dlc_index == PORKLAND_DLC then 
			self:HamletWarning()
		elseif dlc_index == CAPY_DLC and pork_installed then
			PromptPlayerWithPORKCompatibility()
		else
			if pork_installed and sw_installed then
				PromptPlayerWithDoubleCompatibility()
			elseif pork_installed then
				PromptPlayerWithPORKCompatibility()
			elseif sw_installed and dlc_index ~= CAPY_DLC then
				PromptPlayerWithSWCompatibility()
			end
		end

		-- Enables the world customization and start buttons
		self.menu:SetItemEnabled(1, true)
		self.menu:SetItemEnabled(#self.dlc_buttons + 2, true)
		self.menu:SetItemEnabled(#self.dlc_buttons + 3, true)
	end

	dlc_btn.disable = function()
		dlc_btn.is_enabled = false
		dlc_btn.checkbox:SetTint(1.0,0.5,0.5,1)
		dlc_btn.image:SetTint(1,1,1,.3)
		dlc_btn.checkbox:SetTexture("images/ui.xml", "button_checkbox1.tex")
		--self:RevertCharacter()
		DisableDLC(dlc_btn.dlc_index)
	end

	dlc_btn.GetHelpText = function()
		local controller_id = TheInput:GetControllerID()
		local t = {}
	    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.TOGGLE)
		return table.concat(t, "  ")
	end

	dlc_btn.set_enabled = function (enabled)
		if enabled then
			dlc_btn.enable()
		else
			dlc_btn.disable()
		end
	end

	dlc_btn.dlc_index = dlc_index
	dlc_btn.set_enabled(IsDLCEnabled(dlc_index))

	return dlc_btn
end

-- function NewGameScreen:RevertCharacter()
-- 	if self.character == "wathgrithr" or self.character == "webber" then --Switch to Wilson if currently have DLC char selected
-- 		self.characterreverted = true
-- 		self.prevcharacter = self.character
-- 		self.character = "wilson"
-- 		local atlas = (table.contains(MODCHARACTERLIST, self.character) and "images/saveslot_portraits/"..self.character..".xml") or "images/saveslot_portraits.xml"
-- 		self.portrait:SetTexture(atlas, self.character..".tex")
-- 	end
-- end

-- function NewGameScreen:RestoreCharacter()
-- 	if self.characterreverted == true and self.prevcharacter ~= nil then --Switch back to DLC character if possible
-- 		self.character = self.prevcharacter
-- 		self.prevcharacter = nil
-- 		self.characterreverted = false
-- 		local atlas = (table.contains(MODCHARACTERLIST, self.character) and "images/saveslot_portraits/"..self.character..".xml") or "images/saveslot_portraits.xml"
-- 		self.portrait:SetTexture(atlas, self.character..".tex")
-- 	end
-- end

function NewGameScreen:MakeReignOfGiantsButton()
	DisableAllDLC()
	self.RoG_btn = self:MakeDLCButton(REIGN_OF_GIANTS, "DLCicontoggle.tex")
	return self.RoG_btn
end

function NewGameScreen:MakeCapyButton()
	DisableAllDLC()
	self.CapyDLC_btn = self:MakeDLCButton(CAPY_DLC, "SWicontoggle.tex")
	
	return self.CapyDLC_btn
end

function NewGameScreen:MakePorklandButton()
	DisableAllDLC()
	self.PorklandDLC_btn = self:MakeDLCButton(PORKLAND_DLC, "pork_icon.tex")
	return self.PorklandDLC_btn
end

function NewGameScreen:MakeVanillaButton()
	DisableAllDLC()
	self.Vanilla_btn = self:MakeDLCButton(MAIN_GAME, "DS_icon.tex")
	return self.Vanilla_btn
end

function NewGameScreen:HamletWarning()

	if not self.alreadyViewedHamletWarningPopup and not Profile:GetHamletClicked() then
		self.alreadyViewedHamletWarningPopup = true

		Profile:SetHamletClicked(true)
		Profile:Save(function() end)

		TheFrontEnd:PushScreen(
			BigPopupDialogScreen( STRINGS.UI.NEWGAMESCREEN.HAMLET_WARNING_TITLE,
			  STRINGS.UI.NEWGAMESCREEN.HAMLET_WARNING_BODY,
			  {{
			  		text = STRINGS.UI.NEWGAMESCREEN.CLOSE,
			  		cb = function()
			  			TheFrontEnd:PopScreen()
					end
			  }}
			)
		)
	end
end

return NewGameScreen