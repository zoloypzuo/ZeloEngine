local Beaverness = Class(function(self, inst)
    self.inst = inst
	self.max = 100
    self.current = 0
    self.is_beaver = false
end)


function Beaverness:IsBeaver()
    return self.is_beaver
end

function Beaverness:OnSave()    
    return 
    {
		current = self.current,
        is_beaver = self.is_beaver
	}
end

function Beaverness:StopTimeEffect()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function Beaverness:StartTimeEffect(dt, delta_b)
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
    self.task = self.inst:DoPeriodicTask(dt, function() self:DoDelta(delta_b, true) end)
end

function Beaverness:OnLoad(data)
    if data then
        if data.current then
            self.current = data.current
        end

        if data.is_beaver then
            self.is_beaver = data.is_beaver
        end
    end

    if self.is_beaver then
        if self.makebeaver then
            self.makebeaver(self.inst)
        end
    else
        if self.makeperson then
            self.makeperson(self.inst)
        end
    end

end

function Beaverness:DoDelta(delta, overtime)
    local oldpercent = self.current/self.max
    self.current = self.current + delta
    
    if self.current < 0 then self.current = 0 end
    if self.current > self.max then self.current = self.max end

    self.inst:PushEvent("beavernessdelta", {oldpercent = oldpercent, newpercent = self.current/self.max, overtime = overtime})

    --if delta ~= 0 then
        if self.is_beaver and self.current <= 0 then
            self.is_beaver = false
            
            if self.onbecomeperson then
                self.onbecomeperson(self.inst)
                self.inst:PushEvent("beaverend")
            end

        elseif not self.is_beaver and self.current >= self.max then
            self.is_beaver = true
            
            if self.onbecomebeaver then
                self.onbecomebeaver(self.inst)
                self.inst:PushEvent("beaverstart")
            end
        end
    --end
end

function Beaverness:GetPercent()
    return self.current / self.max
end

function Beaverness:GetDebugString()
    return string.format("%2.2f / %2.2f", self.current, self.max)
end

function Beaverness:SetPercent(percent)
    self.current = self.max*percent
    self:DoDelta(0)
end

return Beaverness
