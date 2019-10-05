local Beard = Class(function(self, inst)
    self.inst = inst
    self.daysgrowth = 0
    self.callbacks = {}
    self.prize = nil
    self.bits = 0
        
    
    inst:ListenForEvent( "daycomplete", function(inst, data) 
        if not self.pause then
            self.daysgrowth = self.daysgrowth + 1
            local cb = self.callbacks[self.daysgrowth]
            if cb then
                cb(self.inst)
            end
        end
    end, GetWorld())
    
    self.inst:ListenForEvent("respawn", function(inst) self:Reset() end)    
    
end)

function Beard:GetInsulation()
    return self.bits * TUNING.INSULATION_PER_BEARD_BIT
end

function Beard:ShouldTryToShave(who, whithwhat)
    if self.bits == 0 then
        return false, "NOBITS"
    end
    
    if self.canshavetest then
        local pass, reason = self.canshavetest(self.inst)
        if not pass then
            return false, reason
        end
    end
    
    return true

end


function Beard:Shave(who, withwhat)
    if self.canshavetest then
        local pass, reason = self.canshavetest(self.inst)
        if not pass then
            return false, reason
        end
    end
    if self.bits == 0 then
        return false, "NOBITS"
    end
    if self.prize then
        for k=1,self.bits do
            local bit = SpawnPrefab(self.prize)
            local x,y,z = self.inst.Transform:GetWorldPosition()
            y = y + 2
            bit.Transform:SetPosition(x,y,z)
            local speed = 1+ math.random()
            local angle = math.random()*360
            bit.Physics:SetVel(speed*math.cos(angle), 2+math.random()*3, speed*math.sin(angle))
        end
        self:Reset()
    end
    
    if who == self.inst and who.components.sanity then
		who.components.sanity:DoDelta(TUNING.SANITY_SMALL)
    end
    
    return true    
end

function Beard:AddCallback(day, cb)
    self.callbacks[day] = cb
end


function Beard:Reset()
    self.daysgrowth = 0
    self.bits = 0
    if self.onreset then
        self.onreset(self.inst)
    end
end


function Beard:OnSave()
    return  { growth = self.daysgrowth, bits = self.bits }
end

function Beard:OnLoad(data)
    -- because there is an unknowable delay between the day callback and actually
    -- growing more hair, we need to store how much hair we _actually_ had on quit
    -- to determing the current beefalo state.
    if data.bits then
        self.bits = data.bits
    end
    if data.growth then
        self.daysgrowth = data.growth
    end
    for k = 0,self.daysgrowth do
        local cb = self.callbacks[k]
        if cb then
            cb(self.inst)
        end
    end
end

function Beard:GetDebugString()
    local nextevent = 999
    for k,v in pairs(self.callbacks) do
        if k >= self.daysgrowth and k < nextevent then
            nextevent = k
        end
    end
    return string.format("Bits: %d Daysgrowth: %d Next Event: %d", self.bits, self.daysgrowth, nextevent)
end


return Beard
