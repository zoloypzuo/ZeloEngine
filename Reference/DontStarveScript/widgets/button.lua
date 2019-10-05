local Widget = require "widgets/widget"
local Text = require "widgets/text"

--base class for imagebuttons and animbuttons. 
local Button = Class(Widget, function(self)
    Widget._ctor(self, "BUTTON")

    self.text = self:AddChild(Text(BUTTONFONT, 40))
	self.text:SetVAlign(ANCHOR_MIDDLE)
    self.text:SetColour(0,0,0,1)
    self.text:Hide()

	self.textcol = {0,0,0,1}
	self.textfocuscolour = {0,0,0,1}
	self.clickoffset = Vector3(0,-3,0)
	
end)


function Button:OnControl(control, down)
	
	if Button._base.OnControl(self, control, down) then return true end

	if not self:IsEnabled() or not self.focus then return end
	
	if control == CONTROL_ACCEPT then
		if down then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			self.o_pos = self:GetLocalPosition()
			self:SetPosition(self.o_pos + self.clickoffset)
			self.down = true
		else
			if self.down then
				self.down = false
				self:SetPosition(self.o_pos)
				if self.onclick then
					self.onclick()
				end
			end
		end
		
		return true
	end

end

function Button:OnGainFocus()

	Button._base.OnGainFocus(self)
	self.text:SetColour(self.textfocuscolour[1],self.textfocuscolour[2],self.textfocuscolour[3],self.textfocuscolour[4])
    if self:IsEnabled() then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
	end
end

function Button:OnLoseFocus()
	Button._base.OnLoseFocus(self)
	self.text:SetColour(self.textcol)
	if self.o_pos then
		self:SetPosition(self.o_pos)
	end
	self.down = false
end

function Button:SetFont(font)
	self.text:SetFont(font)
end

function Button:SetOnClick( fn )
    self.onclick = fn
end

function Button:SetTextColour(r,g,b,a)
	self.textcol = {r,g,b,a}
	
	if not self.focus then
		self.text:SetColour(self.textcol)
	end
end

function Button:SetTextFocusColour(r,g,b,a)
	self.textfocuscolour = {r,g,b,a}
	
	if self.focus then
		self.text:SetColour(self.textfocuscolour)
	end
end

function Button:SetTextSize(sz)
	self.text:SetSize(sz)
end

function Button:GetText()
    return self.text:GetString()
end

function Button:SetText(msg)
    if msg then
    	self.name = msg or "button"
        self.text:SetString(msg)
        self.text:Show()
		self.text:SetColour(self.focus and self.textfocuscolour or self.textcol)
    else
        self.text:Hide()
    end


end

function Button:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.SELECT)	
	return table.concat(t, "  ")
end

return Button