require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local RecipeTile = Class(Widget, function(self)
    Widget._ctor(self, "RecipeTile")
    self.img = self:AddChild(Image())
    self:SetClickable(false)
end)

function RecipeTile:SetVisual(atlas, image)
    self.img:SetTexture(atlas, image)
end

function RecipeTile:SetImageScale(scale)
    self.img:SetScale(scale, scale)
end

function RecipeTile:SetCanBuild(canbuild)
    if canbuild then
        self.img:SetTint(1, 1, 1, 1)
    else
        self.img:SetTint(0, 0, 0, 1)
    end
end

return RecipeTile
