local Resistance = Class(function(self, inst)
    self.inst = inst
    self.tags = {}
end)

function Resistance:GetDebugString()
	local str = "Resists: "
	for k,v in pairs(self.tags) do
		str = str..tostring(v)..","
	end
    return str
end

function Resistance:AddResistance(tag)
    if not table.contains(self.tags, tag) then
		table.insert(self.tags, tag)
    end
end

function Resistance:HasResistance(attacker, weapon)
	if attacker then
		for k,v in pairs(self.tags) do
			if attacker:HasTag(v) then
				return true
			end
			if weapon and weapon:HasTag(v) then
				return true
			end
		end
	end
end

function Resistance:HasResistanceToTag(tag)
	return table.contains(self.tags, tag)
end

return Resistance