local CharacterSpecific = Class(function(self, inst)
    self.inst = inst

    self.owner = "wilson"
    self.inst:DoTaskInTime(0, function() self:CheckOwner() end)
end)

function CharacterSpecific:SetOwner(name)
	self.owner = name
end

function CharacterSpecific:CheckOwner()
	local player = GetPlayer()
	if player and player.prefab ~= self.owner then
		self.inst:Remove()	
	end
end

return CharacterSpecific