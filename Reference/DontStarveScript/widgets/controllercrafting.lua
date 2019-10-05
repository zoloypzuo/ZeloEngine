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
local RecipePopup = require "widgets/recipepopup"



require "widgets/widgetutil"

local REPEAT_TIME = .15
local POPUPOFFSET = Vector3(-300,-360,0)

local ControllerCrafting = Class(Crafting, function(self)
    Crafting._ctor(self, 10)
	self:SetOrientation(true)

	self.tabidx = 1
	self.selected_recipe_by_tab_idx = {}
	self.repeat_time = REPEAT_TIME

	local sc = .75
	self:SetScale(sc,sc,sc)
	self.in_pos = Vector3(550, 250, 0)
	self.out_pos = Vector3(-2000, 250, 0)
	--[[self.in_pos = Vector3(-200, -160, 0)
	self.out_pos = Vector3(-2000, -160, 0)
	--]]

	self.groupname = self:AddChild(Text(TITLEFONT, 100))
	--self.groupname:SetPosition(-400,90,0)
	self.groupname:SetPosition(-410,115,0)
	self.groupname:SetHAlign(ANCHOR_LEFT)
	self.groupname:SetRegionSize(400, 120)
	
	--self.groupimg1 = self:AddChild(Image())
	--self.groupimg1:SetPosition(-200, 90, 0)
	--self.groupimg2 = self:AddChild(Image())
	--self.groupimg2:SetPosition(200, 90, 0)

	self.recipepopup = self:AddChild(RecipePopup(true))
	self.recipepopup:Hide()
	
	self.recipepopup:SetScale(1.25,1.25,1.25)
	
	self.inst:ListenForEvent("builditem", function() self:Refresh() end, self.owner)
	self.inst:ListenForEvent("unlockrecipe", function() self:Refresh() end, self.owner)

end)



function ControllerCrafting:GetTabs()
	local crafttabs = GetPlayer().HUD.controls.crafttabs --this is fugly, but...
	return crafttabs
end

function ControllerCrafting:Close(fn)
	ControllerCrafting._base.Close(self, fn)
	TheFrontEnd:LockFocus(false)
	self:StopUpdating()
end

function ControllerCrafting:Open(fn)
	ControllerCrafting._base.Open(self, fn)
	self:StartUpdating()

	self.control_held = TheInput:IsControlPressed(CONTROL_OPEN_CRAFTING)
	self.control_held_time = 0
	self.accept_down = TheInput:IsControlPressed(CONTROL_PRIMARY)
	
	if self.oldslot then
		self.oldslot:SetScale(1,1,1)
		self.oldslot = nil
	end
	
	
	if not self:OpenRecipeTab(self.tabidx) then
		self:OpenRecipeTab(1)
	end
	self.craftslots:Open(1)
	if not self:SelectRecipe(self.selected_recipe_by_tab_idx[self.tabidx]) then
		self:SelectRecipe()
	end
	self:SetFocus()
	TheFrontEnd:LockFocus(true)
	
end

function ControllerCrafting:SelectRecipe(recipe)
	
	if not recipe then
		recipe = self.valid_recipes[1]
	end

	if recipe then
		for k,v in ipairs(self.valid_recipes) do
			if recipe == v then
				
				--scroll the list to get our item into view
				local slot_idx = k - self.idx
				if slot_idx <= 1 then
					self.idx = k - 2
				elseif slot_idx >= self.num_slots then
					self.idx = self.idx+slot_idx-self.num_slots+1
				end
				

				self.selected_recipe_by_tab_idx[self.tabidx] = recipe
				self:UpdateRecipes()
				self.craftslots:CloseAll()
				
				self.craftslots:LockOpen(k - self.idx)

				local slot = self.craftslots.slots[k - self.idx]
				if slot then
					if self.recipepopup.shown then
						self.recipepopup:SetRecipe(recipe, self.owner)
						self.recipepopup:MoveTo(self.recipepopup:GetPosition(), slot:GetPosition() + POPUPOFFSET, .2)
					else
						self.recipepopup:Show()
						self.recipepopup:SetPosition(slot:GetPosition() + POPUPOFFSET)
					end
				end

				if slot and slot ~= self.oldslot then
					if self.oldslot then
						self.oldslot:ScaleTo(1.4,1,.1)
					end
					slot:ScaleTo(1,1.4,.2)
					self.oldslot = slot
				end
				return true
			end
		end
	end
end

function ControllerCrafting:SelectNextRecipe()
	local old_recipe = self.selected_recipe_by_tab_idx[self.tabidx]

	local last_recipe = nil
	for k,v in ipairs(self.valid_recipes) do
		if last_recipe == self.selected_recipe_by_tab_idx[self.tabidx] then
			self:SelectRecipe(v)
			return old_recipe ~= v
		end
		last_recipe = v
	end
end

function ControllerCrafting:SelectPrevRecipe()
	local old_recipe = self.selected_recipe_by_tab_idx[self.tabidx]

	local last_recipe = self.valid_recipes[1]
	for k,v in ipairs(self.valid_recipes) do
		if self.selected_recipe_by_tab_idx[self.tabidx] == v then
			self:SelectRecipe(last_recipe)
			return last_recipe ~= old_recipe
		end
		last_recipe = v
	end
end

function ControllerCrafting:OpenRecipeTab(idx)
	--self.slot_idx_by_tab_idx[self.tabidx] = self.idx
	local tab = self:GetTabs():OpenTab(idx)
	if tab then
		self.tabidx = idx
		
		self.groupname:SetString(tab.tabname)
		
		--self.groupimg1:SetTexture(tab.icon_atlas, tab.icon)
		--self.groupimg2:SetTexture(tab.icon_atlas, tab.icon)
		
		--self.idx = self.slot_idx_by_tab_idx[self.tabidx] or 1			
		self:SetFilter( 
			function(recipe)
				local rec = GetRecipe(recipe)
				return rec and rec.tab == tab.filter
			end)
		if not self:SelectRecipe(self.selected_recipe_by_tab_idx[self.tabidx]) then
			self:SelectRecipe()
		end
		return tab
	end
	
end

function ControllerCrafting:Refresh()
	self.recipepopup:Refresh()
	self.craftslots:Refresh()
end

function ControllerCrafting:OnControl(control, down)
	if not self.open then return end

	if not down and (control == CONTROL_ACCEPT or control == CONTROL_ACTION) then
		if self.accept_down then
			self.accept_down = false --this was held down when we were opened, so we want to ignore it
		else
			if not DoRecipeClick(self.owner, self.selected_recipe_by_tab_idx[self.tabidx], true) then 
				self.owner.HUD:CloseControllerCrafting()
			end
			
			if not self.control_held then
				self.owner.HUD:CloseControllerCrafting()
			end
		end
        
        return true
	end


	
	if not down and control == CONTROL_OPEN_CRAFTING and self.control_held and self.control_held_time > 1 then
		self.owner.HUD:CloseControllerCrafting()
		return true
	end
	
end

function ControllerCrafting:OnUpdate(dt)
	if GetPlayer().HUD ~= TheFrontEnd:GetActiveScreen() then return end
	if not GetPlayer().HUD.shown then return end
	if not self.open then return end
	
	
	if self.control_held then
		self.control_held = TheInput:IsControlPressed(CONTROL_OPEN_CRAFTING)
		self.control_held_time = self.control_held_time + dt
	end
	
	if self.repeat_time > 0 then
		self.repeat_time = self.repeat_time - dt
	end
	
	if self.repeat_time <= 0 then
		if TheInput:IsControlPressed(CONTROL_MOVE_LEFT) then
			
			if self:SelectPrevRecipe() then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			end
		elseif TheInput:IsControlPressed(CONTROL_MOVE_RIGHT) then
			if self:SelectNextRecipe() then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			end
		elseif TheInput:IsControlPressed(CONTROL_MOVE_UP) then
			local idx = self:GetTabs():GetPrevIdx()
			if self.tabidx ~= idx and self:OpenRecipeTab(idx) then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_up")
			end
		elseif TheInput:IsControlPressed(CONTROL_MOVE_DOWN) then
			local idx = self:GetTabs():GetNextIdx()
			if self.tabidx ~= idx and self:OpenRecipeTab(idx) then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_down")
			end
		else
			self.repeat_time = 0
			return
		end
		self.repeat_time = REPEAT_TIME
	end	
end

return ControllerCrafting