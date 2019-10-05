
StandStill = Class(BehaviourNode, function(self, inst, startfn, keepfn)
    BehaviourNode._ctor(self, "StandStill")
    self.inst = inst
    self.startfn = startfn
    self.keepfn = keepfn
end)


function StandStill:Visit()

    if self.status == READY then
        if not self.startfn or self.startfn(self.inst) then
            self.status = RUNNING
            self.inst.components.locomotor:Stop()
        else
            self.status = FAILED
        end
    end

    if self.status == RUNNING then
        if not self.keepfn or self.keepfn(self.inst) then
            -- yep! standing here is preeeetty great.
            self.inst.components.locomotor:Stop()
        else
            self.status = FAILED
        end
        self:Sleep(.5)
    end
    
end

