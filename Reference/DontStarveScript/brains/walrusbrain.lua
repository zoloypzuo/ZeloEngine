require "behaviours/chaseandattack"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/follow"
require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/leash"

local RUN_START_DIST = 5
local RUN_STOP_DIST = 15

local SEE_FOOD_DIST = 10
local MAX_WANDER_DIST = 40
local MAX_CHASE_TIME = 10

local MIN_FOLLOW_DIST = 8
local MAX_FOLLOW_DIST = 15
local TARGET_FOLLOW_DIST = (MAX_FOLLOW_DIST+MIN_FOLLOW_DIST)/2
local MAX_PLAYER_STALK_DISTANCE = 40

local LEASH_RETURN_DIST = 40
local LEASH_MAX_DIST = 80

local MIN_FOLLOW_LEADER = 2
local MAX_FOLLOW_LEADER = 4
local TARGET_FOLLOW_LEADER = (MAX_FOLLOW_LEADER+MIN_FOLLOW_LEADER)/2

local START_FACE_DIST = MAX_FOLLOW_DIST
local KEEP_FACE_DIST = MAX_FOLLOW_DIST

local function GetFaceTargetFn(inst)
    return GetClosestInstWithTag("player", inst, START_FACE_DIST)
end

local function KeepFaceTargetFn(inst, target)
    return inst:IsNear(target, KEEP_FACE_DIST)
end

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower.leader
end

local function GetNoLeaderFollowTarget(inst)
    if GetLeader(inst) then
        return nil
    end
    return GetClosestInstWithTag("player", inst, MAX_PLAYER_STALK_DISTANCE)
end

local function GetHome(inst)
    return inst.components.homeseeker and inst.components.homeseeker.home
end

local function GetHunter(inst)
    return FindEntity(inst, RUN_START_DIST, nil, nil, {'notarget', "walrus", "hound"}, {"character", "monster"})
end

local function EatFoodAction(inst)
    local target = nil

    if not target then
        target = FindEntity(inst, SEE_FOOD_DIST, function(item) return inst.components.eater:CanEat(item) end)
        if target then
            --check for scary things near the food
            local predator = GetClosestInstWithTag("character", target, RUN_START_DIST)
            if predator then target = nil end
        end
    end
    if target then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem.owner and target.components.inventoryitem.owner ~= inst) end
        return act
    end
end

local function ShouldGoHomeAtNight(inst)
    if GetClock():IsNight() and not GetLeader(inst) and GetHome(inst) and not inst.components.combat.target then
        return true
    end
end

local function ShouldGoHomeScared(inst)
    if inst:HasTag("taunt_attack") and not (GetLeader(inst) and GetLeader(inst):IsValid()) and inst.components.leader:CountFollowers() == 0 then
        return true
    end
end

local function GoHomeAction(inst)
    if GetHome(inst) and GetHome(inst):IsValid() then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME, nil, inst.components.homeseeker:GetHomePos())
    end
end

local function GetHomeLocation(inst)
    return GetHome(inst) and inst.components.homeseeker:GetHomePos()
end

local function GetNoLeaderLeashPos(inst)
    if GetLeader(inst) then
        return nil
    end
    return GetHomeLocation(inst)
end


local function CanAttackNow(inst)
    return inst.components.combat.target == nil or not inst.components.combat:InCooldown()
end


local WalrusBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function WalrusBrain:OnStart()
    local clock = GetClock()
    
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

        Leash(self.inst, GetNoLeaderLeashPos, LEASH_MAX_DIST, LEASH_RETURN_DIST),

        RunAway(self.inst, GetHunter, RUN_START_DIST, RUN_STOP_DIST),
        WhileNode(function() return ShouldGoHomeScared(self.inst) end, "ShouldGoHomeScared", DoAction(self.inst, GoHomeAction, "Go Home Scared", true)),

        Follow(self.inst, GetLeader, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER, false),

        WhileNode(function() return CanAttackNow(self.inst) end, "AttackMomentarily", ChaseAndAttack(self.inst, MAX_CHASE_TIME) ),
        Follow(self.inst, function() return self.inst.components.combat.target end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST, true),

        WhileNode(function() return ShouldGoHomeAtNight(self.inst) end, "ShouldGoHomeAtNight", DoAction(self.inst, GoHomeAction, "Go Home Night" )),

        Follow(self.inst, GetNoLeaderFollowTarget, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST, false),

        DoAction(self.inst, EatFoodAction, "Eat Food"),

        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        FaceEntity(self.inst, GetLeader, GetLeader),

        Wander(self.inst, GetHomeLocation, MAX_WANDER_DIST),
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return WalrusBrain