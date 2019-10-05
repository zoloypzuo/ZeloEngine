require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local CraftSlot = require "widgets/craftslot"
local Crafting = require "widgets/crafting"

require "widgets/widgetutil"

local MouseCrafting = Class(Crafting, function(self)
    Crafting._ctor(self, 7)
    self:SetOrientation(false)
    self.in_pos = Vector3(145, 0, 0)
    self.out_pos = Vector3(0, 0, 0)
    self.craftslots:EnablePopups()
end)


return MouseCrafting