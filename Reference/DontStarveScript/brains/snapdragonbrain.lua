require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/follow"
require "behaviours/attackwall"
--require "behaviours/runaway"
--require "behaviours/doaction"

local SEE_FOOD_DIST = 20
local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5
local WANDER_DIST_DAY = 20
local WANDER_DIST_NIGHT = 5
local START_FACE_DIST = 4
local KEEP_FACE_DIST = 6

local MAX_CHASE_TIME = 6

local MIN_FOLLOW_DIST = 1
local TARGET_FOLLOW_DIST = 5
local MAX_FOLLOW_DIST = 5


local function EatFoodAction(inst)
    local target = FindEntity(inst, SEE_FOOD_DIST,
        function(item)
            return inst.components.eater:CanEat(item) and
            item.components.bait and
            not item:HasTag("planted") and
            not (item.components.inventoryitem and
                item.components.inventoryitem:IsHeld())
        end)
    if target then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld()) end
        return act
    end
end

local function GetFaceTargetFn(inst)
    local target = GetClosestInstWithTag("player", inst, START_FACE_DIST)
    if target and not target:HasTag("notarget") then
        return target
    end
end

local function KeepFaceTargetFn(inst, target)
    return inst:GetDistanceSqToInst(target) <= KEEP_FACE_DIST*KEEP_FACE_DIST and not target:HasTag("notarget")
end

local function GetWanderDistFn(inst)
    if GetClock() and not GetClock():IsDay() then
        return WANDER_DIST_NIGHT
    else
        return WANDER_DIST_DAY
    end
end

local SnapdragonBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SnapdragonBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
		IfNode( function() return self.inst.components.combat.target ~= nil end, "hastarget", AttackWall(self.inst)),
        DoAction(self.inst, EatFoodAction),
        ChaseAndAttack(self.inst, MAX_CHASE_TIME),
        Follow(self.inst, function() return self.inst.components.follower and self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST, false),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("herd") end, GetWanderDistFn)
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return SnapdragonBrain