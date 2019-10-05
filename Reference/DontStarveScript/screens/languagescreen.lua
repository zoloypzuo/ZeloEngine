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
local BigerPopupDialogScreen = require "screens/bigerpopupdialog"

local show_graphics = PLATFORM ~= "NACL"
local text_font = UIFONT--NUMBERFONT

local enableDisableOptions = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }
local spinnerFont = { font = BUTTONFONT, size = 30 }

local LanguageScreen = Class(Screen, function(self)
	Screen._ctor(self, "LanguageScreen")
	--TheFrontEnd:DoFadeIn(2)

--	self.working = deepcopy( self.options )
	
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
	
	self.menu = self.root:AddChild(Menu(nil, -80, false))
	self.menu:SetPosition(260, -235 ,0)

	self.menu:SetScale(.8)

	self.grid = self.root:AddChild(Grid())
	self.grid:InitSize(2, 7, 400, -63)
	self.grid:SetPosition(-250, 140, 0)

	self.title = self.root:AddChild( Text( TITLEFONT, 50 ) )
	self.title:SetPosition(0,200,0)

	self:ShowPage()

	self.language_id = Profile:GetLanguageID()
	self.working_language_id = self.language_id
	self:RefreshPage()

	self.default_focus = self.grid
end)


function LanguageScreen:CreateCheckMarkGroup( text, value )
	local label_width = 300
	--spinner:SetTextColour(0,0,0,1)
	local group = Widget( "CheckMarkGroup" )
	group.language_id = value

	local imageback = group:AddChild(Image("images/global.xml", "square.tex"))
	imageback:SetSize(330,60)
	imageback:SetPosition(25,0,0)
	imageback:SetTint(1,1,1,.1)

	local image = imageback:AddChild(Image("images/global.xml", "square.tex"))
	image:SetSize(320,50)
	image:SetPosition(0,0,0)
	image:SetTint(1,1,1,.1)

	local label = image:AddChild( Text( BUTTONFONT, 30, text ) )
	label:SetPosition( 80, 0, 0 )
	label:SetRegionSize( label_width, 50 )
	label:SetHAlign( ANCHOR_LEFT )

	local check = image:AddChild(Image("images/ui.xml", "button_checkbox1.tex"))
	check:SetScale(.5,.5,.5)
	check:SetPosition(-100,2,0)
	group.check = check

	local focus = imageback
	focus.OnGainFocus = function()
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
		focus:SetScale(1.1,1.1,1)
		imageback:SetTint(1,1,1,.2)
		--self.RoGbutton.bg:GetAnimState():PlayAnimation("over")
	end
	focus.OnLoseFocus = function()
		focus:SetScale(1,1,1)
		imageback:SetTint(1,1,1,.1)
	end
	focus.OnControl = function(_, control, down) 
		if Widget.OnControl(focus, control, down) then return true end
		if control == CONTROL_ACCEPT and not down then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			self:ClickedCheckmark(group)
			return true
		end
	end
	group.focus_forward = imageback

	return group
end

function LanguageScreen:ClickedCheckmark(group)
	self.working_language_id = group.language_id
	self:RefreshPage()
end


function LanguageScreen:RefreshPage()
	self:UpdateMenu()
	for id,group in pairs(self.languages) do
		if id == self.working_language_id then
			group.check:SetTexture("images/ui.xml", "button_checkbox2.tex")
		else
			group.check:SetTexture("images/ui.xml", "button_checkbox1.tex")
		end
	end
end

function LanguageScreen:OnControl(control, down)
    if LanguageScreen._base.OnControl(self, control, down) then return true end
    
    if not down then
	    if control == CONTROL_CANCEL then
			if self:IsDirty() then
				self:ConfirmRevert() --revert and go back, or stay
			else
				self:Back() --just go back
			end
			return true
	    elseif control == CONTROL_INSPECT and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
	    	if self:IsDirty() then
	    		self:ApplyChanges() --apply changes and go back, or stay
	    	end
	    end
	end
end


function LanguageScreen:ApplyChanges()
	if self:IsDirty() then
		self:ConfirmApply()
	end
end

function LanguageScreen:Back()
	TheFrontEnd:PopScreen()					
end

function LanguageScreen:ConfirmRevert()

	TheFrontEnd:PushScreen(
		PopupDialogScreen( STRINGS.UI.OPTIONS.BACKTITLE, STRINGS.UI.OPTIONS.BACKBODY,
		  { 
		  	{ 
		  		text = STRINGS.UI.OPTIONS.YES, 
		  		cb = function()
					self:RevertChanges()
					TheFrontEnd:PopScreen()
					self:Back()
				end
			},
			
			{ 
				text = STRINGS.UI.OPTIONS.NO, 
				cb = function()
					TheFrontEnd:PopScreen()					
				end
			}
		  }
		)
	)		
end

function LanguageScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()

	if self:IsDirty() then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. STRINGS.UI.HELP.APPLY)
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	else
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	end
	return table.concat(t, "  ")
end


function LanguageScreen:Accept()
	self:Save(function() self:Close() end )
end

function LanguageScreen:Save(cb)
	Profile:SetLanguageID( self.language_id )

	Profile:Save( function() if cb then cb() end end)	
end

function LanguageScreen:RevertChanges()
	self.working_language_id = self.language_id 
	self:RefreshPage()
end

function LanguageScreen:IsDirty()
	return self.working_language_id ~= self.language_id
end

function LanguageScreen:ConfirmApply( )
	
	TheFrontEnd:PushScreen(
		PopupDialogScreen( STRINGS.UI.OPTIONS.ACCEPTTITLE, STRINGS.UI.OPTIONS.ACCEPTBODY,
		  { 
		  	{ 
		  		text = STRINGS.UI.OPTIONS.ACCEPT, 
		  		cb = function()
					self:Apply()
					self:Save(function() TheFrontEnd:PopScreen() self:Back() end)
				end
			},
			
			{ 
				text = STRINGS.UI.OPTIONS.CANCEL, 
				cb = function()
					TheFrontEnd:PopScreen()					
				end
			}
		  }
		)
	)	
end



function LanguageScreen:Apply( )
	self.language_id = self.working_language_id
    Profile:SetLanguageID(self.language_id, function() SimReset() end )
end

function LanguageScreen:Close()
	TheFrontEnd:PopScreen()
end	


function LanguageScreen:UpdateMenu()
	self.menu:Clear()
	if TheInput:ControllerAttached() then return end
	if self:IsDirty() then
		self.menu.horizontal = true
		self.menu:AddItem(STRINGS.UI.OPTIONS.APPLY, function() self:ApplyChanges() end, Vector3(50, 0, 0))
		self.menu:AddItem(STRINGS.UI.OPTIONS.REVERT, function() self:RevertChanges() end,  Vector3(-50, 0, 0))
	else
		self.menu.horizontal = false
		self.menu:AddItem(STRINGS.UI.OPTIONS.CLOSE, function() self:Accept() end)
	end
end

function LanguageScreen:DoInitHamletPage()
end              

function LanguageScreen:ShowPage()
	--self.dlcOptionsTitle:Show()
	self.title:SetString(STRINGS.UI.LANGUAGE_OPTIONS_SCREEN.LANGUAGE_OPTIONS)
	self.languages = {}
    for k,id in pairs(LOC.GetLanguages()) do
	    local name = STRINGS.PRETRANSLATED.LANGUAGES[id]
		local col = (k - 1) % 2 + 1
		local row = (k - col) / 2 + 1
		local languageCheckMark = self:CreateCheckMarkGroup(name, id)
		self.languages[id] = languageCheckMark
		self.grid:AddItem(languageCheckMark, col, row)	
    end
	self.grid:DoFocusHookups()
    self.grid:Show()
end

return LanguageScreen