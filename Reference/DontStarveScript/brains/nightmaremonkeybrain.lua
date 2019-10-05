require "behaviours/wander"
require "behaviours/panic"
require "behaviours/chaseandattack"

local MAX_WANDER_DIST = 10

local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 40


local NightmareMonkeyBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function NightmareMonkeyBrain:OnStart()
    
    local root = PriorityNode(
    {

        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST), 
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST),

    }, .25)
    self.bt = BT(self.inst, root)
end

return NightmareMonkeyBrain