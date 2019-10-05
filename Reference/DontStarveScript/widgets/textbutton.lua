local Widget = require "widgets/widget"
local Button = require "widgets/button"
local Text = require "widgets/text"
local Image = require "widgets/image"

local TextButton = Class(Button, function(self, name)
	Button._ctor(self, name or "TEXTBUTTON")

    self.image = self:AddChild(Image("images/ui.xml", "blank.tex"))
    self.text = self:AddChild(Text(DEFAULTFONT, 30))

	self.colour = {0.9,0.8,0.6,1}
	self.overcolour = {1,1,1,1}
end)

	
function TextButton:OnGainFocus()
	TextButton._base.OnGainFocus(self)
    if self:IsEnabled() then
    	self.text:SetColour(self.overcolour)
	end

    if self.image_focus == self.image_normal then
        self.image:SetScale(1.2,1.2,1.2)
    end

end

function TextButton:OnLoseFocus()
	TextButton._base.OnLoseFocus(self)
    if self:IsEnabled() then
    	self.text:SetColour(self.colour)
	end

    if self.image_focus == self.image_normal then
        self.image:SetScale(1,1,1)
    end
end


function TextButton:Enable()
	TextButton._base.Enable(self)
    self.image:SetTexture(self.atlas, self.focus and self.image_focus or self.image_normal)

    if self.image_focus == self.image_normal then
        if self. focus then 
            self.image:SetScale(1.2,1.2,1.2)
        else
            self.image:SetScale(1,1,1)
        end
    end

end

function TextButton:Disable()
	TextButton._base.Disable(self)
	self.image:SetTexture(self.atlas, self.image_disabled)
end

function TextButton:GetSize()
    return self.image:GetSize()
end

function TextButton:SetTextSize(sz)
	self.text:SetSize(sz)
end

function TextButton:SetText(msg)
    if msg then
        self.text:SetString(msg)
        self.text:Show()
    else
        self.text:Hide()
    end
	self.image:SetSize(self.text:GetRegionSize())
end

function TextButton:SetFont(font)
	self.text:SetFont(font)
end

function TextButton:SetColour(r,g,b,a)
	if type(r) == "number" then
		self.colour = {r,g,b,a}
	else
		self.colour = r
	end
	self.text:SetColour(self.colour)
end

function TextButton:SetOverColour(r,g,b,a)
	if type(r) == "number" then
		self.overcolour = {r,g,b,a}
	else
		self.overcolour = r
	end
end

function TextButton:SetOnClick( fn )
    self.onclick = fn
end

return TextButton
