require "util"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local TextEdit = require "widgets/textedit"
local Widget = require "widgets/widget"

local PopupDialogScreen = require "screens/popupdialog"

local UI_ATLAS = "images/ui.xml"
local EMAIL_VALID_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.@!#$%&'*+-/=?^_`{|}~"
local EMAIL_MAX_LENGTH = 254 -- http://tools.ietf.org/html/rfc5321#section-4.5.3.1
local MIN_AGE = 3 -- ages less than this prompt error message, eg. if they didn't change the date at all

local EmailSignupScreen = Class(Screen, function(self)
	Screen._ctor(self, "EmailSignupScreen")

	self:DoInit()

end)

function EmailSignupScreen:OnControl(control, down)
	if EmailSignupScreen._base.OnControl(self, control, down) then return true end

	if not down and control == CONTROL_CANCEL then
		self:Close()
		return true
	end
end

function EmailSignupScreen:Accept()
	if self:Save() then
		-- wait for callback
	end
end

function EmailSignupScreen:OnSubmitCancel()
	print('EmailSignupScreen:OnSubmitCancel()')
	if self.submitscreen then
		print('...closing submit screen')
		self.submitscreen:Close()
		self.submitscreen = nil
	end
end

function EmailSignupScreen:OnPostComplete( result, isSuccessful, resultCode )
	print('EmailSignupScreen:OnPostComplete()', isSuccessful, resultCode, result)

	-- if we don't have a submitscreen then the user cancelled before we got the callback
	if self.submitscreen then
		print('...closing submit screen')
		self.submitscreen:Close()
		self.submitscreen = nil

		-- isSuccessful only tells us that the server successfully returned some result
		-- we still need to check if that result was an error or not
		if isSuccessful and (resultCode == 200) then
			self:Close()

			TheFrontEnd:PushScreen(
				PopupDialogScreen( STRINGS.UI.EMAILSCREEN.SIGNUPSUCCESSTITLE, STRINGS.UI.EMAILSCREEN.SIGNUPSUCCESS,
				  { { text = STRINGS.UI.EMAILSCREEN.OK, cb =
						function()
							TheFrontEnd:PopScreen()
						end
					} }
				  )
			)
		else
			TheFrontEnd:PushScreen(
				PopupDialogScreen( STRINGS.UI.EMAILSCREEN.SIGNUPFAILTITLE, STRINGS.UI.EMAILSCREEN.SIGNUPFAIL,
				  { { text = STRINGS.UI.EMAILSCREEN.OK, cb =
						function()
							TheFrontEnd:PopScreen()
						end
					} }
				  )
			)
		end
	else
		print('...no submit screen, user cancelled?')
	end
end

function EmailSignupScreen:Save()
	local email = self.email_edit:GetString()
	print ("EmailSignupScreen:Save()", email)
	
	local bmonth = self.monthSpinner:GetSelectedIndex()
	local bday = self.daySpinner:GetSelectedIndex()
	local byear = self.yearSpinner:GetSelectedIndex()
	
	if not self:IsValidEmail(email) then
		TheFrontEnd:PushScreen(
			
			PopupDialogScreen( STRINGS.UI.EMAILSCREEN.INVALIDEMAILTITLE, STRINGS.UI.EMAILSCREEN.INVALIDEMAIL,
			  { { text = STRINGS.UI.EMAILSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end } }
			  )
		)
		return false
	end
	
	if not self:IsValidBirthdate(bday, bmonth, byear) then
		TheFrontEnd:PushScreen(
			PopupDialogScreen( STRINGS.UI.EMAILSCREEN.INVALIDDATETITLE, STRINGS.UI.EMAILSCREEN.INVALIDDATE,
			  { { text = STRINGS.UI.EMAILSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end } }
			  )
		)
		return false
	end
	

	self.submitscreen = PopupDialogScreen( STRINGS.UI.EMAILSCREEN.SIGNUPSUBMITTITLE, STRINGS.UI.EMAILSCREEN.SIGNUPSUBMIT,
		  { { text = STRINGS.UI.EMAILSCREEN.CANCEL, cb = function(...) self:OnSubmitCancel(...) end } } )
	TheFrontEnd:PushScreen(self.submitscreen)

	local birth_date = byear .. "-" .. bmonth .. "-" .. bday
	print ("Birthday:", birth_date)
	
	local query = GAME_SERVER.."/email/subscribe/" .. email

	TheSim:QueryServer(
		query,
		function(...) self:OnPostComplete(...) end,
		"POST",
		json.encode({
			birthday = birth_date,
		}) 
	)
	return true
end

function EmailSignupScreen:IsValidBirthdate(day, month, year)
	print("EmailSignupScreen:IsValidBirthdate", day, month, year, self.minYear, self.maxYear)
	if day < 1 or day > 31 then
		return false
	end
	if month < 1 or month > 12 then
		return false
	end
	if year < self.minYear or year > self.maxYear - MIN_AGE then
		return false
	end
	return true
end

-- allow (anything)@(anything).(anything)
-- unless you want to write whatever unnecessarily complex expression would be required to be more accurate without excluding valid addresses
-- http://en.wikipedia.org/wiki/Email_address#Syntax

function EmailSignupScreen:IsValidEmail(email)
	local matchPattern = "^[%w%p]+@[%w%p]+%.[%w%p]+$"
	return string.match(email, matchPattern)
end

function EmailSignupScreen:Close()
	TheInput:EnableDebugToggle(true)
	TheFrontEnd:PopScreen(self)
end

function EmailSignupScreen:DoInit()

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
    --self.root:SetPosition(-RESOLUTION_X/2,-RESOLUTION_Y/2,0)
    

	--throw up the background
    self.bg = self.root:AddChild(Image("images/globalpanels.xml", "small_dialog.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(1.6, 2, 1)    

    local title_size = 300
    local title_offset = 120

    self.title = self.root:AddChild(Text(TITLEFONT, 50))

    self.title:SetString(STRINGS.UI.EMAILSCREEN.TITLE)
    self.title:SetHAlign(ANCHOR_MIDDLE)
    self.title:SetVAlign(ANCHOR_MIDDLE)
	--self.title:SetRegionSize( title_size, 50 )
    self.title:SetPosition(0, title_offset, 0)


	local label_width = 200
	local label_height = 50
	local label_offset = 275

	local space_between = 30
	local height_offset = 60

	local email_fontsize = 30

	
	self.email_label = self.root:AddChild( Text( BODYTEXTFONT, email_fontsize, STRINGS.UI.EMAILSCREEN.EMAIL ) )
	self.email_label:SetPosition( -(label_width * .5 + label_offset), height_offset, 0 )
	self.email_label:SetRegionSize( label_width, label_height )
	self.email_label:SetHAlign(ANCHOR_RIGHT)

	self.bday_label = self.root:AddChild( Text( BODYTEXTFONT, email_fontsize, STRINGS.UI.EMAILSCREEN.BIRTHDAY ) )
	self.bday_label:SetPosition( -(label_width * .5 + label_offset), 0, 0 )
	self.bday_label:SetRegionSize( label_width, label_height )
	self.bday_label:SetHAlign(ANCHOR_RIGHT)

	local edit_width = 550
	local edit_bg_padding = 60
	
	self.bday_message = self.root:AddChild( Text( BODYTEXTFONT, 24,  STRINGS.UI.EMAILSCREEN.BIRTHDAYREASON ) )
	self.bday_message:SetPosition( 0, -height_offset, 0 )
	self.bday_message:SetRegionSize( 700, label_height * 2 )
	self.bday_message:EnableWordWrap(true)
	--self.bday_message:SetHAlign(ANCHOR_LEFT)


    self.edit_bg = self.root:AddChild( Image() )
	self.edit_bg:SetTexture( "images/ui.xml", "textbox_long.tex" )
	self.edit_bg:SetPosition( (edit_width * .5) - label_offset + space_between, height_offset, 0 )
	self.edit_bg:ScaleToSize( edit_width + edit_bg_padding, label_height )

	self.email_edit = self.root:AddChild( TextEdit( BODYTEXTFONT, email_fontsize, "" ) )
	self.email_edit:SetPosition( (edit_width * .5) - label_offset + space_between, height_offset, 0 )
	self.email_edit:SetRegionSize( edit_width, label_height )
	self.email_edit:SetHAlign(ANCHOR_LEFT)
	self.email_edit:SetFocusedImage( self.edit_bg, UI_ATLAS, "textbox_long_over.tex", "textbox_long.tex" )
	self.email_edit:SetTextLengthLimit(EMAIL_MAX_LENGTH)
	self.email_edit:SetCharacterFilter( EMAIL_VALID_CHARS )

	local text_font = BODYTEXTFONT


	local months = {
		{ text = STRINGS.UI.EMAILSCREEN.JAN},
		{ text = STRINGS.UI.EMAILSCREEN.FEB},
		{ text = STRINGS.UI.EMAILSCREEN.MAR},
		{ text = STRINGS.UI.EMAILSCREEN.APR},
		{ text = STRINGS.UI.EMAILSCREEN.MAY},
		{ text = STRINGS.UI.EMAILSCREEN.JUN},
		{ text = STRINGS.UI.EMAILSCREEN.JUL},
		{ text = STRINGS.UI.EMAILSCREEN.AUG},
		{ text = STRINGS.UI.EMAILSCREEN.SEP},
		{ text = STRINGS.UI.EMAILSCREEN.OCT},
		{ text = STRINGS.UI.EMAILSCREEN.NOV},
		{ text = STRINGS.UI.EMAILSCREEN.DEC},
	}

	--self.monthSpinner = Spinner( months, 100, 50, { font = text_font, size = email_fontsize}, UI_ATLAS, spinner_images, 0.5, false )
	--self.daySpinner = NumericSpinner( 1, 31, 50, 50, { font = text_font, size = email_fontsize }, UI_ATLAS, spinner_images, 0.5, true )
	--self.yearSpinner = NumericSpinner( self.minYear, self.maxYear, 100, 50, { font = text_font, size = email_fontsize }, UI_ATLAS, spinner_images, 0.5, true )

	self.spinners = self.root:AddChild(Widget("spinners"))
	
	self.monthSpinner = self.spinners:AddChild(Spinner( months))
	self.daySpinner = self.spinners:AddChild(NumericSpinner( 1, 31))
	self.yearSpinner = self.spinners:AddChild(NumericSpinner( self.minYear, self.maxYear ))

	self.spinners:SetPosition(30,0,0)
	self.monthSpinner:SetPosition(-200, 0, 0)
	self.yearSpinner:SetPosition(200, 0, 0)

	self.monthSpinner:SetTextColour(0,0,0,1)
	self.daySpinner:SetTextColour(0,0,0,1)
	self.yearSpinner:SetTextColour(0,0,0,1)

	self.daySpinner:SetSelectedIndex(tonumber(os.date("%d")))
	self.monthSpinner:SetSelectedIndex(tonumber(os.date("%m")))
	self.yearSpinner:SetSelectedIndex(tonumber(os.date("%Y")))

--[[	local spinners = {}

	table.insert( spinners, { 160, self.monthSpinner, tonumber(os.date("%m")), 2 } )
	table.insert( spinners, { 110, self.daySpinner, tonumber(os.date("%d")), 2 } )
	table.insert( spinners, { 110, self.yearSpinner, tonumber(os.date("%Y")), 4 } )

	self:AddSpinners( spinners )
-]]	
	
	self.monthSpinner:SetWrapEnabled(true)
	self.daySpinner:SetWrapEnabled(true)
	self.yearSpinner:SetWrapEnabled(false)
	
	--[[
	local month_edit_w = 20 + edit_bg_padding
	local day_edit_w = 20 + edit_bg_padding
	local year_edit_w = 50 + edit_bg_padding
	

	local bday_fields = { 
		{ name=STRINGS.UI.EMAILSCREEN.MONTH, width=30 },
		{ name=STRINGS.UI.EMAILSCREEN.DAY, width=30 },
		{ name=STRINGS.UI.EMAILSCREEN.YEAR, width=50 },
	}
	--]]
	
	local menu_items = {
		{ text = STRINGS.UI.EMAILSCREEN.SUBSCRIBE, cb = function() self:Accept() end },
		{ text = STRINGS.UI.EMAILSCREEN.CANCEL, cb = function() self:Close() end },
	}

	self.menu = self.root:AddChild(Menu(menu_items, 200, true))
	self.menu:SetPosition(-100, -130)

	self.default_focus = self.menu

end

return EmailSignupScreen