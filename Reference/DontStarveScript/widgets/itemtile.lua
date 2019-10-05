local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local ItemTile = Class(Widget, function(self, invitem)
    Widget._ctor(self, "ItemTile")
    self.item = invitem

	-- NOT SURE WAHT YOU WANT HERE
	if invitem.components.inventoryitem == nil then
		print("NO INVENTORY ITEM COMPONENT"..tostring(invitem.prefab), invitem)
		return
	end
	
	self.bg = self:AddChild(Image())
	self.bg:SetTexture(HUD_ATLAS, "inv_slot_spoiled.tex")
	self.bg:Hide()
	self.bg:SetClickable(false)
	self.basescale = 1
	
	self.spoilage = self:AddChild(UIAnim())
	
    self.spoilage:GetAnimState():SetBank("spoiled_meter")
    self.spoilage:GetAnimState():SetBuild("spoiled_meter")
    self.spoilage:Hide()
    self.spoilage:SetClickable(false)
	
	
    self.image = self:AddChild(Image(invitem.components.inventoryitem:GetAtlas(), invitem.components.inventoryitem:GetImage()))
    --self.image:SetClickable(false)

    local owner = self.item.components.inventoryitem.owner
    
    if self.item.prefab == "spoiled_food" or self:HasSpoilage() then
		self.bg:Show( )
	end
	
	if self:HasSpoilage() then
		self.spoilage:Show()
	end

    self.inst:ListenForEvent("imagechange", function() 
        self.image:SetTexture(invitem.components.inventoryitem:GetAtlas(), invitem.components.inventoryitem:GetImage())
    end, invitem)
    
    self.inst:ListenForEvent("stacksizechange",
            function(inst, data)
                if invitem.components.stackable then
                
					if data.src_pos then
						local dest_pos = self:GetWorldPosition()
						local im = Image(invitem.components.inventoryitem:GetAtlas(), invitem.components.inventoryitem:GetImage())
						im:MoveTo(data.src_pos, dest_pos, .3, function() 
							self:SetQuantity(invitem.components.stackable:StackSize())
							self:ScaleTo(self.basescale*2, self.basescale, .25)
							im:Kill() end)
					else
	                    self:SetQuantity(invitem.components.stackable:StackSize())
						self:ScaleTo(self.basescale*2, self.basescale, .25)
					end
                end
            end, invitem)


    if invitem.components.stackable then
        self:SetQuantity(invitem.components.stackable:StackSize())
    end

    self.inst:ListenForEvent("percentusedchange",
            function(inst, data)
                self:SetPercent(data.percent)
            end, invitem)
    self.inst:ListenForEvent("perishchange",
            function(inst, data)
				if self.item.components.perishable then
                    if self:HasSpoilage() then
                        self:SetPerishPercent(data.percent)
    				else
                        self:SetPercent(data.percent)
    				end
                end
            end, invitem)

    if invitem.components.fueled then
        self:SetPercent(invitem.components.fueled:GetPercent())
    end

    if invitem.components.finiteuses then
        self:SetPercent(invitem.components.finiteuses:GetPercent())
    end


    if invitem.components.perishable then
        if self:HasSpoilage() then
            self:SetPerishPercent(invitem.components.perishable:GetPercent())
        else
            self:SetPercent(invitem.components.perishable:GetPercent())
        end
    end
    
    if invitem.components.armor then
        self:SetPercent(invitem.components.armor:GetPercent())
    end
    
end)

function ItemTile:SetBaseScale(sc)
	self.basescale = sc
	self:SetScale(sc)
end

function ItemTile:OnControl(control, down)
    self:UpdateTooltip()
    return false
end

function ItemTile:UpdateTooltip()
	local str = self:GetDescriptionString()
	self:SetTooltip(str)
end

function ItemTile:GetDescriptionString()
    local str = nil
    local in_equip_slot = self.item and self.item.components.equippable and self.item.components.equippable:IsEquipped()
    local active_item = GetPlayer().components.inventory:GetActiveItem()
    if self.item and self.item.components.inventoryitem then

        local adjective = self.item:GetAdjective()
        
        if adjective then
            str = adjective .. " " .. self.item:GetDisplayName()
        else
            str = self.item:GetDisplayName()
        end

        if active_item then 
            
            if not in_equip_slot then
                if active_item.components.stackable and active_item.prefab == self.item.prefab then
                    str = str .. "\n" .. STRINGS.LMB .. ": " .. STRINGS.UI.HUD.PUT
                else
                    str = str .. "\n" .. STRINGS.LMB .. ": " .. STRINGS.UI.HUD.SWAP
                end
            end 
            
            local actions = GetPlayer().components.playeractionpicker:GetUseItemActions(self.item, active_item, true)
            if actions then
                str = str.."\n" .. STRINGS.RMB .. ": " .. actions[1]:GetActionString()
            end
        else
            
            --self.namedisp:SetHAlign(ANCHOR_LEFT)
            local owner = self.item.components.inventoryitem and self.item.components.inventoryitem.owner
            local actionpicker = owner and owner.components.playeractionpicker or GetPlayer().components.playeractionpicker
            local inventory = owner and owner.components.inventory or GetPlayer().components.inventory
            if owner and inventory and actionpicker then
            
                if TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) then
                    str = str .. "\n" .. STRINGS.LMB .. ": " .. STRINGS.INSPECTMOD
                elseif TheInput:IsControlPressed(CONTROL_FORCE_TRADE) then
                    str = str .. "\n" .. STRINGS.LMB .. ": " .. ( (TheInput:IsControlPressed(CONTROL_FORCE_STACK) and self.item.components.stackable) and (STRINGS.STACKMOD .. " " ..STRINGS.TRADEMOD) or STRINGS.TRADEMOD)
                elseif TheInput:IsControlPressed(CONTROL_FORCE_STACK) and self.item.components.stackable then
                    str = str .. "\n" .. STRINGS.LMB .. ": " .. STRINGS.STACKMOD
                end

                local actions = nil
                if inventory:GetActiveItem() then
                    actions = actionpicker:GetUseItemActions(self.item, inventory:GetActiveItem(), true)
                end
                
                if not actions then
                    actions = actionpicker:GetInventoryActions(self.item)
                end
                
                if actions then
                    str = str.."\n" .. STRINGS.RMB .. ": " .. actions[1]:GetActionString()
                end

            end
        end
    end
    
    return str or ""
    
end

function ItemTile:OnGainFocus()
    self:UpdateTooltip()
end

function ItemTile:SetQuantity(quantity)
    if not self.quantity then
        self.quantity = self:AddChild(Text(NUMBERFONT, 42))
        self.quantity:SetPosition(2,16,0)
    end
    self.quantity:SetString(tostring(quantity))
end

function ItemTile:SetPerishPercent(percent)
	if self:HasSpoilage() then
		self.spoilage:GetAnimState():SetPercent("anim", 1-self.item.components.perishable:GetPercent())
	end
end

function ItemTile:SetPercent(percent)
    --if not self.item.components.stackable then
        
    if not self.percent then
        self.percent = self:AddChild(Text(NUMBERFONT, 42))
        if JapaneseOnPS4() then
            self.percent:SetHorizontalSqueeze(0.7)
        end
        self.percent:SetPosition(5,-32+15,0)
    end
    local val_to_show = percent*100
    if val_to_show > 0 and val_to_show < 1 then
        val_to_show = 1
    end
	self.percent:SetString(string.format("%2.0f%%", val_to_show))
        
    --end
end

--[[
function ItemTile:CancelDrag()
    self:StopFollowMouse()
    
    if self.item.prefab == "spoiled_food" or (self.item.components.edible and self.item.components.perishable) then
		self.bg:Show( )
	end
	
	if self.item.components.perishable and self.item.components.edible then
		self.spoilage:Show()
	end
	
	self.image:SetClickable(true)

    
end
--]]

function ItemTile:StartDrag()
    --self:SetScale(1,1,1)
    self.spoilage:Hide()
    self.bg:Hide( )
    self.image:SetClickable(false)
end

function ItemTile:HasSpoilage()
    return (self.item.components.perishable and (self.item.components.edible or self.item:HasTag("show_spoilage")) )
end

return ItemTile
