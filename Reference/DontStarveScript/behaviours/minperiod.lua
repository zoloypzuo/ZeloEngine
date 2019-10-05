MinPeriod = Class(BehaviourNode, function(self, inst, minperiod, child)
    BehaviourNode._ctor(self, "MinPeriod", {child})
    
    self.inst = inst
    self.minperiod = minperiod
end)


function MinPeriod:Visit()
    local child = self.children[1]
	if self.status == READY and self.lastsuccesstime then
		local time = GetTime()
		if time - self.lastsuccesstime < self.minperiod then
			self.status = FAILED
			return
		end
	end
	    
    child:Visit()
    if child.status == SUCCESS then
		self.lastsuccesstime = GetTime()
    end
    
	self.status = child.status
	
end

function MinPeriod:DBString()
    if self.minperiod then
		local time = GetTime()
		
		
		local time_since_success = time - (self.lastsuccesstime or 0)
		if not self.lastsuccesstime or time_since_success > self.minperiod then
			return string.format("OK (min period is %2.2f)", self.minperiod)
		else
			return string.format("Waiting for %2.2f (min period is %2.2f)", self.minperiod-time_since_success, self.minperiod)
		end
    end
end