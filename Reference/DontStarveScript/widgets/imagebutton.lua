local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Button = require "widgets/button"
local Image = require "widgets/image"

local ImageButton = Class(Button, function(self, atlas, normal, focus, disabled)
    Button._ctor(self, "ImageButton")

    if not atlas then
        atlas = atlas or "images/ui.xml"
        normal = normal or "button.tex"
        focus = focus or "button_over.tex"
        disabled = disabled or "button_disabled.tex"
    end

    self.image = self:AddChild(Image())
    self.image:MoveToBack()

    self.atlas = atlas
	self.image_normal = normal
    self.image_focus = focus or normal
    self.image_disabled = disabled or normal
    
    self.image:SetTexture(self.atlas, self.image_normal)
end)


function ImageButton:SetTextures(atlas, normal, focus, disabled )
    local default_textures = false
    if not atlas then
        atlas = atlas or "images/frontend.xml"
        normal = normal or "button_long.tex"
        focus = focus or "button_long_halfshadow.tex"
        disabled = disabled or "button_long_disabled.tex"
        default_textures = true
    end
    
    self.atlas = atlas
	self.image_normal = normal
    self.image_focus = focus or normal
    self.image_disabled = disabled or normal

	if self:IsEnabled() then
        if self.focus then
            self:OnGainFocus()
        else
            self:OnLoseFocus()
        end
    else
        self:OnDisable()
    end
end

function ImageButton:OnGainFocus()
	ImageButton._base.OnGainFocus(self)
    if self:IsEnabled() then
    	self.image:SetTexture(self.atlas, self.image_focus)
	end

    if self.image_focus == self.image_normal then
        self.image:SetScale(1.2,1.2,1.2)
    end

end

function ImageButton:OnLoseFocus()
	ImageButton._base.OnLoseFocus(self)
    if self:IsEnabled() then
    	self.image:SetTexture(self.atlas, self.image_normal)
	end

    if self.image_focus == self.image_normal then
        self.image:SetScale(1,1,1)
    end
end


function ImageButton:Enable()
	ImageButton._base.Enable(self)
    self.image:SetTexture(self.atlas, self.focus and self.image_focus or self.image_normal)

    if self.image_focus == self.image_normal then
        if self.focus then 
            self.image:SetScale(1.2,1.2,1.2)
        else
            self.image:SetScale(1,1,1)
        end
    end

end

function ImageButton:Disable()
	ImageButton._base.Disable(self)
	self.image:SetTexture(self.atlas, self.image_disabled)
end

function ImageButton:GetSize()
    return self.image:GetSize()
end

return ImageButton