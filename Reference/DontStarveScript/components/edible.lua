local Edible = Class(function(self, inst)
    self.inst = inst
    self.healthvalue = 10
    self.hungervalue = 10
    self.sanityvalue = 0
    self.foodtype = "GENERIC"
    self.oneaten = nil
    
    self.stale_hunger = TUNING.STALE_FOOD_HUNGER
    self.stale_health = TUNING.STALE_FOOD_HEALTH

    self.spoiled_hunger = TUNING.SPOILED_FOOD_HUNGER
    self.spoiled_health = TUNING.SPOILED_FOOD_HEALTH

end)

function Edible:GetSanity(eater)

	local ignore_spoilage = (eater and eater.components.eater and eater.components.eater.ignoresspoilage) or self.hungervalue < 0
	if self.inst.components.perishable and not ignore_spoilage then
		if self.inst.components.perishable:IsStale() then
			if self.sanityvalue > 0 then
				return 0
			end
		elseif self.inst.components.perishable:IsSpoiled() then
			return -TUNING.SANITY_SMALL
		end
	end
	
	return self.sanityvalue
end

function Edible:GetHunger(eater)
	local multiplier = 1
	
	local ignore_spoilage = (eater and eater.components.eater and eater.components.eater.ignoresspoilage) or self.hungervalue < 0
	
	if self.inst.components.perishable and not ignore_spoilage then
		if self.inst.components.perishable:IsStale() then
			multiplier = (eater and eater.components.eater and eater.components.eater.stale_hunger) or self.stale_hunger
		elseif self.inst.components.perishable:IsSpoiled() then
			multiplier = (eater and eater.components.eater and eater.components.eater.spoiled_hunger) or self.spoiled_hunger
		end
	end
	
	return multiplier*(self.hungervalue)
end

function Edible:GetHealth(eater)
	local multiplier = 1
	
	local ignore_spoilage = (eater and eater.components.eater and eater.components.eater.ignoresspoilage) or self.healthvalue < 0
	
	if self.inst.components.perishable and not ignore_spoilage then
		if self.inst.components.perishable:IsStale() then
			multiplier = (eater and eater.components.eater and eater.components.eater.stale_health) or self.stale_health
		elseif self.inst.components.perishable:IsSpoiled() then
			multiplier = (eater and eater.components.eater and eater.components.eater.spoiled_health) or self.spoiled_health
		end
	end
	
	return multiplier*(self.healthvalue)
end

function Edible:GetDebugString()
    return string.format("Food type: %s, health: %2.2f, hunger: %2.2f, sanity: %2.2f",self.foodtype, self.healthvalue, self.hungervalue, self.sanityvalue)
end

function Edible:SetOnEatenFn(fn)
    self.oneaten = fn
end

function Edible:OnEaten(eater)
    if self.oneaten then
        self.oneaten(self.inst, eater)
    end
    self.inst:PushEvent("oneaten", {eater = eater})
end

function Edible:CollectInventoryActions(doer, actions, right)
    if doer.components.eater and doer.components.eater:CanEat(self.inst) then
        if not self.inst.components.equippable or right then
			table.insert(actions, ACTIONS.EAT)
		end
    end
end

function Edible:CollectUseActions(doer, target, actions, right)
	if (target.components.eater and target.components.eater:CanEat(self.inst)) and (target.components.inventoryitem and target.components.inventoryitem:IsHeld()) and
		target:HasTag("pet") then
		table.insert(actions, ACTIONS.FEED)
	end
end

return Edible