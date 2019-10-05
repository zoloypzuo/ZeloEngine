require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"


local LeifBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function LeifBrain:OnStart()

    local clock = GetClock()

    local root =
        PriorityNode(
        {
			AttackWall(self.inst),
            ChaseAndAttack(self.inst),
            Wander(self.inst)            
        },1)
    
    self.bt = BT(self.inst, root)
end

return LeifBrain