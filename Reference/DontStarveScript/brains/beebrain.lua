require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/findflower"
require "behaviours/panic"
local beecommon = require "brains/beecommon"

local MAX_CHASE_DIST = 15
local MAX_CHASE_TIME = 8

local RUN_AWAY_DIST = 6
local STOP_RUN_AWAY_DIST = 10

local BeeBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)


function BeeBrain:OnStart()

    local clock = GetClock()
    local seasonmanager = GetSeasonManager()
    
    local root =
        PriorityNode(
        {
            WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
            
            WhileNode( function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily", ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST) ),
            WhileNode( function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge", RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST) ),
            
            --ChaseAndAttack(self.inst, beecommon.MAX_CHASE_TIME),
            IfNode(function() return clock and not clock:IsDay() end, "IsNight",
                DoAction(self.inst, function() return beecommon.GoHomeAction(self.inst) end, "go home", true )),
            IfNode(function() return self.inst.components.pollinator:HasCollectedEnough() end, "IsFullOfPollen",
                DoAction(self.inst, function() return beecommon.GoHomeAction(self.inst) end, "go home", true )),
            IfNode(function() return seasonmanager and seasonmanager:IsWinter() end, "IsWinter",
                DoAction(self.inst, function() return beecommon.GoHomeAction(self.inst) end, "go home", true )),

            FindFlower(self.inst),
            Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, beecommon.MAX_WANDER_DIST)            
        },1)
    
    
    self.bt = BT(self.inst, root)
    
end

function BeeBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
end

return BeeBrain
