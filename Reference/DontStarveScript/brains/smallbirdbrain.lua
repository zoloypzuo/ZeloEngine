require "behaviours/chaseandattack"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/follow"
require "behaviours/standstill"


local MIN_FOLLOW_DIST = 2
local MAX_FOLLOW_DIST = 9
local TARGET_FOLLOW_DIST = (MAX_FOLLOW_DIST+MIN_FOLLOW_DIST)/2

local MAX_CHASE_TIME = 10

local TRADE_DIST = 20

local SEE_FOOD_DIST = 15
local FIND_FOOD_HUNGER_PERCENT = 0.75 -- if hunger below this, forage for nearby food

--local MAX_WANDER_DIST = 20
--local MAX_CHASE_DIST = 30

local START_RUN_DIST = 4
local STOP_RUN_DIST = 6

local function IsHungry(inst)
    return inst.components.hunger and inst.components.hunger:GetPercent() < FIND_FOOD_HUNGER_PERCENT
end

local function IsStarving(inst)
    return inst.components.hunger and inst.components.hunger:IsStarving()
end

local function ShouldStandStill(inst)
    return inst.components.hunger and inst.components.hunger:IsStarving() and not inst:HasTag("teenbird") 
end

local function CanSeeFood(inst)
    local target = FindEntity(inst, SEE_FOOD_DIST, function(item) return inst.components.eater:CanEat(item) end)
    if target then
        --print("CanSeeFood", inst.name, target.name)
    end
    return target
end

local function FindFoodAction(inst)
    local target = CanSeeFood(inst)
    if target then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end
end

local function GetTraderFn(inst)
    return (inst.components.follower.leader and inst.components.trader:IsTryingToTradeWithMe(inst.components.follower.leader)) and inst.components.follower.leader or nil
end

local function KeepTraderFn(inst, target)
    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function ShouldRunAwayFromPlayer(inst, player)
    return inst:HasTag("teenbird") and not inst.components.follower.leader
end

local SmallBirdBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SmallBirdBrain:OnStart()
    local root = 
    PriorityNode({
        FaceEntity(self.inst, GetTraderFn, KeepTraderFn),
        -- when starving prefer finding food over fighting
        SequenceNode{
            ConditionNode(function() return IsStarving(self.inst) and CanSeeFood(self.inst) end, "SeesFoodToEat"),
            ParallelNodeAny {
                WaitNode(math.random()*.5),
                PriorityNode {
                    StandStill(self.inst, ShouldStandStill),
                    Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
                },
            },
            DoAction(self.inst, function() return FindFoodAction(self.inst) end),
        },
        SequenceNode{
            ConditionNode(function() return self.inst.components.combat.target ~= nil end, "HasTarget"),
            WaitNode(math.random()*.9),
            ChaseAndAttack(self.inst, MAX_CHASE_TIME),
        },
        RunAway(self.inst, "player", START_RUN_DIST, STOP_RUN_DIST, function(target) return ShouldRunAwayFromPlayer(self.inst, target) end ),
        SequenceNode{
            ConditionNode(function() return IsHungry(self.inst) and CanSeeFood(self.inst) end, "SeesFoodToEat"),
            ParallelNodeAny {
                WaitNode(1 + math.random()*2),
                PriorityNode {
                    StandStill(self.inst, ShouldStandStill),
                    Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
                },
            },
            DoAction(self.inst, function() return FindFoodAction(self.inst) end),
        },
        PriorityNode {
            StandStill(self.inst, ShouldStandStill),
            Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        },
        Wander(self.inst, function() if self.inst.components.follower.leader then return Vector3(self.inst.components.follower.leader.Transform:GetWorldPosition()) end end, MAX_FOLLOW_DIST- 1, {minwalktime=.5, randwalktime=.5, minwaittime=6, randwaittime=3}),
    },.25)
    self.bt = BT(self.inst, root)
 end

return SmallBirdBrain