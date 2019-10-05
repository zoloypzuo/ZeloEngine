local Timer = Class(function(self, inst)
	self.inst = inst
	self.timers = {}

	--self.inst:ListenForEvent("timerdone", function(inst, data) print(data.name) end)
end)

function Timer:GetDebugString()
	local str = "\n"
		for k,v in pairs(self.timers) do
			str = str.."	--"..k.."\n"
			str = str..string.format("		--timeleft: %f \n", self:GetTimeLeft(k) or 0)
			str = str..string.format("		--paused: %s \n", tostring(self:IsPaused(k) == true))
		end
	return str
end

function Timer:TimerExists(name)
	return self.timers[name] ~= nil
end

function Timer:StartTimer(name, time, paused)
	
	if self:TimerExists(name) then
		print("A timer with the name ", name, " already exists on ", self.inst, "!")
		return
	end

	local timerfn = function() self:StopTimer(name) self.inst:PushEvent("timerdone", {name = name}) end
	self.timers[name] = {}
	self.timers[name].timerfn = timerfn
	self.timers[name].timer = self.inst:DoTaskInTime(time, timerfn)
	self.timers[name].timeleft = time
	self.timers[name].end_time = GetTime() + time
	self.timers[name].initial_time = time
	self.timers[name].paused = false

	if paused then
		self:PauseTimer(name)
	end
end

function Timer:StopTimer(name)

	if not self:TimerExists(name) then
		return
	end

	self.timers[name].timer:Cancel()
	self.timers[name].timer = nil
	self.timers[name] = nil
end

function Timer:IsPaused(name)

	if not self:TimerExists(name) then
		return
	end

	return self.timers[name].paused
end

function Timer:PauseTimer(name)

	if not self:TimerExists(name) then
		return
	end

	self:GetTimeLeft(name)
	if not self:IsPaused(name) then
		self.timers[name].paused = true
		self.timers[name].timer:Cancel()
		self.timers[name].timer = nil
	end
end

function Timer:ResumeTimer(name)

	if not self:TimerExists(name) then
		return
	end

	if self:IsPaused(name) then
		self.timers[name].paused = false
		self.timers[name].timer = self.inst:DoTaskInTime(self.timers[name].timeleft, self.timers[name].timerfn)
		self.timers[name].end_time = GetTime() + self.timers[name].timeleft
	end
end

function Timer:GetTimeLeft(name)

	if not self:TimerExists(name) then
		return
	end

	if not self:IsPaused(name) then
		self.timers[name].timeleft = self.timers[name].end_time - GetTime()
	end
	return self.timers[name].timeleft
end

function Timer:SetTimeLeft(name, time)
	if not self:TimerExists(name) then
		return 
	end
	time = math.max(0.1, time)
	self.timers[name].timeleft = time
end

function Timer:GetTimeElapsed(name)
	if not self:TimerExists(name) then
		return 
	end
	return (self.timers[name].initial_time or 0) - self:GetTimeLeft(name)
end

function Timer:OnSave()
	local data = {}

	for k,v in pairs(self.timers) do
		if not data.timers then
			data.timers = {}
		end
		data.timers[k] = {}
		data.timers[k].timeleft = self:GetTimeLeft(k)
		data.timers[k].paused = self.timers[k].paused
		data.timers[k].initial_time = self.timers[k].initial_time
	end

	return data
end

function Timer:OnLoad(data)
	if data.timers then
		for k,v in pairs(data.timers) do
			self:ResumeTimerOnLoad(k, v.initial_time, v.timeleft, v.paused)
		end
	end
end

function Timer:ResumeTimerOnLoad(name, initial_time, timeleft, paused)
	
	if self:TimerExists(name) then
		self:StopTimer(name)
	end

	local timerfn = function() self:StopTimer(name) self.inst:PushEvent("timerdone", {name = name}) end
	self.timers[name] = {}
	self.timers[name].timerfn = timerfn
	self.timers[name].timer = self.inst:DoTaskInTime(timeleft, timerfn)
	self.timers[name].timeleft = timeleft
	self.timers[name].end_time = GetTime() + timeleft
	self.timers[name].initial_time = initial_time
	self.timers[name].paused = false

	if paused then
		self:PauseTimer(name)
	end
end

function Timer:LongUpdate(dt)
	for k,v in pairs(self.timers) do
		self:PauseTimer(k)
		self:SetTimeLeft(k, self:GetTimeLeft(k) - dt)
		self:ResumeTimer(k)
	end
end

return Timer
