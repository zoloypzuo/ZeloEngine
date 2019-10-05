local Teacher = Class(function(self, inst) 
	self.inst = inst
	self.recipe = nil
end)

function Teacher:SetRecipe(recipe)
	self.recipe = recipe
end

function Teacher:CollectInventoryActions(doer, actions)
	if doer.components.builder then
		table.insert(actions, ACTIONS.TEACH)
	end
end

function Teacher:CollectUseActions(doer, target, actions)
	if target.components.builder then
		table.insert(actions, ACTIONS.TEACH)
	end
end

function Teacher:Teach(target)
	if target.components.builder then
		if self.recipe then
			target.components.builder:UnlockRecipe(self.recipe)
			if self.onteach then 
				self.onteach(self.inst, target)
			end
			self.inst:Remove()
			return true
		else
			self.inst:Remove()
			return false
		end
	end
end

return Teacher