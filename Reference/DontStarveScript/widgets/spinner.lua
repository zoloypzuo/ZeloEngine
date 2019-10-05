require "fonts"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local ThreeSlice = require "widgets/threeslice"
local Text = require "widgets/text"
local Image = require "widgets/image"
--
-- You should override the On* functions to implement desired behaviour.
--
-- For example, OnChanged gets called by Changed, the base function. Both get passed the newly selected item.


local spinner_images = {
	arrow_normal = "spin_arrow.tex",
	arrow_over = "spin_arrow_over.tex",
	arrow_disabled = "spin_arrow_disabled.tex",
	arrow_down = "spin_arrow_down.tex",
	bg_middle = "spinner_short.tex",
	bg_middle_focus = "spinner_short_focus.tex",
	bg_middle_changing = "spinner_short_changing.tex",
	bg_end = "spinner_end.tex",
	bg_end_focus = "spinner_end_focus.tex",
	bg_end_changing = "spinner_end_changing.tex",
}

local spinner_atlas = "images/ui.xml"
local spinfont = { font = BUTTONFONT, size = 30 }
local default_width = 200
local default_height = 64


local Spinner = Class(Widget, function( self, options, width, height, textinfo, editable, atlas, textures )
    Widget._ctor(self, "SPINNER")

    
	atlas = atlas or spinner_atlas
	textinfo = textinfo or spinfont
	self.width = width or default_width
	self.height = height or default_height
	
	textures = textures or spinner_images
	atlas = atlas or spinner_atlas

	self.editable = editable or false
	self.options = options
	self.selectedIndex = 1
	--self.textsize = {width = width, height = height}
	self.textcolour = { 1, 1, 1, 1 }
	
	self.atlas = atlas

    self.background = self:AddChild(ThreeSlice(atlas, textures.bg_end, textures.bg_middle))
    self.background:Flow(self.width, self.height, true)

    self.leftimage = self:AddChild( ImageButton(atlas, textures.arrow_normal, textures.arrow_over, textures.arrow_disabled, textures.arrow_down) )
    self.rightimage = self:AddChild( ImageButton(atlas, textures.arrow_normal, textures.arrow_over, textures.arrow_disabled, textures.arrow_down) )
    self.leftimage.silent = true
    self.rightimage.silent = true

	local arrow_scale = 1

	if atlas and textures then
		self.textures = textures
		local arrow_width, arrow_height = self.leftimage:GetSize()
		arrow_scale = arrow_scale * self.height / arrow_height
		self.leftimage:SetScale( -arrow_scale, arrow_scale, 1 )
		self.rightimage:SetScale( arrow_scale, arrow_scale, 1 )
	end

	self.fgimage = self:AddChild( Image() )

	if editable then
	    self.text = self:AddChild( TextEdit( textinfo.font, textinfo.size ) )
	else
	    self.text = self:AddChild( Text( textinfo.font, textinfo.size ) )
	end

	--self.text:SetRegionSize( self.textsize.width, self.textsize.height )
    self.text:Show()

	self.updating = false

	self:Layout()
	self:SetSelectedIndex(1)

	self.changing = false
	self.leftimage:SetOnClick(function() self:Prev(true) end)
	self.rightimage:SetOnClick(function() self:Next(true) end)
end)


function Spinner:OnFocusMove(dir, down)
	if Spinner._base.OnFocusMove(self,dir,down) then return true end

	if self.changing and down then
		if dir == MOVE_LEFT then
			self:Prev()
			return true
		elseif dir == MOVE_RIGHT then
			self:Next()
			return true
		else
			self.changing = false
			self:UpdateBG()
		end
	end
	
end

function Spinner:OnGainFocus()
	Spinner._base.OnGainFocus(self)
	self:UpdateBG()
end

function Spinner:GetHelpText()
	local controller_id = TheInput:GetControllerID()

	local t = {}
	if self.leftimage.enabled then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PREVVALUE) .. " " .. STRINGS.UI.HELP.PREVVALUE)
	end

	if self.rightimage.enabled then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_NEXTVALUE) .. " " .. STRINGS.UI.HELP.NEXTVALUE)
	end
	
	return table.concat(t, "  ")
end

function Spinner:OnLoseFocus()
	Spinner._base.OnLoseFocus(self)
	self.changing = false
	self:UpdateBG()
end

function Spinner:OnControl(control, down)
	if Spinner._base.OnControl(self, control, down) then return true end

	if not down then
		if control == CONTROL_PREVVALUE then
			self:Prev()
			return true
		elseif control == CONTROL_NEXTVALUE then
			self:Next()
			return true
		end
	end

	--[[if not down and control == CONTROL_ACCEPT then
		if self.changing then
			self.changing = false
			self:UpdateBG()
		else
			self.changing = true
			self:UpdateBG()
			self.saved_idx = self:GetSelectedIndex()
		end
		return true
	end

	if not down and control == CONTROL_CANCEL then
		if self.changing then
			self.changing = false
			self:UpdateBG()
			if self.saved_idx then
				self:SetSelectedIndex(self.saved_idx)
				self.saved_idx = nil
			end
			return true
		end
	end--]]


end

function Spinner:UpdateBG()
	if self.changing then 
		self.background:SetImages(self.atlas, self.textures.bg_end_changing, self.textures.bg_middle_changing)
	elseif self.focus then
		self.background:SetImages(self.atlas, self.textures.bg_end_focus, self.textures.bg_middle_focus)
	else
		self.background:SetImages(self.atlas, self.textures.bg_end, self.textures.bg_middle)
	end

end

function Spinner:SetTextColour(r,g,b,a)
	self.textcolour = { r, g, b, a }
	self.text:SetColour( r, g, b, a )
end

function Spinner:Enable()
	self._base.Enable(self)
	self.text:SetColour( self.textcolour )
	self:UpdateState()
end

function Spinner:Disable()
	self._base.Disable(self)
	self.text:SetColour(.7,.7,.7,1)
	self.leftimage:Disable()
	self.rightimage:Disable()
end

function Spinner:SetFont(font)
	self.text:SetFont(font)
end

function Spinner:SetOnClick( fn )
    self.onclick = fn
end

function Spinner:SetTextSize(sz)
	self.text:SetSize(sz)
end

function Spinner:GetWidth()
	return self.width
end

function Spinner:Layout()
	local w = self.rightimage:GetSize()
	self.rightimage:SetPosition( self.width/2 - w/2, 0, 0 )
	self.leftimage:SetPosition( -self.width/2 + w/2, 0, 0 )
end

function Spinner:SetTextHAlign( align )
    self.text:SetHAlign( align )
end

function Spinner:SetTextVAlign( align )
    self.text:SetVAlign( align )
end

function Spinner:Next(noclicksound)
	local oldSelection = self.selectedIndex
	local newSelection = oldSelection
	if self.enabled then
		if self.enableWrap then
			newSelection = self.selectedIndex + 1
			if newSelection > self:MaxIndex() then
				newSelection = self:MinIndex()
			end
		else
			newSelection = math.min( newSelection + 1, self:MaxIndex() )
		end
	end
	if newSelection ~= oldSelection then
		if not noclicksound then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
		self:OnNext()
		self:SetSelectedIndex(newSelection)
		self:Changed()
	else
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative")
	end
end

function Spinner:Prev(noclicksound)
	local oldSelection = self.selectedIndex
	local newSelection = oldSelection
	if self.enabled then
		if self.enableWrap then
			newSelection = self.selectedIndex - 1
			if newSelection < self:MinIndex() then
				newSelection = self:MaxIndex()
			end
		else
			newSelection = math.max( self.selectedIndex - 1, self:MinIndex() )
		end
	end
	if newSelection ~= oldSelection then
		if not noclicksound then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
		self:OnPrev()
		self:SetSelectedIndex(newSelection)
		self:Changed()
	else
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative")
	end
end

function Spinner:GetSelected()
	return self.options[ self.selectedIndex ]
end

function Spinner:GetSelectedIndex()
	return self.selectedIndex
end

function Spinner:GetSelectedText()
	return self.options[ self.selectedIndex ].text
end

function Spinner:GetSelectedImage()
	return self.options[ self.selectedIndex ].image
end

function Spinner:GetSelectedData()
	return self.options[ self.selectedIndex ].data
end

function Spinner:SetSelectedIndex( idx )
	self.updating = true
	self.selectedIndex = math.max(self:MinIndex(), math.min(self:MaxIndex(), idx))
	
	local selected_text = self:GetSelectedText()	
	self:UpdateText( selected_text )
	
	if self.options[ self.selectedIndex ] ~= nil then 
		local selected_image = self:GetSelectedImage()
		if selected_image ~= nil then
			self.fgimage:SetTexture( selected_image )
		end
	end
	
	self:UpdateState()
	self.updating = false
end

function Spinner:SetSelected( data )
	
	for k,v in pairs(self.options) do
		if v.data == data then
			self:SetSelectedIndex(k)			
			return
		end
	end
end

function Spinner:UpdateText( msg )
	self.text:SetString(msg)
end

function Spinner:GetText()
	return self.text:GetString()
end

function Spinner:OnNext()
end

function Spinner:OnPrev()
end

function Spinner:Changed()
	if not self.updating then
		self:OnChanged( self:GetSelectedData() )
		self:UpdateState()
	end
end

function Spinner:SetOnChangedFn(fn)
	self.onchangedfn = fn
end

function Spinner:OnChanged( selected )
	if self.onchangedfn then
		self.onchangedfn(selected)
	end
end

function Spinner:MinIndex()
	return 1
end

function Spinner:MaxIndex()
	return #self.options
end

function Spinner:SetWrapEnabled(enable)
	self.enableWrap = enable
	self:UpdateState()
end

function Spinner:UpdateState()
	if self.enabled then
		self.leftimage:Enable()
		self.rightimage:Enable()
		if not self.enableWrap then
			if self.selectedIndex == self:MinIndex() then
				self.leftimage:Disable()
			end
			if self.selectedIndex == self:MaxIndex() then
				self.rightimage:Disable()
			end
		end
	else
		self.leftimage:Disable()
		self.rightimage:Disable()
	end
end


function Spinner:SetOptions( options )
	self.options = options
	if self.selectedIndex > #self.options then
		self:SetSelectedIndex( #self.options )
	end
	self:UpdateState()
end

return Spinner
