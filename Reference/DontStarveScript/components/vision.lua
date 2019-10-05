local easing = require("easing")

local Vision = Class(function(self, inst)
	self.nearsighted = false
    self.inst = inst   
	self.focused = true
	self:SetFocused()
	self.inst:DoTaskInTime(0, function()
		if self.nearsighted then			
			local headgear = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    		if not headgear or not headgear:HasTag("nearsighted_glasses") then 			    			
				self:SetUnfocused()
			end
		end
	end)
    inst:ListenForEvent("equip", function() self:CheckForGlasses() end )
    inst:ListenForEvent("unequip", function() self:CheckForGlasses() end)    
    self.inst:StartUpdatingComponent(self)
end)

function Vision:OnUpdate(dt)
	local hx, hy, hz = self.inst.AnimState:GetSymbolPosition("head", 0, 0, 0)

	local px, py = TheSim:GetScreenPos(hx,hy,hz)
	local w,h = TheSim:GetScreenSize()
	PostProcessor:SetBlurCenter(px/w, py/h)
end

function Vision:SetFocused()
	if not self.focused then
		self.focused = true
		PostProcessor:SetBlurEnabled(false)
	end
end

function Vision:SetUnfocused()
	if self.focused then 
		self.focused = false
		PostProcessor:SetBlurEnabled(true)
		PostProcessor:SetBlurParams(TUNING.NEARSIGHTED_BLUR_START_RADIUS, TUNING.NEARSIGHTED_BLUR_STRENGTH)
	end
end

function Vision:CheckForGlasses()
    local headgear = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    if headgear and headgear:HasTag("nearsighted_glasses") then  
    	if self.nearsighted then    		
    		self:SetFocused()    		
    	else
    		self:SetUnfocused()			
		end
    else
    	if self.nearsighted then
    		self:SetUnfocused()
    	else
    		self:SetFocused()			
		end
    end
	-- but...headgear can override this again
	if headgear and headgear.CustomFocus then
		headgear:CustomFocus(self.inst)
	end
end

function Vision:testsight(item)
	if not item:IsValid() then
		return false
	end
	-- LIMBO gets things in inventory. Maybe it needs to be more robust than just that, but works for now		
	return item:GetDistanceSqToInst(GetPlayer()) < TUNING.NEARSIGHTED_ACTION_RANGE*TUNING.NEARSIGHTED_ACTION_RANGE or item:HasTag("INLIMBO")
end


return Vision
