require "behaviours/chaseandattack"

local RUN_THRESH = 4.5
local MAX_CHASE_TIME = 5

local WilsonBrain = Class(Brain, function(self, inst)
    Brain._ctor(self,inst)
end)


function WilsonBrain:OnStart()
    local root = PriorityNode(
    {
    	WhileNode(function() return TheInput:IsControlPressed(CONTROL_PRIMARY) end, "Hold LMB", ChaseAndAttack(self.inst, MAX_CHASE_TIME)),
    	ChaseAndAttack(self.inst, MAX_CHASE_TIME, nil, 1),
    },0)
    
    self.bt = BT(self.inst, root)

end

return WilsonBrain