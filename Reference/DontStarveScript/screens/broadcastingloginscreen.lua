require "util"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local TextEdit = require "widgets/textedit"
local Widget = require "widgets/widget"

local UI_ATLAS = "images/ui.xml"
local USERNAME_VALID_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
local PASSWORD_VALID_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.@!#$%&'*+-/=?^_`{|}~"
local STRING_MAX_LENGTH = 254 -- http://tools.ietf.org/html/rfc5321#section-4.5.3.1

local BroadcastingLoginScreen = Class(Screen, function(self)
	Screen._ctor(self, "BroadcastingLoginScreen")
	self:DoInit()
end)

function BroadcastingLoginScreen:OnControl(control, down)
	if BroadcastingLoginScreen._base.OnControl(self, control, down) then return true end

	if not down and control == CONTROL_CANCEL then
		self:Close()
		return true
	end
end

function BroadcastingLoginScreen:OnBecomeActive()
	BroadcastingLoginScreen._base.OnBecomeActive(self)

	self.edit_username:SetFocus()
	self.edit_username:SetEditing(true)
	SetPause(true,'Login')
end

function BroadcastingLoginScreen:Login()
	local username = self.edit_username:GetString()
	local password = self.edit_password:GetLineEditString()
	
	local broadcasting_options = TheFrontEnd:GetBroadcastingOptions()
	broadcasting_options:Login( username, password );
	Profile:Save()	
	self:Close()
end

function BroadcastingLoginScreen:Close()
	TheInput:EnableDebugToggle(true)
	TheFrontEnd:PopScreen(self)
	self.edit_username:SetEditing(false)
	self.edit_password:SetEditing(false)
	SetPause(false)
end

function BroadcastingLoginScreen:DoInit()

	TheInput:EnableDebugToggle(false)

	self.maxYear = tonumber(os.date("%Y"))
	self.minYear = self.maxYear - 130

	--darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)	
    
	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)
	
	self.root = self.proot:AddChild(Widget("ROOT"))

	--throw up the background
    self.bg = self.root:AddChild(Image("images/globalpanels.xml", "small_dialog.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(1.6, 2, 1)    

    local title_size = 300
    local title_offset = 120

	local label_width = 200
	local label_height = 50
	local label_offset = 275

	local space_between = 30
	local username_height_offset = 70
	local password_height_offset =  -50

	local fontsize = 30

	local edit_width = 550
	local edit_bg_padding = 60
	
    self.title = self.root:AddChild(Text(TITLEFONT, 50))

    self.title:SetString("Twitch User Name")
    self.title:SetHAlign(ANCHOR_MIDDLE)
    self.title:SetVAlign(ANCHOR_MIDDLE)
    self.title:SetPosition(0, title_offset, 0)

    self.password_title = self.root:AddChild(Text(TITLEFONT, 50))
    self.password_title:SetString("Twitch Password")
    self.password_title:SetHAlign(ANCHOR_MIDDLE)
    self.password_title:SetVAlign(ANCHOR_MIDDLE)
    self.password_title:SetPosition(0, 10, 0)

    self.edit_username_bg = self.root:AddChild( Image() )
	self.edit_username_bg:SetTexture( "images/ui.xml", "textbox_long.tex" )
	self.edit_username_bg:SetPosition( (edit_width * .5) - label_offset + space_between, username_height_offset, 0 )
	self.edit_username_bg:ScaleToSize( edit_width + edit_bg_padding, label_height )

    self.edit_password_bg = self.root:AddChild( Image() )
	self.edit_password_bg:SetTexture( "images/ui.xml", "textbox_long.tex" )
	self.edit_password_bg:SetPosition( (edit_width * .5) - label_offset + space_between, password_height_offset, 0 )
	self.edit_password_bg:ScaleToSize( edit_width + edit_bg_padding, label_height )
	
	local broadcastingOptions = TheFrontEnd:GetBroadcastingOptions()
		
	self.edit_username = self.root:AddChild( TextEdit( BODYTEXTFONT, fontsize, broadcastingOptions:GetUserName() ) )
	self.edit_username:SetPosition( (edit_width * .5) - label_offset + space_between, username_height_offset, 0 )
	self.edit_username:SetRegionSize( edit_width, label_height )
	self.edit_username:SetHAlign(ANCHOR_LEFT)
	self.edit_username:SetFocusedImage( self.edit_username_bg, UI_ATLAS, "textbox_long_over.tex", "textbox_long.tex" )
	self.edit_username:SetTextLengthLimit( STRING_MAX_LENGTH )
	self.edit_username:SetCharacterFilter( USERNAME_VALID_CHARS )
	self.edit_username:SetAllowClipboardPaste( true )
	
	self.edit_password = self.root:AddChild( TextEdit( BODYTEXTFONT, fontsize, "" ) )
	self.edit_password:SetPosition( (edit_width * .5) - label_offset + space_between, password_height_offset, 0 )
	self.edit_password:SetRegionSize( edit_width, label_height )
	self.edit_password:SetHAlign(ANCHOR_LEFT)
	self.edit_password:SetFocusedImage( self.edit_password_bg, UI_ATLAS, "textbox_long_over.tex", "textbox_long.tex" )
	self.edit_password:SetTextLengthLimit( STRING_MAX_LENGTH )
	self.edit_password:SetCharacterFilter( PASSWORD_VALID_CHARS )
	self.edit_password:SetPassword( true )
	self.edit_password:SetAllowClipboardPaste( true )
	
	local menu_items = {
		{ text = STRINGS.UI.BROADCASTING.LOGIN,  cb = function() self:Login() end },
		{ text = STRINGS.UI.BROADCASTING.SIGNUP, cb = function() VisitURL("http://twitch.tv") end },
		{ text = STRINGS.UI.BROADCASTING.CANCEL, cb = function() self:Close() end },
	}

	self.menu = self.root:AddChild(Menu(menu_items, 200, true))
	self.menu:SetPosition(-170, -130)

	self.edit_username:SetFocus()
end

return BroadcastingLoginScreen