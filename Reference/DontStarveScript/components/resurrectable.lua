
local Resurrectable = Class(function(self, inst)
    self.inst = inst
end)

function Resurrectable:FindClosestResurrector()
	local res = nil
	if self.inst.components.inventory then
		local item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if item and item.prefab == "amulet" then
			return item
		end
	end

	local closest_dist = 0
	for k,v in pairs(Ents) do
		if v.components.resurrector and v.components.resurrector:CanBeUsed() then
			local dist = v:GetDistanceSqToInst(self.inst)
			if not res or dist < closest_dist then
				res = v
				closest_dist = dist
			end
		end
	end

	return res
end

function Resurrectable:CanResurrect()
	if self.inst.components.inventory then
		local item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if item and item.prefab == "amulet" then
			return true
		end
	end

	local res = false

	if SaveGameIndex:CanUseExternalResurector() then
		res = SaveGameIndex:GetResurrector() 
	end

	if res == nil or res == false then
		res = self:FindClosestResurrector()
	end

	if res then
		return true
	end

	return false
end

function Resurrectable:DoResurrect()
    self.inst:PushEvent("resurrect")
	if self.inst.components.inventory then
		local item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if item and item.prefab == "amulet" then
			self.inst.sg:GoToState("amulet_rebirth")
			return true
		end
	end
	
	local res = self:FindClosestResurrector()
	if res and res.components.resurrector then
		res.components.resurrector:Resurrect(self.inst)
		return true
	end

	return false
end

return Resurrectable
