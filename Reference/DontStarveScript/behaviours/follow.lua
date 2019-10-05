Follow = Class(BehaviourNode, function(self, inst, target, min_dist, target_dist, max_dist, canrun)
    BehaviourNode._ctor(self, "Follow")
    
    self.inst = inst
    self.target = target
    self.min_dist = min_dist
    self.max_dist = max_dist
    self.target_dist = target_dist
    self.canrun = canrun
    
    if self.canrun == nil then self.canrun = true end
    
    self.action = "STAND"
end)

function Follow:GetTarget()
    if type(self.target) == "function" then
        return self.target(self.inst)
    end
    
    return self.target
end


function Follow:DBString()
    
    local pos = Point(self.inst.Transform:GetWorldPosition())
    local target_pos = Vector3(0,0,0)
    if self.currenttarget then
        target_pos = Point(self.currenttarget.Transform:GetWorldPosition())
    end
    
    return string.format("%s %s, (%2.2f) ", tostring(self.currenttarget), self.action, math.sqrt(distsq(target_pos, pos)))
end

function Follow:Visit()

    if self.status == READY then
        self.currenttarget = self:GetTarget()
        if self.currenttarget then
			
			local pos = Point(self.inst.Transform:GetWorldPosition())
			local target_pos = Point(self.currenttarget.Transform:GetWorldPosition())
			local dist_sq = distsq(pos, target_pos)
			
			self.status = RUNNING
			
			if dist_sq < self.min_dist*self.min_dist then
				self.action = "BACKOFF"
			elseif dist_sq > self.max_dist*self.max_dist then
				self.action = "APPROACH"
			else
				self.status = FAILED
			end
			
        else
            self.status = FAILED
        end
        
    end

    if self.status == RUNNING then
        if not self.currenttarget or not self.currenttarget:IsValid()
           or (self.currenttarget.components.health and self.currenttarget.components.health:IsDead() ) then
            self.status = FAILED
            self.inst.components.locomotor:Stop()
            return
        end
        
        
        local pos = Point(self.inst.Transform:GetWorldPosition())
        local target_pos = Point(self.currenttarget.Transform:GetWorldPosition())
        local dist_sq = distsq(pos, target_pos)
    
        if self.action == "APPROACH" then
            if dist_sq < self.target_dist*self.target_dist then
                self.status = SUCCESS
                return
            end
        elseif self.action == "BACKOFF" then
            if dist_sq > self.target_dist*self.target_dist then
                self.status = SUCCESS
                return
            end
        end
        
        if self.action == "APPROACH" then
            local should_run = dist_sq > (self.max_dist*.75)*(self.max_dist*.75)
            local is_running = self.inst.sg:HasStateTag("running")
            if self.canrun and (should_run or is_running) then
                self.inst.components.locomotor:GoToPoint(target_pos, nil, true)
            else
                self.inst.components.locomotor:GoToPoint(target_pos)
            end
        elseif self.action == "BACKOFF" then
			
			local angle = self.inst:GetAngleToPoint(target_pos)
            if self.canrun then
                self.inst.components.locomotor:RunInDirection(angle + 180)
            else
                self.inst.components.locomotor:WalkInDirection(angle + 180)
            end
        end
        
        self:Sleep(.25)
    end
    
end

