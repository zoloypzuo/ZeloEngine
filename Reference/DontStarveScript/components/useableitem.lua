local UseableItem = Class(function(self, inst)
	self.inst = inst
	self.onusefn = nil
	self.onstopusefn = nil
	self.inuse = false
	self.caninteractfn = nil
	self.stopuseevents = nil
end)

function UseableItem:SetCanInteractFn(fn)
	self.caninteractfn = fn
end

function UseableItem:SetOnUseFn(fn)
	self.onusefn = fn
end

function UseableItem:SetOnStopUseFn(fn)
	self.onstopusefn = fn
end

function UseableItem:CanInteract()
	if self.caninteractfn then
		return self.caninteractfn(self.inst)
	else
		return not self.inuse and self.inst.components.equippable.isequipped
	end
end

function UseableItem:StartUsingItem()
	self.inuse = true
	if self.onusefn then
		self.onusefn(self.inst)
	end

	if self.stopuseevents then
		self.stopuseevents(self.inst)
	end
end

function UseableItem:StopUsingItem()
	self.inuse = false
	if self.onstopusefn then
		self.onstopusefn(self.inst)
	end
end

function UseableItem:CollectInventoryActions(doer, actions)
	if self:CanInteract() then
		table.insert(actions, ACTIONS.USEITEM)
	end
end

return UseableItem