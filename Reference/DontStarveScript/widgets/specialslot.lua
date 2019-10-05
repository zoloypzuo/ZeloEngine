local ItemSlot = require "widgets/itemslot"
local ItemTile = require "widgets/itemtile"

local SpecialSlot = Class(ItemSlot, function(self, atlas, bgim, owner)
    ItemSlot._ctor(self, atlas, bgim, owner)
    self.owner = owner
    self.highlight = false
    self.is_special = true
    --self.bg = self:AddChild(Image("images/hud.xml", "inventory_bg_single.tex"))
    --self.bg:SetScale(0.9)
    --self.bg:MoveToBack()

end)

function SpecialSlot:Click()
    if self.onclickfn then
        self.onclickfn(self)
    end

    self:OnControl(CONTROL_ACCEPT, true)
end

function SpecialSlot:OnControl(control, down)
    if self.oncontrolfn then
        self.oncontrolfn(self, control, down)
    else
        print ("NO CONTROLFN FOUND ON SPECIAL SLOT")
    end
end

function SpecialSlot:OnItemGet(item)
    if not item then
        -- print ("ERROR! SOMEHOW THE ITEM RECEIVED BECAME NIL, PLEASE REPORT")
        -- print (debugstack())
        return
    end

    if self.onitemgetfn then
        self.onitemgetfn(self, item)
    end

    local tile = ItemTile(item)
    self:SetTile(tile)
    tile:Show()
end

function SpecialSlot:OnItemLose()
    if self.onitemlosefn then
        self.onitemlosefn(self)
    end

    self:SetTile(nil)
end

return SpecialSlot