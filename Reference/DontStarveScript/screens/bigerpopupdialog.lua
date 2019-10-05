local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"


local BigerPopupDialogScreen = Class(Screen, function(self, title, text, buttons, timeout, button_spacing, title_pos)
	Screen._ctor(self, "BigerPopupDialogScreen")

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

	--throw up the background
    self.bg = self.proot:AddChild(Image("images/globalpanels.xml", "panel_upsell.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetScale(0.8,0.8,0.8)
	
	--if #buttons >2 then
	--	self.bg:SetScale(2,1.2,1.2)
	--end
	
	--title	
    self.title = self.proot:AddChild(Text(TITLEFONT, 50))
    self.title:SetPosition(title_pos or Vector3(0, 180, 0))
    self.title:SetString(title)

	--text
    --[[
    if JapaneseOnPS4() then
       self.text = self.proot:AddChild(Text(BODYTEXTFONT, 28))
    else
       self.text = self.proot:AddChild(Text(BODYTEXTFONT, 30))
    end
    ]]
    self.text = self.proot:AddChild(Text(BODYTEXTFONT, 30))

    self.text:SetPosition(0, 5, 0)
    self.text:SetString(text)
    self.text:EnableWordWrap(true)
    --[[
    if JapaneseOnPS4() then
        self.text:SetRegionSize(500, 300)
    else
        self.text:SetRegionSize(500, 200)
    end
    ]]
    self.text:SetRegionSize(700, 350)
	
	--create the menu itself
	local button_w = 200
	local space_between = 20
	local spacing = button_w + space_between
	
	
    local spacing = button_spacing or 200

	self.menu = self.proot:AddChild(Menu(buttons, spacing, true))
	self.menu:SetPosition(-(spacing*(#buttons-1))/2, -220, 0) 
	self.buttons = buttons
	self.default_focus = self.menu
end)

function BigerPopupDialogScreen:OnUpdate( dt )
	if self.timeout then
		self.timeout.timeout = self.timeout.timeout - dt
		if self.timeout.timeout <= 0 then
			self.timeout.cb()
		end
	end
	return true
end

function BigerPopupDialogScreen:OnControl(control, down)
    if BigerPopupDialogScreen._base.OnControl(self,control, down) then 
        return true 
    end
end

return BigerPopupDialogScreen
