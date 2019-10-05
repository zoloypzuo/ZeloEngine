local Book = Class(function(self, inst)
    self.inst = inst
end)


function Book:OnRead(reader)
    if self.onread then
        return self.onread(self.inst, reader)
    end

    return true
end

function Book:CollectSceneActions(doer, actions)
    if doer.components.reader then
        table.insert(actions, ACTIONS.READ)
    end
end

function Book:CollectInventoryActions(doer, actions)
    if doer.components.reader then
        table.insert(actions, ACTIONS.READ)
    end
end

return Book