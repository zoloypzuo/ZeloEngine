local Worker = Class(function(self, inst)
    self.inst = inst
    self.actions = {}
end)

function Worker:GetEffectiveness(act)
    return self.actions[act] or 0
end

function Worker:SetAction(act, effectiveness)
    effectiveness = effectiveness or 1
    self.actions[act] = effectiveness
end

function Worker:GetBestActionForTarget(target, right)
    for k,v in pairs(self.action) do
        if target:IsActionValid(k, right) then
            return k     
        end
    end
end

function Worker:CanDoAction(action)
    return self.actions[action] ~= nil
end


return Worker
