require "util"
require "strings"

local Screen = require "widgets/screen"
local Button = require "widgets/button"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local Widget = require "widgets/widget"

local PopupDialogScreen = require "screens/popupdialog"
local BroadcastingLoginScreen = require "screens/broadcastingloginscreen"

local enableDisableOptions = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }

local BroadcastingOptionsScreen = Class(Screen, function(self, in_game)
	Screen._ctor(self, "BroadcastingOptionsScreen")
	self.in_game = in_game
	local broadcastingOptions = TheFrontEnd:GetBroadcastingOptions()

	local system_bandwidth = broadcastingOptions:GetTargetBandwidth()
	self.options = {
		broadcasting  = broadcastingOptions:GetBroadcastingEnabled(),
		framerate     = broadcastingOptions:GetTargetFrameRate(),
		bandwidth     = system_bandwidth,
		bandwidth_idx = (system_bandwidth/100)-2,
		audio         = broadcastingOptions:GetAudioEnabled(),
		microphone    = broadcastingOptions:GetMicrophoneEnabled(),
		scaling       = broadcastingOptions:GetSmoothScaling(),
		webcam        = broadcastingOptions:GetWebcamEnabled(),
		webcamalpha   = (broadcastingOptions:GetWebcamAlpha() * 10),
		chat		  = broadcastingOptions:GetVisibleChatEnabled()
	}

	self.working = deepcopy( self.options )
	
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
	
	local broadcasting_beta = self.root:AddChild( Text( BUTTONFONT, 26 ) )
	broadcasting_beta:SetString("Broadcasting Beta" ) 
	broadcasting_beta:SetPosition( 0,210,0 )
	broadcasting_beta:SetSize( 40, 30 )	
	
	local help_button = self.root:AddChild(ImageButton())
	    help_button:SetPosition(Vector3(300, -145, 0))
	    help_button:SetText(STRINGS.UI.BROADCASTING.HELP)
	    help_button.text:SetColour(0,0,0,1)
	    help_button:SetOnClick( function() VisitURL("https://kleisupport.desk.com/customer/portal/articles/1536861-how-to-enable-twitch-broadcasting-and-chat") end )
	    help_button:SetFont(BUTTONFONT)
	    help_button:SetTextSize(40)   
	    help_button:SetScale(.8)
			
	self.menu = self.root:AddChild(Menu(nil, -80, false))
	self.menu:SetPosition(260, -235 ,0)
	self.menu:SetScale(.8)

	self.grid = self.root:AddChild(Grid())
	self.grid:InitSize(2, 7, 400, -70)
	self.grid:SetPosition(-240, 145, 0)
	self:DoInit()
	self:InitializeSpinners()

	self.streaming_state = 0
	
	self.default_focus = self.grid
	self:StartUpdating()
end)

function BroadcastingOptionsScreen:OnUpdate()
	local broadcasting_options = TheFrontEnd:GetBroadcastingOptions()
	local new_state = broadcasting_options:GetStreamingState()
	
	if new_state ~= self.streaming_state then
		self.streaming_state = new_state
		self:UpdateMenu()
	end
end

function BroadcastingOptionsScreen:OnControl(control, down)
    if BroadcastingOptionsScreen._base.OnControl(self, control, down) then return true end
    
    if not down then
	    if control == CONTROL_CANCEL then
			if self:IsDirty() then
				self:ConfirmRevert() --revert and go back, or stay
			else
				self:Back() --just go back
			end
			return true
	    elseif control == CONTROL_ACCEPT and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
	    	if self:IsDirty() then
	    		self:ApplyChanges() --apply changes and go back, or stay
	    	end
	    end
	end
end


function BroadcastingOptionsScreen:ApplyChanges()
	if self:IsDirty() then
		self:ConfirmApply()
	end
end


function BroadcastingOptionsScreen:Back()
	TheFrontEnd:PopScreen()					
end

function BroadcastingOptionsScreen:ConfirmRevert()

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

function BroadcastingOptionsScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()
	if self:IsDirty() then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.APPLY)
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	else
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	end
	return table.concat(t, "  ")
end

function BroadcastingOptionsScreen:Accept()
	self:Save(function() self:Close() end )
end

function BroadcastingOptionsScreen:Save(cb)
	self.options = deepcopy( self.working )
	
	local broadcasting_options = TheFrontEnd:GetBroadcastingOptions()
	broadcasting_options:SetBroadcastingEnabled( self.options.broadcasting )
	broadcasting_options:SetTargetFrameRate    ( self.options.framerate )
	broadcasting_options:SetTargetBandwidth    ( self.options.bandwidth )
	broadcasting_options:SetAudioEnabled       ( self.options.audio )
	broadcasting_options:SetMicrophoneEnabled  ( self.options.microphone )
	broadcasting_options:SetSmoothScaling      ( self.options.scaling )
	broadcasting_options:SetWebcamEnabled      ( self.options.webcam )
	broadcasting_options:SetWebcamAlpha        ( self.options.webcamalpha * 0.1 )
	broadcasting_options:SetVisibleChatEnabled ( self.options.chat )
	broadcasting_options:SaveSettings()
	
	if not self.options.broadcasting then
		broadcasting_options:Stop()
	end
	
	Profile:Save( function() if cb then cb() end end)	
end

function BroadcastingOptionsScreen:RevertChanges()
	self.working = deepcopy( self.options )
	self:Apply()
	self:InitializeSpinners()
	self:UpdateMenu()							
end

function BroadcastingOptionsScreen:IsDirty()
	for k,v in pairs(self.working) do
		if v ~= self.options[k] then
			return true	
		end
	end
	return false
end

function BroadcastingOptionsScreen:ToggleStreaming( )
	local broadcasting_options = TheFrontEnd:GetBroadcastingOptions()
	broadcasting_options:ToggleStreaming()
end

function BroadcastingOptionsScreen:Login( )
	local broadcasting_options = TheFrontEnd:GetBroadcastingOptions()
	TheFrontEnd:PushScreen(BroadcastingLoginScreen())	
end

function BroadcastingOptionsScreen:Logout()
	local broadcasting_options = TheFrontEnd:GetBroadcastingOptions()
	broadcasting_options:Forget()
	self:UpdateMenu()
end

function BroadcastingOptionsScreen:ConfirmApply( )
	
	TheFrontEnd:PushScreen(
		PopupDialogScreen( STRINGS.UI.BROADCASTING.ACCEPTTITLE, STRINGS.UI.BROADCASTING.ACCEPTBODY,
		  { 
		  	{ 
		  		text = STRINGS.UI.BROADCASTING.ACCEPT, 
		  		cb = function()
					self:Apply()
					self:Save(function() self:UpdateMenu() self:Back() end)
				end
			},
			{ 
				text = STRINGS.UI.BROADCASTING.CANCEL, 
				cb = function()
					TheFrontEnd:PopScreen()					
				end
			}
		  }
		)
	)	
end

function BroadcastingOptionsScreen:Apply( )
	local broadcasting_options = TheFrontEnd:GetBroadcastingOptions()
	
	broadcasting_options:SetBroadcastingEnabled( self.working.broadcasting )
	broadcasting_options:SetTargetFrameRate    ( self.working.framerate )
	broadcasting_options:SetTargetBandwidth    ( self.working.bandwidth )
	broadcasting_options:SetAudioEnabled       ( self.working.audio )
	broadcasting_options:SetMicrophoneEnabled  ( self.working.microphone  )
	broadcasting_options:SetSmoothScaling      ( self.working.scaling  )
	broadcasting_options:SetWebcamEnabled      ( self.working.webcam  )
	broadcasting_options:SetWebcamAlpha        ( self.working.webcamalpha * 0.1 )
	broadcasting_options:SetVisibleChatEnabled ( self.options.chat )
	
end

function BroadcastingOptionsScreen:Close()
	TheFrontEnd:PopScreen()
end	

local function MakeMenu(offset, menuitems)
	local menu = Widget("BroadcastingMenu")	
	local pos = Vector3(0,0,0)
	for k,v in ipairs(menuitems) do
		local button = menu:AddChild(ImageButton())
	    button:SetPosition(pos)
	    button:SetText(v.text)
	    button.text:SetColour(0,0,0,1)
	    button:SetOnClick( v.cb )
	    button:SetFont(BUTTONFONT)
	    button:SetTextSize(40)    
	    pos = pos + offset  
	end
	return menu
end

function BroadcastingOptionsScreen:CreateSpinnerGroup( text, spinner )
	local label_width = 200
	spinner:SetTextColour(0,0,0,1)
	local group = Widget( "SpinnerGroup" )
	local label = group:AddChild( Text( BUTTONFONT, 30, text ) )
	label:SetPosition( -label_width/2, 0, 0 )
	label:SetRegionSize( label_width, 50 )
	label:SetHAlign( ANCHOR_RIGHT )
	
	group:AddChild( spinner )
	spinner:SetPosition( 125, 0, 0 )
	group.focus_forward = spinner
	return group
end

function BroadcastingOptionsScreen:UpdateMenu()
	self.menu:Clear()
	if TheInput:ControllerAttached() then return end
	local broadcasting_options = TheFrontEnd:GetBroadcastingOptions()

	if self:IsDirty() then
		self.menu.horizontal = true
		self.menu:AddItem(STRINGS.UI.BROADCASTING.APPLY, function() self:ApplyChanges() end, Vector3(50, 30, 0))
		self.menu:AddItem(STRINGS.UI.BROADCASTING.REVERT, function() self:RevertChanges() end,  Vector3(-50, 30, 0))
	else
		self.menu.horizontal = true
		self.menu:AddItem(STRINGS.UI.BROADCASTING.CLOSE, function() self:Accept() end, Vector3(50, 30, 0))
		if broadcasting_options:GetBroadcastingEnabled() then
			if broadcasting_options:IsPastInitializedState() then
				self.menu:AddItem(STRINGS.UI.BROADCASTING.LOGOUT, function() self:Logout() end, Vector3(-50, 30, 0))
			else
				self.menu:AddItem(STRINGS.UI.BROADCASTING.LOGIN, function() self:Login() end, Vector3(-50, 30, 0))
			end
		end
	end	
	
	if broadcasting_options:IsPastInitializedState() and broadcasting_options:GetBroadcastingEnabled() then
		local broadcasting_url  = broadcasting_options:GetChannelURL()	
		
		if broadcasting_url ~= nil and broadcasting_url ~= ""  then
		
			if broadcasting_options:IsStreaming() then
				self.menu:AddItem( STRINGS.UI.BROADCASTING.STOPSTREAM , function() self:ToggleStreaming() end, Vector3(30, 110, 0))	
			else
				self.menu:AddItem( STRINGS.UI.BROADCASTING.STARTSTREAM , function() self:ToggleStreaming() end, Vector3(30, 110, 0))	
			end
			
			self.menu:AddItem( STRINGS.UI.BROADCASTING.VIEWSTREAM , function() VisitURL(broadcasting_url) end, Vector3(110, 190, 0))
		end
	end
	

	
end

function BroadcastingOptionsScreen:DoInit()

	self:UpdateMenu()

	local this = self
	local gBroadcastingOptions = TheFrontEnd:GetBroadcastingOptions()
	
	self.enabledSpinner = Spinner( enableDisableOptions )
	self.enabledSpinner.OnChanged =
		function( _, data )
			this.working.broadcasting = data
			self:UpdateMenu()
		end
		
	self.frameRateSpinner = NumericSpinner( 10, 30 )
	self.frameRateSpinner.OnChanged =
		function( _, data )
			this.working.framerate = data
			self:UpdateMenu()
		end
		
	local bandwidths = {}
	for i = 2 , 23 do
		table.insert( bandwidths, { text = tostring((i+1)*100), data = tostring((i+1)*100) } )
	end
	
	self.bandwidthSpinner = Spinner( bandwidths )
	self.bandwidthSpinner.OnChanged =
		function( _, data )
			this.working.bandwidth_idx = data.idx
			this.working.bandwidth = data
			self:UpdateMenu()
		end
	
	self.audioSpinner = Spinner( enableDisableOptions )
	self.audioSpinner.OnChanged =
		function( _, data )
			this.working.audio = data
			self:UpdateMenu()
		end		

	self.microphoneSpinner = Spinner( enableDisableOptions )
	self.microphoneSpinner.OnChanged =
		function( _, data )
			this.working.microphone = data
			self:UpdateMenu()
		end	
	
	self.smoothScalingSpinner = Spinner( enableDisableOptions )
	self.smoothScalingSpinner.OnChanged =
		function( _, data )
			this.working.scaling = data
			self:UpdateMenu()
		end		
		
	self.webcamSpinner = Spinner( enableDisableOptions )
	self.webcamSpinner.OnChanged =
		function( _, data )
			this.working.webcam = data
			self:UpdateMenu()
		end		
			
	self.webcamAlphaSpinner = NumericSpinner( 1, 10 )
	self.webcamAlphaSpinner.OnChanged =
		function( _, data )
			this.working.webcamalpha = data
			self:UpdateMenu()
		end
				
	self.chatSpinner = Spinner( enableDisableOptions )
	self.chatSpinner.OnChanged =
		function( _, data )
			this.working.chat = data
			self:UpdateMenu()
		end	
		
	local left_spinners = {}
	local right_spinners = {}
	
	table.insert( left_spinners, { STRINGS.UI.BROADCASTING.BROADCASTINGENABLED, self.enabledSpinner       } )
	table.insert( left_spinners, { STRINGS.UI.BROADCASTING.FRAMERATE,		    self.frameRateSpinner     } )
	table.insert( left_spinners, { STRINGS.UI.BROADCASTING.BANDWIDTH,		    self.bandwidthSpinner     } )
	table.insert( left_spinners, { STRINGS.UI.BROADCASTING.SMOOTHSCALING,       self.smoothScalingSpinner } )
	table.insert( left_spinners, { STRINGS.UI.BROADCASTING.WEBCAM,				self.webcamSpinner		  } )
	table.insert( left_spinners, { STRINGS.UI.BROADCASTING.WEBCAMALPHA,			self.webcamAlphaSpinner   } )
	
	table.insert( right_spinners, { STRINGS.UI.BROADCASTING.AUDIO,        self.audioSpinner       } )
	table.insert( right_spinners, { STRINGS.UI.BROADCASTING.MICROPHONE,   self.microphoneSpinner  } )
	table.insert( right_spinners, { STRINGS.UI.BROADCASTING.TWITCHCHAT,	  self.chatSpinner        } )
	
	self.grid:InitSize(2, 7, 400, -70)

	for k,v in ipairs(left_spinners) do
		self.grid:AddItem(self:CreateSpinnerGroup(v[1], v[2]), 1, k)	
	end

	for k,v in ipairs(right_spinners) do
		self.grid:AddItem(self:CreateSpinnerGroup(v[1], v[2]), 2, k)	
	end

end

local function EnabledOptionsIndex( enabled )
	if enabled then
		return 2
	else
		return 1
	end
end

function BroadcastingOptionsScreen:InitializeSpinners()
	self.enabledSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.broadcasting ) )
	self.audioSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.audio ) )
	self.microphoneSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.microphone ) )
	self.smoothScalingSpinner:SetSelectedIndex( EnabledOptionsIndex(self.working.scaling) )
	self.webcamSpinner:SetSelectedIndex( EnabledOptionsIndex(self.working.webcam) )
	self.webcamAlphaSpinner:SetSelectedIndex( math.floor(self.working.webcamalpha + 0.1) )
	self.bandwidthSpinner:SetSelectedIndex( self.working.bandwidth_idx )
	self.frameRateSpinner:SetSelectedIndex( self.working.framerate )
	self.chatSpinner:SetSelectedIndex( EnabledOptionsIndex( self.working.chat ) )
end

return BroadcastingOptionsScreen