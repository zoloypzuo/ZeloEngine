local SEE_DIST = 30

FindFlower = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "FindFlower")
    self.inst = inst
end)

function FindFlower:DBString()
    return string.format("Go to flower %s", tostring(self.inst.components.pollinator.target))
end

function FindFlower:Visit()
    
    if self.status == READY then
        self:PickTarget()
        if self.inst.components.pollinator and self.inst.components.pollinator.target then
			local action = BufferedAction(self.inst, self.inst.components.pollinator.target, ACTIONS.POLLINATE, nil, nil, nil, 0.1)
			self.inst.components.locomotor:PushAction(action, self.shouldrun)
			self.status = RUNNING
		else
			self.status = FAILED
        end
    end
    
    if self.status == RUNNING then
        if not self.inst.components.pollinator.target
           or not self.inst.components.pollinator:CanPollinate(self.inst.components.pollinator.target)
           or FindEntity(self.inst.components.pollinator.target, 2, function(guy) return guy ~= self.inst and guy.components.pollinator and guy.components.pollinator.target == self.inst.components.pollinator.target end, {"pollinator"}) then
            self.status = FAILED
        end
    end
end

function FindFlower:PickTarget()
    local closestFlower = GetClosestInstWithTag("flower", self.inst, SEE_DIST)
    if closestFlower
	   and self.inst.components.pollinator
	   and self.inst.components.pollinator:CanPollinate(closestFlower) 
	   and not FindEntity(closestFlower, 2, function(guy) return guy.components.pollinator and guy.components.pollinator.target == closestFlower end, {"pollinator"}) then
		self.inst.components.pollinator.target = closestFlower
	else
		self.inst.components.pollinator.target = nil
	end
end
