local Widget = require "widgets/widget"
local Image = require "widgets/image"

local MapWidget = Class(Widget, function(self)
    Widget._ctor(self, "MapWidget")
	self.owner = GetPlayer()

    self.bg = self:AddChild(Image("images/hud.xml", "map.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.bg.inst.ImageWidget:SetBlendMode( BLENDMODE.Premultiplied )
    
    self.minimap = GetWorld().minimap.MiniMap
    
    self.img = self:AddChild(Image())
    self.img:SetHAnchor(ANCHOR_MIDDLE)
    self.img:SetVAnchor(ANCHOR_MIDDLE)
    self.img.inst.ImageWidget:SetBlendMode( BLENDMODE.Additive )    
    
	self.lastpos = nil
	self.minimap:ResetOffset()	
	self:StartUpdating()

end)


function MapWidget:SetTextureHandle(handle)
	self.img.inst.ImageWidget:SetTextureHandle( handle )
end

function MapWidget:OnZoomIn(  )
	if self.shown then
		self.minimap:Zoom( -1 )
	end
end

function MapWidget:OnZoomOut( )
	if self.shown and self.minimap:GetZoom() < 20 then
		self.minimap:Zoom( 1 )
	end
end

function MapWidget:UpdateTexture()
	local handle = self.minimap:GetTextureHandle()
	self:SetTextureHandle( handle )
end

function MapWidget:OnUpdate(dt)

	if not self.shown then return end
	
	if TheInput:IsControlPressed(CONTROL_PRIMARY) then
		local pos = TheInput:GetScreenPosition()
		if self.lastpos then
			local scale = 0.25
			local dx = scale * ( pos.x - self.lastpos.x )
			local dy = scale * ( pos.y - self.lastpos.y )
			self.minimap:Offset( dx, dy )
		end
		
		self.lastpos = pos
	else
		self.lastpos = nil
	end
end

function MapWidget:Offset(dx,dy)
	self.minimap:Offset(dx,dy)
end


function MapWidget:OnShow()
	self.minimap:ResetOffset()
end

function MapWidget:OnHide()
	self.lastpos = nil
end
return MapWidget