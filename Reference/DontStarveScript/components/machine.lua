local Machine = Class(function(self, inst)
	self.inst = inst
	self.turnonfn = nil
	self.turnofffn = nil
	self.ison = false
	self.cooldowntime = 3
	self.oncooldown = false
	self.caninteractfn = nil
end)

function Machine:OnSave()
	local data = {}	
	data.ison = self.ison

	return data
end

function Machine:OnLoad(data)
	if data then
		self.ison = data.ison

		if self:IsOn() then 
			self.inst:DoTaskInTime(0,function() self:TurnOn() end)
		else 
			self:TurnOff() 
		end
	end
end

function Machine:TurnOn()
	if self.cooldowntime > 0 then 
		self.oncooldown = true
		self.inst:DoTaskInTime(self.cooldowntime, function() self.oncooldown = false end)
	end

	if self.turnonfn then
		self.turnonfn(self.inst)
	end
	self.ison = true
	self.inst:PushEvent("turnedon")
end

function Machine:CanInteract(doer)
	if self.caninteractfn then
		return self.caninteractfn(self.inst,doer)
	else
		return true
	end
end

function Machine:TurnOff()
	if self.cooldowntime > 0 then 
		self.oncooldown = true
		self.inst:DoTaskInTime(self.cooldowntime, function() self.oncooldown = false end)
	end

	if self.turnofffn then
		self.turnofffn(self.inst)
	end
	self.ison = false
	self.inst:PushEvent("turnedoff")
end

function Machine:IsOn()
	return self.ison
end

function Machine:CollectSceneActions(doer, actions, right)	
	if right and not self.oncooldown and self:CanInteract(doer) then
		if self:IsOn() then
			table.insert(actions, ACTIONS.TURNOFF)
		else
			table.insert(actions, ACTIONS.TURNON)
		end	
	end
end

function Machine:CollectInventoryActions(doer, actions)
	if not self.oncooldown and self:CanInteract(doer) then
		if self:IsOn() then
			table.insert(actions, ACTIONS.TURNOFF)
		else
			table.insert(actions, ACTIONS.TURNON)
		end	
	end
end

return Machine