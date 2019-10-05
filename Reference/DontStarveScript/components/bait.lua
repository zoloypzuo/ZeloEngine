local Bait = Class(function(self, inst)
    self.inst = inst
    self.trap = nil
    self.inst:ListenForEvent( "onpickup", function() if self.trap then self.trap:RemoveBait() end end )  
    self.inst:ListenForEvent( "oneaten", function(inst, data) if self.trap then self.trap:BaitTaken(data.eater) end end )  
    
end)

function Bait:DebugString()
    return "Trap:"..tostring(self.trap)
end

function Bait:IsFree() 
    return self.trap == nil
end


function Bait:CollectUseActions(doer, target, actions)
    if target.components.trap and target.components.trap:AcceptingBait() then
        table.insert(actions, ACTIONS.BAIT)
    end
end

return Bait