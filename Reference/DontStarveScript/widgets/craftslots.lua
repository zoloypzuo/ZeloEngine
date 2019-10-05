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

local CraftSlots = Class(Widget, function(self, num, owner)
    Widget._ctor(self, "CraftSlots")
    
    self.slots = {}
    for k = 1, num do
        local slot = CraftSlot(HUD_ATLAS, "craft_slot.tex", owner)
        slot.test_index = k
        self.slots[k] = slot
        self:AddChild(slot)
    end
end)

function CraftSlots:AddSlot(slot)
    local index = #self.slots + 1
    self.slots[index] = slot
    self:AddChild(slot)
end

function CraftSlots:EnablePopups()
    for k,v in ipairs(self.slots) do
        v:EnablePopup()
    end
end

function CraftSlots:Refresh()
	for k,v in pairs(self.slots) do
		v:Refresh()
	end
end

function CraftSlots:Open(idx)
	if idx > 0 and idx <= #self.slots then	
		self.slots[idx]:Open()
	end
end

function CraftSlots:LockOpen(idx)
	if idx > 0 and idx <= #self.slots then	
		self.slots[idx]:LockOpen()
	end
end

function CraftSlots:Clear()
    for k,v in ipairs(self.slots) do
        v:Clear()
    end
end

function CraftSlots:CloseAll()
    for k,v in ipairs(self.slots) do
        v:Close()
    end
end


return CraftSlots
