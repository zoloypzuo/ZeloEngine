
local function PercentChanged(inst, data)
    if inst.components.tool
       and data.percent and data.percent <= 0
       and inst.components.inventoryitem and inst.components.inventoryitem.owner then
        inst.components.inventoryitem.owner:PushEvent("toolbroke", {tool = inst})
    end
end

local Tool = Class(function(self, inst)
    self.inst = inst
    
    self.inst:ListenForEvent("percentusedchange", PercentChanged)
    
end)


function Tool:GetEffectiveness(act)
    if self.action and self.action[act] then
        return self.action[act]
    end
    return 0
end

function Tool:SetAction(act, effectiveness)
    effectiveness = effectiveness or 1
    if not self.action then
        self.action = {}
    end
    
    self.action[act] = effectiveness


    --self.action = act
end

function Tool:GetBestActionForTarget(target, right)
    for k,v in pairs(self.action) do
        if target:IsActionValid(k, right) then
            return k     
        end
    end
end

function Tool:CanDoAction(action)
    for k,v in pairs(self.action) do
        if k == action then return true end
    end
end

function Tool:CollectUseActions(doer, target, actions, right)
    local bestaction = self:GetBestActionForTarget(target, right)

    if bestaction then
        table.insert(actions, bestaction)
    end

    -- if target:IsActionValid(self.action, right) then
    --     table.insert(actions, self.action)
    -- end
end

function Tool:CollectEquippedActions(doer, target, actions, right)

    local bestaction = self:GetBestActionForTarget(target, right)

    if bestaction then
        table.insert(actions, bestaction)
    end

    -- if target:IsActionValid(self.action, right) then
    --     table.insert(actions, self.action)
    -- end
end


return Tool
