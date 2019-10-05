require "util"
require "strings"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local Widget = require "widgets/widget"
local PopupDialogScreen = require "screens/popupdialog"


local enableDisableOptions = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }


local OptionsScreen = Class(Screen, function(self, in_game)
	Screen._ctor(self, "OptionsScreen")
	self.in_game = in_game

	self.options = {
		fxvolume = TheMixer:GetLevel( "set_sfx" ) * 10,
		musicvolume = TheMixer:GetLevel( "set_music" ) * 10,
		ambientvolume = TheMixer:GetLevel( "set_ambience" ) * 10,
		hudSize = Profile:GetHUDSize(),
		vibration = Profile:GetVibrationEnabled(),
		autosave = Profile:GetAutosaveEnabled(),
		screenshake = Profile:IsScreenShakeEnabled(),
	}

	if IsDLCInstalled(REIGN_OF_GIANTS) then
		self.options.wathgrithrfont = Profile:IsWathgrithrFontEnabled()
	end
	
	self.working = deepcopy( self.options )
	
	
	self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
    if IsDLCEnabled(REIGN_OF_GIANTS) then
    	self.bg:SetTint(BGCOLOURS.PURPLE[1],BGCOLOURS.PURPLE[2],BGCOLOURS.PURPLE[3], 1)
    else
   		self.bg:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 1)
    end
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    
	self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,15,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
	local shield = self.root:AddChild( Image( "images/fepanels.xml", "panel_controls.tex" ) )
	shield:SetPosition( 0,-20,0 )

	self.title = self.root:AddChild(Text(TITLEFONT, 70))
	self.title:SetString(STRINGS.UI.MAINSCREEN.SETTINGS)

	self.grid = self.root:AddChild(Grid())

	if IsDLCInstalled(REIGN_OF_GIANTS) then
		if JapaneseOnPS4() then
	        shield:SetScale(1.4, 0.85, 1.0)	
	    else
	        shield:SetScale(1.3, 0.85, 1.0)	
	    end
		self.title:SetPosition(0, 150, 0)
		self.grid:InitSize(2, 5, 400, -70)
		self.grid:SetPosition(-230, 70, 0)
	else
		if JapaneseOnPS4() then
	        shield:SetScale(1.4, 0.75, 1.0)	
	    else
	        shield:SetScale(1.2, 0.75, 1.0)	
	    end
		self.title:SetPosition(0, 120, 0)
		self.grid:InitSize(2, 5, 400, -70)
		self.grid:SetPosition(-250, 35, 0)
	end

	self:DoInit()
	self:InitializeSpinners()

	self.default_focus = self.grid

end)


function OptionsScreen:OnControl(control, down)
    if OptionsScreen._base.OnControl(self, control, down) then return true end
    
    if not down then
	    if control == CONTROL_CANCEL then
			if self:IsDirty() then
				self:ConfirmRevert() --revert and go back, or stay
			else
				self:Back() --just go back
			end
			return true
	    elseif control == CONTROL_CONTROLLER_ATTACK then
	    	if self:IsDirty() then
	    		self:ConfirmApply() --apply changes and go back, or stay
	    	end
	    end
	end
end

function OptionsScreen:Back()
	TheFrontEnd:PopScreen()					
end

function OptionsScreen:ConfirmRevert()

	TheFrontEnd:PushScreen(
		PopupDialogScreen( STRINGS.UI.OPTIONS.BACKTITLE, STRINGS.UI.OPTIONS.BACKBODY,
		  { 
		  	{ 
		  		text = STRINGS.UI.OPTIONS.YES, 
		  		cb = function()
					self:RevertChanges()
					TheFrontEnd:PopScreen()
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



function OptionsScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()
	if self:IsDirty() then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HELP.APPLY)
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	else
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	end
	return table.concat(t, "  ")
end


function OptionsScreen:Accept()
	self:Save(function() self:Close() end )
end

function OptionsScreen:Save(cb)
	self.options = deepcopy( self.working )

	Profile:SetVolume( self.options.ambientvolume, self.options.fxvolume, self.options.musicvolume )
	Profile:SetHUDSize( self.options.hudSize )
	Profile:SetScreenShakeEnabled( self.options.screenshake )
	Profile:SetVibrationEnabled( self.options.vibration )
	Profile:SetAutosaveEnabled( self.options.autosave )
	if IsDLCInstalled(REIGN_OF_GIANTS) then Profile:SetWathgrithrFontEnabled( self.options.wathgrithrfont ) end
	
	Profile:Save( function() if cb then cb() end end)	
end


function OptionsScreen:RevertChanges()
	self.working = deepcopy( self.options )
	self:Apply()
	self:InitializeSpinners()
end

function OptionsScreen:IsDirty()
	for k,v in pairs(self.working) do
		if v ~= self.options[k] then
			return true	
		end
	end
	return false
end

function OptionsScreen:ConfirmApply( )
	
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


function OptionsScreen:ApplyVolume()
	TheMixer:SetLevel("set_sfx", self.working.fxvolume / 10 )
	TheMixer:SetLevel("set_music", self.working.musicvolume / 10 )
	TheMixer:SetLevel("set_ambience", self.working.ambientvolume / 10 )
end

function OptionsScreen:ApplyVibration()
    TheInputProxy:EnableVibration(self.working.vibration )
end

function OptionsScreen:Apply( force )
	self:ApplyVolume()
	self:ApplyVibration()
	Profile:SetScreenShakeEnabled( self.working.screenshake )
	if IsDLCInstalled(REIGN_OF_GIANTS) then Profile:SetWathgrithrFontEnabled( self.working.wathgrithrfont ) end
end

function OptionsScreen:Close()
	--TheFrontEnd:DoFadeIn(2)
	TheFrontEnd:PopScreen()
end	


function OptionsScreen:CreateSpinnerGroup( text, spinner )
	local label_width = 200
	spinner:SetTextColour(0,0,0,1)
	local group = Widget( "SpinnerGroup" )
	local label = group:AddChild( Text( TITLEFONT, 40, text ) )
	label:SetPosition( -label_width/2, -5, 0 )
	label:SetRegionSize( label_width, 50 )
	label:SetHAlign( ANCHOR_RIGHT )
	
	group:AddChild( spinner )
	spinner:SetPosition( 100, 0, 0 )
	
	--pass focus down to the spinner
	group.focus_forward = spinner
	return group
end


function OptionsScreen:DoInit()


	local this = self
		
	self.fxVolume = NumericSpinner( 0, 10 )
	self.fxVolume.text:SetSize(40)
	self.fxVolume.text:SetPosition(0, -4, 0)
	self.fxVolume.OnChanged =
		function( _, data )
			this.working.fxvolume = data
			this:ApplyVolume()
		end

	self.musicVolume = NumericSpinner( 0, 10 )
	self.musicVolume.text:SetSize(40)
	self.musicVolume.text:SetPosition(0, -4, 0)
	self.musicVolume.OnChanged =
		function( _, data )
			this.working.musicvolume = data
			this:ApplyVolume()
		end

	self.ambientVolume = NumericSpinner( 0, 10 )
	self.ambientVolume.text:SetSize(40)
	self.ambientVolume.text:SetPosition(0, -4, 0)
	self.ambientVolume.OnChanged =
		function( _, data )
			this.working.ambientvolume = data
			this:ApplyVolume()
		end
		
	self.hudSize = NumericSpinner( 0, 10 )
	self.hudSize.text:SetSize(40)
	self.hudSize.text:SetPosition(0, -4, 0)
	self.hudSize.OnChanged =
		function( _, data )
			this.working.hudSize = data
			this:Apply()
		end
			
	self.vibrationSpinner = Spinner( enableDisableOptions )
	self.vibrationSpinner.text:SetSize(40)
	self.vibrationSpinner.text:SetPosition(0, -4, 0)
	self.vibrationSpinner.OnChanged =
		function( _, data )
			this.working.vibration = data
			this:Apply()
		end

	self.screenshakeSpinner = Spinner( enableDisableOptions )
	self.screenshakeSpinner.text:SetSize(40)
	self.screenshakeSpinner.text:SetPosition(0, -4, 0)
	self.screenshakeSpinner.OnChanged =
		function( _, data )
			this.working.screenshake = data
			--this:Apply()
		end
			
	self.autosaveSpinner = Spinner( enableDisableOptions )
	self.autosaveSpinner.text:SetSize(40)
	self.autosaveSpinner.text:SetPosition(0, -4, 0)
	self.autosaveSpinner.OnChanged =
		function( _, data )
			this.working.autosave = data
			this:Apply()
		end

	if IsDLCInstalled(REIGN_OF_GIANTS) then
		self.wathgrithrfontSpinner = Spinner( enableDisableOptions )
		self.wathgrithrfontSpinner.text:SetSize(40)
		self.wathgrithrfontSpinner.text:SetPosition(0, -4, 0)
		self.wathgrithrfontSpinner.OnChanged =
			function( _, data )
				this.working.wathgrithrfont = data
				--this:Apply()
			end
	end
		
	local left_spinners = {}
	local right_spinners = {}
	
	if IsDLCInstalled(REIGN_OF_GIANTS) then
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.FX, self.fxVolume } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.MUSIC, self.musicVolume } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.AMBIENT, self.ambientVolume } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.HUDSIZE, self.hudSize} )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.SCREENSHAKE, self.screenshakeSpinner} )
		table.insert( right_spinners, { STRINGS.UI.OPTIONS.VIBRATION, self.vibrationSpinner} )
		table.insert( right_spinners, { STRINGS.UI.OPTIONS.WATHGRITHRFONT, self.wathgrithrfontSpinner} )
		table.insert( right_spinners, { STRINGS.UI.OPTIONS.AUTOSAVE, self.autosaveSpinner} )
	else
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.FX, self.fxVolume } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.MUSIC, self.musicVolume } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.AMBIENT, self.ambientVolume } )
		table.insert( left_spinners, { STRINGS.UI.OPTIONS.HUDSIZE, self.hudSize} )
		table.insert( right_spinners, { STRINGS.UI.OPTIONS.SCREENSHAKE, self.screenshakeSpinner} )
		table.insert( right_spinners, { STRINGS.UI.OPTIONS.VIBRATION, self.vibrationSpinner} )
		table.insert( right_spinners, { STRINGS.UI.OPTIONS.AUTOSAVE, self.autosaveSpinner} )
	end

    
    self.display_area = self.root:AddChild(Widget("DisplayArea"))
    
	self.display_area_label = self.display_area:AddChild(Text(TITLEFONT, 40))
    self.display_area_label:SetString(STRINGS.UI.OPTIONS.DISPLAY_AREA_LABEL)
    self.display_area_label:SetPosition(-50, -5, 0)
    
	self.display_area_button = self.display_area:AddChild(ImageButton())
    self.display_area_button:SetText(STRINGS.UI.OPTIONS.DISPLAY_AREA_BUTTON)
    self.display_area_button.text:SetColour(0,0,0,1)
    self.display_area_button:SetOnClick( function() self:OnAdjustDisplayArea() end )
    self.display_area_button:SetFont(BUTTONFONT)
    self.display_area_button:SetTextSize(40)
    self.display_area_button:SetPosition(100, 0, 0)
    self.display_area.focus_forward = self.display_area_button

	for k,v in ipairs(left_spinners) do
		self.grid:AddItem(self:CreateSpinnerGroup(v[1], v[2]), 1, k)	
	end

	for k,v in ipairs(right_spinners) do
		self.grid:AddItem(self:CreateSpinnerGroup(v[1], v[2]), 2, k)	
	end
	
	self.grid:AddItem(self.display_area, 2, self.grid:GetRowsInCol(2) + 1)

end

local function EnabledOptionsIndex( enabled )
	if enabled then
		return 2
	else
		return 1
	end
end

function OptionsScreen:InitializeSpinners()
	
	local spinners = { fxvolume = self.fxVolume, musicvolume = self.musicVolume, ambientvolume = self.ambientVolume }
	for key, spinner in pairs( spinners ) do
		local volume = self.working[ key ] or 7
		spinner:SetSelectedIndex( math.floor( volume + 0.5 ) )
	end
	
	self.hudSize:SetSelectedIndex( self.working.hudSize or 5)
	self.vibrationSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.vibration ) )
	self.autosaveSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.autosave) )
	self.screenshakeSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.screenshake ) )
	if IsDLCInstalled(REIGN_OF_GIANTS) then self.wathgrithrfontSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.wathgrithrfont ) ) end
end

function OptionsScreen:OnAdjustDisplayArea()
    TheSystemService:AdjustDisplaySafeArea()
end

return OptionsScreen