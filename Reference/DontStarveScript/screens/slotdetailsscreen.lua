local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"

local BigerPopupDialogScreen = require "screens/bigerpopupdialog"
local PopupDialogScreen = require "screens/popupdialog"
local BigPopupDialogScreen = require "screens/bigpopupdialog"
require "os"

local function ShowLoading()
	if global_loading_widget then 
		global_loading_widget:SetEnabled(true)
	end
end

local SlotDetailsScreen = Class(Screen, function(self, slotnum, worlds)
	Screen._ctor(self, "SlotDetailsScreen")
    self.profile = Profile
    self.saveslot = slotnum

	local mode = SaveGameIndex:GetCurrentMode(slotnum)
	local day = SaveGameIndex:GetSlotDay(slotnum)
	local world = SaveGameIndex:GetSlotWorld(slotnum)
	local character = SaveGameIndex:GetSlotCharacter(slotnum) or "wilson"
	local DLC = SaveGameIndex:GetSlotDLC(slotnum)
	self.RoG = (DLC ~= nil and DLC.REIGN_OF_GIANTS ~= nil) and DLC.REIGN_OF_GIANTS or false
	self.capyDLC = (DLC ~= nil and DLC.CAPY_DLC ~= nil) and DLC.CAPY_DLC or false
	self.porkDLC = (DLC ~= nil and DLC.PORKLAND_DLC ~= nil) and DLC.PORKLAND_DLC or false
	self.character = character

	self.scaleroot = self:AddChild(Widget("scaleroot"))
    self.scaleroot:SetVAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetHAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetPosition(0,0,0)
    self.scaleroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root = self.scaleroot:AddChild(Widget("root"))
    self.root:SetScale(.9)
    self.bg = self.root:AddChild(Image("images/fepanels.xml", "panel_saveslots.tex"))

    if JapaneseOnPS4() then
        self.text = self.root:AddChild(Text(TITLEFONT, 40))
    else
        self.text = self.root:AddChild(Text(TITLEFONT, 50))
    end

    self.text:SetPosition( 75, 135, 0)
    self.text:SetRegionSize(250,60)
    self.text:SetHAlign(ANCHOR_LEFT)

	self.portraitbg = self.root:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
	self.portraitbg:SetPosition(-120, 135, 0)	
	self.portraitbg:SetClickable(false)	

	self.portrait = self.root:AddChild(Image())
	self.portrait:SetClickable(false)		
	local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
	self.portrait:SetTexture(atlas, character..".tex")
	self.portrait:SetPosition(-120, 135, 0)
    
    print("Loading slot",slotnum,"details my DLC is RoG = ", self.RoG, " Capy = ", self.capyDLC, " Pork = ", self.porkDLC)

    local world_count = 0
    
    local shield_imgs = 
    {
    	porkland = "HAMicon.tex",
		shipwrecked = "SWicon.tex",
		survival = SaveGameIndex:ROGEnabledOnSlot(slotnum) and "DLCicon.tex" or "DSicon.tex",
	}

	local used_shields = {}
    for k,v in pairs(worlds) do
    	if v then
    		world_count = world_count + 1
    		table.insert(used_shields, shield_imgs[k])
    	end
    end

    self.dlcindicators = {}
    local x_offset = - (world_count - 1) * 36

    for i=1,world_count do
    	local new_shield = self.root:AddChild(Image())
		new_shield:SetClickable(false)
		new_shield:SetTexture("images/ui.xml", used_shields[i])
		new_shield:SetScale(.75,.75,1)


		new_shield:SetPosition(x_offset, 45, 0)
		x_offset = x_offset + 72

		table.insert(self.dlcindicators, new_shield)
    end

  --   if shield_img then
		-- self.dlcindicator = self.root:AddChild(Image())
		-- self.dlcindicator:SetClickable(false)
		-- self.dlcindicator:SetTexture("images/ui.xml", shield_img)
		-- self.dlcindicator:SetScale(.75,.75,1)
		-- self.dlcindicator:SetPosition(0, 60, 0)
  --   end
      
    self.menu = self.root:AddChild(Menu(nil, -70))
	self.menu:SetPosition(0, -50, 0)
	
	self.default_focus = self.menu
end)

function SlotDetailsScreen:OnBecomeActive()
	self:BuildMenu()
	SlotDetailsScreen._base.OnBecomeActive(self)
end

function SlotDetailsScreen:RestoreSave()
	print("Restore Save")
	TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.SAVEINTEGRATION.WARNING, STRINGS.UI.SAVEINTEGRATION.RESTORATION_DESCRIPTION,
			{{text=STRINGS.UI.SAVEINTEGRATION.YES,
				cb = function()

					local function tileclicked()
						TheFrontEnd:PopScreen()
						TheFrontEnd:PopScreen()
						TheFrontEnd:PopScreen()
						
						SaveGameIndex:RestoreSave(self.backup_index, self.saveslot)
						TheFrontEnd:DoFadeIn(1)
					end

					if SaveGameIndex:GetFirstEmptySlot() ~= nil then
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")	
						TheFrontEnd:Fade(false, 1, function() tileclicked() end)
					else
						TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.SAVEINTEGRATION.NO_EMPTY_SLOTS,  STRINGS.UI.SAVEINTEGRATION.NO_EMPTY_SLOTS_DESCRIPTION,
						{
							{
								text=STRINGS.UI.SAVEINTEGRATION.OK,
								cb = function()
									TheFrontEnd:PopScreen()
									TheFrontEnd:PopScreen()
								end
							}
						}))
					end

				end},
			{text=STRINGS.UI.SAVEINTEGRATION.NO,
				cb = function()
					TheFrontEnd:PopScreen()
				end}
			})
		)
end

function SlotDetailsScreen:BuildMenu()


	local mode = SaveGameIndex:GetCurrentMode(self.saveslot)
	local day = SaveGameIndex:GetSlotDay(self.saveslot)
	local world = SaveGameIndex:GetSlotWorld(self.saveslot)
	local character = SaveGameIndex:GetSlotCharacter(self.saveslot) or "wilson"
	local backup_index = SaveGameIndex:GetSlotBackup(self.saveslot)

    local menuitems = {}
    
    if backup_index ~= nil and BRANCH == "dev" then
    	self.backup_index = backup_index
    	menuitems =
    	{
			{name = STRINGS.UI.SLOTDETAILSSCREEN.CONTINUE, fn = function() self:Continue() end, offset = Vector3(0,20,0)},
			{name = STRINGS.UI.SLOTDETAILSSCREEN.DELETE, fn = function() self:Delete() end},
			{name = STRINGS.UI.SLOTDETAILSSCREEN.CANCEL, fn = function() EnableAllDLC() TheFrontEnd:PopScreen(self) end},
			{name = STRINGS.UI.SAVEINTEGRATION.RESTORE_BUTTON, fn = function() self:RestoreSave() end},
		}
    else
    	menuitems =
	    {
			{name = STRINGS.UI.SLOTDETAILSSCREEN.CONTINUE, fn = function() self:Continue() end, offset = Vector3(0,20,0)},
			{name = STRINGS.UI.SLOTDETAILSSCREEN.DELETE, fn = function() self:Delete() end},
			{name = STRINGS.UI.SLOTDETAILSSCREEN.CANCEL, fn = function() EnableAllDLC() TheFrontEnd:PopScreen(self) end},
		}
	end

	if mode == "adventure" then
		self.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.ADVENTURE, world, day))
	elseif mode == "survival" then
		self.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.SURVIVAL, world, day))
	elseif mode == "cave" then
		self.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.CAVE, world, day))
	elseif mode == "shipwrecked" then
		self.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.SHIPWRECKED, world, day))
	elseif mode == "porkland" then
		self.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.PORKLAND, world, day))
	elseif mode == "volcano" then
		self.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.VOLCANO, world, day))
	else
		--This should only happen if the user has run a mod that created a new type of game mode.
		self.text:SetString(string.format("%s",STRINGS.UI.LOADGAMESCREEN.MODDED))
	end 
    
	self.menu:Clear()

    for k,v in pairs(menuitems) do
    	self.menu:AddItem(v.name, v.fn, v.offset)
    end

    if self.RoG and not IsDLCInstalled(REIGN_OF_GIANTS) then
		for i,j in pairs(self.menu.items) do
			if j:GetText() == STRINGS.UI.SLOTDETAILSSCREEN.CONTINUE then
				j:SetTextColour(0,0,0,.5)
				j:SetTextFocusColour(1,0,0,.75)
				j:SetOnClick(function() self:PushCantContinueDialog(REIGN_OF_GIANTS) end)
			end
		end
	end
    if self.capyDLC and not IsDLCInstalled(CAPY_DLC) then
		for i,j in pairs(self.menu.items) do
			if j:GetText() == STRINGS.UI.SLOTDETAILSSCREEN.CONTINUE then
				j:SetTextColour(0,0,0,.5)
				j:SetTextFocusColour(1,0,0,.75)
				j:SetOnClick(function() self:PushCantContinueDialog(CAPY_DLC) end)
			end
		end
	end

	if self.porkDLC and not IsDLCInstalled(PORKLAND_DLC) then
		for i,j in pairs(self.menu.items) do
			if j:GetText() == STRINGS.UI.SLOTDETAILSSCREEN.CONTINUE then
				j:SetTextColour(0,0,0,.5)
				j:SetTextFocusColour(1,0,0,.75)
				j:SetOnClick(function() self:PushCantContinueDialog(PORKLAND_DLC) end)
			end
		end
	end
end

function SlotDetailsScreen:OnControl( control, down )
	if SlotDetailsScreen._base.OnControl(self, control, down) then return true end
	
	if control == CONTROL_CANCEL and not down then
		TheFrontEnd:PopScreen(self)
		return true
	end
end


function SlotDetailsScreen:Delete()

	local menu_items = 
	{
		-- ENTER
		{
			text=STRINGS.UI.MAINSCREEN.DELETE, 
			cb = function()
				EnableAllDLC()
				TheFrontEnd:PopScreen()
				SaveGameIndex:DeleteSlot(self.saveslot, function() TheFrontEnd:PopScreen() end)
			end
		},
		-- ESC
		{text=STRINGS.UI.MAINSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() self.menu:SetFocus() end},
	}

	TheFrontEnd:PushScreen(
		PopupDialogScreen(STRINGS.UI.MAINSCREEN.DELETE.." "..STRINGS.UI.MAINSCREEN.SLOT.." "..self.saveslot, STRINGS.UI.MAINSCREEN.SURE, menu_items ) )

end

function SlotDetailsScreen:PushCantContinueDialog(index)
	local menu_items = 
	{
		-- OK
		{text=STRINGS.UI.MAINSCREEN.OK, cb = function() TheFrontEnd:PopScreen() self.menu:SetFocus() end},
	}

	local cant_load_strings = 
	{
		[REIGN_OF_GIANTS] = STRINGS.UI.MAINSCREEN.CANT_LOAD_ROG,
		[CAPY_DLC] = STRINGS.UI.MAINSCREEN.CANT_LOAD_CAPY_DLC,
		[PORKLAND_DLC] = STRINGS.UI.MAINSCREEN.CANT_LOAD_PORKLAND_DLC
	}

	TheFrontEnd:PushScreen(
			PopupDialogScreen(STRINGS.UI.MAINSCREEN.CANT_LOAD_TITLE, cant_load_strings[index].." "..STRINGS.UI.MAINSCREEN.SLOT.." "..self.saveslot..".", menu_items ) )
end

function SlotDetailsScreen:CheckForDisabledMods()

	local function isModEnabled(mod, enabledmods)
		for i,v in pairs(enabledmods) do
			if mod == v then
				return true
			end
		end
		return false
	end

	local disabled = {}

	local savedmods = SaveGameIndex:GetSlotMods(self.saveslot)
	local currentlyenabledmods = ModManager:GetEnabledModNames()

	for i,v in pairs(savedmods) do
		if not isModEnabled(v, currentlyenabledmods) and KnownModIndex:IsModCompatibleWithMode(v, self.RoG) then
			table.insert(disabled, v)
		end
	end

	return disabled
end

function SlotDetailsScreen:ShowModalModsDisabledWarning(disabledmods)	
	local maxlistlength = 185
	local maxnamelength = 25
	local message_body = STRINGS.UI.SLOTDETAILSSCREEN.MODSDISABLEDWARNINGBODY_EXPLANATION.."\n"

	local truncated = false
	for i,v in ipairs(disabledmods) do
		local name = KnownModIndex:GetModFancyName(v) or v
		if string.len(name) > maxnamelength then
			name = string.sub(name, 0, maxnamelength)
		end
		if i == 1 then -- No comma for first mod in the list
			message_body = message_body..name
		elseif string.len(message_body..", "..name) <= maxlistlength then -- Subsequent mods get a comma and added, but only if they don't break max size
			message_body = message_body..", "..name
		else
			truncated = true
			break
		end
	end

	if truncated then
		message_body = message_body..STRINGS.UI.SLOTDETAILSSCREEN.MODSDISABLEDWARNINGBODY_TRUNCATEDLIST
	end

	message_body = message_body.."\n\n"..STRINGS.UI.SLOTDETAILSSCREEN.MODSDISABLEDWARNINGBODY_QUESTION

	TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.SLOTDETAILSSCREEN.MODSDISABLEDWARNINGTITLE, message_body, 
			{{text=STRINGS.UI.SLOTDETAILSSCREEN.CONTINUE, 
				cb = function() 
					TheFrontEnd:PopScreen()
					self:Continue(true)
				end},
			{text=STRINGS.UI.SLOTDETAILSSCREEN.CANCEL, 
				cb = function() 
					TheFrontEnd:PopScreen() 
				end}  
			})
		)
end

function SlotDetailsScreen:Continue(force)
	print("Continue Saved Game")
	
	if self.porkDLC and not self.seemEApopup and EARLYACCESS_ON == true then

			self.seemEApopup = true

			TheFrontEnd:PushScreen(
				BigerPopupDialogScreen( STRINGS.UI.EARLYACCESS.EA_TITLE, 
					STRINGS.UI.EARLYACCESS.EA_BODY,
				  {
				  	{
				  		text = STRINGS.UI.EARLYACCESS.CLOSE,
				  		cb = function()			
				  			TheFrontEnd:PopScreen()
				  			self:Continue(force)
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
	else
		self.seemEApopup = nil
		local disabledmods = self:CheckForDisabledMods()
		if #disabledmods == 0 or force then
			self.root:Disable()
			
		    ShowLoading()
			
			TheFrontEnd:Fade(false, 1, function() 
				StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = self.saveslot})
			 end)
		else
			self:ShowModalModsDisabledWarning(disabledmods)
		end
	end
end

function SlotDetailsScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	return TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK
end

return SlotDetailsScreen
