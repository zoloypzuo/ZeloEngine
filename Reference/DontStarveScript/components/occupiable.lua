local Occupiable = Class(function(self, inst)
    self.inst = inst
	self.occupant = nil
end)

function Occupiable:IsOccupied()
	return self.occupant ~= nil
end

function Occupiable:CanOccupy(occupier)
	if self.occupant == nil and self.occupytestfn and occupier.components.occupier then
		return self.occupytestfn(self.inst, occupier)
	end
	return false
end

function Occupiable:Occupy(occupier)
	
	if not self.occupant and occupier and occupier.components.occupier then
		self.occupant = occupier
		self.occupant.persists = true
		
		if occupier.components.occupier.onoccupied then
			occupier.components.occupier.onoccupied(occupier, self.inst)
		end
		
		if self.onoccupied then
			self.onoccupied(self.inst, occupier)
		end	
		
		self.inst:AddChild(occupier)
		occupier:RemoveFromScene()
	end
		
end

function Occupiable:Harvest()
	if self.occupant and self.occupant.components.inventoryitem then
		local occupant = self.occupant
		self.occupant = nil
		self.inst:RemoveChild(occupant)
		if self.onemptied then
			self.onemptied(self.inst)
		end
		occupant:ReturnToScene()
		return occupant
	end
end

function Occupiable:CollectSceneActions(doer, actions)
    if self.occupant then
        table.insert(actions, ACTIONS.HARVEST)
    end
end


function Occupiable:OnSave()
    local data = {}
    if self.occupant and self.occupant:IsValid() then
		data.occupant = self.occupant:GetSaveRecord()
    end
    return data
end   

function Occupiable:OnLoad(data, newents)

    if data.occupant then
        local inst = SpawnSaveRecord(data.occupant, newents)
		if inst then
			self:Occupy(inst)
		end
    end

end


return Occupiable
