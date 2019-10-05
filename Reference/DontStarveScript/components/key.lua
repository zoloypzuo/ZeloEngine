local Key = Class(function(self, inst)
	self.inst = inst
	self.keytype = "door"
	self.onused = nil
	self.onremoved = nil
end)

function Key:SetOnUsedFn(fn)
	self.onused = fn
end

function Key:SetOnRemovedFn(fn)
	self.onremoved = fn
end

function Key:OnUsed(lock, doer)
	if self.onused then
		self.onused(self.inst, lock, doer)
	end
end

function Key:OnRemoved(lock, doer)
	if self.onremoved then
		self.onremoved(self.inst, lock, doer)
	end
end

function Key:CollectUseActions(doer, target, actions)
	if target.components.lock and not target.components.lock:IsStuck() and target.components.lock:CompatableKey(self.keytype) then
		table.insert(actions, ACTIONS.UNLOCK)
	end
end

function Key:CollectEquippedActions(doer, target, actions, right)
	if target.components.lock and not target.components.lock:IsStuck() and target.components.lock:CompatableKey(self.keytype) then
		table.insert(actions, ACTIONS.UNLOCK)
	end
end

return Key