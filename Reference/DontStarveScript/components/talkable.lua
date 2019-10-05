local Talkable = Class(function(self, inst)
    self.inst = inst
    self.conversation = nil
    self.conv_index = 1
end)

function Talkable:CollectSceneActions(doer, actions)
    if self.inst.components.maxwelltalker and not self.inst.components.maxwelltalker:IsTalking() then
        table.insert(actions, ACTIONS.TALKTO)
    end
end

function Talkable:CollectInventoryActions(doer, actions)
    if self.inst.components.maxwelltalker and not self.inst.components.maxwelltalker:IsTalking() then
        table.insert(actions, ACTIONS.TALKTO)
    end
end

return Talkable