require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/doaction"
require "behaviours/chattynode"
require "behaviours/panic"

local MAX_WANDER_DIST = 20
local START_RUN_DIST = 3
local STOP_RUN_DIST = 5
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30
local SEE_TARGET_DIST = 20
local SEE_FOOD_DIST = 10
local RUN_AWAY_DIST = 6
local STOP_RUN_AWAY_DIST = 8

local function FindFoodAction(inst)
    local target = FindEntity(inst, SEE_FOOD_DIST, function(item) return inst.components.eater:CanEat(item) end)
    if target then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end
end

local function GoHomeAction(inst)
    if not inst.components.follower.leader and
       inst.components.homeseeker and 
       inst.components.homeseeker.home and 
       inst.components.homeseeker.home:IsValid() then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function TargetIsAggressive(inst)
    local target = inst.components.combat.target
    return target and
           target.components.combat and
           target.components.combat.defaultdamage > 0 and
           target.components.combat.target == inst
end

local WerePigBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function WerePigBrain:OnStart()
    --print(self.inst, "WerePigBrain:OnStart")
    local clock = GetClock()
    
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        WhileNode(function() return not TargetIsAggressive(self.inst) end, "SafeToEat",
	        DoAction(self.inst, function() return FindFoodAction(self.inst) end, "EatMeat", true)
		),
		
        ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST),
    }, .5)
    
    self.bt = BT(self.inst, root)
end

function WerePigBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
end


return WerePigBrain