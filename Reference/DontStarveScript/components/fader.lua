local Fader = Class(function(self, inst)
    self.inst = inst

    self.values = {}
    self.numvals = 0
end)

function Fader:Fade(startval, endval, time, setter, atend, id)
    
    local rate = (endval-startval)/time
    --  table.insert depricated     -- table.insert(self.values, {val=startval, v2 = endval, t=time, rate = rate, fn = setter, atend = atend})
    self.values[#self.values+1] = {val=startval, v2 = endval, t=time, rate = rate, fn = setter, atend = atend}
    
    self.numvals = self.numvals + 1

    id = id or #self.values
    self.values[#self.values].id = id 
    
    if self.numvals == 1 then
        self.inst:StartUpdatingComponent(self)
    end

    return id
end

function Fader:StopAll()
    self:OnUpdate(999999)
    self.values = {}
    self.inst:StopUpdatingComponent(self)
end

function Fader:OnUpdate(dt)

    for k,v in pairs(self.values) do
        v.t = v.t - dt
        if v.t <= 0 then
            v.val = v.v2
        else
            v.val = v.val + v.rate*dt
        end
        
        v.fn(v.val,self.inst)  -- calling in this order to keep old code functioning without change
        if v.t <= 0 then
        
            if v.atend then
                v.atend(self.inst,v.val) 
            end
            
            self.values[k] = nil
            self.numvals = self.numvals - 1
        end
    end
    
    if self.numvals == 0 then
        self.inst:StopUpdatingComponent(self)
    end

end

return Fader
