local BalloonMaker = Class(function(self, inst)
    self.inst = inst
end)

function BalloonMaker:CollectInventoryActions(doer, actions, right)
    table.insert(actions, ACTIONS.MAKEBALLOON)
end

function BalloonMaker:MakeBalloon(x,y,z)
    local balloon = SpawnPrefab("balloon")
    if balloon then
        balloon.Transform:SetPosition(x,y,z)
    end
end

return BalloonMaker