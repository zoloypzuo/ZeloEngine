require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/attackwall"
require "behaviours/minperiod"
require "behaviours/leash"
require "behaviours/faceentity"
require "behaviours/doaction"
require "behaviours/standstill"

local HoundBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local SEE_DIST = 30

local MIN_FOLLOW_LEADER = 2
local MAX_FOLLOW_LEADER = 6
local TARGET_FOLLOW_LEADER = (MAX_FOLLOW_LEADER+MIN_FOLLOW_LEADER)/2

local LEASH_RETURN_DIST = 10
local LEASH_MAX_DIST = 40

local HOUSE_MAX_DIST = 40
local HOUSE_RETURN_DIST = 50 

local SIT_BOY_DIST = 10

local function EatFoodAction(inst)
    local target = FindEntity(inst, SEE_DIST, function(item) return inst.components.eater:CanEat(item) and item:IsOnValidGround() end)
    if target then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end
end

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower.leader
end

local function GetHome(inst)
    return inst.components.homeseeker and inst.components.homeseeker.home
end

local function GetHomePos(inst)
    local home = GetHome(inst)
    return home and home:GetPosition()
end

local function GetNoLeaderLeashPos(inst)
    if GetLeader(inst) then
        return nil
    end
    return GetHomePos(inst)
end

local function GetWanderPoint(inst)
    local target = GetLeader(inst) or GetPlayer()

    if target then
        return target:GetPosition()
    end 
end

local function ShouldStandStill(inst)
    return inst:HasTag("pet_hound") and not GetClock():IsDay() and not GetLeader(inst) and not inst.components.combat.target and inst:IsNear(GetHome(inst), SIT_BOY_DIST)
end

function HoundBrain:OnStart()
    
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst) ),
        WhileNode(function() return not GetLeader(self.inst) end, "NoLeader", AttackWall(self.inst) ),

        WhileNode(function() return self.inst:HasTag("pet_hound") end, "Is Pet", ChaseAndAttack(self.inst, 10)),
        WhileNode(function() return not self.inst:HasTag("pet_hound") and GetHome(self.inst) end, "No Pet Has Home", ChaseAndAttack(self.inst, 10, 20)),
        WhileNode(function() return not self.inst:HasTag("pet_hound") and not GetHome(self.inst) end, "Not Pet", ChaseAndAttack(self.inst, 100)),
        
        Leash(self.inst, GetNoLeaderLeashPos, HOUSE_MAX_DIST, HOUSE_RETURN_DIST),

        DoAction(self.inst, EatFoodAction, "eat food", true ),
        Follow(self.inst, GetLeader, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER),
        FaceEntity(self.inst, GetLeader, GetLeader),

        StandStill(self.inst, ShouldStandStill),

        WhileNode(function() return GetHome(self.inst) end, "HasHome", Wander(self.inst, GetHomePos, 8) ),
        Wander(self.inst, GetWanderPoint, 20),
    }, .25)
    
    self.bt = BT(self.inst, root)
    
end

return HoundBrain
