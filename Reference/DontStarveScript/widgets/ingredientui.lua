require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"


local IngredientUI = Class(Widget, function(self, atlas, image, quantity, on_hand, has_enough, name, owner)
    Widget._ctor(self, "IngredientUI")
    
    --self:SetClickable(false)
    
    local hud_atlas = resolvefilepath( "images/hud.xml" )
    
    if has_enough then
        self.bg = self:AddChild(Image(hud_atlas, "inv_slot.tex"))
    else
        self.bg = self:AddChild(Image(hud_atlas, "resource_needed.tex"))
    end
    
    self:SetTooltip(name)
    
    self.ing = self:AddChild(Image(atlas, image))
    if quantity then

        if owner and owner.components.builder then
            quantity = RoundUp(quantity * owner.components.builder.ingredientmod)
        end

        if JapaneseOnPS4() then
            self.quant = self:AddChild(Text(SMALLNUMBERFONT, 30))
        else
            self.quant = self:AddChild(Text(SMALLNUMBERFONT, 24))
        end
        self.quant:SetPosition(7,-32, 0)
        self.quant:SetString(string.format("%d/%d", on_hand,quantity))
        if not has_enough then
            self.quant:SetColour(255/255,155/255,155/255,1)
        end
    end
end)

return IngredientUI
