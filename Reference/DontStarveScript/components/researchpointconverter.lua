--DON'T USE THIS! Use prototyper.lua instead.

local ResearchPointConverter = Class(function(self, inst)
    self.inst = inst
	self.val = 0
	self.active = false
	self.level = 1
	self.on = false
end)

function ResearchPointConverter:TurnOn()
	if not self.on and self.onturnon then
		self.onturnon(self.inst)
		self.on = true
	end
end

function ResearchPointConverter:TurnOff()
	if self.on and self.onturnoff then
		self.onturnoff(self.inst)
		self.on = false
	end
end


function ResearchPointConverter:Activate()
	if self.onactivate then
		self.onactivate()
	end
end


return ResearchPointConverter