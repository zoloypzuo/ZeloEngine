local Age = Class(function(self, inst)
	self.inst = inst

    self.saved_age = 0
    self.spawntime = GetTime()
end)

function Age:GetAge()
	return self.saved_age + (GetTime() - self.spawntime)
end

function Age:OnSave()
    return 
    {
		age = self:GetAge()
	}
end

function Age:GetDebugString()
    if self:GetAge() > .5*TUNING.TOTAL_DAY_TIME then
		return string.format("%2.2f days", self:GetAge() / TUNING.TOTAL_DAY_TIME)
	else
		return string.format("%2.2f s", self:GetAge())
	end
end

function Age:LongUpdate(dt)
	self.saved_age = self.saved_age + dt
end

function Age:OnLoad(data)
	if data and data.age then
		self.saved_age = data.age
	end
end

return Age
