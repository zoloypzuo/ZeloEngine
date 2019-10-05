require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/minperiod"
require "behaviours/follow"

local MIN_FOLLOW = 5
local MED_FOLLOW = 15
local MAX_FOLLOW = 30

local NightmareCreatureBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function NightmareCreatureBrain:OnStart()
    
    local root = PriorityNode(
    {
        ChaseAndAttack(self.inst, 40),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, 20),
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return NightmareCreatureBrain