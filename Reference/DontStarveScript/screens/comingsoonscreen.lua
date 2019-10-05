local Screen = require "widgets/screen"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Widget = require "widgets/widget"

local ComingSoonScreen = Class(Screen, function(self)
    Widget._ctor(self, "ComingSoonScreen")

    self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))

    SetBGcolor(self.bg)

    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    
    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.worldgentext = self.root:AddChild(Text(TITLEFONT, 100))
    self.worldgentext:SetPosition(0, 200, 0)
    self.worldgentext:SetString(STRINGS.UI.COMINGSOONSCREEN.TITLE)
    
    --menu buttons
    
    if not TheInput:ControllerAttached() then
		self.cancelbutton = self.root:AddChild(ImageButton())
	    self.cancelbutton:SetPosition(0, -260, 0)
	    self.cancelbutton:SetText(STRINGS.UI.COMINGSOONSCREEN.OK)
	    self.cancelbutton.text:SetColour(0,0,0,1)
	    self.cancelbutton:SetOnClick( function() TheFrontEnd:PopScreen(self) end )
	    self.cancelbutton:SetFont(BUTTONFONT)
	    self.cancelbutton:SetTextSize(40)
	end
end)

function ComingSoonScreen:OnControl(control, down)
    
    if ComingSoonScreen._base.OnControl(self, control, down) then return true end
    if not down then
    	if control == CONTROL_CANCEL or CONTROL_ACCEPT then
    		TheFrontEnd:PopScreen(self)
    	else
    		return false
    	end 

    	return true
    end

end

return ComingSoonScreen