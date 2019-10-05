local Shelf = Class(function(self, inst)
	self.inst = inst
	self.cantakeitemfn = nil
	self.itemonshelf = nil
	self.onitemtakenfn = nil
	self.cantakeitem = false
	
end)

function Shelf:OnSave()

end

function Shelf:OnLoad(data)

end

function Shelf:IsEmpty()

end

function Shelf:TakeItem(taker)
	if self.cantakeitem then
		if taker.components.inventory then
			taker.components.inventory:GiveItem(self.itemonshelf)

			if self.inst.components.inventory then
				self.inst.components.inventory:RemoveItem(self.itemonshelf)
			end
			
			self.itemonshelf = nil
		else
			self.inst.components.inventory:DropItem(self.itemonshelf)
		end

		if self.ontakeitemfn then
			self.ontakeitemfn(self.inst, taker)
		end
	end
end

function Shelf:CollectSceneActions(doer, actions)
	if self.cantakeitem and self.itemonshelf then
		table.insert(actions, ACTIONS.TAKEITEM)
	end
end

return Shelf