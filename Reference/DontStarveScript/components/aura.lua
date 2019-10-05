local Aura = Class(function(self, inst)
    self.inst = inst
    self.radius = 3
    self.tickperiod = 1
    self.active = false
    self.applying = false

end)

function Aura:GetDebugString()
    
    local str = string.format("radius:%2.2f, enabled:%s", self.radius, tostring(self.active) )
    if self.active then
        str = str .. string.format(" %2.2fs applying:%s", self.tickperiod, tostring(self.applying))
    end
    
    return str
end

function Aura:Enable(val)
    if self.active ~= val then
        self.active = val
        if self.active then
            self.task = self.inst:DoPeriodicTask(self.tickperiod, function() self:OnTick() end)
        else
            if self.task then
                self.task:Cancel()
                self.task = nil
            end
            if self.applying then
                self.inst:PushEvent("stopaura")
                self.applying = false
            end

        end
    end
end

function Aura:OnTick()
    local applied = false

    if self.inst.components.combat then
        local hits = self.inst.components.combat:DoAreaAttack(self.inst, self.radius, nil, 
            function(target) 
                if target:HasTag("noauradamage") then return false end

                if self.auratestfn then
                    if not self.auratestfn(self.inst, target) then
                        return false
                    end
                end


                return true
            end)
        --print("Aura:OnTick", hits)
        applied = hits > 0
    end

    if applied ~= self.applying then
        if applied then
            self.inst:PushEvent("startaura")
        else
            self.inst:PushEvent("stopaura")
        end
    
        self.applying = applied
    end
end

return Aura