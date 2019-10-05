local ItemSlot = require "widgets/itemslot"

local EquipSlot = Class(ItemSlot, function(self, equipslot, atlas, bgim, owner)
    ItemSlot._ctor(self, atlas, bgim, owner)
    self.owner = owner
    self.equipslot = equipslot
    self.highlight = false

    self.inst:ListenForEvent("newactiveitem", function(inst, data)
        if data.item and data.item.components.equippable and data.item.components.equippable.equipslot == self.equipslot then
            self:ScaleTo(1, 1.3, .125)
            self.highlight = true
        elseif self.highlight then
            self.highlight = false
            self:ScaleTo(1.3, 1, .125)
        end
    end, self.owner)
end)

function EquipSlot:Click()
    self:OnControl(CONTROL_ACCEPT, true)
end

function EquipSlot:OnControl(control, down)
    if down then
        if control == CONTROL_ACCEPT then

            local active_item = GetPlayer().components.inventory:GetActiveItem()
            local current_item = GetPlayer().components.inventory:GetEquippedItem(self.equipslot)

            if current_item and current_item.components.equippable.un_unequipable then
                return 
            end

            if active_item and active_item.components.equippable and active_item.components.equippable.equipslot == self.equipslot then
                GetPlayer().components.inventory:Equip(active_item, true)
            elseif self.tile and not active_item then
                self.owner.components.inventory:SelectActiveItemFromEquipSlot(self.equipslot)
            end

            return true
        elseif control == CONTROL_SECONDARY and self.tile and self.tile.item then
            GetPlayer().components.inventory:UseItemFromInvTile(self.tile.item)
            return true
        end
    end
end

return EquipSlot