--Note: If you want to add a new tech tree you must also add it into the "NO_TECH" constant in constants.lua

local Prototyper = Class(function(self, inst)
    self.inst = inst
	self.active = false
	self.trees = {
		SCIENCE = 0,
		MAGIC = 0,
		ANCIENT = 0,
	}
	self.on = false
end)

function Prototyper:TurnOn()
	if not self.on and self.onturnon then
		self.onturnon(self.inst)
		self.on = true
	end
end

function Prototyper:TurnOff()
	if self.on and self.onturnoff then
		self.onturnoff(self.inst)
		self.on = false
	end
end

function Prototyper:GetTechTrees()
	return deepcopy(self.trees)

end

function Prototyper:Activate()
	if self.onactivate then
		self.onactivate()
	end
end

return Prototyper