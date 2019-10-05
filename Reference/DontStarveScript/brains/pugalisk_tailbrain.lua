require "behaviours/chaseandattack"
require "behaviours/standstill"
local pu = require ("prefabs/pugalisk_util")

local Pugalisk_tailBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function Pugalisk_tailBrain:OnStart()
    local root =
        PriorityNode(
        {              
            ChaseAndAttack(self.inst),            
            StandStill(self.inst)

        },1)
    
    self.bt = BT(self.inst, root)        
end

return Pugalisk_tailBrain
