local FiniteUses = Class(function(self, inst)
    self.inst = inst
    self.total = 100
    self.current = 100
    self.consumption = {}
end)

function FiniteUses:SetConsumption(action, uses)
    self.consumption[action] = uses
end

function FiniteUses:GetDebugString()
    return string.format("%d/%d", self.current, self.total)
end

function FiniteUses:OnSave()
    if self.current ~= self.total then
        return { uses = self.current }
    end
end

function FiniteUses:OnLoad(data)
    if data.uses then
        self:SetUses(data.uses)
    end
end

function FiniteUses:SetMaxUses(val)
    self.total = val
end

function FiniteUses:SetUses(val)
    local was_positive = self.current > 0
    self.current = val
    self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
    if self.current <= 0 then
        self.current = 0
        if was_positive and self.onfinished then
            self.onfinished(self.inst)
        end
    end

end

function FiniteUses:GetUses()
    return self.current
end

function FiniteUses:Use(num)
    if not self.unlimited_uses then
        self:SetUses(self.current - (num or 1))
    end
end

function FiniteUses:OnUsedAsItem(action)
    local uses = self.consumption[action]
    if uses then
        self:Use(uses)
    end
end

function FiniteUses:GetPercent()
    return self.current / self.total
end

function FiniteUses:SetPercent(amount)
    local target = (self.total * amount)
    self:SetUses((target - self.current) + self.current)
end

function FiniteUses:SetOnFinished(fn)
    self.onfinished = fn
end

return FiniteUses