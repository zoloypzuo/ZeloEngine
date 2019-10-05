require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local RecipeTile = require "widgets/recipetile"
local RecipePopup = require "widgets/recipepopup"

require "widgets/widgetutil"

local CraftSlot = Class(Widget, function(self, atlas, bgim, owner)
    Widget._ctor(self, "Craftslot")
    self.owner = owner
    
    self.atlas = atlas
    self.bgimage = self:AddChild(Image(atlas, bgim))
    
    self.tile = self:AddChild(RecipeTile())
    self.fgimage = self:AddChild(Image("images/hud.xml", "craft_slot_locked.tex"))
    self.fgimage:Hide()
    self.test_index = -1
end)

function CraftSlot:EnablePopup()
    if not self.recipepopup then
        self.recipepopup = self:AddChild(RecipePopup())
        self.recipepopup:SetPosition(0, -20, 0)
        self.recipepopup:Hide()
        local s = 1.25
        self.recipepopup:SetScale(s, s, s)
    end
end

function CraftSlot:OnGainFocus()
    CraftSlot._base.OnGainFocus(self)
    self:Open()
end


function CraftSlot:OnControl(control, down)
    if CraftSlot._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_ACCEPT then
        if self.owner and self.recipe then
            if self.recipepopup and not self.recipepopup.focus then 
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                if not DoRecipeClick(self.owner, self.recipe) then 
                    self:Close() 
                end
                return true
            end
        end
    end
end


function CraftSlot:OnLoseFocus()
    CraftSlot._base.OnLoseFocus(self)
    self:Close()
end


function CraftSlot:Clear()
    self.recipename = nil
    self.recipe = nil
    self.canbuild = false
    
    if self.tile then
        self.tile:Hide()
    end
    
    self.fgimage:Hide()
    self.bgimage:SetTexture(self.atlas, "craft_slot.tex")
    --self:HideRecipe()
end

function CraftSlot:LockOpen()
	self:Open()
	self.locked = true
    if self.recipepopup then
	   self.recipepopup:SetPosition(-300, -300, 0)
    end
end

function CraftSlot:Open()
    if self.recipepopup then
        self.recipepopup:SetPosition(0, -20, 0)
    end
    self.open = true
    self:ShowRecipe()
    self.owner.SoundEmitter:PlaySound("dontstarve/HUD/click_mouseover")
end

function CraftSlot:Close()
    self.open = false
    self.locked = false
    self:HideRecipe()
end

function CraftSlot:ShowRecipe()
    if self.recipe and self.recipepopup then
        self.recipepopup:Show()
        self.recipepopup:SetRecipe(self.recipe, self.owner)
    end
end

function CraftSlot:HideRecipe()
    if self.recipepopup then
        self.recipepopup:Hide()
    end
end


function CraftSlot:Refresh(recipename)
	recipename = recipename or self.recipename
    local recipe = GetRecipe(recipename)
    
	
    local canbuild = self.owner.components.builder:CanBuild(recipename)
    local knows = self.owner.components.builder:KnowsRecipe(recipename)
    local buffered = self.owner.components.builder:IsBuildBuffered(recipename)
    
    local do_pulse = self.recipename == recipename and not self.canbuild and canbuild
    self.recipename = recipename
    self.recipe = recipe
    
    if self.recipe then
        self.canbuild = canbuild

        local image = self.recipe.image
        local imagename = string.gsub(image, ".tex", "")
        
        if SaveGameIndex:IsModePorkland() and PORK_ICONS[imagename] ~= nil then
            image = PORK_ICONS[imagename] .. ".tex"
        end   

        self.tile:SetVisual(self.recipe.atlas, image)
        self.tile:Show()

        if self.fgimage then
            if knows or recipe.nounlock then
                if buffered then
                    self.bgimage:SetTexture(self.atlas, "craft_slot_place.tex")
                else
                    self.bgimage:SetTexture(self.atlas, "craft_slot.tex")
                end
                self.fgimage:Hide()
            else
                local right_level = CanPrototypeRecipe(self.recipe.level, self.owner.components.builder.accessible_tech_trees)-- self.owner.components.builder.current_tech_level >= self.recipe.level
                --print("Right_Level for: ", recipename, " ", right_level)
                local show_highlight = false
                
                show_highlight = canbuild and right_level
                
                local hud_atlas = resolvefilepath( "images/hud.xml" )
                
                if not right_level then
                    self.fgimage:SetTexture(hud_atlas, "craft_slot_locked_nextlevel.tex")
                elseif show_highlight then
                    self.fgimage:SetTexture(hud_atlas, "craft_slot_locked_highlight.tex")
                else
                    self.fgimage:SetTexture(hud_atlas, "craft_slot_locked.tex")
                end
                
                self.fgimage:Show()
                if not buffered then self.bgimage:SetTexture(self.atlas, "craft_slot.tex") end -- Make sure we clear out the place bg if it's a new tab
            end
        end

        self.tile:SetCanBuild((buffered or canbuild) and (knows or recipe.nounlock))

        if self.recipepopup then
            self.recipepopup:SetRecipe(self.recipe, self.owner)
        end
        
        --self:HideRecipe()
    end
end

function CraftSlot:SetRecipe(recipename)
    self:Show()
	self:Refresh(recipename)
end


return CraftSlot
