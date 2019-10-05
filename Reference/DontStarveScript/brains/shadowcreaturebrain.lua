require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/minperiod"
require "behaviours/follow"

local MIN_FOLLOW = 5
local MED_FOLLOW = 15
local MAX_FOLLOW = 30

local ShadowCreatureBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function ShadowCreatureBrain:OnStart()
    
    local root = PriorityNode(
    {
        ChaseAndAttack(self.inst, 100),
        Follow(self.inst, function() return GetPlayer() end, MIN_FOLLOW, MED_FOLLOW, MAX_FOLLOW),
        Wander(self.inst, function() local player = GetPlayer() if player then return Vector3(player.Transform:GetWorldPosition()) end end, 20)
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return ShadowCreatureBrain