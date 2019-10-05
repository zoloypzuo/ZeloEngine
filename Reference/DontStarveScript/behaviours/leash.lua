Leash = Class(BehaviourNode, function(self, inst, homelocation, max_dist, inner_return_dist, running)
    BehaviourNode._ctor(self, "Leash")
    self.homepos = homelocation
    self.maxdist = max_dist
    self.inst = inst
	self.returndist = inner_return_dist
	self.running = running or false
end)


function Leash:Visit()

    if not self:GetHomePos() then
        self.status = FAILED
        return
    end

    if self.status == READY then
		if self:IsInsideLeash() then
			self.status = FAILED
		else
			self.inst.components.locomotor:Stop()
			self.status = RUNNING
		end
    elseif self.status == RUNNING then
		if self:IsOutsideReturnDist() then
			self.inst.components.locomotor:GoToPoint(self:GetHomePos(), nil, self.running)
		else
			self.status = SUCCESS
		end
    end
end

function Leash:DBString()
    return string.format("%s, %2.2f", tostring(self:GetHomePos()), math.sqrt(self:GetDistFromHomeSq() or 0) )
end

function Leash:GetHomePos()
    if type(self.homepos) == "function" then 
        return self.homepos(self.inst)
    end
    
    return self.homepos
end

function Leash:GetDistFromHomeSq()
    local homepos = self:GetHomePos()
	if not homepos then
		return nil
	end
    local pos = Vector3(self.inst.Transform:GetWorldPosition())
    return distsq(homepos, pos)
end

function Leash:IsInsideLeash()
	return self:GetDistFromHomeSq() < self:GetMaxDistSq()
end

function Leash:IsOutsideReturnDist()
	return self:GetDistFromHomeSq() > self:GetReturnDistSq()
end

function Leash:GetMaxDistSq()
    if type(self.maxdist) == "function" then
        local dist = self.maxdist(self.inst)
        return dist*dist
    end
    
    return self.maxdist*self.maxdist
end

function Leash:GetReturnDistSq()
    if type(self.returndist) == "function" then
        local dist = self.returndist(self.inst)
        return dist*dist
    end
    
    return self.returndist*self.returndist
end
