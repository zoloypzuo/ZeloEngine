local Cooldown = Class(function(self, inst)
    self.inst = inst
    self.charged = false
    --self.cooldown_time_left = nil
    self.cooldown_duration = nil
end)


function donecharging(inst)
    if inst.components.cooldown then
        inst.components.cooldown.charged = true
        inst.components.cooldown.cooldown_deadline = nil

        if inst.components.cooldown.onchargedfn then
            inst.components.cooldown.onchargedfn(inst)
        end
    end

end

function Cooldown:StartCharging(time)
    time = time or self.cooldown_duration
    self.charged = false
    self.cooldown_deadline = GetTime() + time

    if self.cooldown_deadline <= 0 then
        donecharging(self.inst)
        if self.startchargingfn then
            self.startchargingfn(self.inst)
        end
        return
    end

    self.inst:DoTaskInTime(self.cooldown_duration, donecharging)    
    if self.startchargingfn then
        self.startchargingfn(self.inst)
    end

end

function Cooldown:GetTimeToCharged()
    if self.cooldown_deadline then
        return self.cooldown_deadline - GetTime()
    end

    return 0
end

function Cooldown:IsCharged()
    return self.charged
end

function Cooldown:IsCharging()
    return not self.charged and self.cooldown_duration
end

function Cooldown:OnSave()

    local data = {
        charged = self.charged
    }

    if self.cooldown_deadline then
        data.time_to_charge = math.max(0, self.cooldown_deadline - GetTime())
    end

    return data
end

function Cooldown:GetDebugString()
    if self.charged then
		return "CHARGED!"
    else
		return string.format("%2.2f", self:GetTimeToCharged())
    end
end


function Cooldown:LongUpdate(dt)
    if self.cooldown_deadline then
        self.cooldown_deadline = self.cooldown_deadline - dt
        if self.cooldown_deadline < GetTime() then
            donecharging(self.inst)
        else
            self:StartCharging(self.cooldown_deadline - GetTime())
        end
    end
end

function Cooldown:OnLoad(data)
    if data.charged then
        donecharging(self.inst)
    elseif data.time_to_charge then
        self:StartCharging(data.time_to_charge)
    end
end


return Cooldown
