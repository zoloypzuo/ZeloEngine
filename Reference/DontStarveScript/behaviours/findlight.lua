local SEE_DIST = 30
local SAFE_DIST = 5

FindLight = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "FindLight")
    self.inst = inst
    self.targ = nil
end)



function FindLight:DBString()
    return string.format("Stay near light %s", tostring(self.targ))
end

function FindLight:Visit()
    
    if self.status == READY then
        self:PickTarget()
        self.status = RUNNING
    end
    
    if self.status == RUNNING then
       
        if self.targ and self.targ:HasTag("lightsource") then
            
            local dsq = self.inst:GetDistanceSqToInst(self.targ)
            
            if dsq >= SAFE_DIST*SAFE_DIST then
                self.inst.components.locomotor:RunInDirection(self.inst:GetAngleToPoint(Point(self.targ.Transform:GetWorldPosition())))
            else
                self.inst.components.locomotor:Stop()
                self:Sleep(.5)
            end
        else
            self.status = FAILED
        end
    end
end

function FindLight:PickTarget()
    self.targ = GetClosestInstWithTag("lightsource", self.inst, SEE_DIST)
end
