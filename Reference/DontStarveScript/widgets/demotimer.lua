local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"

-------------------------------------------------------------------------------------------------------

local DemoTimer = Class(Widget, function(self, owner)
    self.owner = owner

    Widget._ctor(self, "DemoTimer")
    
    local font = UIFONT
    self.purchasebutton = self:AddChild(ImageButton(UI_ATLAS, "button.tex", "button_over.tex", "button_disabled.tex"))
    self.purchasebutton:SetPosition(-60, 0, 0)
    self.purchasebutton:SetText(STRINGS.UI.HUD.BUYNOW)
    self.purchasebutton:SetOnClick( function() self:Purchase() end)
    self.purchasebutton:SetFont(font)
    
    self.base_scale = .5
    self.purchasebutton:SetTextSize(50) 
    self.purchasebutton:SetScale(self.base_scale,self.base_scale,self.base_scale)
    
    self.text = self:AddChild(Text(NUMBERFONT, 40))
    self.text:SetString("0:00")
    self.text:SetHAlign(ANCHOR_LEFT)
    self.text:SetVAlign(ANCHOR_MIDDLE)
	self.text:SetRegionSize( 350, 50 )
	self.text:SetPosition( 145, 0, 0 )
	
    self:OnUpdate()
    self:StartUpdating()
end)

function DemoTimer:Purchase()
	ShowUpsellScreen(false)
end

function DemoTimer:OnUpdate()
    if self.owner and not IsGamePurchased() then
		local time = GetTimePlaying()
		local time_left = TUNING.DEMO_TIME - time
		
		if time_left > 0 then
			local minutes = math.floor(time_left / 60)
			local seconds = math.floor(time_left - minutes*60)
	        
			if minutes > 0 then
				self.text:SetString(string.format("Demo %d:%02d", minutes, seconds ))
			else
				self.text:SetString(string.format("Demo %02d", seconds ))
			end
		else
			self.text:SetString(string.format("Demo Over!"))
		end
    end
end

return DemoTimer