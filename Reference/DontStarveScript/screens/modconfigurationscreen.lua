require "util"
require "strings"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local Widget = require "widgets/widget"

local PopupDialogScreen = require "screens/popupdialog"

local text_font = UIFONT

local enableDisableOptions = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }
local spinnerFont = { font = BUTTONFONT, size = 30 }

local COLS = 2
local ROWS_PER_COL = 7

local options = {}

local ModConfigurationScreen = Class(Screen, function(self, modname)
	Screen._ctor(self, "ModConfigurationScreen")
	self.modname = modname
	self.config = KnownModIndex:LoadModConfigurationOptions(modname)

	self.left_spinners = {}
	self.right_spinners = {}
	options = {}
	
	if self.config and type(self.config) == "table" then
		for i,v in ipairs(self.config) do
			-- Only show the option if it matches our format exactly
			if v.name and v.options and (v.saved ~= nil or v.default ~= nil) then 
				table.insert(options, {name = v.name, label = v.label, options = v.options, default = v.default, value = v.saved})
			end
		end
	end

	self.started_default = self:IsDefaultSettings()
	
	self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))

	SetBGcolor(self.bg)

    
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    
	self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    	
    local shield = self.root:AddChild( Image( "images/globalpanels.xml", "panel.tex" ) )
	shield:SetPosition( 0,0,0 )
	shield:SetSize( 1000, 700 )		

	local titlestr = KnownModIndex:GetModFancyName(modname)
	local maxtitlelength = 26
	if titlestr:len() > maxtitlelength then
		titlestr = titlestr:sub(1, maxtitlelength)
	end
	titlestr = titlestr.." "..STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX
	local title = self.root:AddChild( Text(TITLEFONT, 50, titlestr) )
	title:SetPosition(0,210)
	title:SetColour(1,1,1,1)

	self.option_offset = 0
    self.optionspanel = self.root:AddChild(Widget("optionspanel"))	
    self.optionspanel:SetPosition(0,-20)

	self.menu = self.root:AddChild(Menu(nil, 0, false))
	self.applybutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.APPLY, function() self:Apply() end, Vector3(-260, -290, 0))
	self.cancelbutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.CANCEL, function() self:Cancel() end,  Vector3(-110, -290, 0))
	self.resetbutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.RESETDEFAULT, function() self:ResetToDefaultValues() end,  Vector3(205, -290, 0))
	self.applybutton:SetScale(.9)
	self.cancelbutton:SetScale(.9)
	self.resetbutton:SetScale(.9)
	self.applybutton:SetFocusChangeDir(MOVE_RIGHT, self.cancelbutton)
	self.cancelbutton:SetFocusChangeDir(MOVE_LEFT, self.applybutton)
	self.cancelbutton:SetFocusChangeDir(MOVE_RIGHT, self.resetbutton)
	self.resetbutton:SetFocusChangeDir(MOVE_LEFT, self.cancelbutton)

	self.default_focus = self.applybutton
	self.dirty = false

	self.rightbutton = self.optionspanel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.rightbutton:SetPosition(440, 0, 0)
    self.rightbutton:SetScale(.9)
    self.rightbutton:SetOnClick( function() self:Scroll(ROWS_PER_COL) end)
    if #options <= ROWS_PER_COL * COLS then -- Only show the arrow if we have a ton of options
		self.rightbutton:Hide()
	end
	
	self.leftbutton = self.optionspanel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.leftbutton:SetPosition(-440, 0, 0)
    self.leftbutton:SetScale(-.9,.9,.9)
    self.leftbutton:SetOnClick( function() self:Scroll(-ROWS_PER_COL) end)	
    self.leftbutton:Hide()

    self.optionwidgets = {}

    self:RefreshOptions()
end)

function ModConfigurationScreen:CollectSettings()
	local settings = nil
	for i,v in pairs(options) do
		if not settings then settings = {} end
		table.insert(settings, {name=v.name, label = v.label, options=v.options, default=v.default, saved=v.value})
	end
	return settings
end

function ModConfigurationScreen:ResetToDefaultValues()
	local function reset()
		for i,v in pairs(options) do
			options[i].value = options[i].default
		end
		self:RefreshOptions()
	end

	if not self:IsDefaultSettings() then
		self:ConfirmRevert(function() 
			TheFrontEnd:PopScreen()
			self:MakeDirty()
			reset()
		end)
	end
end

function ModConfigurationScreen:Apply()
	if self:IsDirty() then
		local settings = self:CollectSettings()
		KnownModIndex:SaveConfigurationOptions(function() self:MakeDirty(false) TheFrontEnd:PopScreen() end, self.modname, settings)
	else
		self:MakeDirty(false)
		TheFrontEnd:PopScreen()
	end
end

function ModConfigurationScreen:ConfirmRevert(callback)
	TheFrontEnd:PushScreen(
		PopupDialogScreen( STRINGS.UI.MODSSCREEN.BACKTITLE, STRINGS.UI.MODSSCREEN.BACKBODY,
		  { 
		  	{ 
		  		text = STRINGS.UI.MODSSCREEN.YES, 
		  		cb = callback or function() TheFrontEnd:PopScreen() end
			},
			{ 
				text = STRINGS.UI.MODSSCREEN.NO, 
				cb = function()
					TheFrontEnd:PopScreen()					
				end
			}
		  }
		)
	)		
end

function ModConfigurationScreen:Cancel()
	if self:IsDirty() and not (self.started_default and self:IsDefaultSettings()) then
		self:ConfirmRevert(function()
			TheFrontEnd:PopScreen()
			self:MakeDirty(false)
			self:Cancel()
		end)
	else
		self:MakeDirty(false)
		TheFrontEnd:PopScreen()
	end
end

function ModConfigurationScreen:MakeDirty(dirty)
	if dirty ~= nil then
		self.dirty = dirty
	else
		self.dirty = true
	end
end

function ModConfigurationScreen:IsDefaultSettings()
	local alldefault = true
	for i,v in pairs(options) do
		if options[i].value ~= options[i].default then
			alldefault = false
			break
		end
	end
	return alldefault
end

function ModConfigurationScreen:IsDirty()
	return self.dirty
end

function ModConfigurationScreen:OnControl(control, down)
    if ModConfigurationScreen._base.OnControl(self, control, down) then return true end
    
    if not down then
	    if control == CONTROL_CANCEL then
			self:Cancel()
	    elseif control == CONTROL_ACCEPT and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
	    	self:Apply() --apply changes and go back, or stay
	    elseif control == CONTROL_PAGELEFT then
    		if self.leftbutton.shown then
    			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
    			self:Scroll(-ROWS_PER_COL)
    		end
    	elseif control == CONTROL_PAGERIGHT then
    		if self.rightbutton.shown then
    			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
    			self:Scroll(ROWS_PER_COL)
    		end
    	else
    		return false
    	end 

    	return true
	end
end

function ModConfigurationScreen:Scroll(dir)
	if (dir > 0 and (self.option_offset + ROWS_PER_COL*2) < #options) or
		(dir < 0 and self.option_offset + dir >= 0) then
	
		self.option_offset = self.option_offset + dir
	end
	
	if self.option_offset > 0 then
		self.leftbutton:Show()
	else
		self.leftbutton:Hide()
	end
	
	if self.option_offset + ROWS_PER_COL*2 < #options then
		self.rightbutton:Show()
	else
		self.rightbutton:Hide()
	end
	
	self:RefreshOptions()
end

function ModConfigurationScreen:RefreshOptions()

	local focus = self:GetDeepestFocus()
	local old_column = focus and focus.column
	local old_idx = focus and focus.idx
	
	for k,v in pairs(self.optionwidgets) do
		v.root:Kill()
	end
	self.optionwidgets = {}

	self.left_spinners = {}
	self.right_spinners = {}

	for k = 1, ROWS_PER_COL*2 do
	
		local idx = self.option_offset+k
		
		if options[idx] then
			
			local spin_options = {} --{{text="default"..tostring(idx), data="default"},{text="2", data="2"}, }
			for k,v in ipairs(options[idx].options) do
				table.insert(spin_options, {text=v.description, data=v.data})
			end
			
			local opt = self.optionspanel:AddChild(Widget("option"))
			
			local spin_height = 50
			local w = 220
			local spinner = opt:AddChild(Spinner( spin_options, w, spin_height))
			spinner:SetTextColour(0,0,0,1)
			local default_value = options[idx].value
			if default_value == nil then default_value = options[idx].default end
			
			spinner.OnChanged =
				function( _, data )
					options[idx].value = data
					self:MakeDirty()
				end
				
			spinner:SetSelected(default_value)
			spinner:SetPosition(35,0,0 )

			local spacing = 55
			local label_width = 180
			
			local label = spinner:AddChild( Text( BUTTONFONT, 30, (options[idx].label or options[idx].name) or STRINGS.UI.MODSSCREEN.UNKNOWN_MOD_CONFIG_SETTING ) )
			label:SetPosition( -label_width/2 - 105, 0, 0 )
			label:SetRegionSize( label_width, 50 )
			label:SetHAlign( ANCHOR_MIDDLE )

			if k <= ROWS_PER_COL then
				opt:SetPosition(-155, (ROWS_PER_COL-1)*spacing*.5 - (k-1)*spacing - 10, 0)
				table.insert(self.left_spinners, spinner)
				spinner.column = "left"
				spinner.idx = #self.left_spinners
			else
				opt:SetPosition(265, (ROWS_PER_COL-1)*spacing*.5 - (k-1-ROWS_PER_COL)*spacing- 10, 0)
				table.insert(self.right_spinners, spinner)
				spinner.column = "right"
				spinner.idx = #self.right_spinners
			end
			
			table.insert(self.optionwidgets, {root = opt})
		end
	end

	--hook up all of the focus moves
	self:HookupFocusMoves()

	if old_column and old_idx then
		local list = old_column == "right" and self.right_spinners or self.left_spinners
		list[math.min(#list, old_idx)]:SetFocus()
	end
	
end

function ModConfigurationScreen:HookupFocusMoves()
	local GetFirstEnabledSpinnerAbove = function(k, tbl)
		for i=k-1,1,-1 do
			if tbl[i] and tbl[i].enabled then
				return tbl[i]
			end
		end
		return nil
	end
	local GetFirstEnabledSpinnerBelow = function(k, tbl)
		for i=k+1,#tbl do
			if tbl[i] and tbl[i].enabled then
				return tbl[i]
			end
		end
		return nil
	end

	for k = 1, #self.left_spinners do
		local abovespinner = GetFirstEnabledSpinnerAbove(k, self.left_spinners)
		if abovespinner then
			self.left_spinners[k]:SetFocusChangeDir(MOVE_UP, abovespinner)
		end

		local belowspinner = GetFirstEnabledSpinnerBelow(k, self.left_spinners)
		if belowspinner	then
			self.left_spinners[k]:SetFocusChangeDir(MOVE_DOWN, belowspinner)
		else
			self.left_spinners[k]:SetFocusChangeDir(MOVE_DOWN, self.applybutton)
		end

		if self.right_spinners[k] then
			self.left_spinners[k]:SetFocusChangeDir(MOVE_RIGHT, self.right_spinners[k])
		end
	end

	for k = 1, #self.right_spinners do
		local abovespinner = GetFirstEnabledSpinnerAbove(k, self.right_spinners)
		if abovespinner then
			self.right_spinners[k]:SetFocusChangeDir(MOVE_UP, abovespinner)
		end

		local belowspinner = GetFirstEnabledSpinnerBelow(k, self.right_spinners)
		if belowspinner	then
			self.right_spinners[k]:SetFocusChangeDir(MOVE_DOWN,belowspinner)
		else
			self.right_spinners[k]:SetFocusChangeDir(MOVE_DOWN, self.resetbutton)
		end

		if self.left_spinners[k] then
			self.right_spinners[k]:SetFocusChangeDir(MOVE_LEFT, self.left_spinners[k])
		end
	end

	self.applybutton:SetFocusChangeDir(MOVE_UP, self.left_spinners[#self.left_spinners])
	self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.left_spinners[#self.left_spinners])
	self.resetbutton:SetFocusChangeDir(MOVE_UP, self.right_spinners[#self.right_spinners])
end

function ModConfigurationScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()

	if self:IsDirty() then
		local focus = self:GetDeepestFocus()
		if focus ~= self.applybutton and focus ~= self.cancelbutton and focus ~= self.resetbutton then
			table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.APPLY)
		end
	end
	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

	if self.leftbutton.shown then 
    	table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_PAGELEFT) .. " " .. STRINGS.UI.HELP.SCROLLBACK)
    end

    if self.rightbutton.shown then
    	table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_PAGERIGHT) .. " " .. STRINGS.UI.HELP.SCROLLFWD)
    end

	return table.concat(t, "  ")
end

return ModConfigurationScreen