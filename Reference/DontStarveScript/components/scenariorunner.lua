local ScenarioRunner = Class(function(self, inst)
    self.inst = inst
	self.scriptname = nil
	self.script = nil
	self.hasrunonce = false
end)

function ScenarioRunner:OnLoad(data)
	if data then
		if data.scriptname then
			self:SetScript(data.scriptname)
		end
		if data.hasrunonce then
			self.hasrunonce = data.hasrunonce
		end
	end
end

function ScenarioRunner:OnSave()
	local data = {}
	data.hasrunonce = self.hasrunonce
	if self.scriptname then data.scriptname = self.scriptname end
	return data
end

function ScenarioRunner:SetScript(name)
	if self.scriptname ~= nil then
		print("Warning! The scenario runner on "..self.inst.name.." already has a script '"..self.scriptname.."' but we are adding a script '"..name.."'")
	end
	self.scriptname = name
	self.script = require("scenarios/"..name)
	assert(self.script.OnCreate or self.script.OnLoad, "Scenario '"..name.."' doesn't export an OnLoad or OnCreate.")
end

function ScenarioRunner:Run()
	if not self.hasrunonce and self.script.OnCreate then
		self.script.OnCreate(self.inst, self)
		self.hasrunonce = true
	end

	if self.script.OnLoad then
		self.script.OnLoad(self.inst, self)
	else
		self:ClearScenario()
	end
end

function ScenarioRunner:ClearScenario()
	self.inst:RemoveComponent("scenariorunner")
	if self.script.OnDestroy then
		self.script.OnDestroy(self.inst)
	end
end

function ScenarioRunner:Reset()
	if self.script.OnDestroy then
		self.script.OnDestroy(self.inst)
	end
	self.script = nil
	self.scriptname = nil
	self.hasrunonce = false
end

return ScenarioRunner
