local Widget = require "widgets/widget"

local ItemSlot = Class(Widget, function(self, atlas, bgim, owner)
    Widget._ctor(self, "ItemSlot")
    self.owner = owner
    self.bgimage = self:AddChild(Image(atlas, bgim))
    self.tile = nil    
end)

function ItemSlot:Highlight()
	if not self.big then
		self:ScaleTo(1, 1.3, .125)
		self.big = true	
	end
end

function ItemSlot:DeHighlight()
    if self.big then    
        self:ScaleTo(1.3, 1, .25)
        self.big = false
    end
end

function ItemSlot:OnGainFocus()
	self:Highlight()

end

function ItemSlot:OnLoseFocus()
	self:DeHighlight()
end

function ItemSlot:SetTile(tile)
    if self.tile and tile ~= self.tile then
        self.tile = self.tile:Kill()
    end

    if tile then
        self.tile = self:AddChild(tile)
    end
end

function ItemSlot:Inspect()
    if self.tile and self.tile.item then 
        GetPlayer().components.locomotor:PushAction(BufferedAction(GetPlayer(), self.tile.item, ACTIONS.LOOKAT), true)
    end
end

return ItemSlot

