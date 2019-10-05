local Activatable = Class(function(self, inst, activcb)
    self.inst = inst
    self.OnActivate = activcb
    self.inactive = true
	self.quickaction = false
end)

function Activatable:CollectSceneActions(doer, actions)
	if self.inactive then 
		table.insert(actions, ACTIONS.ACTIVATE)
	end
end

function Activatable:DoActivate(doer)
	if self.OnActivate ~= nil then
		self.inactive = false
		self.OnActivate(self.inst, doer)
	end
end

return Activatable
